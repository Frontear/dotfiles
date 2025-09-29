{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.fonts.fontconfig;
in {
  # TODO: eventually I want to move this to some environment flag, such as
  # `config.environment.isTerminal`, `config.environment.isGraphical`, and
  # have these environment flags controlled by their respective programs.
  #
  # For example, using `programs.eza.enable` should enable the `isTerminal`
  # flag, and therefore bring in all terminal styling configurations.
  #
  # The naming here is very much pending, but I prefer this instead of
  # activating it here.
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nerd-fonts.symbols-only
    ];
  };
}