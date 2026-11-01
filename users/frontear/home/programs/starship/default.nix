{
  lib,
  ...
}:
{
  config = {
    stylix.targets.starship.enable = true;

    programs.starship = {
      enable = true;

      presets = [
        "nerd-font-symbols"
      ];

      # https://starship.rs/config/
      settings = {
        right_format = lib.concatStrings [
          "$status"
        ];

        status = {
          disabled = false;

          format = "[$status]($style)";

          success_symbol = "✔️";
          success_style = "bold green";
          failure_style = "bold red";
        };
      };
    };
  };
}