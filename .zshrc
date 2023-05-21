if [ -z $GPG_TTY ]; then
  export GPG_TTY=$TTY # powerlevel10k instant prompt breaks stdin
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [ "$TERM" = "linux" ]; then
  PS1="[%n@%m %~]$ "
  return # don't execute rest of script
fi

# export PATH=$HOME/bin:/usr/local/bin:$PATH

ZSH=/usr/share/oh-my-zsh/
ZSH_THEME="powerlevel10k"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

CACHE_DIR=${XDG_CONFIG_DIR:-$HOME/.cache}
if [ ! -d $CACHE_DIR ]; then
  mkdir -p $CACHE_DIR
fi

export ZSH_COMPDUMP=$CACHE_DIR/.zcompdump
export HISTFILE=$CACHE_DIR/.zsh_history
export LESSHISTFILE=$CACHE_DIR/.lesshst
export CARGO_HOME=$CACHE_DIR/.cargo
export RUSTUP_HOME=$CACHE_DIR/.rustup

alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"

ZSH_CACHE_DIR=$CACHE_DIR/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir -p $ZSH_CACHE_DIR 
fi

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
