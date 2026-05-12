# Dotfiles — Mac startup

Setup completo para configurar um Mac do zero: pacotes (Homebrew), shell (zsh), git, defaults do macOS e perfil do iTerm2.

## Requisitos

- macOS (Apple Silicon ou Intel)
- Xcode Command Line Tools: `xcode-select --install`

## Uso

```bash
git clone <repo> ~/dev/dotfiles
cd ~/dev/dotfiles
make all
```

## Alvos do Makefile

| Alvo | O que faz |
|------|-----------|
| `make all` | Roda tudo: `brew` + `link` + `macos` + `iterm2` |
| `make brew` | Instala Homebrew (se necessário) e roda `brew bundle` com o `Brewfile` |
| `make link` | Cria symlinks de `.zshrc` e `.gitignore_global` em `~`, e configura `git core.excludesfile` |
| `make macos` | Aplica `defaults write` para Finder, Dock e teclado |
| `make iterm2` | Aponta o iTerm2 para ler prefs deste repo (`iterm2/`) |

## Estrutura

```
.
├── Brewfile               # pacotes Homebrew (CLI + casks)
├── Makefile               # alvos de setup
├── macos.sh               # defaults macOS
├── zsh/.zshrc             # config do shell
├── git/.gitignore_global  # gitignore global (inclui pastas de IA)
├── iterm2/                # plist do iTerm2 (load preferences from custom folder)
└── ai/                    # placeholder para configs de IA (fase futura)
```
