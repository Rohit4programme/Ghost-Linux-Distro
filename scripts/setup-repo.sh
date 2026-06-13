#!/usr/bin/env bash

# Ghost-Linux Package Repository Setup and Indexing Tool
# Re-adds compiled packages in repo-local and regenerates the database index file.

set -e

# Path declarations
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$SCRIPTS_DIR/.."
REPO_DIR="$WORKSPACE_DIR/repo-local"

echo "Re-indexing Ghost-Linux Custom Repository at $REPO_DIR..."

# Create directory if missing
mkdir -p "$REPO_DIR"

cd "$REPO_DIR"

# Check if there are any compiled package files
if [ -n "$(find . -name '*.pkg.tar.zst' -print -quit)" ]; then
    echo "Found compiled packages. Regenerating DB index..."
    
    # Remove old databases
    rm -f ghost-linux-repo.db ghost-linux-repo.db.tar.gz
    rm -f ghost-linux-repo.files ghost-linux-repo.files.tar.gz
    
    # Generate database index
    repo-add ghost-linux-repo.db.tar.gz *.pkg.tar.zst
    
    # Create symlinks
    ln -sf ghost-linux-repo.db.tar.gz ghost-linux-repo.db
    ln -sf ghost-linux-repo.files.tar.gz ghost-linux-repo.files
    
    echo "Custom repository database index updated successfully!"
else
    echo "No package binaries (*.pkg.tar.zst) found in $REPO_DIR."
    echo "Run scripts/build-local.sh or compile packages first."
fi
