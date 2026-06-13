#!/usr/bin/env bash

# Ghost-Linux Local Docker Build Helper Script
# Runs the full Archiso build sequence inside a privileged Docker container.

set -e

# Make sure we run from workspace root
WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WORKSPACE_DIR"

echo "=================================================="
echo "          Ghost-Linux Local Build Helper"
echo "=================================================="

# Check if docker is running
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker daemon is not running. Please start Docker."
    exit 1
fi

# Load loop module
if [ "$(uname)" == "Linux" ]; then
    echo "Ensuring loop module is loaded..."
    sudo modprobe loop || true
fi

echo "Spinning up Arch Linux Docker container..."
docker run --privileged --rm \
    -v "$WORKSPACE_DIR:/workspace" \
    archlinux:latest \
    /bin/bash -c "
        echo 'Updating containers...'
        pacman-key --init
        pacman-key --populate archlinux
        pacman -Syu --noconfirm --needed devtools archiso base-devel git sudo

        # Create build user
        if ! id -u builder >/dev/null 2>&1; then
            useradd -m -G wheel builder
            echo 'builder ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
        fi
        chown -R builder:builder /workspace

        echo 'Compiling custom packages...'
        mkdir -p /workspace/repo-local
        
        # Build keyring
        sudo -u builder bash -c 'cd /workspace/packages/ghost-linux-keyring && makepkg -sc --noconfirm'
        mv -f /workspace/packages/ghost-linux-keyring/*.pkg.tar.zst /workspace/repo-local/

        # Build branding
        sudo -u builder bash -c 'cd /workspace/packages/ghost-linux-branding && makepkg -dsc --noconfirm'
        mv -f /workspace/packages/ghost-linux-branding/*.pkg.tar.zst /workspace/repo-local/

        # Build apps
        sudo -u builder bash -c 'cd /workspace/packages/ghost-linux-apps && makepkg -dsc --noconfirm'
        mv -f /workspace/packages/ghost-linux-apps/*.pkg.tar.zst /workspace/repo-local/

        echo 'Adding packages to repository database...'
        cd /workspace/repo-local
        repo-add ghost-linux-repo.db.tar.gz *.pkg.tar.zst

        echo 'Compiling bootable ISO...'
        mkdir -p /tmp/archiso-workspace
        mkdir -p /tmp/archiso-out

        mkarchiso -v -w /tmp/archiso-workspace -o /tmp/archiso-out /workspace/iso-profile
        
        cp -f /tmp/archiso-out/*.iso /workspace/
        echo 'ISO build completed!'
    "

echo "=================================================="
echo "Success! The Ghost-Linux ISO is built at workspace root."
echo "=================================================="
