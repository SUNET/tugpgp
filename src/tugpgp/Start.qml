import QtQuick

Rectangle {
    id: root
    color: "white"
    signal clicked

    Text {
        width: 400
        height: 200
        anchors.centerIn: parent
        text: qsTr("Welcome to Tugpgp.\nClick next to begin the process.")
        font.pixelSize: 25
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

        onClicked: root.clicked()
    }
}
