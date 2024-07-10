{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mapAttrs' mapAttrsToList mkIf;

  # thanks lychee :3
  # https://github.com/itslychee/config/blob/69290575cc0829d40b516654e19d6b789edf32d0/modules/nix/settings.nix
  inputFarm = pkgs.linkFarm "input-farm" (mapAttrsToList (name: path: {
    inherit name path;
  }) inputs);
in {
  config = mkIf config.nix.enable {
    nix.channel.enable = false;

    nix.nixPath = [ "${inputFarm}" ];
    nix.registry = mapAttrs' (name: val: {
      inherit name;
      value.flake = val;
    }) inputs;
  };
}