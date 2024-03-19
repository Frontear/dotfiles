{ inputs, ... }:
let
  vscode-extensions = inputs.nix-vscode-extensions.extensions."x86_64-linux".vscode-marketplace;
in {
  # User
  home-manager.users.frontear = {
    programs.vscode = {
      enable = true;

      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;

      extensions = with vscode-extensions; [
        jeff-hykin.better-syntax
        ms-vscode.cpptools
        streetsidesoftware.code-spell-checker
        dbaeumer.vscode-eslint
        redhat.java
        sumneko.lua
        (ms-vscode.makefile-tools.overrideAttrs (
          _: { sourceRoot = "extension"; }
        ))

        emroussel.atomize-atom-one-dark-theme
        pkief.material-icon-theme
        pkief.material-product-icons

        bbenoist.nix
        jnoortheen.nix-ide
        ms-python.vscode-pylance
        ms-python.python
        rafamel.subtle-brackets
        qcz.text-power-tools
        jgclark.vscode-todo-highlight
      ];

      mutableExtensionsDir = false;
      userSettings = {
        "editor.accessibilitySupport" = "off";
        "editor.cursorBlinking" = "phase";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.folding" = false;
        "editor.fontFamily" = "monospace, Symbols Nerd Font";
        "editor.guides.bracketPairs" = true;
        "editor.matchBrackets" = "never";
        "editor.minimap.enabled" = false;
        "editor.smoothScrolling" = true;
        "editor.wordWrap" = "on";

        "explorer.excludeGitIgnore" = true;

        "files.autoSave" = "onFocusChange";
        "files.eol" = "\n";
        "files.insertFinalNewline" = false;
        "files.trimFinalNewlines" = true;
        "files.trimTrailingWhitespace" = true;

        "security.workspace.trust.enabled" = false;

        #"security.workspace.trust.banner" = "never";
        #"security.workspace.trust.untrustedFiles" = "newWindow";

        "terminal.integrated.cursorBlinking" = true;
        "terminal.integrated.persistentSessionReviveProcess" = "never";
        "terminal.integrated.rightClickBehavior" = "default";
        "terminal.integrated.smoothScrolling" = true;

        "window.commandCenter" = false;
        "window.confirmBeforeClose" = "keyboardOnly";
        "window.openFoldersInNewWindow" = "on";

        "workbench.colorCustomizations" = {
          "editorBracketHighlight.foreground1" = "#5caeef";
          "editorBracketHighlight.foreground2" = "#dfb976";
          "editorBracketHighlight.foreground3" = "#c172d9";
          "editorBracketHighlight.foreground4" = "#4fb1bc";
          "editorBracketHighlight.foreground5" = "#97c26c";
          "editorBracketHighlight.foreground6" = "#abb2c0";
          "editorBracketHighlight.unexpectedBracket.foreground" = "#db6165";
        };
        "workbench.colorTheme" = "Atomize";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.layoutControl.enabled" = false;
        "workbench.list.smoothScrolling" = true;
        #"workbench.productIconTheme" = "material-product-icons";
        "workbench.startupEditor" = "newUntitledFile";

        # Extensions

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";

        "subtleBrackets.disableNative" = false; # we handle it ourselves

        "todohighlight.include" = [
          "**/*.c"
          "**/*.cpp"
          "**/*.css"
          "**/*.html"
          "**/*.java"
          "**/*.js"
          "**/*.nix"
          "**/*.py"
          "**/*.rs"
        ];

        # colors generated via "Developer: Generate Color Theme From Current Settings"
        "todohighlight.keywords" = [
          {
              "text" = "FIXME";
              "regex" = {
                  "pattern" = "(?<=^|\"|\\s)FIXME[:]?(?!\\w)";
              };
              "color" = "white";
              "backgroundColor" = "#e05561";
          }
          {
              "text" = "TODO";
              "regex" = {
                  "pattern" = "(?<=^|\"|\\s)TODO[:]?(?!\\w)";
              };
              "color" = "white";
              "backgroundColor" = "#42b3c2";
          }
          {
              "text" = "WARN";
              "regex" = {
                  "pattern" = "(?<=^|\"|\\s)WARN[:]?(?!\\w)";
              };
              "color" = "white";
              "backgroundColor" = "#d18f52";
          }
        ];
      };
    };
  };
}
