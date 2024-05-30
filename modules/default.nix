rec {
  default = { ... }: {
    imports = [
      ./home-files
      ./impermanence
      ./zram
    ];
  };

  home-files = default;

  impermanence = default;
}