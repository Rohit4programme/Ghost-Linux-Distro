# Ghost-Linux User Manual

Welcome to Ghost-Linux, a next-generation Linux operating system designed for simplicity, gaming, development, and advanced desktop reliability.

---

## 1. Installing Ghost-Linux

1. Download the bootable ISO file from the releases page.
2. Flash the ISO to a USB flash drive (minimum 8GB) using a tool like Rufus or BalenaEtcher.
3. Boot your system from the USB drive. Ensure UEFI is enabled in your BIOS/firmware settings.
4. When the desktop loads, click the **Install Ghost-Linux** icon on the taskbar to launch the installation wizard.
5. Follow the slides:
   - **Partitioning:** Choose "Erase disk". The system defaults to **Btrfs** filesystem with subvolumes `@` (root), `@home` (user files), and `@snapshots` (system rollback checkpoints).
   - **User setup:** Create a user account and select password.
6. The installer will prepare your system and configure Plymouth boot loaders. Reboot when complete.

---

## 2. Zero-Terminal Device and Driver Center

The **Driver Center** manages hardware drivers automatically:
- Launch **Driver Center** from the application launcher.
- **GPU Detection:** The system detects whether you are using NVIDIA, AMD, or Intel graphics. If using NVIDIA, click "Install Driver" to configure NVIDIA DKMS modules.
- **Networking:** Manage Wi-Fi chipsets and bluetooth profiles.
- **Printers:** Seamlessly configure network and local printers via the CUPS driver module.
- **Diagnostics:** Click **Run Diagnostics** to perform real-time checks on driver states and dmesg log alerts.

---

## 3. Universal Ghost-Linux Software Store

The **Ghost-Linux Store** integrates multiple package managers behind a single search layout:
- **Search once, download everywhere:** Search term queries list matches across native Pacman repositories, Flatpak/Flathub, Snaps, and GitHub releases.
- **Visual details:** View system descriptions, rating stars, and origin badges.
- **Actions:** Install software with one click without typing root pacman commands. The system manages background authorizations automatically.

---

## 4. Built-in JARVIS AI Assistant

**JARVIS** acts as your conversational system co-pilot:
- Click the **JARVIS** icon or press the hotkey to summon the panel overlay.
- **Voice Activation:** Click the microphone button and state your command (e.g. *"Hey Jarvis, launch Steam"* or *"Hey Jarvis, install Discord"*).
- **System Command capability:** JARVIS translates natural language queries to execute actions like starting Android emulation (Waydroid), running updates, searching local documents, or diagnosing error codes.
- **Developer mode:** Request code blocks, software project architectures, or terminal automation.

---

## 5. Gaming Center

**Gaming Center** pre-configures performance properties:
- **Monitoring:** Displays real-time CPU utilization, GPU temperature, RAM footprint, and FPS counts.
- **Performance profiles:** Choose from Battery Saver, Balanced, Gaming, and Maximum Power to throttle CPU governors (`cpupower`) and GPU envelopes.
- **Overlay & Optimizers:** Toggle **MangoHud Overlay** and **GameMode** switches to configure dynamic framerate trackers and process priorities.

---

## 6. Backups & Rollback Recovery

Ghost-Linux protects your personal configuration files:
- **Snapshots:** The system generates daily Btrfs snapshots automatically.
- **Manual Backups:** Open **Control Center**, go to **Btrfs Recovery**, and click **Create Snapshot** to save a restore checkpoint.
- **Rollbacks:** If a system update crashes your setup, boot into GRUB and choose **Btrfs Snapshots**. Select your previous working state from the list to boot and rollback your installation instantly.

---

## 7. Security Center (Kali Linux Security Tools)

Ghost-Linux includes a comprehensive **Security Center** application with 100+ Kali Linux security tools organized by category:

### Security Categories
- **Information Gathering**: Nmap, Wireshark, Masscan, TheHarvester, Recon-ng
- **Vulnerability Analysis**: Nikto, SQLMap, Nuclei, OpenVAS
- **Web Application Analysis**: Burp Suite, OWASP ZAP, Gobuster, FFUF
- **Password Attacks**: Hashcat, John the Ripper, Hydra, Medusa
- **Wireless Attacks**: Aircrack-ng, Kismet, Reaver, Wifite
- **Exploitation Tools**: Metasploit, Searchsploit, SET, BeEF
- **Sniffing & Spoofing**: Ettercap, Mitmproxy, Bettercap, Hping3
- **Post-Exploitation**: Mimikatz, LaZagne
- **Forensics**: Autopsy, Volatility, Binwalk, Sleuth Kit
- **Reverse Engineering**: Ghidra, Radare2, Cutter, GDB

### Using Security Center
1. Launch **Security Center** from the application menu
2. Browse tools by category with installation status indicators
3. Click **Launch** to run installed tools
4. Click **Install** to install missing tools via pacman
5. Click **Info** to view tool descriptions and usage

### JARVIS AI Security Commands
- "Scan network with nmap"
- "Launch wireshark"
- "Open security center"
- "Run security scan on 192.168.1.1"
- "Install burpsuite"

> **Important**: These tools should only be used on systems you own or have explicit permission to test. Unauthorized use is illegal.

---

## 8. Cloud Synchronization

Open **Control Center → Cloud Sync** to manage remote cloud storage via rclone:

- **Provider Cards:** Click Google Drive, OneDrive, Dropbox, or Nextcloud to add a new account. A browser authentication page will open.
- **Connected Remotes:** All configured remotes are listed with their sync path and last-sync timestamp.
- **Sync Now:** Click **Sync Now** on any remote to pull latest files into `~/CloudSync/<remote-name>/`.
- **Console:** A live console panel shows real-time download progress and file transfer logs.
- **Remove:** Click **Remove** to disconnect a remote account (does not delete local files).

---

## 9. Android Apps (Waydroid)

Open **Control Center → Android Apps** to manage the Android subsystem:

- **Start / Stop:** Toggle the Android container on or off with the green Start/Stop button.
- **Status Panel:** View the running Android version, image type (VANILLA / GAPPS), IP address, and session state.
- **Install APK:** Click the **📦 Drop APK** zone to browse and sideload any `.apk` package directly.
- **Resource Limits:** Adjust CPU core count (1–16) and RAM allocation (512MB–8GB) with sliders, then click **Apply**.
- **Installed Apps:** Browse all installed Android apps in a grid. Click **✕** to uninstall any app from the container.

> **Note:** For full Google Play Store support, use the GAPPS image type during initial Waydroid setup.

