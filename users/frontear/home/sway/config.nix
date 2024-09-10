# vim:ft=swayconfig
''
# Super_L doesn't work
set $SUPER Mod4

exec swayidle -w \
  timeout '${toString (2 * 60)}' 'swaylock -fls solid_color -c 000000' \
  timeout '${toString (5 * 60)}' 'swaymsg "output * dpms off"' \
  resume 'swaymsg "output * dpms on"'

bar {
  gaps 2
  mode dock
  position top

  swaybar_command waybar

  status_command \
    while date +'%Y-%m-%d %X'; do \
    sleep 1; \
    done

  colors {
    background #323232
  }
}

default_orientation horizontal
workspace_layout default
xwayland enable
bindsym --no-repeat {
  Ctrl+Alt+Delete exit
  Ctrl+Alt+R reload

  $SUPER+BackSpace kill
  $SUPER+Return exec foot
  $SUPER+E exec rofi -show drun
}
default_border normal 1
output eDP-1 {
  scale 1.5
  scale_filter smart

  background #222222 solid_color
}

input type:keyboard {
  repeat_delay 250
  repeat_rate 25
}

input type:touchpad {
  accel_profile adaptive
  click_method clickfinger
  drag disabled
  dwt enabled
  dwtp enabled
  left_handed disabled
  middle_emulation disabled
  natural_scroll disabled
  pointer_accel 0
  scroll_factor 1
  scroll_method two_finger
  tap enabled
  tap_button_map lrm
}

bindsym --no-repeat {
  $SUPER+Left focus left
  $SUPER+Right focus right
  $SUPER+Up focus up
  $SUPER+Down focus down

  $SUPER+Shift+Left move left
  $SUPER+Shift+Right move right
  $SUPER+Shift+Up move up
  $SUPER+Shift+Down move down

  $SUPER+1 workspace number 1
  $SUPER+2 workspace number 2
  $SUPER+3 workspace number 3
  $SUPER+4 workspace number 4
  $SUPER+5 workspace number 5
  $SUPER+6 workspace number 6
  $SUPER+7 workspace number 7
  $SUPER+8 workspace number 8
  $SUPER+9 workspace number 9
  $SUPER+0 workspace number 10

  $SUPER+Shift+1 move container to workspace number 1
  $SUPER+Shift+2 move container to workspace number 2
  $SUPER+Shift+3 move container to workspace number 3
  $SUPER+Shift+4 move container to workspace number 4
  $SUPER+Shift+5 move container to workspace number 5
  $SUPER+Shift+6 move container to workspace number 6
  $SUPER+Shift+7 move container to workspace number 7
  $SUPER+Shift+8 move container to workspace number 8
  $SUPER+Shift+9 move container to workspace number 9
  $SUPER+Shift+0 move container to workspace number 10
}

include /etc/sway/config.d/*
''
