{
  pkgs,
  ...
}:
{
  my.programs.vscode = {
    enable = true;

    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix);

    packages = pkgs: with pkgs; [
      # For `ms-vscode.cpptools`
      gcc-unwrapped
      gdb

      # For `dbaeumer.vscode-eslint`
      eslint

      # For `redhat.java
      openjdk21

      # For `jnoortheen.nix-ide`
      nixd

      # For `ms-python.python`
      python3

      # For `rust-lang.rust-analyzer`
      rust-analyzer
    ];

    settings = import ./settings.nix;
  };
}