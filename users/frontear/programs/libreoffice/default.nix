{
  pkgs,
  ...
}:
{
  my.programs.libreoffice = {
    enable = true;

    dictionaries = with pkgs.hunspellDicts; [
      en_CA
      en_US
    ];

    fonts = [ pkgs.corefonts ];
  };
}