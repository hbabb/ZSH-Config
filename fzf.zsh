# =========================================================
# fzf
# =========================================================
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'  # strip-cwd-prefix removes the leading ./ from results
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"                      # Ctrl-T uses fd
fi

# =========================================================
# UI
# =========================================================
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt=" "
  --pointer=" "
  --preview-window=right:65%:wrap:border-left
'

# =========================================================
# Preview
# =========================================================
if command -v bat >/dev/null 2>&1; then
  export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
elif command -v batcat >/dev/null 2>&1; then
  export _FZF_PREVIEW_CMD='batcat --color=always --style=plain,numbers --line-range=:500 {}'
else
  export _FZF_PREVIEW_CMD='cat {}'
fi

export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

# =========================================================
# Ctrl+F file picker (excludes hidden files)
# =========================================================
_fzf_file_no_hidden() {
  local cmd
  local result

  if [[ -n "$FZF_DEFAULT_COMMAND" ]]; then
    cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
  else
    cmd='find . -type f'
  fi

  result="$(eval "$cmd" | fzf --preview "$_FZF_PREVIEW_CMD")" || return
  LBUFFER+="$result"
  zle reset-prompt
}

zle -N _fzf_file_no_hidden

