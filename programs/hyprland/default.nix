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
    libinput
  ];

  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${config.programs.hyprland.package}/bin/Hyprland --time --remember --remember-session --asterisks";
      };
    };
  };

  # User
  home-manager.users.frontear =
  let
    mainMod = "SUPER";
    workspaces = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" ];
    directions = { l = "Left"; r = "Right"; u = "Up"; d = "Down"; };
  in {
    xdg.configFile."hypr/hyprland.conf" = {
      text = ''
      monitor =, highres, auto, 1.5

      xwayland {
        use_nearest_neighbor = true
        force_zero_scaling = true
      }

      bind = ${mainMod}, Return, exec, ${pkgs.kitty}/bin/kitty
      bind = ${mainMod}, BackSpace, killactive
      bind = Control Alt, Delete, exit

      ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (key: arg: "bind = ${mainMod}, ${arg}, movefocus, ${key}") directions)}
      ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (key: arg: "bind = ${mainMod} Shift, ${arg}, movewindow, ${key}") directions)}

      ${builtins.concatStringsSep "\n" (map (n: "bind = ${mainMod}, ${n}, workspace, ${n}") workspaces)}
      bind = ${mainMod}, 0, workspace, 10
      ${builtins.concatStringsSep "\n" (map (n: "bind = ${mainMod} Shift, ${n}, movetoworkspace, ${n}") workspaces)}
      bind = ${mainMod} Shift, 0, movetoworkspace, 10
      '';

      # TODO: make workie
      #onChange = ''
      #[ -z "''${HYPRLAND_INSTANCE_SIGNATURE-_}" ] && ${config.programs.hyprland.package}/bin/hyprctl reload
      #'';
    };
  };
}