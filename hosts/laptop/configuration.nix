{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
  ];

  # Frontear/dotfiles
  impermanence = {
    enable = true;

    user = {
      directories = [
        { directory = ".config/ArmCord"; mode = "0700"; }
        { directory = ".config/microsoft-edge"; mode = "0700"; }
        ".local/share/cargo"
        ".local/share/gradle"
        { directory = ".local/share/gnupg"; mode = "0700"; }
        { directory = ".ssh"; mode = "0700"; }
      ] ++ [ # xdg-user dirs
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        #"Public"
        #"Templates"
        "Videos"
      ];

      files = [
        ".local/state/zsh/history"
      ];
    };
  };

  networking.hostName = "LAPTOP-3DT4F02";

  time.timeZone = "America/Toronto";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    # TODO: promptInit conflicts with prompts defined in HM.
  };

  environment.systemPackages = with pkgs; [
    armcord
    atool
    cliphist
    eza
    git
    grimblast
    inotify-tools
    kitty
    microsoft-edge
    fastfetch
    neovim
    prismlauncher
    sassc
    swaybg
    wl-clip-persist
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [ "NerdFontsSymbolsOnly" ];
    })
  ];

  services.upower.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    audio.enable = true;
    jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  programs.command-not-found.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd Hyprland --greeting \"Welcome to NixOS!\" --time --remember --asterisks";
      };
    };
  };
  impermanence.root.directories = [
    "/var/cache/tuigreet"
  ];

  programs.hyprland.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];

  system.stateVersion = "24.05";
}
