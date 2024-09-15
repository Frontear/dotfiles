# vim:ft=swayconfig tabstop=2 shiftwidth=2
let
  Super = "Mod4";
in ''
output eDP-1 {
  scale 1.5
  bg ${./wallpapers/wallpaper_dark.jpg} fit
}

client.focused #ff000055 #33333388 #dddddd #00000000 #ff000055
client.unfocused #595959aa #16161688 #666666 #00000000 #595959aa
titlebar_separator disable

corner_radius 8
gaps inner 2
gaps outer 4

bar {
  swaybar_command waybar
}

focus_wrapping no
workspace_layout default
exec papersway

exec swayidle -w \
  timeout '${toString (2 * 60)}' 'swaylock -fls solid_color -c 000000' \
  timeout '${toString (5 * 60)}' 'swaymsg "output * dpms off"' \
  resume 'swaymsg "output * dpms on"'

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
  --locked Ctrl+Alt+Delete exit
  Ctrl+Alt+R reload

  ${Super}+BackSpace kill
  ${Super}+Return exec foot
  ${Super}+E exec rofi -show drun

  F11 fullscreen toggle
  ${Super}+F floating toggle

  ${Super}+Left exec papersway-msg focus left
  ${Super}+Right exec papersway-msg focus right
  ${Super}+Up focus up
  ${Super}+Down focus down

  ${Super}+Shift+Left exec papersway-msg move left
  ${Super}+Shift+Right exec papersway-msg move right
  ${Super}+Shift+Up move up
  ${Super}+Shift+Down move down
}

include /etc/sway/config.d/*
''
