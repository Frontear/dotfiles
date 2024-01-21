{
  ...
}: {
  # TODO: should /nix definition be moved here?
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "mode=755" "noatime" "size=1G" ];
    };
  };
}
