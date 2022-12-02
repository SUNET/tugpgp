import QtQuick
import QtQuick.Controls
import Qt.labs.platform

Rectangle {
    id: root
    property bool secret: false
    property alias text: pathTxt.text
    property alias dir: dirTxt.text
    property string fileName: qsTr("Default name")
    signal saved
    signal skipped
    color: "white"

    FolderDialog {
        id: folderDialog
        currentFolder: StandardPaths.standardLocations(
                           StandardPaths.HomeLocation)[0]
        folder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
    }

    Column {
        id: centerColumn
        anchors.top: root.top
        anchors.left: root.left
        anchors.right: root.right
        anchors.leftMargin: 100
        spacing: 10

        Item {
            width: parent.width
            height: 150
        }

        Text {
            id: pathTxt
            text: secret ? qsTr("Select directory to save the secret key.") : qsTr(
                               "Select directory to save the public key.")
            bottomPadding: 10
            font.pixelSize: 25
        }
        Row {
            spacing: 5
            TextField {
                id: dirTxt
                width: 450
                height: 40
                bottomPadding: 10

                font.pixelSize: 20
                color: "black"

                background: Rectangle {
                    color: "white"
                    radius: 5
                    border.color: "#ca402b"
                }

                text: getName()
            }

            TButton {
                id: selectButton
                height: 40
                font.bold: false
                text: qsTr("Select Directory")

                onClicked: {
                    folderDialog.open()
                }
            }
        }

        Row {
            spacing: 5
            Text {
                id: resultMainTxt
                text: secret ? qsTr("Secret Key filename: ") : qsTr(
                                   "Public Key filename: ")
                bottomPadding: 10
                font.pixelSize: 15
            }
            Text {
                id: resultTxt
                text: fileName
                bottomPadding: 10
                font.pixelSize: 15
            }
        }
        Text {
            id: errorTxt
            text: qsTr("Error while saving the file.")
            bottomPadding: 10
            font.pixelSize: 30
            color: "red"
            visible: false
        }
    }

    Row {
        spacing: 5
        // For the button row itself
        anchors {
            bottom: root.bottom
            bottomMargin: 20
            right: root.right
            rightMargin: 20
        }

        TButton {
            id: saveButton
            text: qsTr("Save")
            onClicked: {
                if (process.saveKey(dirTxt.text, root.secret)) {
                    root.saved()
                } else {
                    errorTxt.visible = true
                }
            }
        }

        TButton {
            id: skipButton
            visible: root.secret ? true : false
            text: qsTr("Skip")

            onClicked: {
                root.skipped()
            }
        }
    }
    function getName() {
        var u = new URL(folderDialog.folder)
        return u.pathname
    }
}
