{ ... }: {
  # System
  programs.light = {
    enable = true;
  };
  users.users.frontear.extraGroups = [ "video" ];
}