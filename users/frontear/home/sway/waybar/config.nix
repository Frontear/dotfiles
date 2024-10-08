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
    "sway/workspaces",
    "custom/spacer",
    "disk",
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

  "sway/workspaces": {
    "disable-scroll": true,
    "disable-click": true,
    "current-only": true,
  },

  "disk": {
    "format-0": "󰄰",
    "format-1": "󰪞",
    "format-2": "󰪟",
    "format-3": "󰪠",
    "format-4": "󰪡",
    "format-5": "󰪢",
    "format-6": "󰪣",
    "format-7": "󰪤",
    "format-8": "󰪥",

    "states": {
      "0": 0,
      "1": 12,
      "2": 25,
      "3": 37,
      "4": 50,
      "5": 62,
      "6": 75,
      "7": 87,
      "8": 100,
    },

    "path": "/nix/store",

    "tooltip": true,
    "tooltip-format": "{used} / {total} ({percentage_used}%)",
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
