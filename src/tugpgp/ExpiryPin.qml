import QtQuick
import QtQuick.Controls
import Qt.labs.platform

Rectangle {
    id: root
    color: "white"
    signal next
    
    property string primaryFingerprint: ""
    property string primaryExpiry: ""
    property string yubikeyPin: userPinTxt.text
    
    function setKeyData(data) {
        primaryFingerprint = String(data.fingerprint)
        primaryExpiry = data.expiration ? String(data.expiration) : "No expiration"
        
        // Create subkey entries
        for (var i = 0; i < data.subkeys.length; i++) {
            var subkey = data.subkeys[i]
            subkeyModel.append({
                "type": String(subkey[0]),
                "fingerprint": String(subkey[1]),
                "expiry": subkey[2] ? String(subkey[2]) : "No expiration"
            })
        }
    }

    function showError(message) {
        badTxt.text = message
        badTxt.visible = true
    }



    ListModel {
        id: subkeyModel
    }

    ScrollView {
        id: subkeyScroll
        anchors.fill: parent
        anchors.margins: 20
        anchors.bottomMargin: 100
        
        Column {
            id: centerColumn
            width: parent.width
            spacing: 20

            Item {
                width: parent.width
                height: 30
            }

            Text {
                text: qsTr("Key Information")
                font.pixelSize: 24
                font.bold: true
                color: "#252021"
            }

            // Header row
            Item {
                width: parent.width - 100
                height: 35

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 20

                    Text {
                        text: "Type"
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 16
                        font.bold: true
                        color: "#252021"
                    }
                    Text {
                        text: "Fingerprint"
                        width: 350
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 16
                        font.bold: true
                        color: "#252021"
                    }
                    Text {
                        text: "Expiry"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 16
                        font.bold: true
                        color: "#252021"
                    }
                }
            }

            // Primary key row
            Item {
                width: parent.width - 100
                height: 45


                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 20

                    Text {
                        text: "Primary"
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 15
                        font.bold: true
                        color: "#e97f2e"
                    }
                    Text {
                        text: primaryFingerprint
                        width: 350
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 14
                        color: "#252021"
                        elide: Text.ElideMiddle
                    }
                    Text {
                        text: primaryExpiry
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 14
                        color: "#252021"
                    }
                }
            }

            // Subkeys
            Repeater {
                model: subkeyModel

                Item {
                    width: parent.width - 100
                    height: 15

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 20

                        Text {
                            text: model.type
                            width: 120
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 14
                            color: "#444444"
                        }
                        Text {
                            text: model.fingerprint
                            width: 350
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 14
                            color: "#444444"
                            elide: Text.ElideMiddle
                        }
                        Text {
                            text: model.expiry
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 13
                            color: "#666666"
                        }
                    }

                }
            }
        }
    }
    
    Text {
        id: detailsTxt
        text: qsTr("After clicking update, touch the Yubikey when flashing. It will be required for the primary key and every subkey.")
        wrapMode: Text.WordWrap
        width: 600
        font.pixelSize: 16
        color: "#000000"
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.bottom: userPinLabel.top
        anchors.bottomMargin: 16
    }


    Text {
        id: badTxt
        anchors.bottom: detailsTxt.top
        anchors.bottomMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("")
        font.pixelSize: 20
        color: "red"
        visible: false
    }

    Text {
        id: userPinLabel
        text: qsTr("Yubikey PIN")
        font.pixelSize: 18
        color: "#252021"
        anchors.left: userPinTxt.left
        anchors.bottom: userPinTxt.top
        anchors.bottomMargin: 6
    }

    PinEntry {
        id: userPinTxt
        width: 550
        height: 40
        bottomPadding: 10

        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.bottom: ueButton.top
        anchors.bottomMargin: 20
    }
    

    TButton {
        id: ueButton
        anchors {
            bottom: parent.bottom
            bottomMargin: 20
            right: parent.right
            rightMargin: 20
        }
        text: qsTr("Update")
        onClicked: {
            badTxt.visible = true
            badTxt.text = qsTr("Touch the Yubikey when flashing...")
            nextTimer.start()
        }
    }

    Timer {
        id: nextTimer
        interval: 100
        repeat: false
        onTriggered: root.next()
    }
}
