import QtQuick
import QtQuick.Controls

TextField {
    id: field
    property bool passwordVisible: false

    color: "black"
    font.pixelSize: 20
    echoMode: passwordVisible ? TextInput.Normal : TextInput.Password
    rightPadding: toggle.width + 16
    selectByMouse: true

    onActiveFocusChanged: if (!activeFocus) passwordVisible = false

    background: Rectangle {
        color: "white"
        radius: 5
        border.color: "#ca402b"
    }

    Image {
        id: toggle
        width: 24
        height: 24
        anchors.right: field.right
        anchors.rightMargin: 8
        anchors.verticalCenter: field.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: field.passwordVisible ? "eye_hidden.svg" : "eye_visible.svg"
        smooth: true

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                field.passwordVisible = !field.passwordVisible
                field.forceActiveFocus()
            }
        }
    }
}
