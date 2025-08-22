{
  ...
}:
{
  config = {
    # Enable SysRq in the event of system freeze, to help "gracefully" clean up.
    boot.kernel.sysctl."kernel.sysrq" = 1;
  };
}
