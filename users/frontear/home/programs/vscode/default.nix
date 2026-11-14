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
          ++ [
            pkgs.vscode-extensions."13xforever".language-x86-64-assembly
          ] ++ (with pkgs.vscode-extensions; [
            astro-build.astro-vscode
            bbenoist.nix
            codezombiech.gitignore
            dbaeumer.vscode-eslint
            editorconfig.editorconfig
            emroussel.atomize-atom-one-dark-theme
            github.vscode-github-actions
            jgclark.vscode-todo-highlight
            jnoortheen.nix-ide
            karunamurti.haml
            mattn.lisp
            mechatroner.rainbow-csv
            ms-python.python
            ms-python.vscode-pylance
            ms-vscode.cmake-tools
            ms-vscode.cpptools
            ms-vsliveshare.vsliveshare
            myriad-dreamin.tinymist
            pkief.material-icon-theme
            pkief.material-product-icons
            redhat.java
            rust-lang.rust-analyzer
            scala-lang.scala
            shopify.ruby-lsp
            streetsidesoftware.code-spell-checker
            tamasfe.even-better-toml
            unifiedjs.vscode-mdx
            visualstudioexptteam.intellicode-api-usage-examples
            visualstudioexptteam.vscodeintellicode
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