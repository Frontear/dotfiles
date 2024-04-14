{ outputs, config, ... }: {
  imports = [
    outputs.nixosModules.main-user
  ];

  # System
  programs.light = {
    enable = true;
  };
  users.users.${config.main-user.name}.extraGroups = [ "video" ];
}