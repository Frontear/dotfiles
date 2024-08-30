# An impure nix expression that tries to
# parse all packages part of the various
# programs.* nixos module options exposed
# in my.system and my.users.<name>

let
  inherit (builtins)
    attrValues
    filter
    getEnv
    getFlake
    map
    toString
    ;

  hostName = getEnv "HOSTNAME";
  flakeRef = (getFlake (toString ../.)).nixosConfigurations.${hostName};

  inherit (flakeRef.lib)
    concatLists
    pipe
    ;

  systemPackages = pipe flakeRef.config.my.system [
    attrValues
    (filter (x: x ? package))
    (map (x: x.package))
  ];

  userPackages = pipe flakeRef.config.my.users [
    attrValues
    (map (x: attrValues x.programs))
    concatLists
    (filter (x: x ? package))
    (map (x: x.package))
  ];
in systemPackages ++ userPackages