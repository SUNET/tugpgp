import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "white"

    RowLayout {
        id: bigRow
        anchors.centerIn: parent

        Image {
            id: checkLogo
            source: "check-big.svg"
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120
            anchors.verticalCenter: Layout.verticalCenter
        }

        Text {
            width: 200
            text: qsTr("Updated public key saved.")
            font.pixelSize: 25
            anchors.verticalCenter: Layout.verticalCenter
        }
    }

    Rectangle {
        id: messageBackground
        anchors.top: bigRow.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(message.implicitWidth + 24, parent.width - 80)
        height: message.implicitHeight + 20
        color: "#fafafa"
        radius: 4
        border.color: "#ddd"

        TextInput {
            id: message
            anchors.centerIn: parent
            width: parent.width - 24
            font.pixelSize: 13
            font.family: "monospace"
            color: "#252021"
            text: process.UpdatedFilePath
            readOnly: true
            selectByMouse: true
        }
    }
}
