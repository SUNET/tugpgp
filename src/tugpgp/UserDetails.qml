import QtQuick
import QtQuick.Controls

Rectangle {

    id: root
    signal next

    property alias username: userTxt.text
    property alias emails: emailsTxt.text
    property alias password: passwordTxt.text

    //color: "seagreen"
    Column {
        id: centerColumn
        anchors.top: root.top
        anchors.left: root.left
        anchors.right: root.right
        anchors.leftMargin: 100

        Item {
            width: parent.width
            height: 100
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
            color: "black"

            background: Rectangle {
                color: "white"
                radius: 5
                border.color: "#ca402b"
            }
        }
        Text {
            text: "Email Addresses (one each line)"
            topPadding: 10
            bottomPadding: 10
            font.pixelSize: 25
        }
        TextArea {
            id: emailsTxt
            width: 550
            height: 200
            bottomPadding: 10

            font.pixelSize: 20
            color: "black"

            KeyNavigation.priority: KeyNavigation.BeforeItem
            KeyNavigation.tab: nextItemInFocusChain()

            background: Rectangle {
                color: "white"
                radius: 5
                border.color: "#ca402b"
            }
        }
        Text {
            text: "Password for the secret key"
            bottomPadding: 10
            font.pixelSize: 25
        }
        TextField {
            id: passwordTxt
            echoMode: TextInput.Password
            width: 550
            height: 40
            bottomPadding: 10

            font.pixelSize: 20
            color: "black"

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
