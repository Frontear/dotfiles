{
  vscode,
  vscode-with-extensions,

  withExtensions ? [],
  withPackages ? (pkgs: []),
}:
vscode-with-extensions.override {
  vscode = vscode.fhsWithPackages withPackages;

  vscodeExtensions = withExtensions;
}