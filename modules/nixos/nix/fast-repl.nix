# https://wiki.nixos.org/wiki/Flakes#Getting_Instant_System_Flakes_Repl
builtins // {
  inherit (import <nixpkgs> {}) pkgs lib;
}
