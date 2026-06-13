import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3

Item {
    id: cloudPage
    anchors.fill: parent

    property var remotes: []
    property string syncLog: ""
    property string selectedRemote: ""
    property string localSyncPath: "~/CloudSync"

    Connections {
        target: controlManager
        onRemotesUpdated: { cloudPage.remotes = JSON.parse(remotesJson) }
        onSyncLogUpdated: { cloudPage.syncLog += line }
        onActionFinished: { if (!success) cloudPage.syncLog += "[ERROR] " + message + "\n" }
    }

    Component.onCompleted: controlManager.get_rclone_remotes()

    // ── Add Remote Helper Dialog ─────────────────────────────────────────
    Dialog {
        id: addRemoteDialog
        title: "Connect Cloud Storage"
        anchors.centerIn: parent
        width: 360; height: 260
        modal: true
        background: Rectangle { color: "#1c1c28"; radius: 12; border.color: "#30ffffff" }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 12

            Text { text: "Cloud Provider"; color: "#a0a0b0"; font.pointSize: 9 }
            ComboBox {
                id: providerBox
                model: ["Google Drive", "Microsoft OneDrive", "Dropbox", "Nextcloud", "Amazon S3", "SFTP / SSH"]
                Layout.fillWidth: true; height: 38
                background: Rectangle { color: "#20ffffff"; radius: 6 }
                contentItem: Text { text: providerBox.displayText; color: "white"; font.pointSize: 10; verticalAlignment: Text.AlignVCenter; leftPadding: 8 }
            }

            Text { text: "Remote Name (no spaces)"; color: "#a0a0b0"; font.pointSize: 9 }
            TextField {
                id: remoteName; placeholderText: "e.g. gdrive, mynas"
                Layout.fillWidth: true; height: 38; color: "white"
                placeholderTextColor: "#50ffffff"; font.pointSize: 10
                background: Rectangle { color: "#20ffffff"; radius: 6 }
            }

            Text {
                text: "Note: A browser authentication window will open to authorize your cloud storage account."
                color: "#606070"; font.pointSize: 8; wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Cancel"; Layout.fillWidth: true
                    background: Rectangle { color: "#20ffffff"; radius: 6 }
                    contentItem: Text { text: "Cancel"; color: "white"; horizontalAlignment: Text.AlignHCenter }
                    onClicked: addRemoteDialog.close()
                }
                Button {
                    text: "Connect"
                    Layout.fillWidth: true
                    background: Rectangle { color: "#00ffff"; radius: 6 }
                    contentItem: Text { text: "Connect"; color: "black"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                    onClicked: {
                        // rclone config create <name> <type> — opens browser OAuth
                        var typeMap = {
                            "Google Drive": "drive",
                            "Microsoft OneDrive": "onedrive",
                            "Dropbox": "dropbox",
                            "Nextcloud": "webdav",
                            "Amazon S3": "s3",
                            "SFTP / SSH": "sftp"
                        }
                        addRemoteDialog.close()
                    }
                }
            }
        }
    }

    ScrollView {
        anchors.fill: parent; clip: true

        ColumnLayout {
            width: parent.width - 10
            spacing: 18

            // ── Header ───────────────────────────────────────────────────
            Text { text: "Cloud Synchronization"; color: "white"; font.family: "Outfit"; font.pointSize: 18; font.bold: true }
            Text { text: "Sync your files across Google Drive, OneDrive, Dropbox, and more via rclone"; color: "#808090"; font.pointSize: 9 }

            // ── Provider Cards Row ────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true; spacing: 12

                Repeater {
                    model: [
                        { name: "Google Drive",  icon: "☁",  color: "#0088ff" },
                        { name: "OneDrive",      icon: "📦",  color: "#0078d4" },
                        { name: "Dropbox",       icon: "🗂",  color: "#0061ff" },
                        { name: "Nextcloud",     icon: "🔒",  color: "#00a2e8" },
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 72
                        color: "#14141e"; radius: 10; border.color: "#18ffffff"
                        ColumnLayout {
                            anchors.centerIn: parent; spacing: 4
                            Text { text: modelData.icon; font.pointSize: 20; Layout.alignment: Qt.AlignHCenter }
                            Text { text: modelData.name; color: "white"; font.pointSize: 9; Layout.alignment: Qt.AlignHCenter }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: addRemoteDialog.open()
                        }
                    }
                }
            }

            // ── Connected Remotes Table ───────────────────────────────────
            Rectangle {
                Layout.fillWidth: true; color: "#10101b"; radius: 12; border.color: "#20ffffff"
                height: remotesCol.implicitHeight + 30

                ColumnLayout {
                    id: remotesCol
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 15 }
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Connected Remotes"; color: "white"; font.bold: true; font.pointSize: 13; Layout.fillWidth: true }
                        Button {
                            text: "+ Connect New"
                            background: Rectangle { color: "#00ffff"; radius: 6 }
                            contentItem: Text { text: "+ Connect New"; color: "black"; font.bold: true }
                            onClicked: addRemoteDialog.open()
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#20ffffff" }

                    Column {
                        Layout.fillWidth: true; spacing: 8

                        Repeater {
                            model: cloudPage.remotes
                            delegate: Rectangle {
                                width: parent.width; height: 70; color: "#14141e"; radius: 8; border.color: "#18ffffff"
                                border.color: cloudPage.selectedRemote === modelData.name ? "#00ffff" : "#18ffffff"

                                RowLayout {
                                    anchors { fill: parent; margins: 12 }; spacing: 14

                                    // Cloud icon circle
                                    Rectangle {
                                        width: 44; height: 44; radius: 22
                                        color: "#2000ffff"
                                        Text { text: "☁"; font.pointSize: 18; color: "#00ffff"; anchors.centerIn: parent }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true; spacing: 2
                                        Text { text: modelData.name; color: "white"; font.bold: true; font.pointSize: 12 }
                                        Text { text: modelData.type + "  |  " + modelData.path; color: "#808090"; font.pointSize: 9 }
                                        Text { text: "Last sync: " + modelData.last_sync; color: "#505060"; font.pointSize: 8 }
                                    }

                                    ColumnLayout {
                                        spacing: 6
                                        Button {
                                            text: cloudPage.selectedRemote === modelData.name ? "Syncing..." : "Sync Now"
                                            enabled: cloudPage.selectedRemote !== modelData.name
                                            background: Rectangle { color: parent.enabled ? "#00ff88" : "#20ffffff"; radius: 6 }
                                            contentItem: Text {
                                                text: parent.text; color: parent.parent.enabled ? "black" : "white"
                                                font.bold: true; font.pointSize: 9; horizontalAlignment: Text.AlignHCenter
                                            }
                                            onClicked: {
                                                cloudPage.selectedRemote = modelData.name
                                                cloudPage.syncLog = ""
                                                controlManager.sync_remote(modelData.name, cloudPage.localSyncPath + "/" + modelData.name)
                                            }
                                        }
                                        Button {
                                            text: "Remove"
                                            background: Rectangle { color: "#20ff3366"; radius: 6 }
                                            contentItem: Text { text: "Remove"; color: "#ff3366"; font.pointSize: 9; horizontalAlignment: Text.AlignHCenter }
                                            onClicked: controlManager.delete_remote(modelData.name)
                                        }
                                    }
                                }
                            }
                        }

                        // Empty state
                        Text {
                            visible: cloudPage.remotes.length === 0
                            text: "No cloud remotes configured. Click '+ Connect New' to add one."
                            color: "#505060"; font.pointSize: 10
                            Layout.alignment: Qt.AlignHCenter; horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            // ── Sync Console Log ──────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true; height: 140; color: "#080810"; radius: 10; border.color: "#18ffffff"

                ColumnLayout {
                    anchors { fill: parent; margins: 12 }; spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Sync Console"; color: "#60ff80"; font.family: "monospace"; font.pointSize: 9; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Button {
                            text: "Clear"
                            background: null
                            contentItem: Text { text: "Clear"; color: "#404050"; font.pointSize: 8 }
                            onClicked: cloudPage.syncLog = ""
                        }
                    }

                    ScrollView {
                        Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                        TextArea {
                            text: cloudPage.syncLog || "Sync output will appear here..."
                            color: cloudPage.syncLog ? "#00ff88" : "#303040"
                            font.family: "monospace"; font.pointSize: 9
                            readOnly: true; wrapMode: Text.WordWrap; background: null
                        }
                    }
                }
            }
        }
    }
}
