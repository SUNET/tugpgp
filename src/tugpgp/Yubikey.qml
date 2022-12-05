import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {

    id: root
    signal next
    property alias text: mainTxt.text
    property bool dclick: false

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

        Rectangle {

            id: doubleCheck
            color: "#f9b700"
            radius: 4
            visible: false

            width: mainTxt.width
            height: 120

            RowLayout {
                anchors.centerIn: parent
                Image {
                    id: warningLogo
                    source: "warning.svg"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 100
                    anchors.verticalCenter: Layout.verticalCenter
                }

                Text {
                    width: 220
                    text: qsTr("Please make sure that only the correct\nYubikey is attached and then click upload\nbutton.")
                    font.pixelSize: 20
                    anchors.verticalCenter: Layout.verticalCenter
                }
            }
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
                if (!dclick) {
                    // This is the first click.
                    dclick = true
                    doubleCheck.visible = true
                    mainTxt.visible = false
                    badTxt.visible = false
                    nextButton.text = qsTr("Upload")
                } else {
                    // This is the user clicking next button second time
                    // We have the correct clicks
                    root.next()
                }
            }
        }
    }
}
