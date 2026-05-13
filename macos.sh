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
defaults write com.apple.universalaccess mouseDriver -bool false
defaults write com.apple.universalaccess mouseDriverShortcut -bool false

# Screenshots: save to ~/Screenshots
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location "$HOME/Screenshots"

killall Finder SystemUIServer 2>/dev/null || true
