# =========================================================
# File system
# =========================================================
if command -v eza >/dev/null 2>&1; then
  # Better ls
  alias ls='eza -lh --group-directories-first --icons=auto --git'
  alias ll='eza --icons auto'
  alias lla='ll -a'
  alias lsa='ls -a'
  # Detailed listing including hidden files
  alias la='eza -lah --icons=auto --git --group-directories-first'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
  # Tree view
  alias tree='eza --tree --icons=auto'

  # Reuse ls completions for eza (avoids defining a separate completion function)
  if (( $+functions[compdef] )); then
    compdef eza=ls
  fi
fi

# =========================================================
# Core utilities
# =========================================================
if command -v bat >/dev/null 2>&1; then
  alias cat='bat'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat'
fi

if command -v rg >/dev/null 2>&1; then
  alias grep='rg --color=auto'
fi

if diff --color=auto /dev/null /dev/null >/dev/null 2>&1; then
  alias diff='diff --color=auto'
fi

alias df='df -h'


# =========================================================
# Navigation
# =========================================================

alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# =========================================================
# File preview and fuzzy finder
# =========================================================
ff() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed" >&2
    return 127
  fi

  if command -v bat >/dev/null 2>&1; then
    fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
  elif command -v batcat >/dev/null 2>&1; then
    fzf --preview 'batcat --style=numbers --color=always --line-range :500 {}'
  else
    fzf
  fi
}

eff() {
  local file

  file="$(ff)" || return
  [[ -n "$file" ]] || return

  "${EDITOR:-nvim}" "$file"
}

_recent_files() {
  if find . -type f -printf '' >/dev/null 2>&1; then
    find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2-
  elif command -v stat >/dev/null 2>&1; then
    case "$(uname -s)" in
      Darwin|FreeBSD)
        find . -type f -exec stat -f '%m\t%N' {} + | sort -rn | cut -f2-
        ;;
      *)
        find . -type f -exec stat -c '%Y\t%n' {} + | sort -rn | cut -f2-
        ;;
    esac
  else
    find . -type f
  fi
}

sff() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: sff <destination> (e.g. sff host:/tmp/)" >&2
    return 1
  fi

  local file

  file="$(_recent_files | ff)" || return
  [[ -n "$file" ]] || return

  scp "$file" "$1"
}

lf() { # zsh follow lf navigation
    tmp=$(mktemp)
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir=$(cat "$tmp")
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

# =========================================================
# Smart directory navigation
# =========================================================
# zoxide is already initialized in .zshrc, before this file loads,
# so 'z' exists by the time we get here. Just wire up the alias.
if command -v zoxide >/dev/null 2>&1; then
  alias cd='zd'

  zd() {
    if (( $# == 0 )); then
      builtin cd ~ || return
      return
    fi

    if (( $# == 1 )) && [[ -d "$1" ]]; then
      builtin cd "$1" || return
      return
    fi

    if ! z "$@"; then
      echo "Error: Directory not found: $*" >&2
      return 1
    fi

    printf "󱞩 "
    pwd
  }
fi

# =========================================================
# Editor
# =========================================================
if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
  alias vi='nvim'

  n() {
    if [[ $# -eq 0 ]]; then
      command nvim .
    else
      command nvim "$@"
    fi
  }
fi

# =========================================================
# Tools
# =========================================================
if command -v docker >/dev/null 2>&1; then
  alias d='docker'
elif command -v podman >/dev/null 2>&1; then
  alias d='podman'
fi

if command -v podman >/dev/null 2>&1; then
  alias p='podman'
elif command -v docker >/dev/null 2>&1; then
  alias p='docker'
fi

if command -v rails >/dev/null 2>&1; then
  alias r='rails'
  alias br='bin/rails'
fi

# Package Install Aliases
if command -v sfw >/dev/null 2>&1; then
  alias npm="sfw npm"
  alias npx="sfw npx"
  alias pnpm="sfw pnpm"
  alias pnpx="sfw pnpx"
  alias yarn="sfw yarn"
  alias bun="sfw bun"
  alias bunx="sfw bunx"
  alias nub="sfw nub"
  alias nubx="sfw nubx"
fi

# =========================================================
# Git
# =========================================================
if command -v git >/dev/null 2>&1; then
  alias g='git'

  alias gs='git status --short --branch'
  alias ga='git add'
  alias gaa='git add --all'

  alias gcm='git commit -m'
  alias gcam='git commit -a -m'
  alias gcad='git commit -a --amend'

  alias gp='git push'
  alias gpl='git pull --ff-only'

  alias glog='GIT_PAGER="less -F -X" git log'                                   # -F quit if one screen, -X no clear on exit
  alias gl='GIT_PAGER="less -F -X" git log --all --decorate --oneline --graph'
  alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
fi

if command -v lazygit >/dev/null 2>&1; then
  alias lg='lazygit'
fi

# =========================================================
# Video
# =========================================================

alias stream='mpv av://v4l2:/dev/video4 --fullscreen --demuxer-lavf-o=input_format=mjpeg,framerate=30 --profile=low-latency --untimed'
