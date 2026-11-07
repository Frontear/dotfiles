{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.my.persist;
in {
  config = lib.mkIf cfg.enable {
    # Perform a late copy of contents into the persist as a one-off service.
    # This service attempts to orient itself after most compliant services are
    # shutdown (via `shutdown.target`), to ensure that copying can capture as
    # much as possible. For non-compliant services, this will possibly lose
    # some data, but it will be able to synchronise permissions, since that
    # is an extremely fast operation.
    #
    # The primary purpose of this service is to create a base-line directory
    # structure in the persistent volume with permissions copied over. This is
    # then used in the next boot to correctly synchronise permissions and create
    # the bind mounts. Copying data is a secondary objective to salvage as much
    # as possible for the next boot.
    systemd.services = lib.listToAttrs (map (path: {
      name = "persist-copy-${utils.escapeSystemdPath path.dst}";
      value = {
        unitConfig = {
          DefaultDependencies = "no";

          After = "shutdown.target";
          Before = "final.target";

          RequiresMountsFor = "${path.src}";

          ConditionPathExists = [
            "${path.dst}"
            "!${path.src}"
          ];
        };

        serviceConfig = {
          Type = "oneshot";

          ExecStart = [
            ("${lib.getExe pkgs.frontear.persist-make}"
              + " '/' '${lib.removeSuffix path.dst path.src}' '${path.dst}'")
            ("${lib.getExe' pkgs.coreutils "cp"}"
              # `--archive` copies all possible permission values to the target.
              # `--no-target-directory` treats the destination as a file.
              #
              # The reason we use `--no-target-directory` is for when we are
              # copying directories. `persist-make` creates the path up until
              # the source object itself. It's easiest to explain with visuals,
              # so imagine we have two paths: file `/foo` and directory `/bar`.
              #
              # The copy service would create all the parents for both paths
              # (in this case, no parents beside `/`), and will then create a
              # 'placeholder' entry, an empty file for `/foo` and an empty
              # directory for `/baz`. This manifests as `/nix/persist/.../foo`
              # and `/nix/persist/.../baz` respectively.
              #
              # The next `cp --archive` command would try to copy the object
              # with the respective content and permission modes. This was
              # done primarily for directories, and it worked fine for files
              # so it wasn't disambiguated. When the file `/foo` is given,
              # `cp --archive` can copy the file contents to the persist
              # path at `/nix/persist/.../foo`. Not an issue yet.
              # The issue is seen with `/bar`. When `cp --archive` tries to
              # copy `/bar` to the persist path, the intent was for it to copy
              # the files _within_ `/bar`, such as `/bar/1`, `/bar/2`, etc.
              # That's not what ended up happening. What actually happened
              # was it copied _into_ the path that `persist-make` made, so
              # `/bar` got copied to `/nix/persist/.../bar/bar`.
              #
              # This is obviously a mistake, and one I did notice on occasion
              # but didn't really prioritize it due to uncertainty on whether
              # it was a bug from me or some race condition. However,
              # I began to notice this consistently when setting up my new
              # laptop, which consistently nested the directories and broke
              # how they were expected to be.
              #
              # From rudimentary testing adding `--no-target-directory` does
              # not affect how files are handled, but it changes directories
              # by instead copying the contents of `/bar` into the persist
              # path rather than copying the directory into it. Essentially,
              # the contents of `/bar` go to `/nix/persist/.../bar`, rather
              # than having `/nix/persist/.../bar/bar`.
              + " '--archive' '--no-target-directory'"
              + " '${path.dst}' '${path.src}'"
            )
          ];
        };

        requiredBy = [ "final.target" ];
      };
    }) cfg.toplevel);
  };
}