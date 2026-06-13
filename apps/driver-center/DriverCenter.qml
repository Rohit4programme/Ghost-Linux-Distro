import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    width: 800
    height: 600
    color: "#0f0f15"

    // Property storage for detected hardware
    property var devices: ({})
    property string logText: "No diagnostic runs completed."

    // Connections to backend signals
    Connections {
        target: driverManager
        
        onHardwareDetected: {
            root.devices = JSON.parse(hardwareJson);
        }
        onInstallProgress: {
            progressPopup.open();
            progressLabel.text = message;
            progressBar.value = percent / 100.0;
        }
        onInstallFinished: {
            progressPopup.close();
            statusPopup.statusMessage = message;
            statusPopup.statusSuccess = success;
            statusPopup.open();
            driverManager.detect_hardware(); // Refresh status
        }
        onDiagnosticResult: {
            root.logText = results;
        }
    }

    Component.onCompleted: {
        driverManager.detect_hardware();
    }

    // Main Layout Grid
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Header Panel
        RowLayout {
            Layout.fillWidth: true
            
            ColumnLayout {
                Text {
                    text: "Ghost-Linux Driver Center"
                    font.family: "Outfit, sans-serif"
                    font.pointSize: 20
                    font.bold: true
                    color: "#ffffff"
                }
                Text {
                    text: "Zero-terminal device management and health monitor"
                    font.family: "Outfit, sans-serif"
                    font.pointSize: 10
                    color: "#a0a0b0"
                }
            }
            
            Item { Layout.fillWidth: true }
            
            Button {
                id: btnRefresh
                text: "Scan Hardware"
                background: Rectangle {
                    color: btnRefresh.hovered ? "#25ffffff" : "#12ffffff"
                    radius: 6
                    border.color: "#30ffffff"
                }
                contentItem: Text { text: btnRefresh.text; color: "white"; font.pointSize: 10 }
                onClicked: driverManager.detect_hardware()
            }
        }

        // Main Hardware Panels
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width - 20
                spacing: 15

                // GPU Card
                Rectangle {
                    Layout.fillWidth: true
                    height: 120
                    color: "#181824"
                    radius: 10
                    border.color: "#20ffffff"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20

                        Rectangle {
                            width: 60
                            height: 60
                            radius: 30
                            color: "#2500ffff"
                            Text {
                                text: "GPU"
                                color: "#00ffff"
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Text {
                                text: root.devices.gpu ? (root.devices.gpu.vendor + " " + root.devices.gpu.device) : "Scanning GPU..."
                                font.pointSize: 13
                                font.bold: true
                                color: "#ffffff"
                            }
                            Text {
                                text: root.devices.gpu ? ("Driver Recommendation: " + root.devices.gpu.recommended_driver) : ""
                                color: "#a0a0b0"
                                font.pointSize: 9
                            }
                            Text {
                                text: root.devices.gpu ? ("Status: " + root.devices.gpu.status) : ""
                                color: (root.devices.gpu && root.devices.gpu.status === "Not Installed") ? "#ff3366" : "#00ff88"
                                font.pointSize: 9
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            spacing: 8
                            Button {
                                text: "Install Driver"
                                visible: root.devices.gpu ? (root.devices.gpu.status === "Not Installed") : false
                                background: Rectangle { color: "#a000ffff"; radius: 6 }
                                contentItem: Text { text: "Install Driver"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                                onClicked: driverManager.install_driver(root.devices.gpu.recommended_driver)
                            }
                            Button {
                                text: "Rollback"
                                visible: root.devices.gpu ? (root.devices.gpu.status !== "Not Installed") : false
                                background: Rectangle { color: "#25ffffff"; radius: 6; border.color: "#30ffffff" }
                                contentItem: Text { text: "Rollback"; color: "white"; horizontalAlignment: Text.AlignHCenter }
                                onClicked: driverManager.rollback_driver(root.devices.gpu.recommended_driver)
                            }
                        }
                    }
                }

                // WiFi & Bluetooth Card
                Rectangle {
                    Layout.fillWidth: true
                    height: 120
                    color: "#181824"
                    radius: 10
                    border.color: "#20ffffff"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20

                        Rectangle {
                            width: 60
                            height: 60
                            radius: 30
                            color: "#25e000ff"
                            Text {
                                text: "NET"
                                color: "#e000ff"
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Network & Bluetooth Interfaces"
                                font.pointSize: 13
                                font.bold: true
                                color: "#ffffff"
                            }
                            Text {
                                text: root.devices.wifi ? ("Wi-Fi Driver: " + root.devices.wifi.recommended_driver + " (" + root.devices.wifi.status + ")") : "Scanning Network..."
                                color: "#a0a0b0"
                                font.pointSize: 9
                            }
                            Text {
                                text: root.devices.bluetooth ? ("Bluetooth System: " + root.devices.bluetooth.status) : ""
                                color: "#a0a0b0"
                                font.pointSize: 9
                            }
                        }

                        ColumnLayout {
                            spacing: 8
                            Button {
                                text: "Update Driver"
                                visible: root.devices.wifi ? (root.devices.wifi.status === "Not Installed") : false
                                background: Rectangle { color: "#a0e000ff"; radius: 6 }
                                contentItem: Text { text: "Update Driver"; color: "white"; font.bold: true }
                                onClicked: driverManager.install_driver(root.devices.wifi.recommended_driver)
                            }
                        }
                    }
                }

                // Diagnostics Panel
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    color: "#12121c"
                    radius: 10
                    border.color: "#20ffffff"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Hardware & Driver Health Diagnostics"
                                font.pointSize: 11
                                font.bold: true
                                color: "#ffffff"
                            }
                            Item { Layout.fillWidth: true }
                            Button {
                                text: "Run Diagnostics"
                                background: Rectangle { color: "#1888ff"; radius: 6 }
                                contentItem: Text { text: "Run Diagnostics"; color: "white"; font.bold: true }
                                onClicked: driverManager.run_diagnostics()
                            }
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            TextArea {
                                text: root.logText
                                color: "#bbbbcc"
                                font.family: "monospace"
                                font.pointSize: 9
                                readOnly: true
                                wrapMode: Text.WordWrap
                                background: null
                            }
                        }
                    }
                }
            }
        }
    }

    // Modal Progress Overlay
    Popup {
        id: progressPopup
        width: 300
        height: 120
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            color: "#1c1c28"
            radius: 12
            border.color: "#30ffffff"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12
            
            Text {
                id: progressLabel
                text: "Installing driver..."
                color: "#ffffff"
                font.pointSize: 10
                Layout.alignment: Qt.AlignHCenter
            }

            ProgressBar {
                id: progressBar
                Layout.fillWidth: true
                height: 8
                value: 0.0
            }
        }
    }

    // Install Finished Notification Overlay
    Popup {
        id: statusPopup
        property string statusMessage: ""
        property bool statusSuccess: true

        width: 320
        height: 150
        anchors.centerIn: parent
        modal: true

        background: Rectangle {
            color: "#1c1c28"
            radius: 12
            border.color: "#30ffffff"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            Text {
                text: statusPopup.statusSuccess ? "Driver Task Succeeded" : "Driver Task Failed"
                color: statusPopup.statusSuccess ? "#00ff88" : "#ff3366"
                font.bold: true
                font.pointSize: 11
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: statusPopup.statusMessage
                color: "#ffffff"
                font.pointSize: 9
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Button {
                text: "OK"
                Layout.alignment: Qt.AlignHCenter
                background: Rectangle { color: "#25ffffff"; radius: 6 }
                contentItem: Text { text: "OK"; color: "white" }
                onClicked: statusPopup.close()
            }
        }
    }
}
