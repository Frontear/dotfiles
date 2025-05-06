{
  config,
  lib,
  ...
}:
let
  cfg = config.my.persist;

  # Common module options shared between NixOS and Home-Manager.
  # `attrs` allows for minimal extensability in the necessary context.
  commonOpts = attrs: lib.genAttrs [ "directories" "files" ] (_: lib.mkOption {
    default = [];

    type = with lib.types; listOf systemPath;
  } // attrs);

  # Convert our finalized list of unique path entries into a compact attrset
  # that exposes the source and destination paths for our entry. This is very
  # useful for the configuration to resolve things without needing to manually
  # append `${cfg.volume}/${path}` everywhere. It also exposes a consistent
  # place to modify the `src` in the case of specification-specific persistence.
  toplevelSubmodule = {
    options = lib.genAttrs [ "src" "dst" ] (_: lib.mkOption {
      type = with lib.types; path;

      readOnly = true;
      internal = true;
    });
  };

  # Optimizes a list of filesystem directories by intelligently
  # deciding which are redundant based on whether their parents
  # exist as part of the list.
  #
  # The simple description of this algorithm is as follows:
  # 1. Break down each path into an attribute set
  # 2. Sort these attribute sets to ensure the shortest
  #    paths are at the bottom of the list
  # 3. Recursively merge them into one another, which
  #    will destructively merge the shorter parents into
  #    any existing children, thereby "optimizing" them
  # 4. Join them back into a valid path string
  optimizePaths = (paths: (
  let
    splitList = (paths: lib.forEach paths (path:
      lib.splitString "/" path
      |> lib.filter (x: x != "")
    ));

    joinAttrs = (delim: attrs: (map (n:
      if attrs.${n} == null then
        "${delim}${n}"
      else
        joinAttrs "${delim}${n}/" attrs.${n}
    ) (lib.attrNames attrs)));
  in splitList paths
    |> lib.sort (e1: e2: lib.length e1 > lib.length e2)
    |> map (path: lib.setAttrByPath path null)
    |> lib.foldl lib.recursiveUpdate {}
    |> joinAttrs "/"
    |> lib.flatten
  ));
in {
  options = {
    my.persist = {
      enable = lib.mkEnableOption "persist";

      volume = lib.mkOption {
        default = "/nix/persist";

        type = with lib.types; path;

        readOnly = true;
        internal = true;
      };

      toplevel = lib.mkOption {
        type = with lib.types; listOf (coercedTo path (path: {
          src = "${cfg.volume}/${path}";
          dst = "${path}";
        }) (submodule toplevelSubmodule));

        readOnly = true;
        internal = true;
      };
    } // commonOpts {};
  };

  config = {
    # Optimize all the important paths from all users and the system.
    my.persist.toplevel = optimizePaths (
      cfg.directories ++
      cfg.files ++ (
        lib.attrValues config.home-manager.users
        |> map (config: config.my.persist)
        |> map (cfg: cfg.directories ++ cfg.files)
        |> lib.flatten
      )
    );

    home-manager.sharedModules = [({ config, ... }: {
      options = {
        my.persist = commonOpts {
          # Manipulate our paths to be normal directories here to make it easier
          # later, when resolving the `toplevel` attribute.
          type = with lib.types; listOf (coercedTo userPath (path:
            lib.replaceStrings [ "~" ] [ "${config.home.homeDirectory}" ] path
          ) path);
        };
      };
    })];
  };
}
