{
  lib,
  ...
}:
let
  self' = {
    mkDefaultEnableOption = (name:
      (lib.mkEnableOption name) // { default = true; }
    );
  };
in
  self'