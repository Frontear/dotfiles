{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) baseNameOf concatStringsSep isString replaceStrings;
  inherit (lib) attrValues concatLists forEach getExe mapAttrsToList mkOption types;

  system-files = attrValues config.my.system.file;
  user-files = concatLists (mapAttrsToList (_: v: attrValues v.file) config.my.users);
  all-files = system-files ++ user-files;

  # I do not like the attr -> attr thing, but idk how else to work it.
  fileOpts = { user, group, from, to }: { name, ... }: {
    options = {
      content = mkOption {
        default = null;
        description = ''
          Content that is written into the file. Can be a path or raw text.
        '';
        type = types.either types.path types.str;
        apply = v: if isString v then pkgs.writeText (replaceStrings [ "." ] [ "-" ] (baseNameOf name)) v else v;
      };

      user = mkOption {
        default = user;
        description = ''
          The user who owns the file.
        '';
        type = types.str;
      };

      group = mkOption {
        default = group;
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
        apply = x: replaceStrings from to x;
      };
    };
  };

  mkFileOption = { example, user, group, from, to }: mkOption {
    default = {};
    inherit example;
    description = ''
      Arbitrary files to be placed on the filesystem. Has optional
      purity adjustments, intended to be used for people who aren't
      interested in doing a rebuild for every small config change.

      Impure files can be given an optional permissions scheme. By default,
      this is user=root, group=root, mode=644. This permission is propagated
      to the file every time a rebuild occurs via an activation script. This
      can be forced by running the script found at `/run/current-system/activate`.

      File content is placed onto the filesystem once. If purity is desired the file
      is a symlink to the /nix/store, otherwise it is a one-time placement of the original
      file contents, and is not changed unless the file is deleted and a rebuild issued.
    '';
    type = with types; attrsOf (submodule (fileOpts { inherit user group from to; }));
  };

  userOpts = { config, ... }: {
    options = {
      file = mkFileOption {
        user = config.username;
        group = "users";
        from = [ "~" ];
        to = [ config.homeDirectory ];

        example = {
          "~/.zshenv" = {
            content = ''
              export PATH="$PATH:$HOME/.local/bin"
            '';
          };
        };
      };
    };
  };
in {
  options = {
    my.system.file = mkFileOption {
      user = "root";
      group = "root";
      from = [];
      to = [];

      example = {
        "/etc/resolv.conf" = {
          content = ''
            nameserver 1.1.1.1
            nameserver 8.8.8.8
          '';
        };
      };
    };

    my.users = mkOption {
      type = with types; attrsOf (submodule userOpts);
    };
  };

  config = {
    system.activationScripts = {
      place-files.text = ''
        # $1 - Path to file written in the /nix/store
        # $2 - Absolute path to where the file will be placed
        # $3 - User value for 'chown', ignored if impure = false
        # $4 - Group value for 'chown', ignored if impure = false
        # $5 - Mode value for 'chmod', ignored if impure = false
        # $6 - Whether the file is placed with the possibility to impurely modify it
        #
        # File exists:
        # - Impure: if symlink to /nix/store then replace, else update permissions only.
        # - Pure: if symlink to /nix/store then replace, else error
        #
        # File not exists:
        # - Impure: Copy in place and set perms
        # - Pure: Symlink in place
        #
        function placeFile() {
          mkdir -pv "$(dirname "$2")" | ${getExe pkgs.gnused} "s|'||g;s|.* ||g" | while read dir; do
            chown "$3:$4" "$dir"
            chmod "755" "$dir"
          done

          if [ -f "$2" ]; then
            if [ "$6" = "false" ]; then
              if [[ "$(readlink -f "$2")" =~ ^/nix/store/* ]]; then
                ln -Tsf "$1" "$2"
              else
                echo "File exists at $2, will not replace."
              fi
            else
              if [[ "$(readlink -f "$2")" =~ ^/nix/store/* ]]; then
                rm -f "$2"
                cat "$1" > "$2"
              fi
              chown "$3:$4" "$2"
              chmod "$5" "$2"
            fi
          else
            if [ "$6" = "false" ]; then
              ln -Tsf "$1" "$2"
            else
              rm -f "$2"
              cat "$1" > "$2"
              chown "$3:$4" "$2"
              chmod "$5" "$2"
            fi
          fi
        }

      '' + concatStringsSep "\n" (forEach all-files (f: ''placeFile "${f.content}" "${f.target}" "${f.user}" "${f.group}" "${f.mode}" "${if f.impure then "true" else "false"}"''));
    };
  };
}
