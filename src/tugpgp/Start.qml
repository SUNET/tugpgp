import QtQuick

Rectangle {
    id: root
    signal clicked

    Text {
        width: 400
        height: 200
        anchors.centerIn: parent
        text: "Welcome to Tugpgp, make sure that you have a Yubikey ready.\nClick next to begin the process."
    }

    TButton {
        id: nextButton
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            right: parent.right
            rightMargin: 20
        }
        text: "Next"

        onClicked: root.clicked()
    }
}
