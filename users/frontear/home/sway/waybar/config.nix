# vim:ft=jsonc tabstop=2 shiftwidth=2
''
{
  "layer": "top",
  "position": "top",
  "spacing": 0,
  "margin": "4",
  "mode": "dock",

  "modules-left": [
    "custom/os-logo",
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

  "custom/os-logo": {
    "format": "",
  },

  "custom/spacer": {
    "format": "|",
  },
  
  "idle_inhibitor": {
    "format": "{icon}",
    "format-icons": {
      "activated": "",
      "deactivated": "",
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
    "interval": 5,

    "format": "{icon}",
    "format-icons": {
      "full": "󱟢",
      "charging": [ "󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅", ],
      "discharging": [ "󱃍", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹", ],
    },

    "states": {
      "critical": 10,
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
