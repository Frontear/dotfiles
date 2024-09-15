# vim:ft=sass tabstop=2 shiftwidth=2
''
* {
  all: unset;
}

@mixin fontStyle($family, $size) {
  min-width: ($size / 2) * 3; // idk where i came up with this
  font-size: $size;
  font-family: $family;
}

.modules-left, .modules-center, .modules-right {
  background-color: rgba(black, 0.4);
  border-radius: 1.5rem;
  padding: 0.25rem 0.5rem;
}

#custom-os-logo, #workspaces button, #idle_inhibitor, #wireplumber, #network, #backlight, #battery {
  @include fontStyle("Symbols Nerd Font", 1.25rem);
}

#custom-spacer, #clock {
  @include fontStyle("monospace", 1rem);
}

#custom-os-logo {
  color: #5277c3;
}

#workspaces button {
  color: rgba(white, 0.25);

  &.empty {
    color: rgba(black, 0.25);
  }

  &.focused {
    color: rgba(white, 0.5);
  }
}

/*
#wireplumber.muted, #network.disconnected, #battery.discharging.critical {
  color: #ff6961;
}

#battery.full {
  color: #61ffb8;
}
*/
''
