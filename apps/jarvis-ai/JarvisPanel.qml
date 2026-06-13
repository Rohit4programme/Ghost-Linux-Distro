import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

ApplicationWindow {
    id: rootWindow
    visible: true
    width: 400
    height: 650
    title: "JARVIS AI Assistant"
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    // Background Container
    Rectangle {
        id: panelBg
        anchors.fill: parent
        color: "rgba(12, 12, 18, 0.85)"
        radius: 20
        border.color: "rgba(255, 255, 255, 0.15)"
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 8
            radius: 20
            color: "#80000000"
        }

        // State properties
        property string aiState: "idle" // idle, listening, thinking, speaking
        property double coreScale: 1.0
        property real waveAmp: 0.0

        Connections {
            target: jarvisEngine
            
            onStateChanged: {
                panelBg.aiState = state;
            }
            onChatMessage: {
                chatModel.append({"sender": sender, "message": text});
                chatListView.positionViewAtEnd();
            }
            onVoiceWave: {
                panelBg.waveAmp = amplitude;
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Window Header (With Close Trigger)
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "JARVIS OS CO-PILOT"
                    color: "#00ffff"
                    font.family: "Outfit, sans-serif"
                    font.bold: true
                    font.pointSize: 10
                    letterSpacing: 2
                }
                Item { Layout.fillWidth: true }
                Button {
                    text: "✕"
                    background: null
                    contentItem: Text { text: "✕"; color: "#60ffffff"; font.pointSize: 12 }
                    onClicked: rootWindow.close()
                }
            }

            // JARVIS Neon Core Visualizer
            Item {
                Layout.preferredHeight: 160
                Layout.fillWidth: true

                // Glowing Neon Core
                Rectangle {
                    id: aiCore
                    width: 100
                    height: 100
                    radius: 50
                    anchors.centerIn: parent
                    
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: panelBg.aiState === "listening" ? "#00ffff" : 
                                   (panelBg.aiState === "thinking" ? "#e000ff" : 
                                   (panelBg.aiState === "speaking" ? "#0088ff" : "#203050"))
                        }
                        GradientStop { position: 1.0; color: "#000000" }
                    }

                    // Pulsing animation bindings
                    scale: panelBg.aiState === "listening" ? (1.0 + Math.sin(Date.now() / 150) * 0.1) : 
                           (panelBg.aiState === "speaking" ? (1.0 + panelBg.waveAmp * 0.3) : 1.0)

                    Behavior on scale { NumberAnimation { duration: 100 } }

                    // Ring glow border
                    layer.enabled: true
                    layer.effect: Glow {
                        radius: panelBg.aiState === "idle" ? 8 : 20
                        color: panelBg.aiState === "listening" ? "#a000ffff" : 
                               (panelBg.aiState === "thinking" ? "#a0e000ff" : 
                               (panelBg.aiState === "speaking" ? "#a00088ff" : "#5000ffff"))
                        spread: 0.3
                    }
                }

                Text {
                    text: panelBg.aiState.toUpperCase()
                    anchors.top: aiCore.bottom
                    anchors.topMargin: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#ffffff"
                    font.family: "Outfit"
                    font.bold: true
                    font.pointSize: 9
                    opacity: 0.7
                }
            }

            // Chat conversation log list view
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: chatListView
                    width: parent.width - 10
                    spacing: 10
                    model: ListModel { id: chatModel }
                    delegate: Item {
                        width: chatListView.width
                        height: chatBubble.height + 10

                        Rectangle {
                            id: chatBubble
                            width: Math.min(parent.width * 0.75, messageText.implicitWidth + 20)
                            height: messageText.implicitHeight + 20
                            radius: 12
                            anchors.right: sender === "User" ? parent.right : undefined
                            anchors.left: sender === "Jarvis" ? parent.left : undefined
                            
                            color: sender === "User" ? "#202030" : "#143040"
                            border.color: sender === "User" ? "#30ffffff" : "#4000ffff"
                            border.width: 1

                            Text {
                                id: messageText
                                text: message
                                color: "white"
                                font.pointSize: 10
                                wrapMode: Text.WordWrap
                                anchors.fill: parent
                                anchors.margins: 10
                            }
                        }
                    }
                }
            }

            // User Chat & Voice Input Controls
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                TextField {
                    id: txtInput
                    placeholderText: "Command JARVIS..."
                    Layout.fillWidth: true
                    height: 40
                    color: "white"
                    placeholderTextColor: "#60ffffff"
                    font.pointSize: 10
                    background: Rectangle {
                        color: "#15ffffff"
                        radius: 8
                        border.color: txtInput.activeFocus ? "#00ffff" : "#20ffffff"
                    }
                    onAccepted: {
                        jarvisEngine.send_chat_message(txtInput.text)
                        txtInput.text = ""
                    }
                }

                // Mic Button
                Button {
                    id: btnMic
                    width: 40; height: 40
                    background: Rectangle {
                        color: panelBg.aiState === "listening" ? "#ff3366" : "#2000ffff"
                        radius: 20
                        border.color: "#50ffffff"
                    }
                    contentItem: Text {
                        text: "🎙"
                        font.pointSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: jarvisEngine.toggle_voice_mode()
                }

                // Send Button
                Button {
                    id: btnSend
                    width: 40; height: 40
                    background: Rectangle { color: "#25ffffff"; radius: 20 }
                    contentItem: Text {
                        text: "➔"
                        font.pointSize: 12
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        jarvisEngine.send_chat_message(txtInput.text)
                        txtInput.text = ""
                    }
                }
            }
        }
    }
}
