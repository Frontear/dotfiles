{
  config,
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
            ms-vscode.cmake-tools
            ms-vscode.cpptools
            myriad-dreamin.tinymist
            redhat.java
            rust-lang.rust-analyzer
          ]);

        userSettings = import ./settings.nix // {
          # TODO: these colors aren't amazing..
          "workbench.colorTheme" = lib.mkForce "Atomize";

          # Ensure VSCode can render nerd font symbols in the terminal
          "terminal.integrated.fontFamily" = "Symbols Nerd Font, ${config.stylix.fonts.monospace.name}";
        };
      };
    };
  };
}