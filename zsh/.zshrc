export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="robbyrussell"
# zsh-syntax-highlighting must come last in the plugins list
plugins=(nvm fzf-tab zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# --- PATH ---
export PATH=/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$PATH
export PATH=/opt/homebrew/bin:$PATH
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.yarn/bin"
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="/usr/local/opt/postgresql@18/bin:$PATH"

export BASH_MAX_OUTPUT_LENGTH=15000

# --- Editor ---
export EDITOR='subl -w'

# --- Java ---
export JAVA_HOME=$(/usr/libexec/java_home -v 20 2>/dev/null)

# --- NVM ---
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# --- fzf (Ctrl+R history, Ctrl+T files, Alt+C cd) ---
[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && source /opt/homebrew/opt/fzf/shell/completion.zsh

# --- Docker ---
export DOCKER_HOST="unix://$HOME/.docker/run/docker.sock"
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE='/var/run/docker.sock'

# --- Secrets (git-ignored, never committed) ---
[ -f "$HOME/.dotfiles/.env.local" ] && source "$HOME/.dotfiles/.env.local"
