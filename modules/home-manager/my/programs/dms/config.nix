{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.dms;
  fmt = pkgs.formats.json { };

  inputDms = inputs.DankMaterialShell;
  inputQs = inputs.quickshell;
  system = pkgs.stdenv.hostPlatform.system;

  dgop = inputDms.inputs.dgop.packages.${system}.default;
  dms = inputDms.packages.${system}.default;
  dms-cli = inputDms.inputs.dms-cli.packages.${system}.default;
  quickshell = inputQs.packages.${system}.default;

  # DankMaterialShell's `wallpaperFillMode` option requires sentence casing
  toSentenceCase = string: let
    head = lib.substring 0 1 string;
    tail = lib.substring 1 (-1) string;
  in
    (lib.toUpper head) + tail;
in {
  # NOTE: this is a re-implementation of the upstream DankMaterialShell module,
  # because the aforementioned module is poorly written.
  #
  # see: https://github.com/AvengeMedia/DankMaterialShell/blob/master/nix/default.nix
  config = lib.mkIf cfg.enable {
    home.packages = [
      dgop
      dms-cli
    ] ++ (with pkgs; [
      # Needed for brightness functionality
      brightnessctl

      # Needed for clipboard functionality
      cliphist
      wl-clipboard

      # Needed for monitor control
      ddcutil

      # Needed for calendar events
      khal

      # Needed for soundlets
      kdePackages.qtmultimedia
    ]);

    # Set some values for Stylix
    my.programs.dms = lib.mkIf config.stylix.enable {
      session = {
        "isLightMode" = config.stylix.polarity == "light";

        "wallpaperPath" = config.stylix.image;
      };

      settings = {
        "fontFamily" = config.stylix.fonts.sansSerif.name;
        "monoFontFamily" = config.stylix.fonts.monospace.name;

        "wallpaperFillMode" = toSentenceCase config.stylix.imageScalingMode;
      };
    };

    # Persist stateful data
    my.persist.directories = [{
      path = "~/.local/state/DankMaterialShell";
      unique = true;
    }];

    programs.quickshell = {
      enable = true;
      package = quickshell;

      configs = {
        dms = "${dms}/etc/xdg/quickshell/dms";
      };
    };

    systemd.user.services.dms = {
      Unit = {
        PartOf = [ config.wayland.systemd.target ];
        After = [ config.wayland.systemd.target ];

        X-Restart-Triggers = [
          config.programs.quickshell.configs.dms
        ];
      };

      Service = {
        # Synchronise the default settings onto the expected settings path
        # before DMS starts up.
        #
        # This fixes an issue with DMS failing to update its state after copying
        # the default settings on startup. Instead, we perform the copy for it,
        # which will correctly configure DMS.
        #
        # Note that this will destructively copy over any pre-existing file.
        ExecStartPre = "${lib.getExe' pkgs.coreutils "cp"} " +
          "--dereference --no-preserve=all " +
          "${config.xdg.configHome}/DankMaterialShell/default-settings.json " +
          "${config.xdg.configHome}/DankMaterialShell/settings.json";
        ExecStart = "${lib.getExe dms-cli} run";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ config.wayland.systemd.target ];
      };
    };

    # TODO: hidden dangers of configuring `settings.json` directly?
    xdg.configFile."DankMaterialShell/default-settings.json" =
      lib.mkIf (cfg.settings != {}) {
        source = fmt.generate "default-settings.json" cfg.settings;
      };

    xdg.stateFile."DankMaterialShell/default-session.json" =
      lib.mkIf (cfg.session != {}) {
        source = fmt.generate "default-session.json" cfg.session;
      };
  };
}