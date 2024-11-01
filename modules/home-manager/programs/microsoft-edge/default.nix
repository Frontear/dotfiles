{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.microsoft-edge;
in {
  options.my.programs.microsoft-edge = {
    enable = lib.mkEnableOption "microsoft-edge";
    package = lib.mkOption {
      default = pkgs.callPackage ./package.nix { commandLineArgs = "--user-data-dir=${lib.replaceStrings [ "~" ] [ "${config.home.homeDirectory}" ] cfg.userDataDir}"; };
      defaultText = "<wrapped-drv>";
      description = ''
        The microsoft-edge package to use.
      '';

      type = with lib.types; package;
    };

    userDataDir = lib.mkOption {
      default = "~/.config/microsoft-edge";
      description = ''
        Directory to store persistent user data.
      '';

      type = with lib.types; userPath;
    };

    useAsPDFViewer = lib.mkDefaultEnableOption "using as pdf viewer";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      my.persist.directories = [ "${cfg.userDataDir}" ];

      home.packages = [ cfg.package ];
    }
    (lib.mkIf cfg.useAsPDFViewer {
      xdg.mimeApps.enable = true;
      xdg.mimeApps.defaultApplications = {
        "application/pdf" = "microsoft-edge.desktop";
      };
    })
  ]);
}
