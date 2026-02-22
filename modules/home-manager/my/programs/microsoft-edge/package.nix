{
  microsoft-edge,

  fetchurl,

  commandLineArgs ? "",
}:
# Some fatal bug was messing with user files in version 145.0.3800.53, which has
# since been removed from their sources, causing a build failure.
#
# The PR that bumped the version has not landed in unstable, so we will override
# in-place until then.
#
# TODO: drop when the relevant PR lands in unstable.
# see: https://github.com/NixOS/nixpkgs/issues/492012
(microsoft-edge.overrideAttrs (finalAttrs: prevAttrs: {
  version = "145.0.3800.70";

  src = fetchurl {
    url = "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_${finalAttrs.version}-1_amd64.deb";
    hash = "sha256-gUyh9AD1ntnZb2iLRwKLxy0PxY0Dist73oT9AC2pFQI=";
  };
})).override {
  inherit commandLineArgs;
}