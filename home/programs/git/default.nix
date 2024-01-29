{ ... }: {
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        delta = {
          line-numbers = true;
          side-by-side = true;
        };
      };
    };
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
    signing = {
      key = "BCB5CEFDE22282F5";
      signByDefault = true;
    };
    userEmail = "perm-iterate-0b@icloud.com";
    userName = "Ali Rizvi";
  };
}
