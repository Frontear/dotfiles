{
  ...
}:
{
  my.programs.gnupg = {
    enable = true;

    agent = {
      enable = true;
      enableSSHSupport = true;

      sshKeys = [ "AF4BF6EE3E68FD7576667BE7D8A7CFA50BC8E9F2" ];
    };
  };
}