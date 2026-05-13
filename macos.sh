#!/usr/bin/env bash
set -e

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Keyboard: fast key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Avoid .DS_Store on external volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Accessibility: disable Mouse Keys and its 5-press toggle shortcut
# Requires Full Disk Access for the calling terminal (System Settings → Privacy & Security → Full Disk Access).
# Skipped with a warning when FDA is not granted, so a fresh-machine `make` doesn't abort.
if ! defaults write com.apple.universalaccess mouseDriver -bool false 2>/dev/null \
   || ! defaults write com.apple.universalaccess mouseDriverShortcut -bool false 2>/dev/null; then
  echo "warning: skipping com.apple.universalaccess tweaks — grant Full Disk Access to your terminal and rerun 'make macos'." >&2
fi

# Screenshots: save to ~/Screenshots
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location "$HOME/Screenshots"

killall Finder SystemUIServer 2>/dev/null || true
