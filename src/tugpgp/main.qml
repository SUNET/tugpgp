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

    Connections {
        target: process
        function onUpdated() {
            stack.push(publicSaveView)
        }
    }

    Component {
        id: startView
        Start {
            onClicked: stack.push(userView)
        }
    }

    Component {
        id: userView
        UserDetails {
            onNext: {
                stack.push(waitView)
                // Now start the key generation process
                process.generateKey(username, emails, password)
            }
        }
    }

    Component {
        id: waitView
        WaitGlass {
            text: "Wait while we generate the key."
        }
    }

    Component {
        id: publicSaveView
        SaveDir {
            fileName: process.PublicKey
            onSaved: {
                stack.push(secretSaveView)
            }
        }
    }

    Component {
        id: secretSaveView
        SaveDir {
            secret: true
            fileName: process.SecretKey
            onSaved: {
                console.log("Saveing secret key at: " + dir)
                stack.push(userPinsView)
            }
            onSkipped: {
                stack.push(userPinsView)
            }
        }
    }

    Component {
        id: userPinsView
        Pins {
            user: true
            onNext: {
                stack.push(adminPinsView)
            }
        }
    }

    Component {
        id: adminPinsView
        Pins {
            user: false
            onNext: {
                stack.push(finalView)
            }
        }
    }

    Component {
        id: ykView
        Yubikey {}
    }

    Component {
        id: finalView
        Final {}
    }
}
