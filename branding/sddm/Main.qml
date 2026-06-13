import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: container
    width: 1920
    height: 1080
    color: "#0f0f15"

    // Background Image
    Image {
        id: bgImage
        anchors.fill: parent
        source: config.background || "wallpaper.png"
        fillMode: Image.PreserveAspectCrop
        visible: true
    }

    // Blurred Background Layer for Acrylic/Glass Effect
    ShaderEffectSource {
        id: blurSource
        anchors.fill: glassCard
        sourceItem: bgImage
        sourceRect: Qt.rect(glassCard.x, glassCard.y, glassCard.width, glassCard.height)
        live: true
    }

    FastBlur {
        id: bgBlur
        anchors.fill: glassCard
        source: blurSource
        radius: 64
    }

    // Glassmorphic Card Container
    Rectangle {
        id: glassCard
        width: 420
        height: 500
        anchors.centerIn: parent
        color: "#22000000" // Semi-transparent black overlay
        radius: 20
        border.color: "#30ffffff" // Thin glass border
        border.width: 1

        // Drop shadow for depth
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 12
            radius: 24
            color: "#66000000"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 20

            // Logo or Avatar Placeholder
            Item {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    id: avatarMask
                    width: 100
                    height: 100
                    radius: 50
                    color: "white"
                    visible: false
                }

                Image {
                    id: avatarImage
                    width: 100
                    height: 100
                    source: "logo.png"
                    fillMode: Image.PreserveAspectCrop
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: avatarMask
                    }
                }

                // Smooth hover scale effect
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: avatarImage.scale = 1.05
                    onExited: avatarImage.scale = 1.0
                }
            }

            // Welcome Header
            Text {
                text: "Welcome to Ghost-Linux"
                color: "#ffffff"
                font.family: config.fontFamily || "sans-serif"
                font.pointSize: 18
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Unlock the Next Generation OS"
                color: "#bbffffff"
                font.family: config.fontFamily || "sans-serif"
                font.pointSize: 10
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -10
            }

            // Username Field (Text Field)
            TextField {
                id: txtUser
                placeholderText: "Username"
                text: userModel.lastUser
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                color: "#ffffff"
                font.family: config.fontFamily || "sans-serif"
                font.pointSize: 11
                placeholderTextColor: "#80ffffff"
                background: Rectangle {
                    color: txtUser.activeFocus ? "#30ffffff" : "#15ffffff"
                    radius: 8
                    border.color: txtUser.activeFocus ? "#a000ffff" : "#15ffffff" // Cyan glow on focus
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }

            // Password Field
            TextField {
                id: txtPassword
                placeholderText: "Password"
                echoMode: TextInput.Password
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                color: "#ffffff"
                font.family: config.fontFamily || "sans-serif"
                font.pointSize: 11
                placeholderTextColor: "#80ffffff"
                background: Rectangle {
                    color: txtPassword.activeFocus ? "#30ffffff" : "#15ffffff"
                    radius: 8
                    border.color: txtPassword.activeFocus ? "#a0e000ff" : "#15ffffff" // Purple glow on focus
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                
                onAccepted: sddm.login(txtUser.text, txtPassword.text, sessionIndex)
            }

            // Login Button
            Button {
                id: btnLogin
                text: "Sign In"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                Layout.topMargin: 10
                
                contentItem: Text {
                    text: btnLogin.text
                    font.family: config.fontFamily || "sans-serif"
                    font.pointSize: 11
                    font.bold: true
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    id: btnBg
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: btnLogin.hovered ? "#00ffff" : "#a000ffff" } // Cyan to Purple Gradient
                        GradientStop { position: 1.0; color: btnLogin.hovered ? "#e000ff" : "#5000aa" }
                    }
                    radius: 8
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                onClicked: sddm.login(txtUser.text, txtPassword.text, sessionIndex)
                onHoveredChanged: btnBg.scale = btnLogin.hovered ? 1.02 : 1.0
            }
        }
    }

    // Session Selector & Power Controls Overlay (Bottom bar)
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 30
        spacing: 20

        // Session Selection Box
        ComboBox {
            id: sessionBox
            model: sessionModel
            currentIndex: sessionModel.lastIndex
            Layout.preferredWidth: 160
            
            background: Rectangle {
                color: "#25ffffff"
                radius: 6
                border.color: "#20ffffff"
            }
            
            contentItem: Text {
                text: sessionBox.displayText
                font.pointSize: 9
                color: "white"
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }
        }

        Item { Layout.fillWidth: true } // Spacer

        // Shut down / Reboot Control Buttons
        Button {
            id: btnReboot
            text: "Reboot"
            onClicked: sddm.reboot()
            background: Rectangle { color: btnReboot.hovered ? "#35ffffff" : "transparent"; radius: 6 }
            contentItem: Text { text: btnReboot.text; color: "white"; font.pointSize: 9 }
        }

        Button {
            id: btnShutdown
            text: "Shut Down"
            onClicked: sddm.poweroff()
            background: Rectangle { color: btnShutdown.hovered ? "#35ffffff" : "transparent"; radius: 6 }
            contentItem: Text { text: btnShutdown.text; color: "white"; font.pointSize: 9 }
        }
    }

    // Keep session index synced
    property int sessionIndex: sessionBox.currentIndex
}
