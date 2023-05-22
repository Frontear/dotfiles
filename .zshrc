export GPG_TTY=$(tty)

if [ "$TERM" = "linux" ]; then
  PS1="[%n@%m %~]$ "; return
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

CACHE_DIR=${XDG_CACHE_DIR:-$HOME/.cache}
DATA_DIR=${XDG_DATA_HOME:-$HOME/.local/share}

ZSH=/usr/share/oh-my-zsh/
ZSH_THEME="powerlevel10k"

export ZSH_COMPDUMP=$CACHE_DIR/.zcompdump
export HISTFILE=$CACHE_DIR/.zsh_history
export LESSHISTFILE=$CACHE_DIR/.lesshst
export RUSTUP_HOME=$CACHE_DIR/.rustup
export CARGO_HOME=$CACHE_DIR/.cargo
export GNUPGHOME=$DATA_DIR/gnupg

export PATH="$HOME/.local/bin:$PATH:$CARGO_HOME/bin"

export EDITOR="nvim"

plugins=(colored-man-pages git zsh-autosuggestions zsh-syntax-highlighting)

alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

ZSH_CACHE_DIR=$CACHE_DIR/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir -p $ZSH_CACHE_DIR 
fi

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
