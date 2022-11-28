import QtQuick
import QtQuick.Controls
import Qt.labs.platform

Rectangle {
    id: root
    color: "white"
    property bool user: true
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
            font.pixelSize: 25
        }
        TextField {
            id: pass2Txt
            width: 550
            height: 40
            bottomPadding: 10
            echoMode: TextInput.Password

            font.pixelSize: 20
            background: Rectangle {
                color: "white"
                radius: 5
                border.color: "#ca402b"
            }
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
        text: "Next"

        onClicked: root.next()
    }
}
