{
  vscode-with-extensions,

  vscodeExtensions ? []
}:
vscode-with-extensions.override { inherit vscodeExtensions; }