# vim:ft=sass tabstop=2 shiftwidth=2
''
* {
  all: unset;

  font-family: FontAwesome, sans-serif;
  font-size: 1.1rem;
}

#custom-spacer {
  margin: 0 0.5rem;
}

.modules-left, .modules-center, .modules-right {
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 2rem;

  padding: 0.25rem 0;
}

#workspaces button {
  &.empty {
    color: rgba(black, 0.2);
  }

  &.focused {
    color: rgba(white, 0.6);
  }

  color: rgba(white, 0.2);
  margin-right: 0.5rem;
}

#window, #clock {
  margin-right: 0.5rem;
}

#workspaces button, #idle_inhibitor, #wireplumber, #network, #backlight, #battery {
  min-width: 1.75rem;
}
''
