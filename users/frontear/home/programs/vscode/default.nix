{
  pkgs,
  ...
}:
{
  my.programs.vscode = {
    enable = true;

    extensions =
      pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix)
      ++ (with pkgs.vscode-extensions; [
      # TODO: prefer Nixpkgs extensions when possible
      ms-python.python
      ms-vscode.cpptools
      rust-lang.rust-analyzer
    ]);

    settings = import ./settings.nix;
  };
}