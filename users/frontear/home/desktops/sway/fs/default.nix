{
  lib,
  pkgs,
  stdenvNoCC,

  sassc,
}:
let
  # TODO: move `./bin` to the `pkgs` directory at root.
  screenshot = pkgs.callPackage ./bin/screenshot/package.nix {};
in stdenvNoCC.mkDerivation {
  name = "sway-env";

  src = with lib.fileset; toSource {
    root = ./.;
    fileset = unions [
      ./foot/foot.ini
      ./sway/backgrounds
      ./sway/config
      ./waybar/config.jsonc
      ./waybar/style.scss
    ];
  };

  nativeBuildInputs = [
    sassc
  ];

  buildPhase = ''
    sassc $src/waybar/style.scss waybar-style.css
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 $src/foot/foot.ini $out/foot/foot.ini
    install -Dm644 -t $out/sway/backgrounds $src/sway/backgrounds/*
    install -Dm644 $src/sway/config $out/sway/config
    install -Dm644 $src/waybar/config.jsonc $out/waybar/config.jsonc
    install -Dm644 waybar-style.css $out/waybar/style.css

    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/sway/config \
      --subst-var-by backgrounds $out/sway/backgrounds \
      --subst-var-by screenshot ${lib.getExe screenshot}
  '';
}
