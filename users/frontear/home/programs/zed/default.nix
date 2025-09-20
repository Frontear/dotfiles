{
  config,
  pkgs,
  ...
}:
{
  config = {
    # TODO: extensions install node binaries, which does NOT work on NixOS.
    # Figure out a proper fix for this, or else this editor is useless.
    #
    # see: https://wiki.nixos.org/wiki/Zed#LSP_Support
    programs.zed-editor = {
      enable = true;

      extensions = [
        "material-icon-theme"
        "one-dark-pro"

        "basher"
        "java"
        "nix"
      ];

      extraPackages = with pkgs; [
        openjdk21
        nixd
      ];

      # https://zed.dev/docs/key-bindings
      userKeymaps = [
        {
          context = "Editor && vim_mode == normal";
          bindings = {
            "ctrl-w" = "pane::CloseActiveItem";
          };
        }
      ];

      # https://zed.dev/docs/configuring-zed
      userSettings = {
        "auto_update" = false;
        "disable_ai" = true;

        "base_keymap" = "VSCode";
        "vim_mode" = true;

        "buffer_font_family" = config.stylix.fonts.monospace.name;
        "buffer_font_size" = config.stylix.fonts.sizes.applications;
        "ui_font_family" = config.stylix.fonts.sansSerif.name;
        "ui_font_size" = config.stylix.fonts.sizes.applications;

        # Disable ligatures as neither of my fonts support it.
        "buffer_font_features"."calt" = false;
        "ui_font_features"."calt" = false;

        "icon_theme" = "Material Icon Theme";
        "theme" = {
          "mode" = "dark";
          "dark" = "One Dark Pro";
          "light" = "One Light"; # necessary to declare apparently..
        };

        "inlay_hints"."enabled" = true;

        # Mirrored from VSCode
        "autosave" = "on_focus_change";
        "minimap"."show" = "never";

        "cursor_blink" = true;
        "cursor_shape" = "bar";

        "preferred_line_length" = 80;
        "soft_wrap" = "bounded";

        # NOTE: this mimics the `.editorconfig`, may not be necessary
        "tab_size" = 2;
        "hard_tabs" = false;
        "ensure_final_newline_on_save" = false;
        "remove_trailing_whitespace_on_save" = true;
      };
    };
  };
}