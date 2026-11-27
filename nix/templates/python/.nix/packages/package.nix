{
  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "app";
  version = "0.1.0";

  src = with lib.fileset; toSource {
    root = ../../app;
    fileset = unions [
      ../../app/src
      ../../app/pyproject.toml
    ];
  };

  pyproject = true;

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
  ];

  meta = with lib; {
    description = "App";
    homepage = "https://github.com/Frontear/<app>";

    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "app";
  };
})