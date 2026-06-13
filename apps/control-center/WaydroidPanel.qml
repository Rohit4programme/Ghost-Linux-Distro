import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3

Item {
    id: waydroidPage
    anchors.fill: parent

    property var status: ({running: false, android_version: "Unknown", image_type: "VANILLA", ip: "", cpu_cores: 4, ram_mb: 2048})
    property var androidApps: []
    property int cpuCores: 4
    property int ramMb: 2048

    Connections {
        target: controlManager
        onWaydroidStatusUpdated:  { waydroidPage.status = JSON.parse(statusJson) }
        onWaydroidAppsUpdated:    { waydroidPage.androidApps = JSON.parse(appsJson) }
    }

    Component.onCompleted: {
        controlManager.get_waydroid_status()
        controlManager.get_waydroid_apps()
    }

    // ── APK File Picker ──────────────────────────────────────────────────
    FileDialog {
        id: apkPicker
        title: "Select APK File to Install"
        nameFilters: ["APK Files (*.apk)"]
        onAccepted: controlManager.install_apk(apkPicker.fileUrl.toString().replace("file:///",""))
    }

    ScrollView {
        anchors.fill: parent; clip: true

        ColumnLayout {
            width: parent.width - 10
            spacing: 18

            // ── Header ───────────────────────────────────────────────────
            Text { text: "Android Subsystem (Waydroid)"; color: "white"; font.family: "Outfit"; font.pointSize: 18; font.bold: true }
            Text { text: "Run Android apps natively with full GPU acceleration, clipboard sync, and Play Store support"; color: "#808090"; font.pointSize: 9 }

            // ── Status + Start/Stop Hero Card ─────────────────────────────
            Rectangle {
                Layout.fillWidth: true; height: 130
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: waydroidPage.status.running ? "#0d2b1a" : "#1a0d0d" }
                    GradientStop { position: 1.0; color: "#0c0c18" }
                }
                radius: 14; border.color: waydroidPage.status.running ? "#00ff88" : "#ff3366"; border.width: 1

                RowLayout {
                    anchors { fill: parent; margins: 20 }; spacing: 20

                    // Animated ring
                    Rectangle {
                        width: 80; height: 80; radius: 40
                        color: waydroidPage.status.running ? "#2000ff88" : "#20ff3366"
                        border.color: waydroidPage.status.running ? "#00ff88" : "#ff3366"; border.width: 2
                        Text { text: waydroidPage.status.running ? "▶" : "⏹"; font.pointSize: 26; color: waydroidPage.status.running ? "#00ff88" : "#ff3366"; anchors.centerIn: parent }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 4
                        Text { text: waydroidPage.status.android_version; color: "white"; font.bold: true; font.pointSize: 14 }
                        Text { text: "Image: " + waydroidPage.status.image_type + "   IP: " + waydroidPage.status.ip; color: "#9090a0"; font.pointSize: 9 }
                        Text {
                            text: waydroidPage.status.running ? "Container Running" : "Container Stopped"
                            color: waydroidPage.status.running ? "#00ff88" : "#ff3366"
                            font.bold: true; font.pointSize: 10
                        }
                    }

                    ColumnLayout {
                        spacing: 8
                        Button {
                            text: waydroidPage.status.running ? "Stop Android" : "Start Android"
                            implicitWidth: 130; height: 42
                            background: Rectangle {
                                color: waydroidPage.status.running ? "#ff3366" : "#00ff88"; radius: 8
                            }
                            contentItem: Text {
                                text: parent.text; color: "black"; font.bold: true
                                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: controlManager.toggle_waydroid_session(!waydroidPage.status.running)
                        }
                    }
                }
            }

            // ── Two Column Layout: APK Install + Resource Config ──────────
            RowLayout {
                Layout.fillWidth: true; spacing: 14

                // APK Installer Card
                Rectangle {
                    Layout.fillWidth: true; height: 180; color: "#10101b"; radius: 12; border.color: "#20ffffff"

                    ColumnLayout {
                        anchors { fill: parent; margins: 15 }; spacing: 12

                        Text { text: "Install APK"; color: "white"; font.bold: true; font.pointSize: 13 }
                        Text { text: "Sideload any Android APK directly into the container"; color: "#808090"; font.pointSize: 9 }

                        // Drop-zone visual
                        Rectangle {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            color: "#080810"; radius: 8
                            border.color: "#30ffffff"; border.width: 1
                            // Dashed border approximation via opacity animation
                            opacity: apkDropHover.containsMouse ? 0.9 : 0.6
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            ColumnLayout {
                                anchors.centerIn: parent; spacing: 6
                                Text { text: "📦"; font.pointSize: 26; Layout.alignment: Qt.AlignHCenter }
                                Text { text: "Drop APK here or click to browse"; color: "#707080"; font.pointSize: 9; Layout.alignment: Qt.AlignHCenter }
                            }

                            MouseArea {
                                id: apkDropHover
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: apkPicker.open()
                            }
                        }
                    }
                }

                // Resource Configuration Card
                Rectangle {
                    Layout.fillWidth: true; height: 180; color: "#10101b"; radius: 12; border.color: "#20ffffff"

                    ColumnLayout {
                        anchors { fill: parent; margins: 15 }; spacing: 10

                        Text { text: "Container Resources"; color: "white"; font.bold: true; font.pointSize: 13 }
                        Text { text: "Allocate CPU cores and RAM for the Android session"; color: "#808090"; font.pointSize: 9 }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "CPU Cores"; color: "white"; font.pointSize: 10; Layout.preferredWidth: 90 }
                            Slider {
                                id: cpuSlider; from: 1; to: 16; stepSize: 1; value: waydroidPage.cpuCores
                                Layout.fillWidth: true
                                onValueChanged: waydroidPage.cpuCores = value
                            }
                            Text { text: cpuSlider.value.toFixed(0); color: "#00ffff"; font.bold: true; Layout.preferredWidth: 28 }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "RAM (MB)"; color: "white"; font.pointSize: 10; Layout.preferredWidth: 90 }
                            Slider {
                                id: ramSlider; from: 512; to: 8192; stepSize: 256; value: waydroidPage.ramMb
                                Layout.fillWidth: true
                                onValueChanged: waydroidPage.ramMb = value
                            }
                            Text { text: ramSlider.value.toFixed(0); color: "#e000ff"; font.bold: true; Layout.preferredWidth: 40 }
                        }

                        Button {
                            text: "Apply Resource Settings"
                            Layout.alignment: Qt.AlignRight
                            background: Rectangle { color: "#00ffff"; radius: 6 }
                            contentItem: Text { text: "Apply Resource Settings"; color: "black"; font.bold: true }
                            onClicked: controlManager.configure_waydroid_resources(cpuSlider.value, ramSlider.value)
                        }
                    }
                }
            }

            // ── Installed Android Apps Table ──────────────────────────────
            Rectangle {
                Layout.fillWidth: true; color: "#10101b"; radius: 12; border.color: "#20ffffff"
                height: appsCol.implicitHeight + 30

                ColumnLayout {
                    id: appsCol
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 15 }
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Installed Android Apps"; color: "white"; font.bold: true; font.pointSize: 13; Layout.fillWidth: true }
                        Button {
                            text: "Refresh"
                            background: Rectangle { color: "#20ffffff"; radius: 6; border.color: "#30ffffff" }
                            contentItem: Text { text: "Refresh"; color: "white" }
                            onClicked: controlManager.get_waydroid_apps()
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#20ffffff" }

                    // App grid
                    GridView {
                        Layout.fillWidth: true
                        height: Math.ceil(waydroidPage.androidApps.length / 3) * 68
                        cellWidth: parent.width / 3
                        cellHeight: 64
                        model: waydroidPage.androidApps
                        clip: true
                        delegate: Rectangle {
                            width: parent.width / 3 - 8; height: 56
                            color: "#14141e"; radius: 8; border.color: "#18ffffff"
                            margin: 4

                            RowLayout {
                                anchors { fill: parent; margins: 10 }; spacing: 10

                                Rectangle {
                                    width: 36; height: 36; radius: 8; color: "#20e000ff"
                                    Text { text: modelData.name.charAt(0); color: "#e000ff"; font.bold: true; font.pointSize: 14; anchors.centerIn: parent }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 1
                                    Text { text: modelData.name; color: "white"; font.pointSize: 10; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                                    Text { text: modelData.package; color: "#606070"; font.pointSize: 7; elide: Text.ElideRight; Layout.fillWidth: true }
                                }

                                Button {
                                    text: "✕"; width: 26; height: 26
                                    background: Rectangle { color: "#20ff3366"; radius: 5 }
                                    contentItem: Text { text: "✕"; color: "#ff3366"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pointSize: 9 }
                                    onClicked: controlManager.uninstall_android_app(modelData.package)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
