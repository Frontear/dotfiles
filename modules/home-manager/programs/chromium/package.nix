{
  chromium,

  commandLineArgs ? "",
}:
chromium.override {
  inherit commandLineArgs;
}
