export GPG_TTY=$TTY

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
export EDITOR="nvim"

plugins=(colored-man-pages git zsh-autosuggestions zsh-syntax-highlighting)

alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir -p $ZSH_CACHE_DIR 
fi

# No valid display session, we are likely in tty
if [ -z $DISPLAY ]; then
  PS1="[%n@%m %~]$ "
else
  source $ZSH/oh-my-zsh.sh
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi  
