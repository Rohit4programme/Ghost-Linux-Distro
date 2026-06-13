import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    width: 1000
    height: 700
    color: "#0f0f15"

    property var tools: ({})
    property string selectedCategory: "Information Gathering"
    property string logText: "No operations performed yet."

    Connections {
        target: securityManager
        
        onToolDetected: {
            root.tools = JSON.parse(toolsJson);
        }
        onScanProgress: {
            progressPopup.open();
            progressLabel.text = message;
            progressBar.value = percent / 100.0;
        }
        onScanFinished: {
            progressPopup.close();
            statusPopup.statusMessage = message;
            statusPopup.statusSuccess = success;
            statusPopup.open();
        }
        onToolResult: {
            root.logText = result;
        }
    }

    Component.onCompleted: {
        securityManager.detect_tools();
    }

    // Main Layout
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Header
        RowLayout {
            Layout.fillWidth: true
            
            ColumnLayout {
                Text {
                    text: "Ghost-Linux Security Center"
                    font.family: "Outfit, sans-serif"
                    font.pointSize: 22
                    font.bold: true
                    color: "#ffffff"
                }
                Text {
                    text: "Comprehensive Kali Linux Security Tools Management"
                    font.family: "Outfit, sans-serif"
                    font.pointSize: 11
                    color: "#a0a0b0"
                }
            }
            
            Item { Layout.fillWidth: true }
            
            Button {
                id: btnRefresh
                text: "Scan Tools"
                background: Rectangle {
                    color: btnRefresh.hovered ? "#25ffffff" : "#12ffffff"
                    radius: 6
                    border.color: "#30ffffff"
                }
                contentItem: Text { text: btnRefresh.text; color: "white"; font.pointSize: 10 }
                onClicked: securityManager.detect_tools()
            }
        }

        // Category Tabs
        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            
            Repeater {
                model: ["Information Gathering", "Vulnerability Analysis", "Web Application Analysis", 
                        "Password Attacks", "Wireless Attacks", "Exploitation Tools", "Sniffing & Spoofing",
                        "Post-Exploitation", "Forensics", "Reverse Engineering", "Reporting Tools",
                        "Hardware Hacking", "Network Analysis", "Cryptography"]
                
                Button {
                    text: modelData
                    Layout.preferredWidth: 180
                    height: 35
                    background: Rectangle {
                        color: root.selectedCategory === modelData ? "#00ffff" : "#12ffffff"
                        radius: 6
                    }
                    contentItem: Text { 
                        text: parent.text; 
                        color: root.selectedCategory === modelData ? "black" : "white"; 
                        font.pointSize: 8; 
                        font.bold: true;
                        elide: Text.ElideRight
                    }
                    onClicked: root.selectedCategory = modelData
                }
            }
        }

        // Tools Grid
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            GridView {
                id: toolsGrid
                width: parent.width - 20
                cellWidth: 280
                cellHeight: 100
                model: root.tools[root.selectedCategory] || []
                delegate: toolCardDelegate
            }
        }

        // Log Panel
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: "#12121c"
            radius: 10
            border.color: "#20ffffff"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15

                Text {
                    text: "Operation Log"
                    color: "#ffffff"
                    font.pointSize: 10
                    font.bold: true
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    TextArea {
                        text: root.logText
                        color: "#bbbbcc"
                        font.family: "monospace"
                        font.pointSize: 8
                        readOnly: true
                        wrapMode: Text.WordWrap
                        background: null
                    }
                }
            }
        }
    }

    // Tool Card Delegate
    Component {
        id: toolCardDelegate
        Rectangle {
            width: 260
            height: 90
            color: modelData.installed ? "#1a1a24" : "#0a0a10"
            radius: 8
            border.color: modelData.installed ? "#00ff88" : "#ff3366"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Text { 
                        text: modelData.name; 
                        color: "white"; 
                        font.bold: true; 
                        font.pointSize: 11; 
                        Layout.fillWidth: true 
                    }
                    
                    Rectangle {
                        width: 60; height: 18; radius: 4
                        color: modelData.installed ? "#2000ff88" : "#20ff3366"
                        Text {
                            anchors.centerIn: parent
                            text: modelData.installed ? "Installed" : "Missing"
                            color: modelData.installed ? "#00ff88" : "#ff3366"
                            font.pointSize: 7; font.bold: true
                        }
                    }
                }

                RowLayout {
                    spacing: 8
                    Button {
                        text: "Launch"
                        enabled: modelData.installed
                        background: Rectangle { color: enabled ? "#00ffff" : "#20ffffff"; radius: 4 }
                        contentItem: Text { text: "Launch"; color: enabled ? "black" : "#60ffffff"; font.pointSize: 8; font.bold: true }
                        onClicked: securityManager.run_tool(modelData.name)
                    }
                    Button {
                        text: "Install"
                        enabled: !modelData.installed
                        background: Rectangle { color: enabled ? "#e000ff" : "#20ffffff"; radius: 4 }
                        contentItem: Text { text: "Install"; color: enabled ? "white" : "#60ffffff"; font.pointSize: 8; font.bold: true }
                        onClicked: securityManager.install_tool(modelData.name)
                    }
                    Button {
                        text: "Info"
                        background: Rectangle { color: "#25ffffff"; radius: 4; border.color: "#30ffffff" }
                        contentItem: Text { text: "Info"; color: "white"; font.pointSize: 8 }
                        onClicked: securityManager.get_tool_info(modelData.name)
                    }
                }
            }
        }
    }

    // Progress Popup
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
                text: "Processing..."
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

    // Status Popup
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
                text: statusPopup.statusSuccess ? "Operation Succeeded" : "Operation Failed"
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
