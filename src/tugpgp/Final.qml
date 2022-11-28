import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    signal clicked

    RowLayout {
        //spacing: 10
        anchors.centerIn: parent

        Image {
            id: checkLogo
            source: "check-big.svg"
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100
            anchors.verticalCenter: Layout.verticalCenter
        }

        Text {
            width: 200
            text: "Your Yubikey is now ready."
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
        text: "Done"

        onClicked: root.clicked()
    }
}
