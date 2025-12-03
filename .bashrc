export HISTCONTROL=ignoredups:erasedups
# === kubernetes ===

KUBECONF_DIR=$HOME/.kubeconfigs
CLUSTER_MERGE=${KUBECONF_DIR}/cluster-merge
TMP_KUBECONFIG=$(find ${KUBECONF_DIR} -name kubeconfig -printf %p:)
export KUBECONFIG=${CLUSTER_MERGE}:${TMP_KUBECONFIG}
TMP_KUBECONFIG=$(find ${KUBECONF_DIR} -name kubeconfig -printf %p:)

alias kubectl='kubecolor'
alias k='kubecolor'

source <(kubectl completion bash | sed 's/kubectl/kubecolor/g')
source <(kubectl completion bash | sed 's/kubectl/k/g')

# Assuming d8 is a valid command with tab completion
eval "$(d8 completion bash)"

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

fzf_history_widget() {
  local selected_command
  selected_command=$(history | awk '{$1=""; print substr($0, 2)}' | fzf --height 40% --reverse)

  if [ -n "$selected_command" ]; then
    # Insert the selected command into the current line
    READLINE_LINE=$selected_command
    READLINE_POINT=${#selected_command}
  fi
}

bind -x '"\C-r": fzf_history_widget'
