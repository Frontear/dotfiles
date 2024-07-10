{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) concatLists isString;
  inherit (lib) attrValues mkOption types;

  fileOpts = { name, config, ... }: {
    options = {
      content = mkOption {
        default = null;
        description = ''
          Content that is written into the file. Can be a path or raw text.
        '';
        type = types.either types.path types.str;
        apply = v: if isString v then pkgs.writeText "" v else v;
      };

      perms = {
        user = mkOption {
          default = "root";
          description = ''
            The user who owns the file.
          '';
          type = types.str;
        };

        group = mkOption {
          default = "root";
          description = ''
            The group who owns the file.
          '';
          type = types.str;
        };

        mode = mkOption {
          default = "644";
          description = ''
            The modifiers on the file.
          '';
          type = types.str;
        };
      };

      impure = mkOption {
        default = false;
        description = ''
          Allow modification of the file after creation.
        '';
        type = types.bool;
      };

      target = mkOption {
        default = name;
        internal = true;
        readOnly = true;
      };
    };
  };
in {
  options.file = mkOption {
    default = {};
    description = ''
      Arbitrary files to be placed on the filesystem. Has optional
      purity adjustments, intended to be used for people who aren't
      interested in doing a rebuild for every small config change.

      Impure files can be given an optional permissions scheme. By default,
      this is user=root, group=root, mode=644. This permission is propagated
      to the file every time a rebuild occurs, or more specifically, whenever
      systemd-tmpfiles is resetup through systemd-tmpfiles-resetup.service.

      File content is placed onto the filesystem once. If purity is desired the file
      is a symlink to the /nix/store, otherwise it is a one-time placement of the original
      file contents, and is not changed unless the file is deleted and a rebuild issued.
    '';
    type = with types; attrsOf (submodule fileOpts);
    example = {
      "/home/user/.zshenv" = {
        text = ''
          export PATH="$HOME/.local/bin:$PATH"
        '';
      };
    };
  };

  config = {
    /*
    system.activationScripts = {
      file-linker.text = ''
      # $1 - Full path to file that must be created. This will not replace existing files.
      # $2 - Store derivation that is linked/copied in-place of file path. Assumed to exist
      # $3 - Whether the created file is linked impurely or not (readonly symlink vs in-place copy)

      function create() {
        if [ "$3" = "false" ]; then
          # If pure, doesn't matter if file exists or not, just force a symbolic link.
          ln -sfn "$2" "$1"
        elif [ ! -f "$1" ]; then
          # If impure and file doesn't exist, atomically copy-in-place and provide write permissions.
          cp "$2" "$1".bak
          mv "$1"{.bak,}
          chmod u+w "$1" # safe default
        fi
      }

      '' + (concatStringsSep "\n" (forEach (attrValues config.file) (f: ''create "${f.target}" "${f.source}" "${if f.impure then "true" else "false"}"'')));
    };
    */

    systemd.tmpfiles.rules = concatLists (map (f:
      if f.impure then
        [
          "C ${f.target} - - - - ${f.content}"
          "Z ${f.target} ${f.perms.mode} ${f.perms.user} ${f.perms.group} - -"
        ]
      else
        [
          "L+ ${f.target} - - - - ${f.content}"
        ]
    ) (attrValues config.file));
  };
}