{
  osConfig,
  pkgs,
  ...
}:
{
  my.desktops.sway = {
    enable = osConfig.my.desktops.sway.enable;
    extraPackages = with pkgs; [
      foot
      rofi
      swayidle
      swaylock

      perlPackages.Apppapersway

      wl-clip-persist
    ];

    config = import ./config.nix;

    fonts = with pkgs; [
      nerd-fonts.symbols-only
    ];

    programs.waybar = {
      enable = true;

      config = import ./waybar/config.nix;
      style = import ./waybar/style.nix;
    };
  };
}
