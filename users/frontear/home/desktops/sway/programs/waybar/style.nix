{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.sway;
  colors = config.lib.stylix.colors.withHashtag;

  # https://github.com/chriskempson/base16/blob/main/styling.md#styling-guidelines
  bg = "#000000"; # colors.base00; doesn't look that good..
  fg = colors.base05;

  fontStyle = family: size: ''
    min-width: ${toString ((size / 2) * 3)}rem;
    font-size: ${toString size}rem;
    font-family: "${family}";
  '';

  window-waybar.common = ''
    background-color: alpha(${bg}, 0.4);
    border-radius: 1.5rem;
  '';
in {
  config = lib.mkIf cfg.enable {
    programs.waybar.style = ''
      * {
        all: unset;
      }


      tooltip {
        background-color: alpha(${bg}, 0.4);
        border-radius: 0.5rem;
      }

      tooltip * {
        color: ${fg};
      }


      window#waybar.top .modules-left,
      window#waybar.top .modules-center,
      window#waybar.top .modules-right {
        ${window-waybar.common}
        padding: 0.25rem 0.5rem;
      }

      window#waybar.bottom .modules-center {
        ${window-waybar.common}
        padding: 0.25rem;
      }


      #icon {
        min-width: ${toString ((1.925 / 2) * 3)}rem;
      }

      #icon:hover {
        background-color: alpha(${fg}, 0.1);
        border-radius: 1.25rem;
      }


      #workspaces button,
      #clock {
        ${fontStyle config.stylix.fonts.monospace.name 0.825}
      }

      #network,
      #wireplumber,
      #battery {
        ${fontStyle "Symbols Nerd Font" 1.1}
      }
    '';
  };
}
