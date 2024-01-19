{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
    inputs.nix-index-database.nixosModules.nix-index

    ./nixos
    ./noxis
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = "nix-command flakes";
  };

  # Frontear/dotfiles
  # TODO: move this persistence stuff to ./nixos/impermanence.nix
  environment.persistence."/nix/persist" = {
    users.frontear = {
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

  home-manager.users.frontear =
  {
    ...
  }: {
    imports = [
      inputs.ags.homeManagerModules.default
      inputs.nixvim.homeManagerModules.nixvim
    ];

    programs.direnv = {
      enable = true;
      config = {
        whitelist = {
          prefix = [ "/home/frontear/Documents/projects" ];
        };
      };
      nix-direnv.enable = true;
    };

    # Misterio77/nix-starter-configs
    programs.home-manager.enable = true;
    systemd.user.startServices = "sd-switch";

    xdg.enable = true;

    home.stateVersion = "24.05";
  };

  networking.hostName = "LAPTOP-3DT4F02";

  time.timeZone = "America/Toronto";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  users.users.frontear = {
    initialHashedPassword = "$y$j9T$UdbhMx5bVd6gnI86Gjh3L.$TAdn8keK0ljg9fOVzApsEimx9wgZ9V116yLAsU2GgE3";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

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

  powerManagement.enable = true;
  services = {
    power-profiles-daemon.enable = true;
    thermald.enable = true;
    #tlp.enable = true;
  };

  services.upower.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    audio.enable = true;
    jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
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
  programs.hyprland.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];

  system.stateVersion = "24.05";
}
