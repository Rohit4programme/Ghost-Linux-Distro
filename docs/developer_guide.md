# Ghost-Linux Developer Guide

Welcome to the Ghost-Linux developer manual. This document contains information on how to modify the OS, compile custom packages, extend the custom PyQt/QML applications, and build the bootable ISO file.

---

## Repository Architecture

The project is structured as follows:

- `branding/`: Contains wallpapers, SDDM login screen themes, Plymouth boot animations, and KDE Plasma overrides.
- `iso-profile/`: The Archiso configurations including package list manifests and configuration overlays.
- `calamares/`: Custom settings and slideshow slides for the Calamares graphical installer.
- `apps/`: PySide6 (Python) backends and QML visual interfaces for Ghost-Linux core applications (Driver Center, Store, JARVIS AI, Gaming Center, Control Center, Security Center).
- `packages/`: pacman PKGBUILD recipe templates used to package branding, keyrings, and desktop applications.
- `scripts/`: Shell automation scripts for compiling and re-indexing repositories.

---

## 1. Modifying PyQt/QML Applications

All core administrative applications are stored in `apps/`. They are structured with a Python backend managing low-level CLI commands (such as `pacman`, `systemctl`, `timeshift`, `cpupower`, etc.) and a QML graphical layer managing animations and layouts.

### Structure of an Application (Example: Gaming Center)
- `apps/gaming-center/main.py`: PySide6 bootstrapper. Instantiates the backend QObject and registers it to QML.
- `apps/gaming-center/gaming_manager.py`: Backend class containing signals and slots for system modification.
- `apps/gaming-center/GamingCenter.qml`: QML interface mapping components.

### Development Guidelines
- Always design your PySide6 slots to execute computationally heavy or root-level scripts in a separate background thread (using `threading.Thread` or `QThreadPool`) so that the user interface never freezes.
- Use the shared styling parameters defined in [style.py](file:///c:/linux%20Distro/apps/common/style.py) (e.g. `BG_CARD`, `ACCENT_CYAN`, `FONT_FAMILY`, etc.) to maintain visual consistency.
- Handle non-Linux systems (Windows/macOS) by writing graceful mocks inside the backend scripts, allowing developers to debug the QML designs without running a Linux kernel directly.

---

## 2. Packaging Custom Applications and Branding

Ghost-Linux uses pacman to manage its core system applications. These packages are defined as standard PKGBUILD recipes inside `packages/`:

- **`ghost-linux-keyring`**: Handles installing trusted GPG keys for pacman security.
- **`ghost-linux-branding`**: Installs visuals to `/usr/share/backgrounds/`, `/usr/share/sddm/themes/`, `/usr/share/plymouth/themes/`, and copies configuration defaults to `/etc/skel/.config/` for new user creation.
- **`ghost-linux-apps`**: Bundles the PyQt/QML scripts, installs wrapper executables to `/usr/bin/`, adds `.desktop` launchers to `/usr/share/applications/`, and registers polkit configuration files in `/usr/share/polkit-1/rules.d/` to permit passwordless execution for members of the `wheel` group.

### Compiling Packages Locally (Requires Arch Linux or Docker)
To test individual package modifications:
```bash
cd packages/ghost-linux-apps
makepkg -sc
```
This yields a `*.pkg.tar.zst` package file which can be installed via `pacman -U`.

---

## 3. Building the Bootable ISO File

### Using the CI/CD Pipeline (Recommended)
Pushes to the `main` branch trigger the GitHub Actions workflow defined in `.github/workflows/build-iso.yml`. This action:
1. Bootstraps a privileged Arch Linux Docker container.
2. Resolves dependencies and builds custom packages.
3. Places them in a local pacman repository folder.
4. Generates a signed, bootable `.iso` image using `mkarchiso`.
5. Uploads the final ISO as a build artifact.

### Building Locally using Docker
If you have Docker installed on your development host, you can run the local build script:
```bash
chmod +x scripts/build-local.sh
./scripts/build-local.sh
```
This mounts the workspace directory, spins up the build container, and builds the ISO directly into your workspace folder.
