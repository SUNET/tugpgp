import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    signal backup

    RowLayout {
        //spacing: 10
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
            text: qsTr("Your Yubikey is now ready.")
            font.pixelSize: 25
            anchors.verticalCenter: Layout.verticalCenter
        }
    }

    TButton {
        id: backButton
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            left: parent.left
            leftMargin: 20
        }
        text: qsTr("Create Backup key")

        onClicked: root.backup()
    }

    TButton {
        id: nextButton
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            right: parent.right
            rightMargin: 20
        }
        text: qsTr("Done")

        onClicked: Qt.callLater(Qt.quit)
    }
}
