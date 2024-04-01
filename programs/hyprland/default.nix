{ inputs, config, pkgs, lib, ... }: {
  imports = [
    inputs.hyprland.nixosModules.default
  ];

  # System
  environment.persistence."/nix/persist" = {
    directories = [
      { directory = "/var/cache/tuigreet"; user = "greeter"; group = "greeter"; mode = "0755"; }
    ];
  };

  environment.systemPackages = with pkgs; [
    kitty
    libinput
  ];

  programs.hyprland = {
    enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --cmd ${lib.getExe config.programs.hyprland.package} --time --remember --remember-session --asterisks";
      };
    };
  };

  # User
  home-manager.users.frontear = {
    xdg.configFile."hypr/hyprland.conf".text = ''
    monitor =, highres, auto, 1.5

    xwayland {
      use_nearest_neighbor = true
      force_zero_scaling = true
    }

    $mainMod = SUPER

    bind = $mainMod, Return, exec, kitty
    bind = $mainMod, BackSpace, killactive
    bind = Control Alt, Delete, exit
    '';
  };
}