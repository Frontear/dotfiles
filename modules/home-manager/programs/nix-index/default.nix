{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.programs.nix-index = {
    enable = lib.mkEnableOption "nix-index" // { default = true; };
    package = lib.mkOption {
      default = pkgs.nix-index;
      defaultText = "pkgs.nix-index";
      description = ''
        The nix-index package to use.
      '';

      type = with lib.types; package;
    };
  };

  config = lib.mkIf config.my.programs.nix-index.enable {
    my.persist.directories = [ "~/.cache/nix-index" ];

    programs.command-not-found.enable = lib.mkForce false;
    programs.nix-index.enable = true;
  };
}