import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    RowLayout {
        //spacing: 10
        anchors.centerIn: parent

        Image {
            id: checkLogo
            source: "errors.svg"
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120
            anchors.verticalCenter: Layout.verticalCenter
        }

        Text {
            width: 200
            text: qsTr("There is an unexpected Error. Please try again.")
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
        text: qsTr("Close")

        onClicked: Qt.callLater(Qt.quit)
    }
}
