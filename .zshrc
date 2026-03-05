# === Oh My Zsh ===
export ZSH="$HOME/.oh-my-zsh"

# Using starship prompt instead of oh-my-zsh theme
ZSH_THEME=""

# Uncomment to change auto-update behavior
# zstyle ':omz:update' mode auto

plugins=(
    fzf
    git
    kubectl
    docker
    direnv
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-kubectl-prompt
)

source $ZSH/oh-my-zsh.sh

# === History ===
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

# Arrow key history search (prefix-based)
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search

# === Completion ===
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# === Autosuggestions config ===
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#808080"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# === Common ===
export PATH=$PATH:/usr/local/go/bin:~/go/bin:/home/linuxbrew/.linuxbrew/bin:~/.local/bin/
eval "$(starship init zsh)"

# ls aliases
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# === Kubernetes ===
KUBECONF_DIR=$HOME/.kubeconfigs
CLUSTER_MERGE=${KUBECONF_DIR}/cluster-merge
TMP_KUBECONFIG=$(find ${KUBECONF_DIR} -name kubeconfig -printf %p:)
export KUBECONFIG=${CLUSTER_MERGE}:${TMP_KUBECONFIG}
TMP_KUBECONFIG=$(find ${KUBECONF_DIR} -name kubeconfig -printf %p:)

alias kubectl='kubecolor'
alias k='kubecolor'

source <(kubectl completion zsh)
compdef kubecolor=kubectl
compdef k=kubectl

eval "$(d8 completion zsh)"

# === Aliases ===
alias gitag='kubectl get mpo virtualization -oyaml | yq .spec.imageTag'
alias gpf='git push --force-with-lease'
alias k8s='cd ~/k8s'
alias virt='cd ~/projects/virtualization'
alias vrnd='cd ~/projects/virtualization-rnd'

sitag() {
  if [ -z "$1" ]; then
    echo 'kubectl patch mpo virtualization --type merge -p "{\"spec\" : {\"imageTag\" : \"$1\"}}"'
  else
    kubectl patch mpo virtualization --type merge -p "{\"spec\" : {\"imageTag\" : \"$1\"}}"
  fi
}

scale-dh() {
  if [ -z "$1" ]; then
    echo 'kubectl -n d8-system scale deployment deckhouse --replicas "$1"'
  else
    kubectl -n d8-system scale deployment deckhouse --replicas "$1"
  fi
}
