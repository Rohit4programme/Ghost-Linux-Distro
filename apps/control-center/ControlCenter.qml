import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    width: 900
    height: 650
    color: "#0c0c12"

    property string activeTab: "updates"
    property var updateList: []
    property var kernelData: ({})
    property var serviceList: []
    property var snapshotList: []
    property string statusText: ""

    Connections {
        target: controlManager
        
        onUpdatesChecked: {
            root.updateList = JSON.parse(updatesJson);
        }
        
        onKernelsUpdated: {
            root.kernelData = JSON.parse(kernelsJson);
        }
        
        onServicesUpdated: {
            root.serviceList = JSON.parse(servicesJson);
        }
        
        onSnapshotsUpdated: {
            root.snapshotList = JSON.parse(snapshotsJson);
        }
        
        onActionProgress: {
            actionProgressPopup.open();
            actionProgressLabel.text = message;
            actionProgressBar.value = percent / 100.0;
        }

        onActionFinished: {
            actionProgressPopup.close();
            root.statusText = message;
            statusPopup.open();
        }
    }

    Component.onCompleted: {
        controlManager.check_updates();
        controlManager.get_kernels();
        controlManager.get_services();
        controlManager.get_snapshots();
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar Navigation
        Rectangle {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            color: "#12121c"
            border.color: "#15ffffff"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Text {
                    text: "Control Center"
                    font.family: "Outfit"
                    font.pointSize: 16
                    font.bold: true
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 15
                }

                // Sidebar buttons
                Button {
                    id: btnUpdates
                    text: "System Updates"
                    Layout.fillWidth: true; height: 40
                    background: Rectangle { color: root.activeTab === "updates" ? "#2000ffff" : "transparent"; radius: 6 }
                    contentItem: Text { text: "  System Updates"; color: root.activeTab === "updates" ? "#00ffff" : "white"; font.pointSize: 10; font.bold: true }
                    onClicked: { root.activeTab = "updates"; controlManager.check_updates() }
                }

                Button {
                    id: btnKernels
                    text: "Kernels Manager"
                    Layout.fillWidth: true; height: 40
                    background: Rectangle { color: root.activeTab === "kernels" ? "#2000ffff" : "transparent"; radius: 6 }
                    contentItem: Text { text: "  Kernel Settings"; color: root.activeTab === "kernels" ? "#00ffff" : "white"; font.pointSize: 10; font.bold: true }
                    onClicked: { root.activeTab = "kernels"; controlManager.get_kernels() }
                }

                Button {
                    id: btnServices
                    text: "Services Manager"
                    Layout.fillWidth: true; height: 40
                    background: Rectangle { color: root.activeTab === "services" ? "#2000ffff" : "transparent"; radius: 6 }
                    contentItem: Text { text: "  System Services"; color: root.activeTab === "services" ? "#00ffff" : "white"; font.pointSize: 10; font.bold: true }
                    onClicked: { root.activeTab = "services"; controlManager.get_services() }
                }

                Button {
                    id: btnSnapshots
                    text: "Btrfs Recovery"
                    Layout.fillWidth: true; height: 40
                    background: Rectangle { color: root.activeTab === "snapshots" ? "#2000ffff" : "transparent"; radius: 6 }
                    contentItem: Text { text: "  Btrfs Snapshots"; color: root.activeTab === "snapshots" ? "#00ffff" : "white"; font.pointSize: 10; font.bold: true }
                    onClicked: { root.activeTab = "snapshots"; controlManager.get_snapshots() }
                }

                // ── Separator ─────────────────────────────────────
                Rectangle { Layout.fillWidth: true; height: 1; color: "#18ffffff" }
                Text { text: "  Security & Cloud"; color: "#505060"; font.pointSize: 8; font.bold: true }

                Button {
                    id: btnSecurity
                    text: "Security Center"
                    Layout.fillWidth: true; height: 40
                    background: Rectangle { color: root.activeTab === "security" ? "#2000ffff" : "transparent"; radius: 6 }
                    contentItem: Text { text: "  Security Center"; color: root.activeTab === "security" ? "#00ffff" : "white"; font.pointSize: 10; font.bold: true }
                    onClicked: { root.activeTab = "security" }
                }

                Button {
                    id: btnCloud
                    text: "Cloud Sync"
                    Layout.fillWidth: true; height: 40
                    background: Rectangle { color: root.activeTab === "cloud" ? "#2000ffff" : "transparent"; radius: 6 }
                    contentItem: Text { text: "  Cloud Sync"; color: root.activeTab === "cloud" ? "#00ffff" : "white"; font.pointSize: 10; font.bold: true }
                    onClicked: { root.activeTab = "cloud" }
                }

                Button {
                    id: btnWaydroid
                    text: "Android (Waydroid)"
                    Layout.fillWidth: true; height: 40
                    background: Rectangle { color: root.activeTab === "waydroid" ? "#20e000ff" : "transparent"; radius: 6 }
                    contentItem: Text { text: "  Android Apps"; color: root.activeTab === "waydroid" ? "#e000ff" : "white"; font.pointSize: 10; font.bold: true }
                    onClicked: { root.activeTab = "waydroid" }
                }

                Item { Layout.fillHeight: true }
            }
        }

        // Main Content Switcher
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.margins: 25
            currentIndex: root.activeTab === "updates"   ? 0 :
                          root.activeTab === "kernels"   ? 1 :
                          root.activeTab === "services"  ? 2 :
                          root.activeTab === "snapshots" ? 3 :
                          root.activeTab === "security"  ? 4 :
                          root.activeTab === "cloud"     ? 5 : 6

            // PAGE 0: Updates Panel
            ColumnLayout {
                spacing: 15
                Text { text: "Unified Update Center"; color: "white"; font.pointSize: 18; font.bold: true }
                Text { text: "Keep system kernel, graphics drivers, and desktop application repositories updated"; color: "#808090"; font.pointSize: 9 }
                
                Button {
                    text: "Synchronize & Apply System Upgrades"
                    Layout.preferredHeight: 40
                    background: Rectangle { color: "#00ffff"; radius: 6 }
                    contentItem: Text { text: "Synchronize & Apply System Upgrades"; color: "black"; font.bold: true }
                    onClicked: controlManager.trigger_upgrade()
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ListView {
                        id: updateList
                        width: parent.width - 15
                        spacing: 8
                        model: root.updateList
                        delegate: Rectangle {
                            width: parent.width; height: 60; color: "#14141e"; radius: 8; border.color: "#15ffffff"
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 12
                                ColumnLayout {
                                    Text { text: modelData.name; color: "white"; font.bold: true }
                                    Text { text: "Version change: " + modelData.old_version + " ➔ " + modelData.new_version; color: "#808090"; font.pointSize: 9 }
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    width: 80; height: 20; color: "#2000ffff"; radius: 4
                                    Text { anchors.centerIn: parent; text: modelData.type; color: "#00ffff"; font.pointSize: 8 }
                                }
                            }
                        }
                    }
                }
            }

            // PAGE 1: Kernels Manager
            ColumnLayout {
                spacing: 15
                Text { text: "Linux Kernel Manager"; color: "white"; font.pointSize: 18; font.bold: true }
                Text { text: "Boot and swap different versions of the Linux kernel optimized for security or gaming"; color: "#808090"; font.pointSize: 9 }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Currently Active: "; color: "white"; font.pointSize: 11 }
                    Text { text: root.kernelData.active || "Scanning..."; color: "#00ff88"; font.pointSize: 11; font.bold: true }
                }

                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ListView {
                        width: parent.width - 15
                        spacing: 10
                        model: root.kernelData.available
                        delegate: Rectangle {
                            width: parent.width; height: 70; color: "#14141e"; radius: 8; border.color: "#15ffffff"
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 15
                                ColumnLayout {
                                    Text { text: modelData; color: "white"; font.bold: true }
                                    Text { text: modelData === "linux-zen" ? "Recommended for Android & Gaming (Waydroid optimizations)" : "Standard Linux distribution builds"; color: "#808090"; font.pointSize: 9 }
                                }
                                Item { Layout.fillWidth: true }
                                Button {
                                    text: root.kernelData.installed.includes(modelData) ? "Boot Default" : "Install Kernel"
                                    background: Rectangle { color: root.kernelData.installed.includes(modelData) ? "#20ffffff" : "#00ffff"; radius: 6 }
                                    contentItem: Text { text: parent.text; color: root.kernelData.installed.includes(modelData) ? "white" : "black"; font.bold: true }
                                    onClicked: controlManager.change_kernel(modelData)
                                }
                            }
                        }
                    }
                }
            }

            // PAGE 2: Services controller
            ColumnLayout {
                spacing: 15
                Text { text: "Systemd Services Checklist"; color: "white"; font.pointSize: 18; font.bold: true }
                Text { text: "Control processes running in background without typing systemctl shell scripts"; color: "#808090"; font.pointSize: 9 }

                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ListView {
                        width: parent.width - 15
                        spacing: 8
                        model: root.serviceList
                        delegate: Rectangle {
                            width: parent.width; height: 60; color: "#14141e"; radius: 8; border.color: "#15ffffff"
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 15
                                RowLayout {
                                    spacing: 8
                                    Rectangle { width: 10; height: 10; radius: 5; color: modelData.active ? "#00ff88" : "#ff3366" }
                                    Text { text: modelData.name + ".service"; color: "white"; font.bold: true }
                                }
                                Item { Layout.fillWidth: true }
                                Switch {
                                    checked: modelData.active
                                    onToggled: controlManager.toggle_service(modelData.name, checked)
                                }
                            }
                        }
                    }
                }
            }

            // PAGE 3: Snapshots/Recovery
            ColumnLayout {
                spacing: 15
                Text { text: "Btrfs Snapshots & Timeshift Backups"; color: "white"; font.pointSize: 18; font.bold: true }
                Text { text: "Create rollbacks to easily undo package failures or configure scheduled backups"; color: "#808090"; font.pointSize: 9 }

                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true
                    TextField {
                        id: txtComment
                        placeholderText: "Snapshot description comment..."
                        Layout.fillWidth: true
                        height: 40
                        color: "white"
                        background: Rectangle { color: "#15ffffff"; radius: 6; border.color: "#20ffffff" }
                    }
                    Button {
                        text: "Create Snapshot"
                        background: Rectangle { color: "#00ffff"; radius: 6 }
                        contentItem: Text { text: "Create Backup"; color: "black"; font.bold: true }
                        onClicked: {
                            controlManager.create_snapshot(txtComment.text)
                            txtComment.text = ""
                        }
                    }
                }

                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ListView {
                        width: parent.width - 15
                        spacing: 8
                        model: root.snapshotList
                        delegate: Rectangle {
                            width: parent.width; height: 60; color: "#14141e"; radius: 8; border.color: "#15ffffff"
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 12
                                ColumnLayout {
                                    Text { text: "Snapshot: " + modelData.name; color: "white"; font.bold: true }
                                    Text { text: "Device: " + modelData.device + " | Tag: " + modelData.tags; color: "#808090"; font.pointSize: 9 }
                                }
                                Item { Layout.fillWidth: true }
                                Button {
                                    text: "Rollback"
                                    background: Rectangle { color: "#ff3366"; radius: 6 }
                                    contentItem: Text { text: "Rollback"; color: "white"; font.bold: true }
                                }
                            }
                        }
                    }
                }
            }
            // PAGE 4: Security Center ─ loaded from SecurityCenter.qml
            Item {
                Loader {
                    anchors.fill: parent
                    source: root.activeTab === "security" ? "SecurityCenter.qml" : ""
                    asynchronous: true
                }
            }

            // PAGE 5: Cloud Sync ─ loaded from CloudSync.qml
            Item {
                Loader {
                    anchors.fill: parent
                    source: root.activeTab === "cloud" ? "CloudSync.qml" : ""
                    asynchronous: true
                }
            }

            // PAGE 6: Waydroid Android Subsystem ─ loaded from WaydroidPanel.qml
            Item {
                Loader {
                    anchors.fill: parent
                    source: root.activeTab === "waydroid" ? "WaydroidPanel.qml" : ""
                    asynchronous: true
                }
            }
        }
    }

    // Progress Dialog overlay
    Popup {
        id: actionProgressPopup
        width: 300
        height: 120
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle { color: "#1c1c28"; radius: 10; border.color: "#30ffffff" }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 10
            Text { id: actionProgressLabel; text: "Working..."; color: "white"; Layout.alignment: Qt.AlignHCenter }
            ProgressBar { id: actionProgressBar; Layout.fillWidth: true; height: 8; value: 0.0 }
        }
    }

    // Status Notification Popup
    Popup {
        id: statusPopup
        width: 320
        height: 130
        anchors.centerIn: parent
        modal: true
        background: Rectangle { color: "#1c1c28"; radius: 10; border.color: "#30ffffff" }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 12
            Text { text: "Task Finished"; color: "#00ffff"; font.bold: true; Layout.alignment: Qt.AlignHCenter }
            Text { text: root.statusText; color: "white"; font.pointSize: 9; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
            Button {
                text: "Dismiss"
                Layout.alignment: Qt.AlignHCenter
                background: Rectangle { color: "#25ffffff"; radius: 6 }
                contentItem: Text { text: "Dismiss"; color: "white" }
                onClicked: statusPopup.close()
            }
        }
    }
}
