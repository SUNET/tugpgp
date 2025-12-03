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

    Text {
        id: message
        anchors.top: bigRow.bottom
        anchors.topMargin: 20
        width: parent.width - 80
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: 14
        color: "#252021"
        text: qsTr("%1").arg(process.UpdatedFilePath)
    }
}
