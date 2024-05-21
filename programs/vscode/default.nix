{ inputs, outputs, pkgs, ... }:
let
  extensions = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;

  toJSON = (pkgs.formats.json {}).generate;
in {
  imports = [
    outputs.nixosModules.main-user
    outputs.nixosModules.home-files
  ];

  main-user.extraConfig.packages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = [
        extensions."13xforever".language-x86-64-assembly # won't work in the with scope
      ] ++ (with extensions; [
        basdp.language-gas-x86
        bbenoist.nix
        bierner.lit-html
        boyswan.glsl-literal
        codezombiech.gitignore
        colton.inline-html
        dbaeumer.vscode-eslint
        devkir.elixir-syntax-vscode
        dmitry-korobchenko.prototxt
        dtsvet.vscode-wasm
        dustypomerleau.rust-syntax
        emroussel.atomize-atom-one-dark-theme
        geforcelegend.vscode-glsl
        gimly81.fortran
        guyskk.language-cython
        idleberg.applescript
        jakebathman.mysql-syntax
        jeff-hykin.better-c-syntax
        jeff-hykin.better-cpp-syntax
        jeff-hykin.better-dockerfile-syntax
        jeff-hykin.better-go-syntax
        jeff-hykin.better-js-syntax
        jeff-hykin.better-objc-syntax
        jeff-hykin.better-objcpp-syntax
        jeff-hykin.better-perl-syntax
        jeff-hykin.better-shellscript-syntax
        jeff-hykin.better-syntax
        jep-a.lua-plus
        jgclark.vscode-todo-highlight
        jnoortheen.nix-ide
        jonwolfe.language-polymer
        justusadam.language-haskell
        karunamurti.haml
        kennethceyer.io
        ldez.ignore-files
        magicstack.magicpython
        mariomatheu.syntax-project-pbxproj
        mattn.lisp
        mechatroner.rainbow-csv
        ms-python.debugpy
        ms-python.python
        ms-python.vscode-pylance
        ms-vscode.cpptools
        ms-vsliveshare.vsliveshare
        oscarcs.dart-syntax-highlighting-only
        pkief.material-icon-theme
        pkief.material-product-icons
        qcz.text-power-tools
        radium-v.better-less
        rafamel.subtle-brackets
        rebornix.prolog
        redhat.java
        scala-lang.scala
        shopify.ruby-lsp
        sidneys1.gitconfig
        slevesque.shader
        streetsidesoftware.code-spell-checker
        syler.sass-indented
        tamasfe.even-better-toml
        toasty-technologies.octave
        visualstudioexptteam.intellicode-api-usage-examples
        visualstudioexptteam.vscodeintellicode
        yuce.erlang-otp
      ]);
    })
  ];

  home.file = {
    ".config/Code/User/settings.json".source = toJSON "settings" ({
      "update.mode" = "none";
      "extensions.autoCheckUpdates" = false;

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
    });
  };
}
