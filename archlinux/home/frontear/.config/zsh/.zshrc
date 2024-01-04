# https://wiki.archlinux.org/title/GnuPG#Configure_pinentry_to_use_the_correct_TTY

export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye &> /dev/null

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="vim"
else
  export EDITOR="nvim"
fi

# https://wiki.archlinux.org/title/Color_output_in_console#Applications

alias diff="diff --color=auto"
alias grep="grep --color=auto"
alias ls="eza"
export LESS="-R --use-color -Dd+r\$Du+b$"
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export MANROFFOPT="-P -c"

alias l="ls -lah --group-directories-first"

# --------------------------------------------------

setopt alwaystoend autolist appendhistory
bindkey -e

ZSH_STATE="$XDG_STATE_HOME/zsh"
[ -d "$ZSH_STATE" ] || mkdir $ZSH_STATE

# zstyle :compinstall filename '$ZDOTDIR/.zshrc'
autoload -Uz compinit promptinit

compinit -d $ZSH_STATE/compdump
promptinit && prompt redhat
RPS1='%B%(?.%F{green}.%F{red})%?%f%b' # https://unix.stackexchange.com/a/375730

HISTFILE="$ZSH_STATE/history"
HISTSIZE=1000
SAVEHIST=1000

# https://wiki.archlinux.org/title/Zsh#Key_bindings

typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start { echoti smkx }
    function zle_application_mode_stop { echoti rmkx }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi
