"""
OpenPGP key generation and Yubikey upload tool
"""
import os
import sys
from pathlib import Path
import datetime
import argparse

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QThread, Signal, Slot, QObject, Property

from johnnycanencrypt import Cipher
import johnnycanencrypt.johnnycanencrypt as rjce

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

    def __init__(self):
        super(Process, self).__init__(None)
        self.public_key = "abcd.pub"
        self.secret_key = "abcd.sec"
        self.kt = KeyThread()
        self.kt.updated.connect(self.keygenerated)
        self.yt = YubiThread()
        self.yt.uploaded.connect(self.keyuploaded)
        self.yt.errored.connect(self.handle_error)

    def read_public_key(self):
        "To read the value of public_key in QML"
        return self.public_key

    def read_secret_key(self):
        "To read the value of secret_key in QML"
        return self.secret_key

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
        emails = [email.strip() for email in qemails.split("\n")]
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
