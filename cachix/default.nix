# This is intended to be impure.
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
    pipe;

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