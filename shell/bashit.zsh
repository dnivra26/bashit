# bashit zsh integration: translate the current command line in place.
# Source this from your ~/.zshrc:
#   source /path/to/bashit/shell/bashit.zsh
# Then press Ctrl-G on any line you've typed to replace it with the command.

bashit-widget() {
  emulate -L zsh
  local prompt="$BUFFER"
  if [[ -z "${prompt// }" ]]; then
    zle -M "bashit: empty prompt"
    return 1
  fi

  local err cmd rc
  err=$(mktemp -t bashit.XXXXXX) || return 1
  cmd=$(print -r -- "$prompt" | command bashit 2>"$err")
  rc=$?

  if (( rc != 0 )); then
    zle -M "bashit: $(<"$err" | tr '\n' ' ')"
    rm -f -- "$err"
    return $rc
  fi
  rm -f -- "$err"

  if [[ -z "${cmd// }" ]]; then
    zle -M "bashit: no command returned"
    return 1
  fi

  # Do NOT add `zle reset-prompt` here — it fights zle's own redraw and
  # leaves stale text like "list hidden filesls -a" on screen.
  BUFFER="$cmd"
  CURSOR=${#BUFFER}
}

zle -N bashit-widget
bindkey '^G' bashit-widget
