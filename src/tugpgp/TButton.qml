import QtQuick
import QtQuick.Controls

Button {
    id: control
    width: 180
    height: 54
    font.pixelSize: 22
    font.bold: true
    text: "button"
    // Color
    property color normalColor: "#3290FF"
    property color hoverColor: "#026DEA"
    property color clickColor: "#005DCA"

    property var bColor: control.down ? clickColor : (control.hovered ? hoverColor : normalColor)
    highlighted: true
    flat: true

    background: Rectangle {
        anchors.fill: parent
        color: bColor
        radius: 2
    }
    contentItem: Text {

        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        //color: control.down ? "#17a81a" : "#21be2b"
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
