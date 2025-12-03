"""
OpenPGP key generation and Yubikey upload tool
"""
import argparse
import datetime
import os
import sys
from pathlib import Path

import johnnycanencrypt.johnnycanencrypt as rjce
from johnnycanencrypt import Cipher
from PySide6.QtCore import Property, QObject, QThread, Signal, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

# The default admin pin of Yubikey
ADMIN_PIN = b"12345678"

def next_year(d, years: int):
    "Adds the given years to the given datetime"
    try:
        return d.replace(year=d.year + years)
    except ValueError:
        # For February 29th situation
        return d.replace(year=d.year + years, day=28)


class YubiThread(QThread):
    uploaded = Signal()
    errored = Signal()

    def __init__(self):
        QThread.__init__(self)
        self.password = ""
        self.secret = ""

    def run(self):
        try:
            # First reset the key
            rjce.reset_yubikey()
            # Upload the primary key
            rjce.upload_primary_to_smartcard(
                self.secret.encode("utf-8"), ADMIN_PIN, self.password, whichslot=2
            )
            # now upload the subkeys
            rjce.upload_to_smartcard(
                self.secret.encode("utf-8"), ADMIN_PIN, self.password, whichkeys=5
            )
            # Set touch policies
            rjce.set_keyslot_touch_policy(ADMIN_PIN, rjce.KeySlot.Signature, rjce.TouchMode.Fixed)
            rjce.set_keyslot_touch_policy(ADMIN_PIN, rjce.KeySlot.Encryption, rjce.TouchMode.Fixed)
            rjce.set_keyslot_touch_policy(ADMIN_PIN, rjce.KeySlot.Authentication, rjce.TouchMode.On)
            self.uploaded.emit()
        except:
            self.errored.emit()


class KeyThread(QThread):
    updated = Signal()

    def __init__(self):
        QThread.__init__(self)
        self.name = ""
        self.uids = []
        self.password = ""
        self.public = None
        self.ssh_public = None
        self.secret = None
        self.fingerprint = None

    # run method gets called when we start the thread
    # This is where we will generate the OpenPGP key
    def run(self):
        now = datetime.datetime.now()
        expiration = next_year(now, 1)
        # Process started to generate a new key
        public, secret, fingerprint = rjce.create_key(
            self.password,
            self.uids,
            Cipher.RSA4k.value,
            int(now.timestamp()),
            int(expiration.timestamp()),
            True,
            5,
            True,
            True,
        )
        self.public = public
        self.secret = secret
        self.ssh_public = rjce.get_ssh_pubkey(public.encode("utf-8"), f"Public key for {fingerprint}")
        self.fingerprint = fingerprint
        # Now we can go to next screen
        self.updated.emit()


class Process(QObject):
    "Main process class for the key generation steps"
    updated = Signal()
    uploaded = Signal()
    errored = Signal()
    updatedFilePathChanged = Signal()

    def __init__(self):
        super(Process, self).__init__(None)
        self.public_key = "abcd.pub"
        self.secret_key = "abcd.sec"
        self.kt = KeyThread()
        self.kt.updated.connect(self.keygenerated)
        self.yt = YubiThread()
        self.yt.uploaded.connect(self.keyuploaded)
        self.yt.errored.connect(self.handle_error)
        self.pkey = ""
        self.pkey_expiry = ""
        self.subkeys = []
        self.sub_fingerprints = []
        self.newexpdate = ""
        self.public_key_data = b""
        self.public_key_directory = ""
        self.updated_filepath = ""
        self.timediff: datetime.timedelta | None = None

    def read_public_key(self):
        "To read the value of public_key in QML"
        return self.public_key

    def read_secret_key(self):
        "To read the value of secret_key in QML"
        return self.secret_key
    
    def read_primary_fingerprint(self):
        "To read the value of primary fingerprint in QML"
        return self.pkey

    def read_updated_filepath(self):
        "Expose updated file path to QML"
        return self.updated_filepath

    @Slot(str, result=bool)
    def update_expiry(self, yubikey_pin):
        "Updates the expiry date of the public key data stored"
        try:
            if self.timediff:
                if not rjce.verify_userpin_oncard(yubikey_pin.encode("utf-8")):
                    return False
                new_expiry_in_future = int(self.timediff.total_seconds() + 86400) # Added 1 day for buffer
                updated_data_with_primary_key = rjce.update_primary_expiry_on_card(self.public_key_data, new_expiry_in_future, yubikey_pin.encode("utf-8"))
                updated_data = rjce.update_subkeys_expiry_on_card(updated_data_with_primary_key, self.sub_fingerprints, new_expiry_in_future, yubikey_pin.encode("utf-8"))
                self.updated_filepath = os.path.join(self.public_key_directory, f"updated_{self.pkey}.pub")
                with open(self.updated_filepath, "wb") as f:
                    f.write(updated_data)
                self.updatedFilePathChanged.emit()
                return True
            return False
        except Exception as e:
            print(e)
            return False

    @Slot(str, result=bool)
    def check_date(self, date_str):
        "Checks if the given date string is valid and in future."
        try:
            now = datetime.datetime.now()
            date_str = date_str.strip()
            date_obj = datetime.datetime.strptime(date_str, "%Y-%m-%d")
            if date_obj <= now:
                return False
            self.timediff = (date_obj - now)
            return True
        except ValueError:
            return False

    @Slot(str, str, result='QVariant')
    def parse_public_key(self, pkey_path, date):
        "Parses the given public key and stores details."
        with open(pkey_path, "rb") as f:
            olddata = f.read()
        self.public_key_data = olddata
        self.public_key_directory = os.path.dirname(pkey_path)
        uids, fingerprint, keytype, expirationtime, creationtime, othervalues = (
            rjce.parse_cert_bytes(olddata)
        )
        self.pkey = fingerprint
        self.pkey_expiry = expirationtime.strftime("%Y-%m-%d") if expirationtime else "No expiration"
        subkeys = othervalues.get("subkeys", [])
        for subkey in subkeys:
            # We store type, creation time and expiration time
            if subkey[3]:
                exp = subkey[3].strftime("%Y-%m-%d")
            self.subkeys.append([subkey[4], subkey[1], exp if subkey[3] else "No expiration"])
            self.sub_fingerprints.append(subkey[1])
        return {"fingerprint": self.pkey, "expiration": self.pkey_expiry, "subkeys": self.subkeys}


    @Slot()
    def keygenerated(self):
        self.public_key = f"{self.kt.fingerprint}.pub"
        self.secret_key = f"{self.kt.fingerprint}.sec"
        # Now get the yubikey thread ready
        self.yt.secret = self.kt.secret
        self.yt.password = self.password
        self.updated.emit()

    @Slot()
    def keyuploaded(self):
        "To take the internal thread and pass on"
        self.uploaded.emit()

    @Slot()
    def handle_error(self):
        "We have an error"
        self.errored.emit()

    @Slot(str)
    def save_userpin(self, pin):
        "Saves the new pin for Yubikey"
        try:
            rjce.change_user_pin(ADMIN_PIN, pin.encode("utf-8"))
        except:
            self.errored.emit()

    @Slot(str)
    def save_adminpin(self, pin):
        "Saves the new pin for Yubikey"
        try:
            rjce.change_admin_pin(ADMIN_PIN, pin.encode("utf-8"))
        except:
            self.errored.emit()
        try:
            # Now disable OTP application
            rjce.disable_otp_usb()
        except:
            pass # for now do not report.

    @Slot(str, str, str)
    def generateKey(self, name, qemails, password):
        emails = [] 
        for email in qemails.split("\n"):
            email = email.strip()
            if email:
                # We want some text in that email field
                # TODO: vaildate email (maybe bad idea)
                emails.append(email)
        self.uids = [f"{name} <{email}>" for email in emails]
        self.name = name
        self.kt.uids = self.uids
        self.password = password.strip()
        self.kt.password = self.password
        self.kt.start()

    @Slot()
    def uploadYubikey(self):
        "Uploads to yubikey"
        self.yt.start()

    @Slot(result=bool)
    def is_connected(self):
        "Checks if the Yubikey is connected or not"
        return rjce.is_smartcard_connected()

    @Slot(str, bool, result=bool)
    def saveKey(self, dirpath: str, secret: bool):
        ssh_filename = os.path.join(dirpath, f"ssh-{self.public_key}")
        if secret:
            filename = os.path.join(dirpath, self.secret_key)
        else:
            filename = os.path.join(dirpath, self.public_key)
        try:
            with open(filename, "w") as fobj:
                if secret:
                    fobj.write(self.kt.secret)
                else:
                    fobj.write(self.kt.public)
                    if self.kt.ssh_public:
                        with open(ssh_filename, "w") as fssh:
                            fssh.write(self.kt.ssh_public)
        except Exception as e:
            # TODO: Have to show to user
            print(e)
            return False

        return True

    # This is the property exposed to QML
    PublicKey = Property(str, read_public_key, None)
    SecretKey = Property(str, read_secret_key, None)
    UpdatedFilePath = Property(str, read_updated_filepath, notify=updatedFilePathChanged)


def main():
    # Linux desktop environments use app's .desktop file to integrate the app
    # to their application menus. The .desktop file of this app will include
    # StartupWMClass key, set to app's formal name, which helps associate
    # app's windows to its menu item.
    #
    # For association to work any windows of the app must have WMCLASS
    # property set to match the value set in app's desktop file. For PySide2
    # this is set with setApplicationName().

    # Find the name of the module that was used to start the app
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--allow-private", action="store_true", help="Allows saving private key."
    )
    args = parser.parse_args()

    app_module = sys.modules["__main__"].__package__
    # Retrieve the app's metadata
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    # We store the user progress in this p object.
    p = Process()
    ctx = engine.rootContext()
    ctx.setContextProperty("process", p)
    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)
    # To allow saving private key
    if args.allow_private:
        r = engine.rootObjects()[0]
        r.setProperty("allowsecret", True)
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
