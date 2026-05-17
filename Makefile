.PHONY: all brew zsh link macos iterm2 skills agents claude

all: brew zsh link macos iterm2 skills agents claude

brew:
	@command -v brew >/dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew bundle --file=./Brewfile

zsh:
	@[ -d $$HOME/.oh-my-zsh ] || sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	@mkdir -p $$HOME/.oh-my-zsh/custom/plugins
	@[ -d $$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ] || git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions $$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	@[ -d $$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ] || git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting $$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	@[ -d $$HOME/.oh-my-zsh/custom/plugins/fzf-tab ] || git clone --depth=1 https://github.com/Aloxaf/fzf-tab $$HOME/.oh-my-zsh/custom/plugins/fzf-tab

link:
	ln -sfn $(PWD)/zsh/.zshrc $$HOME/.zshrc
	ln -sfn $(PWD)/git/.gitignore_global $$HOME/.gitignore_global
	git config --global core.excludesfile $$HOME/.gitignore_global

macos:
	bash ./macos.sh

iterm2:
	defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$(PWD)/iterm2"
	defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

skills:
	@mkdir -p $$HOME/.codex/skills $$HOME/.claude/skills
	@find skills -type f -path '*/scripts/*' -exec chmod +x {} +
	@for s in skills/*/; do \
		name=$$(basename $$s); \
		rsync -a --delete "$$s" "$$HOME/.codex/skills/$$name/"; \
		rsync -a --delete "$$s" "$$HOME/.claude/skills/$$name/"; \
	done

agents:
	@mkdir -p "$$HOME/.codex" "$$HOME/.claude"
	ln -sfn "$(PWD)/ai/AGENTS.md" "$$HOME/.codex/AGENTS.md"
	ln -sfn "$(PWD)/ai/AGENTS.md" "$$HOME/.claude/CLAUDE.md"

claude:
	@mkdir -p "$$HOME/.claude"
	ln -sfn "$(PWD)/claude/settings.json" "$$HOME/.claude/settings.json"
