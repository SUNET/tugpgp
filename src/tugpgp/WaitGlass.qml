import QtQuick
import QtQuick.Controls

Rectangle {

    id: root
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
            height: 250
        }
        Image {
            id: glass
            source: "hour-glass.svg"
            height: 100
            width: 100
            anchors.leftMargin: 200
            RotationAnimator on rotation {
                from: 0
                to: 360
                duration: 2000
                loops: Animation.Infinite
            }
        }

        Text {
            id: mainTxt
            anchors.topMargin: 50
            text: "Wait while we generate the key."
            font.pixelSize: 30
        }
    }
}
