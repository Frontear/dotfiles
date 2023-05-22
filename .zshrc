export GPG_TTY=$(tty)

# https://wiki.archlinux.org/title/XDG_Base_Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

if [ "$TERM" = "linux" ]; then
  PS1="[%n@%m %~]$ "; return
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH=/usr/share/oh-my-zsh/
ZSH_THEME="powerlevel10k"
ZSH_CACHE_DIR=$XDG_CACHE_HOME/oh-my-zsh
ZSH_COMPDUMP=$XDG_CACHE_HOME/.zcompdump

export HISTFILE=$XDG_CACHE_HOME/.zsh_history
export LESSHISTFILE=$XDG_CACHE_HOME/.lesshst
export RUSTUP_HOME=$XDG_CACHE_HOME/.rustup
export CARGO_HOME=$XDG_CACHE_HOME/.cargo
export GNUPGHOME=$XDG_DATA_HOME/gnupg

export PATH="$HOME/.local/bin:$PATH:$CARGO_HOME/bin"

export EDITOR="nvim"

plugins=(colored-man-pages git zsh-autosuggestions zsh-syntax-highlighting)

alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir -p $ZSH_CACHE_DIR 
fi

source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
