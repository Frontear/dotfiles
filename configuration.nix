{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.default

    ./hardware-configuration.nix
    ./archlinux
    ./nixos
  ];

  nixpkgs.config.allowUnfree = true;

  # Misterio77/nix-starter-configs
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  nix.nixPath = [ "/etc/nix/path" ]; # ?
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "/nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.settings = {
    experimental-features = "nix-command flakes";
  };

  # Frontear/dotfiles
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    
    directories = [
      { directory = "/etc/NetworkManager/system-connections"; mode = "0700"; }
    ];

    files = [
      "/var/lib/power-profiles-daemon/state.ini"
    ];

    users.frontear = {
      directories = [
        { directory = ".config/microsoft-edge"; mode = "0700"; }
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
    ];

    programs.ags = {
      enable = true;
    };

    # Misterio77/nix-starter-configs
    programs.home-manager.enable = true;
    systemd.user.startServices = "sd-switch";

    home.stateVersion = "24.05";
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "mode=755" "noatime" "size=1G" ];
    };
    "/archive" = {
      device = "/dev/disk/by-label/archive";
      fsType = "btrfs";
      options = [ "compress=zstd:15" ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
      options = [ "noatime" ];
    };
    "/nix" = {
      device = "/dev/disk/by-label/nix";
      fsType = "btrfs";
      options = [ "compress=zstd" "noatime" ];
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "LAPTOP-3DT4F02";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  users.users.frontear = {
    initialHashedPassword = "$y$j9T$UdbhMx5bVd6gnI86Gjh3L.$TAdn8keK0ljg9fOVzApsEimx9wgZ9V116yLAsU2GgE3";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
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

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.hyprland.enable = true;

  zramSwap.enable = true;
  zramSwap.priority = 100;

  system.stateVersion = "24.05";
}
