import QtQuick
import QtQuick.Window
import QtQuick.Controls

ApplicationWindow {
    title: qsTr("Tugpgp v0.1.3a1")
    width: 983
    height: 702
    visible: true

    id: root

    // This defines if we will allow saving private key
    property bool allowsecret: false

    // To check if this is a backup smartcard or not
    property bool backupkey: false

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
            stack.push(ykView)
        }
    }
    Connections {
        target: process
        function onUploaded() {
            stack.push(uploadSuccessView)
        }
    }
    // The following will show the errors view and then close the Application
    Connections {
        target: process
        function onErrored() {
            stack.push(errorsView)
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
            text: qsTr("Wait while we generate the key.")
        }
    }

    Component {
        id: publicSaveView
        SaveDir {
            fileName: process.PublicKey
            onSaved: {
                // To save secret key if allowed
                if (allowsecret) {
                    stack.push(secretSaveView)
                } else {
                    stack.push(userPinsView)
                }
            }
        }
    }

    Component {
        id: secretSaveView
        SaveDir {
            secret: true
            fileName: process.SecretKey
            onSaved: {
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
                process.save_userpin(pin)
                stack.push(adminPinsView)
            }
        }
    }

    Component {
        id: adminPinsView
        Pins {
            user: false
            onNext: {
                process.save_adminpin(pin)
                stack.push(finalView)
            }
        }
    }

    Component {
        id: ykView
        Yubikey {
            onNext: {
                stack.push(ykwaitView)
                // Now upload the key to Yubikey
                process.uploadYubikey()
            }
        }
    }

    Component {
        id: ykwaitView
        WaitGlass {
            text: qsTr("Wait while we upload the key to Yubikey.")
        }
    }

    Component {
        id: uploadSuccessView
        UploadSucess {
            onNext: {
                if (backupkey) {
                    // This is a backup smartcard, no need to save public key again
                    stack.push(userPinsView)
                } else {
                    stack.push(publicSaveView)
                }
            }
        }
    }

    Component {
        id: finalView
        Final {

            onBackup: {
                backupkey = true
                stack.push(ykView)
            }
        }
    }

    Component {
        id: errorsView
        Errors {}
    }
}
