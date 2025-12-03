import QtQuick
import QtQuick.Controls
import Qt.labs.platform

Rectangle {
    id: root
    color: "white"
    signal next

    property alias selectedFile: filePathTxt.text
    property alias expiryDate: expiryDateTxt.text


    FileDialog {
        id: fileDialog
        title: "Please choose a public key file"
        folder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        nameFilters: ["Public key files (*.pub *.asc)", "All files (*)"]
        fileMode: FileDialog.OpenFile
        
        onAccepted: {
            var u = new URL(fileDialog.file)
            filePathTxt.text = u.pathname
        }
    }

    function showError(message) {
        badTxt.text = message
        badTxt.visible = true
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
            height: 100
        }

        Text {
            text: "Select Public Key File (.pub or .asc)"
            bottomPadding: 10
            font.pixelSize: 25
        }

        Row {
            spacing: 10

            TextField {
                id: filePathTxt
                width: 450
                height: 40
                placeholderText: "No file selected"
                readOnly: true
                font.pixelSize: 18
                color: "black"

                background: Rectangle {
                    color: "white"
                    radius: 5
                    border.color: "#ca402b"
                }
            }

            TButton {
                id: browseButton
                text: qsTr("Browse")
                width: 120
                height: 40
                onClicked: fileDialog.open()
            }
        }

        Text {
            text: "New Expiry Date"
            topPadding: 20
            bottomPadding: 10
            font.pixelSize: 25
        }

        TextField {
            id: expiryDateTxt
            width: 550
            height: 40
            placeholderText: "YYYY-MM-DD"
            font.pixelSize: 20
            color: "black"

            background: Rectangle {
                color: "white"
                radius: 5
                border.color: "#ca402b"
            }
        }

        Text {
            text: "Enter the new expiry date in YYYY-MM-DD format"
            topPadding: 5
            font.pixelSize: 16
            color: "#666666"
        }
        
        Text {
            id: badTxt
            anchors.topMargin: 50
            text: qsTr("Date format is incorrect, please try again.")
            font.pixelSize: 15
            color: "red"
            visible: false
        }

        
    }

    TButton {
        id: ueButton
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            right: parent.right
            rightMargin: 20
        }
        text: qsTr("Next")

        onClicked: root.next()
    }
}
