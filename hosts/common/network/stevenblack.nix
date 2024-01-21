{
  inputs,
  ...
}: {
  # Pull Stevenblack's host file compilations straight from flake inputs.
  # This is preferable to using networking.stevenblack, since that one
  # is very behind, last I checked by like 6 months. Not ideal.
  networking.hostFiles = [
    "${inputs.stevenblack.outPath}/hosts"
  ];
}
