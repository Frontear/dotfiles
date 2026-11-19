{
  mkShell,

  app,
}:
mkShell {
  inputsFrom = [
    app
  ];

  packages = [
  ];
}