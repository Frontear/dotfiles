{
  pkgs,
  ...
}:
{
  my.programs.vscode = {
    enable = true;

    config = import ./settings.nix;
    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix);
  };
}