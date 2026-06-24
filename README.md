# Ghost-Linux

![Ghost-Linux](https://img.shields.io/badge/Ghost--Linux-Arch%20Linux-blue)
![Version](https://img.shields.io/badge/version-1.0.0-green)
![License](https://img.shields.io/badge/license-GPL%20v3-orange)

**Ghost-Linux** is a next-generation Arch Linux distribution designed for gaming, productivity, AI-powered desktop computing, and comprehensive security auditing. It combines the power of Arch Linux with a user-friendly interface, built-in AI assistance, and complete Kali Linux security tools.

## Features

### 🎮 Gaming Optimized
- Pre-configured with Steam, Proton, MangoHud, and GameMode
- Gaming Center for performance profile management
- GPU optimization for NVIDIA, AMD, and Intel graphics
- Real-time FPS monitoring and system statistics

### 🤖 JARVIS AI Assistant
- Built-in AI assistant for system management
- Voice activation and natural language commands
- Local and cloud AI model support (Ollama, Gemini)
- Automated task execution and code generation

### 🛒 Unified Software Store
- Single storefront for Pacman, Flatpak, Snap, AppImage, and GitHub releases
- One-click installation without terminal commands
- Visual app descriptions, ratings, and origin badges
- Automatic backend authorization management

### 🔧 Zero-Terminal Administration
- Driver Center for automatic hardware detection and driver installation
- Control Center for visual system settings management
- Btrfs snapshots with automatic backup and rollback
- Cloud synchronization (Google Drive, OneDrive, Dropbox, Nextcloud)

### 📱 Android Integration
- Waydroid for running Android apps natively
- APK sideloading support
- Resource limit configuration
- Google Play Store support (GAPPS image)

### 🔒 Complete Security Suite
- **100+ Kali Linux security tools** organized by category:
  - Information Gathering (Nmap, Wireshark, Masscan, TheHarvester)
  - Vulnerability Analysis (Nikto, SQLMap, Nuclei, OpenVAS)
  - Web Application Analysis (Burp Suite, OWASP ZAP, Gobuster, FFUF)
  - Password Attacks (Hashcat, John the Ripper, Hydra)
  - Wireless Attacks (Aircrack-ng, Kismet, Reaver)
  - Exploitation Tools (Metasploit, SET, BeEF)
  - Sniffing & Spoofing (Ettercap, Mitmproxy, Bettercap)
  - Forensics (Autopsy, Volatility, Binwalk)
  - Reverse Engineering (Ghidra, Radare2, Cutter)
- Security Center application for tool management
- JARVIS AI security commands integration

### 🎨 Modern Desktop Experience
- KDE Plasma on Wayland with custom glassmorphic theme
- SDDM login screen with modern design
- Plymouth boot animation
- Btrfs filesystem with subvolumes for reliability

## Installation

### Requirements
- 64-bit x86_64 system
- UEFI firmware
- Minimum 8GB RAM (16GB recommended)
- Minimum 50GB storage (100GB recommended)
- USB flash drive (minimum 8GB)

### Steps

1. **Download the ISO**
  

2. **Flash to USB**
   ```bash
   # Using dd (Linux/macOS)
   sudo dd if=ghost-linux-rolling-x86_64.iso of=/dev/sdX bs=4M status=progress && sync
   
   # Using Rufus (Windows)
   # Download Rufus from https://rufus.ie and flash the ISO
   ```

3. **Boot from USB**
   - Enable UEFI in BIOS/firmware settings
   - Boot from USB drive
   - Select "Boot Ghost-Linux" from the menu

4. **Install**
   - Click "Install Ghost-Linux" on the desktop
   - Follow the Calamares installer wizard
   - Choose "Erase disk" for automatic Btrfs partitioning
   - Create user account and password
   - Wait for installation to complete
   - Reboot and remove USB

## Documentation

- [User Guide](docs/user_guide.md) - Complete user manual
- [Developer Guide](docs/developer_guide.md) - Development and build instructions
- [Security Tools Documentation](docs/security_tools.md) - Complete Kali Linux security tools reference

## Building from Source

### Prerequisites
- Arch Linux or Arch-based system
- Docker (for containerized builds)
- Git

### Local Build with Docker

```bash
# Clone the repository
git clone https://github.com/ghost-linux/ghost-linux.git
cd ghost-linux

# Run the build script
chmod +x scripts/build-local.sh
./scripts/build-local.sh

# The ISO will be in the project root
```

### Manual Build

```bash
# Install dependencies
sudo pacman -S archiso base-devel git

# Build custom packages
cd packages/ghost-linux-keyring
makepkg -sc --noconfirm

cd ../ghost-linux-branding
makepkg -sc --noconfirm

cd ../ghost-linux-apps
makepkg -sc --noconfirm

# Build ISO with archiso
sudo mkarchiso -v -w /tmp/archiso-work -o /tmp/archiso-out iso-profile

# Copy ISO
cp /tmp/archiso-out/*.iso .
```

## Project Structure

```
ghost-linux/
├── apps/                      # Custom applications
│   ├── common/               # Shared utilities
│   ├── driver-center/       # Hardware driver management
│   ├── ghost-linux-store/   # Software store
│   ├── jarvis-ai/           # AI assistant
│   ├── gaming-center/       # Gaming optimization
│   ├── control-center/      # System settings
│   └── security-center/     # Kali Linux security tools
├── packages/                 # Arch packages
│   ├── ghost-linux-apps/     # Main apps package
│   ├── ghost-linux-branding/ # Themes and branding
│   └── ghost-linux-keyring/ # GPG keyring
├── branding/                 # Visual assets
│   ├── plymouth/            # Boot animation
│   ├── sddm/                # Login screen
│   └── kde-look-and-feel/   # Plasma theme
├── iso-profile/              # Arch ISO configuration
├── calamares/                # Installer configuration
├── scripts/                  # Build and setup scripts
└── docs/                     # Documentation
```

## Applications

### Core Applications
- **Driver Center**: Hardware detection and driver installation
- **Ghost Linux Store**: Unified software installer
- **JARVIS AI**: AI-powered system assistant
- **Gaming Center**: Performance optimization
- **Control Center**: System settings management
- **Security Center**: Kali Linux security tools management

### JARVIS AI Commands
- "Launch Steam" / "Install Discord"
- "Scan network with nmap"
- "Open security center"
- "Run diagnostics"
- "Start Waydroid"
- "Create snapshot"

## Contributing

We welcome contributions! Please see our contributing guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow existing code style and structure
- Test changes thoroughly
- Update documentation as needed
- Use meaningful commit messages
- Ensure all applications work on non-Linux systems (mock mode)

## Security Tools Usage

**IMPORTANT**: The security tools included in Ghost-Linux are powerful and should only be used on systems you own or have explicit permission to test. Unauthorized use is illegal and unethical.

- Always obtain proper authorization before testing
- Follow responsible disclosure practices
- Use tools for educational and defensive purposes
- Respect privacy and data protection laws

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: See [docs/](docs/) directory
- **Issues**: Report bugs on [GitHub Issues](https://github.com/ghost-linux/ghost-linux/issues)
- **Discussions**: Join our [GitHub Discussions](https://github.com/ghost-linux/ghost-linux/discussions)
- **Community**: [Ghost-Linux Community Forum](https://community.ghost-linux.org)

## Acknowledgments

- **Arch Linux**: The foundation of Ghost-Linux
- **Kali Linux**: Security tools and penetration testing framework
- **KDE Plasma**: Desktop environment
- **Calamares**: Installer framework
- **Archiso**: ISO building tools
- **Ollama**: Local AI model support
- **All contributors**: Thank you for making Ghost-Linux better!

## Roadmap

### Version 1.1 (Planned)
- [ ] Additional AI model integrations (Claude, Llama)
- [ ] Enhanced gaming profiles
- [ ] More security tools from Kali
- [ ] Cloud backup integration
- [ ] Mobile companion app

### Version 2.0 (Future)
- [ ] Custom kernel with gaming/security optimizations
- [ ] Ghost-Linux package repository
- [ ] Automated security scanning
- [ ] AI-powered system optimization
- [ ] Cross-platform support

---


