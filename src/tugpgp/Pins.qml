import QtQuick
import QtQuick.Controls
import Qt.labs.platform

Rectangle {
    id: root
    color: "white"
    property bool user: true
    property int clength: user ? 6 : 8
    property alias pin: passTxt.text
    signal next

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
            text: user ? qsTr("User Pin (6+ character long)") : qsTr(
                             "Admin Pin (8+ character long)")
            bottomPadding: 10
            font.pixelSize: 25
        }

        TextField {
            id: passTxt
            width: 550
            height: 40
            bottomPadding: 10
            echoMode: TextInput.Password

            font.pixelSize: 20
            color: "black"
            background: Rectangle {
                color: "white"
                radius: 5
                border.color: "#ca402b"
            }
        }
        Text {
            id: repeatTxt
            text: user ? qsTr("Repeat User Pin") : qsTr("Repeat Admin Pin")
            bottomPadding: 10
            topPadding: 10
            font.pixelSize: 25
        }
        TextField {
            id: pass2Txt
            width: 550
            height: 40
            bottomPadding: 10
            echoMode: TextInput.Password

            font.pixelSize: 20
            color: "black"

            background: Rectangle {
                color: "white"
                radius: 5
                border.color: "#ca402b"
            }
        }
        Text {
            id: wrongTxt
            text: qsTr("Pins do not match.")
            bottomPadding: 10
            font.pixelSize: 25
            color: "red"
            visible: false
        }
        Text {
            id: lessTxt
            text: user ? qsTr("We need 6 characters at least.") : qsTr(
                             "We need 8 characters at least.")
            bottomPadding: 10
            font.pixelSize: 25
            color: "red"
            visible: false
        }
    }

    TButton {
        id: nextButton
        anchors {
            bottom: root.bottom
            bottomMargin: 20
            right: root.right
            rightMargin: 20
        }
        text: qsTr("Next")

        onClicked: {
            // First clear all old errors
            lessTxt.visible = false
            wrongTxt.visible = false

            // Then check for the length of the pin
            if (passTxt.text.length < clength) {
                lessTxt.visible = true
            } else if (passTxt.text != pass2Txt.text) {
                // Here we are making sure that the pins match
                wrongTxt.visible = true
            } else {
                root.next()
            }
        }
    }
}
