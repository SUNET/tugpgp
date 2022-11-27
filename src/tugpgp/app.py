"""
OpenPGP key generation and Yubikey upload tool
"""
import sys
from importlib import metadata as importlib_metadata
from pathlib import Path
import time

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QThread, Signal, Slot, QObject, Property

class KeyThread(QThread):
    updated = Signal()

    def __init__(self):
        QThread.__init__(self)

    # run method gets called when we start the thread
    # This is where we will generate the OpenPGP key
    def run(self):
        print("Process started")
        time.sleep(1)
        print("Now we can go to next screen")
        self.updated.emit()


class Process(QObject):
    "Main process class for the key generation steps"
    updated = Signal()

    def __init__(self):
        super(Process, self).__init__(None)
        self.public_key = "abcd.pub"
        self.secret_key = "abcd.sec"
        self.kt = KeyThread()
        self.kt.updated.connect(self.keygenerated)

    def read_public_key(self):
        "To read the value of public_key in QML"
        return self.public_key

    def read_secret_key(self):
        "To read the value of secret_key in QML"
        return self.secret_key

    @Slot()
    def keygenerated(self):
        self.updated.emit()

    @Slot()
    def generateKey(self):
        self.kt.start()

    @Slot(str)
    def savePublicKey(self, pub_dir):
        print(f"Saving public key in python at {pub_dir} with name {self.public_key}")

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
    app_module = sys.modules['__main__'].__package__
    # Retrieve the app's metadata
    metadata = importlib_metadata.metadata(app_module)
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
    sys.exit(app.exec())
    #QtWidgets.QApplication.setApplicationName(metadata['Formal-Name'])

if __name__ == "__main__":
    main()
