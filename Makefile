.PHONY: all brew link macos iterm2

all: brew link macos iterm2

brew:
	@command -v brew >/dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew bundle --file=./Brewfile

link:
	ln -sfn $(PWD)/zsh/.zshrc $$HOME/.zshrc
	ln -sfn $(PWD)/git/.gitignore_global $$HOME/.gitignore_global
	git config --global core.excludesfile $$HOME/.gitignore_global

macos:
	bash ./macos.sh

iterm2:
	defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$(PWD)/iterm2"
	defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
