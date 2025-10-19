{
  lib,
  pkgs,
  ...
}:
{
  config = {
    stylix.targets.vscode.enable = true;

    programs.vscode = {
      enable = true;

      profiles."default" = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;

        extensions =
          pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix)
          ++ (with pkgs.vscode-extensions; [
            # TODO: prefer Nixpkgs extensions when possible
            ms-python.python
            ms-vscode.cpptools
            rust-lang.rust-analyzer
          ]);

        userSettings = import ./settings.nix // {
          # TODO: these colors aren't amazing..
          "workbench.colorTheme" = lib.mkForce "Atomize";
        };
      };
    };
  };
}