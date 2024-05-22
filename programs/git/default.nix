{ ... }: {
  # System
  programs.git = {
    enable = true;

    config = { init.defaultBranch = "main"; };
  };

  # User
  home-manager.users.frontear = {
    programs.git = {
      enable = true;

      delta = {
        enable = true;

        options = { line-numbers = true; };
      };

      signing = {
        key = "BCB5CEFDE22282F5";
        signByDefault = true;
      };

      userEmail = "perm-iterate-0b@icloud.com";
      userName = "Ali Rizvi";
    };
  };
}
