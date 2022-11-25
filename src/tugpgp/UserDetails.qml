import QtQuick
import QtQuick.Controls

Rectangle {

    id: root
    signal next

    property alias userName: userTxt.text
    property alias emails: emailsEdit.text

    //color: "seagreen"
    Column {
        id: centerColumn
        anchors.top: root.top
        anchors.left: root.left
        anchors.right: root.right
        anchors.leftMargin: 100

        Item {
            width: parent.width
            height: 150
        }

        Text {
            text: "Full Name"
            bottomPadding: 10
            font.pixelSize: 25
        }
        TextField {
            id: userTxt
            width: 550
            height: 40
            bottomPadding: 10

            font.pixelSize: 20
            background: Rectangle {
                color: "white"
                radius: 5
                border.color: "orange"
            }
        }
        Text {
            text: "Email Addresses (one each line)"
            topPadding: 10
            bottomPadding: 10
            font.pixelSize: 25
        }
        TextArea {
            id: emailsEdit
            width: 550
            height: 200
            bottomPadding: 10

            font.pixelSize: 20
            background: Rectangle {
                color: "white"
                radius: 5
                border.color: "orange"
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
