import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Item {
    id: securityPage
    anchors.fill: parent

    property var firewallData: ({enabled: false, default_incoming: "deny", default_outgoing: "allow", rules: []})
    property var flatpakApps:  []
    property string selectedApp: ""
    property var selectedPerms: ({})

    Connections {
        target: controlManager
        onFirewallStatusUpdated: { securityPage.firewallData = JSON.parse(statusJson) }
        onFlatpakAppsUpdated:    { securityPage.flatpakApps  = JSON.parse(appsJson)   }
        onFlatpakPermsUpdated:   {
            if (appId === securityPage.selectedApp)
                securityPage.selectedPerms = JSON.parse(permsJson)
        }
    }

    Component.onCompleted: {
        controlManager.get_firewall_status()
        controlManager.get_flatpak_apps()
    }

    // ── Add Rule Dialog ──────────────────────────────────────────────────
    Dialog {
        id: addRuleDialog
        title: "Add Firewall Rule"
        anchors.centerIn: parent
        width: 340; height: 220
        modal: true

        background: Rectangle { color: "#1c1c28"; radius: 12; border.color: "#30ffffff" }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 12

            RowLayout {
                spacing: 8; Layout.fillWidth: true
                TextField {
                    id: rulePort; placeholderText: "Port (e.g. 8080)"
                    Layout.fillWidth: true; height: 38; color: "white"
                    placeholderTextColor: "#60ffffff"; font.pointSize: 10
                    background: Rectangle { color: "#20ffffff"; radius: 6 }
                }
                ComboBox {
                    id: ruleProto; model: ["tcp","udp","any"]
                    implicitWidth: 80; height: 38
                    background: Rectangle { color: "#20ffffff"; radius: 6 }
                    contentItem: Text { text: ruleProto.displayText; color: "white"; font.pointSize: 10; verticalAlignment: Text.AlignVCenter; leftPadding: 8 }
                }
            }
            ComboBox {
                id: ruleAction; model: ["ALLOW","DENY"]
                Layout.fillWidth: true; height: 38
                background: Rectangle { color: "#20ffffff"; radius: 6 }
                contentItem: Text { text: ruleAction.displayText; color: "white"; font.pointSize: 10; verticalAlignment: Text.AlignVCenter; leftPadding: 8 }
            }
            TextField {
                id: ruleDesc; placeholderText: "Description (optional)"
                Layout.fillWidth: true; height: 38; color: "white"
                placeholderTextColor: "#60ffffff"; font.pointSize: 10
                background: Rectangle { color: "#20ffffff"; radius: 6 }
            }
            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Cancel"; Layout.fillWidth: true
                    background: Rectangle { color: "#20ffffff"; radius: 6 }
                    contentItem: Text { text: "Cancel"; color: "white"; horizontalAlignment: Text.AlignHCenter }
                    onClicked: addRuleDialog.close()
                }
                Button {
                    text: "Add Rule"; Layout.fillWidth: true
                    background: Rectangle { color: "#00ffff"; radius: 6 }
                    contentItem: Text { text: "Add Rule"; color: "black"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                    onClicked: {
                        controlManager.add_firewall_rule(rulePort.text, ruleProto.currentText, ruleAction.currentText, ruleDesc.text)
                        addRuleDialog.close()
                    }
                }
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: parent.width - 10
            spacing: 18

            // ── Header ───────────────────────────────────────────────────
            Text { text: "Security Center"; color: "white"; font.family: "Outfit"; font.pointSize: 18; font.bold: true }
            Text { text: "Manage UFW firewall rules and Flatpak application sandbox permissions"; color: "#808090"; font.pointSize: 9 }

            // ── Firewall Card ─────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true; color: "#10101b"; radius: 12; border.color: "#20ffffff"
                height: fwCol.implicitHeight + 30

                ColumnLayout {
                    id: fwCol
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 15 }
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Text { text: "UFW Firewall"; color: "white"; font.bold: true; font.pointSize: 13 }
                            Text {
                                text: "Default: incoming " + securityPage.firewallData.default_incoming.toUpperCase()
                                    + " / outgoing " + securityPage.firewallData.default_outgoing.toUpperCase()
                                color: "#9090a0"; font.pointSize: 9
                            }
                        }
                        Item { Layout.fillWidth: true }
                        // Status chip
                        Rectangle {
                            width: 90; height: 28; radius: 14
                            color: securityPage.firewallData.enabled ? "#2000ff88" : "#20ff3366"
                            border.color: securityPage.firewallData.enabled ? "#00ff88" : "#ff3366"
                            Text {
                                anchors.centerIn: parent
                                text: securityPage.firewallData.enabled ? "ACTIVE" : "INACTIVE"
                                color: securityPage.firewallData.enabled ? "#00ff88" : "#ff3366"
                                font.bold: true; font.pointSize: 8
                            }
                        }
                        Switch {
                            id: fwSwitch
                            checked: securityPage.firewallData.enabled
                            onToggled: controlManager.toggle_ufw(checked)
                        }
                    }

                    // Rules table header
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#20ffffff" }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Active Rules"; color: "white"; font.bold: true; font.pointSize: 11; Layout.fillWidth: true }
                        Button {
                            text: "+ Add Rule"
                            background: Rectangle { color: "#00ffff"; radius: 6 }
                            contentItem: Text { text: "+ Add Rule"; color: "black"; font.bold: true }
                            onClicked: addRuleDialog.open()
                        }
                    }

                    // Rules list
                    Column {
                        Layout.fillWidth: true
                        spacing: 6
                        Repeater {
                            model: securityPage.firewallData.rules || []
                            delegate: Rectangle {
                                width: parent.width; height: 48; color: "#14141e"; radius: 8; border.color: "#18ffffff"
                                RowLayout {
                                    anchors { fill: parent; margins: 12 }
                                    // Colored action badge
                                    Rectangle {
                                        width: 54; height: 22; radius: 4
                                        color: modelData.action === "ALLOW" ? "#2000ff88" : "#20ff3366"
                                        border.color: modelData.action === "ALLOW" ? "#00ff88" : "#ff3366"
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.action
                                            color: modelData.action === "ALLOW" ? "#00ff88" : "#ff3366"
                                            font.bold: true; font.pointSize: 8
                                        }
                                    }
                                    Text { text: modelData.port + "/" + modelData.proto; color: "white"; font.bold: true }
                                    Text { text: modelData.desc; color: "#9090a0"; font.pointSize: 9; Layout.fillWidth: true }
                                    Button {
                                        text: "✕"; width: 28; height: 28
                                        background: Rectangle { color: "#20ff3366"; radius: 6 }
                                        contentItem: Text { text: "✕"; color: "#ff3366"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                        onClicked: controlManager.delete_firewall_rule(modelData.port, modelData.proto)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Flatpak Sandbox Permissions Card ─────────────────────────
            Rectangle {
                Layout.fillWidth: true; color: "#10101b"; radius: 12; border.color: "#20ffffff"
                height: sandboxCol.implicitHeight + 30

                ColumnLayout {
                    id: sandboxCol
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 15 }
                    spacing: 12

                    Text { text: "Flatpak Sandbox Permissions"; color: "white"; font.bold: true; font.pointSize: 13 }
                    Text { text: "Revoke or grant network, filesystem, and device access per application"; color: "#9090a0"; font.pointSize: 9 }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#20ffffff" }

                    // Two-column layout: app list + permissions panel
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        // App list
                        Rectangle {
                            width: 210; height: 260; color: "#0c0c16"; radius: 8; border.color: "#18ffffff"
                            ListView {
                                anchors { fill: parent; margins: 6 }
                                clip: true; spacing: 4
                                model: securityPage.flatpakApps
                                delegate: Rectangle {
                                    width: parent.width; height: 38; radius: 6
                                    color: securityPage.selectedApp === modelData.id ? "#2000ffff" : "transparent"
                                    border.color: securityPage.selectedApp === modelData.id ? "#00ffff" : "transparent"
                                    ColumnLayout {
                                        anchors { fill: parent; margins: 6 }; spacing: 1
                                        Text { text: modelData.name; color: "white"; font.pointSize: 10; font.bold: true; elide: Text.ElideRight }
                                        Text { text: modelData.id; color: "#707080"; font.pointSize: 7; elide: Text.ElideRight }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            securityPage.selectedApp = modelData.id
                                            controlManager.get_sandbox_permissions(modelData.id)
                                        }
                                    }
                                }
                            }
                        }

                        // Permissions panel
                        Rectangle {
                            Layout.fillWidth: true; height: 260; color: "#0c0c16"; radius: 8; border.color: "#18ffffff"
                            ColumnLayout {
                                anchors { fill: parent; margins: 12 }; spacing: 10
                                Text {
                                    text: securityPage.selectedApp || "Select an app to view permissions"
                                    color: securityPage.selectedApp ? "#00ffff" : "#606070"
                                    font.pointSize: 10; font.bold: true; wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                // Permission toggles
                                Repeater {
                                    model: [
                                        {key: "network",    label: "Network Access",         icon: "🌐"},
                                        {key: "filesystem", label: "Home Folder Access",      icon: "📁"},
                                        {key: "ipc",        label: "Inter-Process Comms",     icon: "🔗"},
                                        {key: "dri",        label: "GPU / Hardware Render",   icon: "🎮"},
                                    ]
                                    delegate: RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: modelData.icon; font.pointSize: 14 }
                                        ColumnLayout {
                                            Layout.fillWidth: true; spacing: 0
                                            Text { text: modelData.label; color: "white"; font.pointSize: 10 }
                                        }
                                        Switch {
                                            checked: !!securityPage.selectedPerms[modelData.key]
                                            enabled: securityPage.selectedApp !== ""
                                            onToggled: controlManager.set_sandbox_permission(securityPage.selectedApp, modelData.key, checked)
                                        }
                                    }
                                }
                                Item { Layout.fillHeight: true }
                            }
                        }
                    }
                }
            }
        }
    }
}
