{
  config,
  inputs,
  pkgs,
  ...
}: {
  ## REORGANIZE
  # Misterio77/nix-starter-configs
  # programs.home-manager.enable = true; <-- no need to have
  systemd.user.startServices = "sd-switch";

  xdg.enable = true;

  home.stateVersion = "24.05";
  ## END

  home.packages = with pkgs; [
    fastfetch
  ];

  # hyprland

  # npm

  # python

  # ranger

  # .local/bin

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "curses";
    sshKeys = [
      "AF4BF6EE3E68FD7576667BE7D8A7CFA50BC8E9F2"
    ];
  };
}
