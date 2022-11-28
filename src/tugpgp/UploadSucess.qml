import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    signal next

    RowLayout {
        //spacing: 10
        anchors.centerIn: parent

        Image {
            id: checkLogo
            source: "upload_success.svg"
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120
            anchors.verticalCenter: Layout.verticalCenter
        }

        Text {
            width: 200
            text: qsTr("Upload successful. Click next.")
            font.pixelSize: 25
            anchors.verticalCenter: Layout.verticalCenter
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

        onClicked: root.next()
    }
}
