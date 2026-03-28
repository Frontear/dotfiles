{
  microsoft-edge,

  commandLineArgs ? "",
}:
microsoft-edge.override {
  inherit commandLineArgs;
}