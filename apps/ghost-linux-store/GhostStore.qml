import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    width: 900
    height: 650
    color: "#0c0c12"

    property list<QtObject> storeItems
    property var searchItems: []
    property var installedApps: []
    property string activeTab: "discover"
    property string statusText: ""

    Connections {
        target: storeManager
        
        onSearchResults: {
            root.searchItems = JSON.parse(resultsJson);
            root.activeTab = "search";
        }
        
        onInstallProgress: {
            installerDrawer.open();
            installProgressText.text = message;
            installProgressBar.value = percent / 100.0;
        }

        onInstallFinished: {
            installerDrawer.close();
            root.statusText = message;
            statusPopup.open();
            storeManager.get_installed_apps();
        }

        onInstalledAppsUpdated: {
            root.installedApps = JSON.parse(installedJson);
        }
    }

    Component.onCompleted: {
        storeManager.get_installed_apps();
        // Load default curated search
        storeManager.search_apps(""); 
        root.activeTab = "discover";
    }

    // Main App Layout
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar Navigation
        Rectangle {
            Layout.preferredWidth: 200
            Layout.fillHeight: true
            color: "#14141e"
            border.color: "#15ffffff"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Text {
                    text: "Ghost-Linux Store"
                    font.family: "Outfit, sans-serif"
                    font.pointSize: 18
                    font.bold: true
                    color: "#00ffff"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                }

                // Nav Buttons
                Button {
                    id: btnDiscover
                    text: "Discover"
                    Layout.fillWidth: true
                    height: 40
                    background: Rectangle {
                        color: root.activeTab === "discover" ? "#20ffffff" : "transparent"
                        radius: 8
                    }
                    contentItem: Text { text: "  Discover"; color: root.activeTab === "discover" ? "#00ffff" : "white"; font.pointSize: 11; font.bold: true }
                    onClicked: { root.activeTab = "discover"; storeManager.search_apps("") }
                }

                Button {
                    id: btnSearch
                    text: "Search Results"
                    Layout.fillWidth: true
                    height: 40
                    background: Rectangle {
                        color: root.activeTab === "search" ? "#20ffffff" : "transparent"
                        radius: 8
                    }
                    contentItem: Text { text: "  Search List"; color: root.activeTab === "search" ? "#00ffff" : "white"; font.pointSize: 11; font.bold: true }
                    onClicked: root.activeTab = "search"
                }

                Button {
                    id: btnUpdates
                    text: "Updates"
                    Layout.fillWidth: true
                    height: 40
                    background: Rectangle {
                        color: root.activeTab === "updates" ? "#20ffffff" : "transparent"
                        radius: 8
                    }
                    contentItem: Text { text: "  Updates"; color: root.activeTab === "updates" ? "#00ffff" : "white"; font.pointSize: 11; font.bold: true }
                    onClicked: root.activeTab = "updates"
                }

                Item { Layout.fillHeight: true } // Spacer

                Text {
                    text: "Unified Package Engine v1.0"
                    color: "#606070"
                    font.pointSize: 8
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Main Content Panel
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.margins: 25
            spacing: 20

            // Search Bar at Top
            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                TextField {
                    id: txtSearch
                    placeholderText: "Search apps (e.g. steam, discord, vscode, docker...)"
                    Layout.fillWidth: true
                    height: 40
                    color: "white"
                    placeholderTextColor: "#70ffffff"
                    font.pointSize: 10
                    background: Rectangle {
                        color: txtSearch.activeFocus ? "#20ffffff" : "#12ffffff"
                        radius: 6
                        border.color: txtSearch.activeFocus ? "#00ffff" : "#15ffffff"
                        border.width: 1
                    }
                    onAccepted: storeManager.search_apps(txtSearch.text)
                }

                Button {
                    text: "Search"
                    background: Rectangle { color: "#00ffff"; radius: 6 }
                    contentItem: Text { text: "Search"; color: "black"; font.bold: true }
                    onClicked: storeManager.search_apps(txtSearch.text)
                }
            }

            // Tabs Loader / Swiper
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.activeTab === "discover" ? 0 : (root.activeTab === "search" ? 1 : 2)

                // 1. Discover Layout (Curated Carousel + App Cards)
                ScrollView {
                    clip: true
                    ColumnLayout {
                        width: parent.width - 15
                        spacing: 20

                        // Featured banner
                        Rectangle {
                            Layout.fillWidth: true
                            height: 140
                            radius: 12
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#0088ff" }
                                GradientStop { position: 1.0; color: "#e000ff" }
                            }
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                Text { text: "Featured Applications"; font.pointSize: 18; font.bold: true; color: "white" }
                                Text { text: "Get preconfigured, optimized developer and gaming suites in one-click."; color: "#e0ffffff"; font.pointSize: 10 }
                            }
                        }

                        Text { text: "Popular Apps"; color: "white"; font.pointSize: 14; font.bold: true }

                        // Curated grid mock items (loads automatically when empty search is performed)
                        GridView {
                            Layout.fillWidth: true
                            height: 300
                            cellWidth: 220
                            cellHeight: 140
                            model: root.searchItems
                            delegate: appCardDelegate
                        }
                    }
                }

                // 2. Search Results List
                ScrollView {
                    clip: true
                    ColumnLayout {
                        width: parent.width - 15
                        spacing: 15

                        Text {
                            text: "Search Results (" + root.searchItems.length + ")"
                            color: "white"
                            font.pointSize: 14
                            font.bold: true
                        }

                        ListView {
                            Layout.fillWidth: true
                            height: 400
                            spacing: 10
                            model: root.searchItems
                            delegate: appListDelegate
                        }
                    }
                }

                // 3. Updates Center
                ScrollView {
                    clip: true
                    ColumnLayout {
                        width: parent.width - 15
                        spacing: 15
                        Text { text: "System & Software Updates"; color: "white"; font.pointSize: 14; font.bold: true }
                        Text { text: "All repositories (Pacman, Flatpak, Snap) are synchronized and up-to-date."; color: "#a0a0b0"; font.pointSize: 10 }
                    }
                }
            }
        }
    }

    // App card delegate (used in Discover Grid)
    Component {
        id: appCardDelegate
        Rectangle {
            width: 200
            height: 120
            color: "#181824"
            radius: 8
            border.color: "#20ffffff"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: modelData.name; color: "white"; font.bold: true; font.pointSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                    
                    // Backend Badge Tag
                    Rectangle {
                        width: 55; height: 18; radius: 4
                        color: modelData.backend === "pacman" ? "#2000ff88" : (modelData.backend === "flatpak" ? "#200088ff" : "#20e000ff")
                        Text {
                            anchors.centerIn: parent
                            text: modelData.backend.toUpperCase()
                            color: modelData.backend === "pacman" ? "#00ff88" : (modelData.backend === "flatpak" ? "#0088ff" : "#e000ff")
                            font.pointSize: 8; font.bold: true
                        }
                    }
                }

                Text { text: modelData.description; color: "#a0a0b0"; font.pointSize: 8; Layout.fillWidth: true; maximumLineCount: 2; wrapMode: Text.WordWrap; elide: Text.ElideRight }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "★ " + modelData.rating.toFixed(1); color: "#ffaa00"; font.bold: true; font.pointSize: 9 }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: root.installedApps.includes(modelData.id) ? "Installed" : "Install"
                        enabled: !root.installedApps.includes(modelData.id)
                        background: Rectangle { color: enabled ? "#00ffff" : "#20ffffff"; radius: 4 }
                        contentItem: Text { text: parent.text; color: parent.enabled ? "black" : "#60ffffff"; font.pointSize: 8; font.bold: true }
                        onClicked: storeManager.install_app(modelData.backend, modelData.id)
                    }
                }
            }
        }
    }

    // App list delegate (used in Search ListView)
    Component {
        id: appListDelegate
        Rectangle {
            width: parent.width
            height: 80
            color: "#14141e"
            radius: 8
            border.color: "#15ffffff"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 15

                Rectangle {
                    width: 50; height: 50; radius: 6; color: "#20ffffff"
                    Text { text: modelData.name.charAt(0); anchors.centerIn: parent; color: "white"; font.pointSize: 16; font.bold: true }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    RowLayout {
                        Text { text: modelData.name; color: "white"; font.bold: true; font.pointSize: 12 }
                        Rectangle {
                            width: 50; height: 16; radius: 3
                            color: "#15ffffff"
                            Text { text: "v" + modelData.version; color: "#bbbbcc"; font.pointSize: 7; anchors.centerIn: parent }
                        }
                    }
                    Text { text: modelData.description; color: "#9090a0"; font.pointSize: 9; elide: Text.ElideRight; Layout.fillWidth: true }
                }

                ColumnLayout {
                    spacing: 5
                    // Rating
                    Text { text: "★ " + modelData.rating.toFixed(1); color: "#ffaa00"; font.bold: true; font.pointSize: 10; Layout.alignment: Qt.AlignRight }
                    
                    Button {
                        text: root.installedApps.includes(modelData.id) ? "Installed" : "Install"
                        enabled: !root.installedApps.includes(modelData.id)
                        background: Rectangle { color: parent.enabled ? "#00ffff" : "#20ffffff"; radius: 5 }
                        contentItem: Text { text: parent.text; color: parent.enabled ? "black" : "#70ffffff"; font.bold: true; font.pointSize: 9 }
                        onClicked: storeManager.install_app(modelData.backend, modelData.id)
                    }
                }
            }
        }
    }

    // Installer Drawer Drawer progress panel
    Drawer {
        id: installerDrawer
        width: parent.width
        height: 100
        edge: Qt.BottomEdge
        closePolicy: Popup.NoAutoClose
        interactive: false

        background: Rectangle {
            color: "#1a1a24"
            border.color: "#20ffffff"
            border.width: 1
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            ColumnLayout {
                Layout.fillWidth: true
                Text {
                    id: installProgressText
                    text: "Downloading packages..."
                    color: "white"
                    font.pointSize: 11
                }
                ProgressBar {
                    id: installProgressBar
                    Layout.fillWidth: true
                    height: 8
                    value: 0.0
                }
            }
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
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

            Text {
                text: "Store Task Completed"
                color: "#00ffff"
                font.bold: true
                font.pointSize: 11
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: root.statusText
                color: "white"
                font.pointSize: 9
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

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
