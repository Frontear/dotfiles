{ inputs, outputs, config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence

    outputs.programs.git
    outputs.programs.gpg
    outputs.programs.hyprland
    outputs.programs.microsoft-edge
    outputs.programs.neovim
    outputs.programs.network-manager
    outputs.programs.systemd-boot
    outputs.programs.vscode
    outputs.programs.zsh
  ];

  # See: CVE-2024-3094
  # WARN: impure
  system.replaceRuntimeDependencies = [
    {
      original = pkgs.xz;
      replacement = pkgs.xz.overrideAttrs (finalAttrs: prevAttrs: {
        version = "5.4.6";

        src = pkgs.fetchurl {
          url = with finalAttrs;
            # "https://github.com/tukaani-project/xz/releases/download/v${version}/xz-${version}.tar.bz2";
            "mirror://sourceforge/lzmautils/xz-${version}.tar.bz2";
          hash = "sha256-kThRsnTo4dMXgeyUnxwj6NvPDs9uc6JDbcIXad0+b0k=";
        };
      });
    }
  ];

  # Nix required
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;
  nix.settings.experimental-features = [ "flakes" "nix-command" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";

  # System Configuration
  console.keyMap = "us";
  i18n.defaultLocale = "en_CA.UTF-8";
  networking.hostName = "LAPTOP-3DT4F02";
  time.timeZone = "America/Toronto";

  environment.persistence."/nix/persist" = {
    hideMounts = true;

    users.frontear = {
      directories = [
        "Documents"
      ];
    };
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "mode=755" "noatime" "size=2G" ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
      options = [ "noatime" ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/store";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  users.users.frontear = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    initialHashedPassword = "$y$j9T$gsXwh6NJa62APePZ.7xR00$lLYi86UgQdN1yjOIgqcegfTKsnqkXI4ufQHWdOTiKr6";
  };

  # Everything else (for now)

  environment.systemPackages = with pkgs; [
    # C
    gcc
    gdb
    gnumake
    man-pages
    valgrind

    # Nix
    nil
    nixpkgs-fmt

    # Rust
    cargo
    rustc
    rustfmt
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.frontear = {
      home.stateVersion = "24.05";
    };
  };

  documentation = {
    dev.enable = true;

    man.generateCaches = true;

    nixos.includeAllModules = true;
  };
}
