{
  options,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.optionalAttrs (options ? isoImage) {
      services.displayManager.autoLogin.user = "frontear";
    })

    (lib.optionalAttrs (options ? wsl) {
      wsl.defaultUser = "frontear";
    })
  ];
}
