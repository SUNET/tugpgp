import QtQuick
import QtQuick.Window
import QtQuick.Controls

ApplicationWindow {
    title: qsTr("Tugpgp")
    width: 983
    height: 702
    visible: true

    id: root

    SplitView {
        anchors.fill: parent

        // Tags of the left side
        Rectangle {
            color: "white"
            height: root.height
            SplitView.minimumWidth: 200

            Image {
                id: sunetLogo
                source: "sunet_logo_color.svg"
                anchors {
                    left: parent.left
                    top: parent.top
                    leftMargin: 20
                    topMargin: 20
                }
            }
        }

        Rectangle {
            id: bigBox
            color: "white"
            height: root.height
            SplitView.minimumWidth: 602

            StackView {
                id: stack
                initialItem: startView
                anchors.fill: parent

                pushEnter: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 100
                    }
                }
                pushExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 100
                    }
                }
                popEnter: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 100
                    }
                }
                popExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 100
                    }
                }
            }
        }
    }

    Component {
        id: startView
        Start {}
    }

    Component {
        id: mainView

        Row {
            spacing: 10

            Button {
                text: "Push"
                onClicked: stack.push(secondView)
            }
            Button {
                text: "Pop"
                enabled: stack.depth > 1
                onClicked: stack.pop()
            }
            Text {
                text: stack.depth
            }
        }
    }
    Component {
        id: secondView

        Row {
            spacing: 10

            Rectangle {
                width: sTxt.implicitWidth
                height: 30
                color: "yellow"
                Text {
                    id: sTxt
                    text: "second view"
                }
            }

            Button {
                text: "Push"
                onClicked: stack.push(mainView)
            }
            Button {
                text: "Pop"
                enabled: stack.depth > 1
                onClicked: stack.pop()
            }
            Text {
                text: stack.depth
            }
        }
    }
}
