#!/bin/bash
# install_snakejobs.sh - Install snakejobs script to user's local bin directory

set -euo pipefail

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SCRIPT="$SCRIPT_DIR/snakejobs"
DEST_DIR="$HOME/.local/bin"
DEST_SCRIPT="$DEST_DIR/snakejobs"
BASHRC="$HOME/.bashrc"

echo "Installing snakejobs script..."

# Create destination directory if it doesn't exist
if [ ! -d "$DEST_DIR" ]; then
    echo "Creating directory: $DEST_DIR"
    mkdir -p "$DEST_DIR"
fi

# Copy the script
echo "Copying snakejobs to $DEST_DIR"
cp "$SOURCE_SCRIPT" "$DEST_SCRIPT"
chmod +x "$DEST_SCRIPT"

# Check if $HOME/.local/bin is in PATH
if [[ ":$PATH:" == *":$DEST_DIR:"* ]]; then
    echo "✓ $DEST_DIR is already in PATH"
else
    echo "Adding $DEST_DIR to PATH in $BASHRC"
    
    # Check if the PATH export already exists in .bashrc
    if grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$BASHRC" 2>/dev/null; then
        echo "✓ PATH export already exists in $BASHRC"
    else
        # Add to .bashrc
        echo "" >> "$BASHRC"
        echo "# Added by snakejobs installation script" >> "$BASHRC"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$BASHRC"
        echo "✓ Added PATH export to $BASHRC"
    fi
    
    # Update current environment
    export PATH="$HOME/.local/bin:$PATH"
    echo "✓ Updated current environment PATH"
fi

echo ""
echo "Installation complete!"
echo ""
echo "The snakejobs script has been installed to $DEST_DIR"
echo ""
echo "Usage:"
echo "  myjobs      # System command - standard job view (no rule names)"
echo "  snakejobs   # New command - enhanced view with Snakemake RULE column"
echo ""
echo "If this is a new terminal session, run:"
echo "  source ~/.bashrc"
echo ""
echo "Or simply start a new terminal session."
