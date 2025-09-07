{
  config,
  lib,
  ...
}:
let
  cfg = config.my.persist;

  toplevelSubmodule = {
    options = lib.genAttrs [ "src" "dst" ] (_: lib.mkOption {
      internal = true;
      readOnly = true;

      type = with lib.types; path;
    });
  };

  sharedPrefix = "shared";
  uniquePrefix = config.environment.etc.specialisation.text or "default";

  allPathVals =
    cfg.directories ++
    cfg.files ++ (
      lib.attrValues config.home-manager.users
      |> map (config: config.my.persist)
      |> map (cfg:
        cfg.directories ++
        cfg.files
      )
      |> lib.flatten
    );

  allShared =
    allPathVals
    |> lib.filter (x: !x.unique)
    |> map (x: x.path)
    |> lib.path.clobber
    |> map (path: {
      src = "${cfg.volume}/${sharedPrefix}/${path}";
      dst = "${path}";
    });

  allUnique =
    allPathVals
    |> lib.filter (x: x.unique)
    |> map (x: x.path)
    |> lib.path.clobber
    |> map (path: {
      src = "${cfg.volume}/unique/${uniquePrefix}/${path}";
      dst = "${path}";
    });

  toplevel = allShared ++ allUnique;
in {
  options = {
    my.persist = {
      toplevel = lib.mkOption {
        internal = true;
        readOnly = true;

        type = with lib.types; listOf (submodule toplevelSubmodule);
      };
    };
  };

  config = {
    my.persist = {
      inherit toplevel;
    };
  };
}
