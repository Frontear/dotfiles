{ nix-vscode-extensions, ... }: ({ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.graphical;

  extensions = nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
in {
  config = mkIf cfg.enable {
    home-manager.users.frontear = { ... }: {
      programs.vscode = {
        enable = true;
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;

        extensions = [
            extensions."13xforever"."language-x86-64-assembly"
            extensions."basdp"."language-gas-x86"
            extensions."bbenoist"."nix"
            extensions."bierner"."lit-html"
            extensions."boyswan"."glsl-literal"
            extensions."codezombiech"."gitignore"
            extensions."colton"."inline-html"
            extensions."dbaeumer"."vscode-eslint"
            extensions."devkir"."elixir-syntax-vscode"
            extensions."dmitry-korobchenko"."prototxt"
            extensions."dtsvet"."vscode-wasm"
            extensions."dustypomerleau"."rust-syntax"
            extensions."emroussel"."atomize-atom-one-dark-theme"
            extensions."geforcelegend"."vscode-glsl"
            extensions."gimly81"."fortran"
            extensions."guyskk"."language-cython"
            extensions."idleberg"."applescript"
            extensions."jakebathman"."mysql-syntax"
            extensions."jeff-hykin"."better-c-syntax"
            extensions."jeff-hykin"."better-cpp-syntax"
            extensions."jeff-hykin"."better-dockerfile-syntax"
            extensions."jeff-hykin"."better-go-syntax"
            extensions."jeff-hykin"."better-js-syntax"
            extensions."jeff-hykin"."better-objc-syntax"
            extensions."jeff-hykin"."better-objcpp-syntax"
            extensions."jeff-hykin"."better-perl-syntax"
            extensions."jeff-hykin"."better-shellscript-syntax"
            extensions."jeff-hykin"."better-syntax"
            extensions."jep-a"."lua-plus"
            extensions."jgclark"."vscode-todo-highlight"
            extensions."jnoortheen"."nix-ide"
            extensions."jonwolfe"."language-polymer"
            extensions."justusadam"."language-haskell"
            extensions."karunamurti"."haml"
            extensions."kennethceyer"."io"
            extensions."ldez"."ignore-files"
            extensions."magicstack"."magicpython"
            extensions."mariomatheu"."syntax-project-pbxproj"
            extensions."mattn"."lisp"
            extensions."mechatroner"."rainbow-csv"
            extensions."ms-python"."debugpy"
            extensions."ms-python"."python"
            extensions."ms-python"."vscode-pylance"
            extensions."ms-vscode"."cpptools"
            extensions."ms-vsliveshare"."vsliveshare"
            extensions."oscarcs"."dart-syntax-highlighting-only"
            extensions."pkief"."material-icon-theme"
            extensions."pkief"."material-product-icons"
            extensions."qcz"."text-power-tools"
            extensions."radium-v"."better-less"
            extensions."rafamel"."subtle-brackets"
            extensions."rebornix"."prolog"
            extensions."redhat"."java"
            extensions."rust-lang"."rust-analyzer"
            extensions."scala-lang"."scala"
            extensions."shopify"."ruby-lsp"
            extensions."sidneys1"."gitconfig"
            extensions."slevesque"."shader"
            extensions."streetsidesoftware"."code-spell-checker"
            extensions."syler"."sass-indented"
            extensions."tamasfe"."even-better-toml"
            extensions."toasty-technologies"."octave"
            extensions."visualstudioexptteam"."intellicode-api-usage-examples"
            extensions."visualstudioexptteam"."vscodeintellicode"
            extensions."yuce"."erlang-otp"
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
          "workbench.productIconTheme" = "material-product-icons";
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
              "regex" = { "pattern" = ''(?<=^|"|\s)FIXME[:]?(?!\w)''; };
              "color" = "white";
              "backgroundColor" = "#e05561";
            }
            {
              "text" = "TODO";
              "regex" = { "pattern" = ''(?<=^|"|\s)TODO[:]?(?!\w)''; };
              "color" = "white";
              "backgroundColor" = "#42b3c2";
            }
            {
              "text" = "WARN";
              "regex" = { "pattern" = ''(?<=^|"|\s)WARN[:]?(?!\w)''; };
              "color" = "white";
              "backgroundColor" = "#d18f52";
            }
          ];
        };
      };
    };
  };
})