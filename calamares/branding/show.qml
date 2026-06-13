import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: slideshow
    width: 800
    height: 480

    // Background Styling
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0d0b18" }
            GradientStop { position: 1.0; color: "#19122a" }
        }
    }

    // Carousel content
    property int currentSlideIndex: 0
    property var slidesData: [
        {
            title: "Next Generation Simplicity",
            subtitle: "Zero Terminal Administration",
            desc: "Ghost-Linux offers a completely visual Control Center, allowing you to manage packages, drivers, kernels, and power profiles without writing a single terminal command."
        },
        {
            title: "JARVIS Built-in AI Assistant",
            subtitle: "Your Intelligent Copilot",
            desc: "Activate JARVIS with a wake word to launch apps, manage OS settings, query developer code, and automate routine tasks using local or cloud AI models."
        },
        {
            title: "Ghost-Linux Store",
            subtitle: "Unified Universal Installer",
            desc: "A single unified storefront that seamlessly searches and installs apps from Pacman, Flatpak, Snap, AppImage, and even direct GitHub releases."
        },
        {
            title: "High Performance Gaming",
            subtitle: "Optimized for Play",
            desc: "Comes preinstalled with Steam, Proton, MangoHud, and GameMode. Easily toggle performance profiles from the Gaming Center dashboard."
        },
        {
            title: "Ghost-Linux Recovery & Btrfs",
            subtitle: "Crash-Resistant Reliability",
            desc: "Rest easy with automatic snapshots and rollback support built directly into the bootloader, protecting your personal data against system failures."
        },
        {
            title: "Security Center",
            subtitle: "Kali Linux Security Tools",
            desc: "Complete penetration testing and security auditing platform with 100+ tools including Nmap, Wireshark, Metasploit, Burp Suite, Hashcat, and more."
        }
    ]

    Timer {
        interval: 7000 // Change slide every 7 seconds
        running: true
        repeat: true
        onTriggered: {
            slideshow.currentSlideIndex = (slideshow.currentSlideIndex + 1) % slideshow.slidesData.length
        }
    }

    // Slide visual container
    Item {
        anchors.fill: parent
        anchors.margins: 40

        ColumnLayout {
            anchors.fill: parent
            spacing: 15

            // Progress Indicators (Dots)
            Row {
                Layout.alignment: Qt.AlignLeft
                spacing: 8
                Repeater {
                    model: slideshow.slidesData.length
                    delegate: Rectangle {
                        width: index === slideshow.currentSlideIndex ? 24 : 8
                        height: 8
                        radius: 4
                        color: index === slideshow.currentSlideIndex ? "#00ffff" : "#30ffffff"
                        Behavior on width { NumberAnimation { duration: 200 } }
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }
            }

            // Text Slides Content with Fade Animations
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    Text {
                        text: slideshow.slidesData[slideshow.currentSlideIndex].title
                        font.pointSize: 22
                        font.bold: true
                        color: "#00ffff"
                        Layout.fillWidth: true
                    }

                    Text {
                        text: slideshow.slidesData[slideshow.currentSlideIndex].subtitle
                        font.pointSize: 14
                        font.bold: false
                        color: "#e000ff"
                        Layout.fillWidth: true
                    }

                    Text {
                        text: slideshow.slidesData[slideshow.currentSlideIndex].desc
                        font.pointSize: 11
                        color: "#dddddd"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                    }
                }
            }
        }
    }
}
