pkgs:
let
  delta = "${pkgs.delta}/bin/delta";
in {
  user.email = "perm-iterate-0b@icloud.com";
  user.name = "Ali Rizvi";
  user.signingKey = "BCB5CEFDE22282F5";

  commit.gpgSign = true;
  tag.gpgSign = true;

  # https:/dandavision.github.io/delta
  core.pager = "${delta}";
  interactive.diffFilter = "${delta} --color-only";
  delta.line-numbers = true;

  init.defaultBranch = "main";
}