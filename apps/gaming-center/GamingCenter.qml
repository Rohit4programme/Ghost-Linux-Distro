import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    width: 800
    height: 600
    color: "#0a0a0f"

    property double cpuUsage: 0.0
    property double gpuTemp: 0.0
    property double ramUsage: 0.0
    property double fpsCount: 0.0
    property string activeMode: "Balanced"

    Connections {
        target: gamingManager
        
        onTelemetryUpdated: {
            root.cpuUsage = cpu_load;
            root.gpuTemp = gpu_temp;
            root.ramUsage = ram_usage;
            root.fpsCount = fps;
        }

        onModeChanged: {
            root.activeMode = mode;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        // Title and Header
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Text { text: "Gaming Center"; color: "#ffffff"; font.family: "Outfit"; font.pointSize: 22; font.bold: true }
                Text { text: "Optimize hardware parameters and launch game libraries"; color: "#808090"; font.family: "Outfit"; font.pointSize: 10 }
            }
            Item { Layout.fillWidth: true }
            
            // Mode Status Chip
            Rectangle {
                width: 140; height: 35; radius: 18
                color: root.activeMode === "Gaming" ? "#20ffaa00" : (root.activeMode === "Maximum" ? "#20ff3366" : "#2000ffff")
                border.color: root.activeMode === "Gaming" ? "#ffaa00" : (root.activeMode === "Maximum" ? "#ff3366" : "#00ffff")
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: root.activeMode.toUpperCase() + " MODE"
                    color: root.activeMode === "Gaming" ? "#ffaa00" : (root.activeMode === "Maximum" ? "#ff3366" : "#00ffff")
                    font.bold: true; font.pointSize: 9
                }
            }
        }

        // Telemetry Circular Cards Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            // CPU Gauge
            telemetryGaugeDelegate: "CPU"
            property real valueVal: root.cpuUsage
            property string colorStr: "#00ffff"
            property string suffix: "%"

            // GPU Temp Gauge
            // RAM Gauge
            // FPS Gauge
            Repeater {
                model: [
                    { name: "CPU", val: root.cpuUsage, color: "#00ffff", unit: "%" },
                    { name: "GPU", val: root.gpuTemp, color: "#ff5500", unit: "°C" },
                    { name: "RAM", val: root.ramUsage, color: "#e000ff", unit: "%" },
                    { name: "FPS", val: root.fpsCount, color: "#00ff88", unit: "" }
                ]

                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 120
                    color: "#14141e"
                    radius: 10
                    border.color: "#15ffffff"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: modelData.name; color: "#a0a0b0"; font.pointSize: 9; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                        
                        // Ring Visual (simple text and colored arc wrapper)
                        RowLayout {
                            spacing: 5
                            Text {
                                text: modelData.val.toFixed(0) + modelData.unit
                                color: modelData.color
                                font.pointSize: 18
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }

        // Performance Mode Selector Box
        Rectangle {
            Layout.fillWidth: true
            height: 130
            color: "#10101b"
            radius: 12
            border.color: "#20ffffff"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12

                Text { text: "Hardware Performance Profiles"; color: "white"; font.bold: true; font.pointSize: 11 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Repeater {
                        model: ["Battery Saver", "Balanced", "Gaming", "Maximum"]
                        delegate: Button {
                            id: profileBtn
                            Layout.fillWidth: true
                            height: 45
                            
                            background: Rectangle {
                                color: root.activeMode === modelData ? "#25ffffff" : "#12ffffff"
                                radius: 8
                                border.color: root.activeMode === modelData ? 
                                              (modelData === "Maximum" ? "#ff3366" : (modelData === "Gaming" ? "#ffaa00" : "#00ffff")) : "#15ffffff"
                                border.width: root.activeMode === modelData ? 2 : 1
                            }

                            contentItem: Text {
                                text: modelData
                                color: root.activeMode === modelData ? "white" : "#80ffffff"
                                font.bold: true
                                font.pointSize: 10
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: gamingManager.set_performance_mode(modelData)
                        }
                    }
                }
            }
        }

        // Game Clients Launch Panel
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 15

            // Left Box: Gaming Clients launchers
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#10101b"
                radius: 12
                border.color: "#20ffffff"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Text { text: "Quick Launch Games"; color: "white"; font.bold: true; font.pointSize: 11 }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        spacing: 20

                        // Steam
                        Button {
                            id: btnSteam
                            Layout.preferredWidth: 80; height: 80
                            background: Rectangle { color: btnSteam.hovered ? "#20ffffff" : "#12ffffff"; radius: 10 }
                            contentItem: ColumnLayout {
                                anchors.centerIn: parent
                                Text { text: "🎮"; font.pointSize: 20; Layout.alignment: Qt.AlignHCenter }
                                Text { text: "Steam"; color: "white"; font.pointSize: 9; Layout.alignment: Qt.AlignHCenter }
                            }
                            onClicked: gamingManager.launch_game_client("steam")
                        }

                        // Lutris
                        Button {
                            id: btnLutris
                            Layout.preferredWidth: 80; height: 80
                            background: Rectangle { color: btnLutris.hovered ? "#20ffffff" : "#12ffffff"; radius: 10 }
                            contentItem: ColumnLayout {
                                anchors.centerIn: parent
                                Text { text: "🛡"; font.pointSize: 20; Layout.alignment: Qt.AlignHCenter }
                                Text { text: "Lutris"; color: "white"; font.pointSize: 9; Layout.alignment: Qt.AlignHCenter }
                            }
                            onClicked: gamingManager.launch_game_client("lutris")
                        }

                        // Heroic
                        Button {
                            id: btnHeroic
                            Layout.preferredWidth: 80; height: 80
                            background: Rectangle { color: btnHeroic.hovered ? "#20ffffff" : "#12ffffff"; radius: 10 }
                            contentItem: ColumnLayout {
                                anchors.centerIn: parent
                                Text { text: "🚀"; font.pointSize: 20; Layout.alignment: Qt.AlignHCenter }
                                Text { text: "Heroic"; color: "white"; font.pointSize: 9; Layout.alignment: Qt.AlignHCenter }
                            }
                            onClicked: gamingManager.launch_game_client("heroic")
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            // Right Box: Integration Settings (Toggles)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#10101b"
                radius: 12
                border.color: "#20ffffff"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Text { text: "System Optimizations"; color: "white"; font.bold: true; font.pointSize: 11 }

                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Text { text: "MangoHud Overlay"; color: "white"; font.pointSize: 10; font.bold: true }
                            Text { text: "Draw performance overlay in games"; color: "#808090"; font.pointSize: 8 }
                        }
                        Item { Layout.fillWidth: true }
                        Switch {
                            id: hudSwitch
                            onToggled: gamingManager.toggle_mangohud(checked)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Text { text: "GameMode Integration"; color: "white"; font.pointSize: 10; font.bold: true }
                            Text { text: "Force system process priority scaling"; color: "#808090"; font.pointSize: 8 }
                        }
                        Item { Layout.fillWidth: true }
                        Switch {
                            checked: true
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
