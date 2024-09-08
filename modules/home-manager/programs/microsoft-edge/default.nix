{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.programs.microsoft-edge = {
    enable = lib.mkEnableOption "microsoft-edge";
    package = lib.mkOption {
      default = pkgs.callPackage ./package.nix { commandLineArgs = "--user-data-dir=${config.my.programs.microsoft-edge.userDataDir}"; };
      defaultText = "<wrapped-drv>";
      description = ''
        The microsoft-edge package to use.
      '';

      type = with lib.types; package;
    };

    userDataDir = lib.mkOption {
      default = ".config/microsoft-edge";
      description = ''
        Directory to store persistent user data.
      '';

      type = with lib.types; str;
    };
  };

  config = lib.mkIf config.my.programs.microsoft-edge.enable {
    warnings = [
      "WARN: Impermanence not configured! (persist ~/${config.my.programs.microsoft-edge.userDataDir})"
    ];

    home.packages = [ config.my.programs.microsoft-edge.package ];
  };
}