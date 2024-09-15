# vim:ft=jsonc tabstop=2 shiftwidth=2
''
{
  "layer": "top",
  "position": "top",
  "spacing": 0,
  "mode": "dock",

  "modules-left": [
    "sway/workspaces",
  ],

  "modules-center": [
    "idle_inhibitor",
  ],

  "modules-right": [
    "wireplumber",
    "network",
    "backlight",
    "battery",
    "custom/spacer",
    "clock",
  ],

  "custom/spacer": {
    "format": "|",
  },

  "sway/workspaces": {
    "format": "",

    "disable-scroll": true,
    "disable-click": true,
    "persistent-workspaces": {
      "1": [],
      "2": [],
      "3": [],
      "4": [],
      "5": [],
      "6": [],
      "7": [],
      "8": [],
      "9": [],
      "10": [],
    },
  },
  
  "idle_inhibitor": {
    "format": "{icon}",
    "format-icons": {
      "activated": "",
      "deactivated": "",
    },
  },

  "wireplumber": {
    "format": "{icon}",
    "format-muted": "󰝟",
    "format-icons": [ "󰕿", "󰖀", "󰕾", ],

    "on-click": "wpctl set-mute @DEFAULT_SINK@ toggle",
  },

  "network": {
    "format-disconnected": "󰤫",
    "format-ethernet": "󰈀",
    "format-wifi": "{icon}",

    "format-icons": [ "󰤯", "󰤟", "󰤢", "󰤥", "󰤨", ],

    "tooltip": true,
    "tooltip-format": "TODO",
  },
  
  "backlight": {
    "format": "{icon}",
    "format-icons": [ "󰛩", "󱩎", "󱩏", "󱩐", "󱩑", "󱩒", "󱩓", "󱩔", "󱩕", "󱩖", "󰛨", ],

    "tooltip": true,
    "tooltip-format": "{percent}%",
  },
  
  "battery": {
    "format": "{icon}",
    "format-full": "󰁹",
    "format-icons": {
      "charging": [ "󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅", ],
      "discharging": [ "󱃍", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹", ],
    },
  },

  "clock": {
    "format": "{:%H:%M}",

    "tooltip": true,
    "tooltip-format": "<tt><small>{calendar}</small></tt>",

    "calendar": {
      "format": {
        "today": "<b><u>{}</u></b>",
      },
    },
  },
}
''
