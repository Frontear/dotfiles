[ -f ~/.zshrc ] && . ~/.zshrc
[ "$TTY" = "/dev/tty1" ] && [ -z $DISPLAY ] && exec Hyprland 
