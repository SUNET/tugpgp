import QtQuick
import QtQuick.Controls

Rectangle {

    id: root
    signal next
    property alias text: mainTxt.text

    //color: "seagreen"
    Column {
        id: centerColumn
        anchors.top: root.top
        anchors.left: root.left
        anchors.right: root.right
        anchors.leftMargin: 100
        spacing: 20

        Item {
            width: parent.width
            height: 100
        }
        Image {
            id: yk
            source: "yk.png"
            anchors.leftMargin: 200
        }

        Text {
            id: mainTxt
            anchors.topMargin: 50
            text: qsTr("Please connect your Yubikey, and click next.")
            font.pixelSize: 25
        }

        Text {
            id: badTxt
            anchors.topMargin: 50
            text: qsTr("Can not find any Yubikey, please try again.")
            font.pixelSize: 30
            color: "red"
            visible: false
        }
    }
    TButton {
        id: nextButton
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            right: parent.right
            rightMargin: 20
        }
        text: qsTr("Next")

        onClicked: {
            if (!process.is_connected()) {
                badTxt.visible = true
            } else {
                root.next()
            }
        }
    }
}
