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

  # We prefer to use '~' as a prefix for our home-manager paths,
  # since it feels natural to type and use. This is obviously
  # not something that works when resolving paths, so we normalize
  # these paths to strip off the '~' and replace it with the user's
  # home directory.
  #
  # We intentionally perform the check to prevent breaking any paths
  # which are absolute. In the 99% case, these absolute paths are
  # to directories within the users control, so it won't pose a
  # permissions problem. In the 1% mishap, the activation will fail,
  # and I think that's sufficient.
  normalizeUserPaths = (config:
  let
    cfg = config.my.persist;
  in cfg.directories ++ cfg.files
    |> map (path:
      if lib.hasPrefix "~" path then
        config.home.homeDirectory + (lib.removePrefix "~" path)
      else
        path
    )
  );
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
        type = with lib.types; listOf path;

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
        |> map normalizeUserPaths
        |> lib.flatten
      )
    );

    home-manager.sharedModules = [{
      options = {
        # Ensure our custom paths are valid. We will resolve them later on so
        # this won't pose a problem.
        my.persist = commonOpts {
          type = with lib.types; listOf userPath;
        };
      };
    }];
  };
}
