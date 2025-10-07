{
  vscode,
  vscode-with-extensions,

  withExtensions ? [],
}:
vscode-with-extensions.override {
  inherit vscode;

  vscodeExtensions = withExtensions;
}