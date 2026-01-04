#!/bin/bash
# ===============================================================
# Matrix Morpheus GRUB Theme Installer for Kali Linux
# Author: @psychoSherlock
# Original Author: @Priyank-Adhav
# Repository: https://github.com/psychoSherlock/Morpheus-GRUB-Theme-KALI-WINDOWS.git
# ===============================================================
# NOTE: This script is specifically designed for Kali Linux & Windows 11
# dual-boot setups, but should work with other distributions as well.
# ===============================================================

set -e

THEME_NAME="Matrix"
THEME_DIR="/boot/grub/themes"
GRUB_CFG="/etc/default/grub"
GRUB_FILE="/boot/grub/grub.cfg"
KALI_CFG="/etc/default/grub.d/kali-themes.cfg"

echo ""
echo "==========================="
echo "Matrix GRUB Theme Installer (Kali Linux & Windows 11)"
echo "==========================="
echo ""

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (use sudo)."
    exit 1
fi

# Ensure theme directory exists 
echo "Checking for theme directory..."
mkdir -p "$THEME_DIR"

# Copy theme files 
echo "Installing theme..."
cp -r "$THEME_NAME" "$THEME_DIR/" || {
    echo "Failed to copy theme files."
    exit 1
}

# Configure GRUB to use the new theme 
echo "Updating GRUB configuration..."
if grep -q '^GRUB_THEME=' "$GRUB_CFG"; then
    sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"|" "$GRUB_CFG"
else
    echo "" >> "$GRUB_CFG"
    echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> "$GRUB_CFG"
fi

# Update Kali-specific theme configuration
if [ -f "$KALI_CFG" ]; then
    echo "Configuring Kali theme settings..."
    
    # Get current screen resolution
    SCREEN_RES=$(xdpyinfo | awk '/dimensions/{print $2}' 2>/dev/null || echo "1920x1080")
    
    # Comment out existing GRUB_GFXMODE line
    sed -i 's/^GRUB_GFXMODE=/#GRUB_GFXMODE=/' "$KALI_CFG"
    
    # Add new GRUB_GFXMODE with detected resolution
    if grep -q '^GRUB_GFXMODE=' "$KALI_CFG" || grep -q '^#GRUB_GFXMODE=' "$KALI_CFG"; then
        sed -i "/^#GRUB_GFXMODE=/a GRUB_GFXMODE=\"${SCREEN_RES}\"" "$KALI_CFG"
    else
        echo "GRUB_GFXMODE=\"${SCREEN_RES}\"" >> "$KALI_CFG"
    fi
    
    # Update GRUB_THEME to Matrix theme
    sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"|" "$KALI_CFG"
    
    echo "Screen resolution set to: $SCREEN_RES"
else
    echo "Kali theme config not found. Skipping Kali-specific configuration."
fi

# Regenerate GRUB
echo "Rebuilding GRUB configuration..."
if command -v update-grub >/dev/null 2>&1; then
    update-grub >/dev/null
    echo "GRUB configuration updated successfully using update-grub."
elif command -v grub-mkconfig >/dev/null 2>&1; then
    grub-mkconfig -o "$GRUB_FILE" >/dev/null
    echo "GRUB configuration updated successfully using grub-mkconfig."
else
    echo "Neither update-grub nor grub-mkconfig found. Please update your GRUB manually."
    exit 1
fi

echo ""
echo "===================================="
echo "Installation complete!"
echo "===================================="
echo ""
echo "Reboot to see your new Matrix GRUB theme."
echo ""
echo "NOTE: To change the OS icons, manually edit the icon files"
echo "in the 'icons' folder of this project to your preferred ones."
echo ""