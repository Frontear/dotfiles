{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.niri;
in {
  config = lib.mkIf cfg.enable {
    my.programs.dms = {
      enable = true;

      session = {
        # Displays
        # TODO: does not automatically enable on first-run
        # "nightModeEnabled" = false; # is changed automatically
        "nightModeTemperature" = 5000;
        "nightModeHighTemperature" = 6500;
        "nightModeAutoEnabled" = true;
        "nightModeAutoMode" = "location";
        "nightModeUseIPLocation" = true;
      };

      settings = {
        # Time & Weather
        "use24HourClock" = true;
        "showSeconds" = false;
        "clockDateFormat" = "MMM d";
        "lockDateFormat" = ""; # value: System Default

        "weatherEnabled" = true;
        "useFahrenheit" = true;
        "useAutoLocation" = true;

        # Dank Bar
        "dankBarPosition" = 0; # value: "Top"
        "dankBarAutoHide" = false;
        "dankBarOpenOnOverview" = false;
        "dankBarSpacing" = 4; # should match Niri layout gaps + struts
        "dankBarBottomGap" = 0;
        "dankBarInnerPadding" = 0;
        "popupGapsAuto" = true;
        "dankBarSquareCorners" = false;
        "dankBarNoBackground" = false;
        "dankBarGothCornersEnabled" = false;
        "dankBarBorderEnabled" = false;

        "dankBarLeftWidgets" = [
          "launcherButton"
          "workspaceSwitcher"
          "focusedWindow"
        ];

        "dankBarCenterWidgets" = [
          "clock"
          "weather"
        ];

        "dankBarRightWidgets" = [
          "systemTray"
          "clipboard"
          "notificationButton"
          "battery"
          "controlCenterButton"
        ];

        # Widgets
        "showWorkspaceIndex" = false;
        "showWorkspacePadding" = false;
        "showWorkspaceApps" = false;
        "workspacesPerMonitor" = true;
        "waveProgressEnabled" = true;
        "updaterUseCustomCommand" = false;
        "runningAppsCurrentWorkspace" = false;
        "notificationPopupPosition" = 0; # value: Top Right
        "osdAlwaysShowValue" = false;

        # Dock
        "dockPosition" = 1; # value: Bottom
        "showDock" = true;
        "dockAutoHide" = false;
        "dockOpenOnOverview" = false;
        "dockGroupByApp" = false;
        "dockIndicatorStyle" = "line";
        "dockIconSize" = 36;
        "dockSpacing" = 2;
        "dockBottomGap" = -8;
        "dockMargin" = 4;
        "dockTransparency" = 0.25;

        # Launcher
        "launcherLogoMode" = "os";
        "launcherLogoColorOverride" = ""; # value: Default
        "launcherLogoSizeOffset" = 0;
        "launchPrefix" = "app2unit";
        "sortAppsAlphabetically" = false;

        # Theme & Colors
        "currentThemeName" = "monochrome";
        "dankBarTransparency" = 1;
        "dankBarWidgetTransparency" = 1;
        "popupTransparency" = 1;
        "cornerRadius" = 8; # should match Niri window-rule geometry-corner-radius
        "modalDarkenBackground" = true;
        # "fontWeight" = 400; # value: Default
        "fontScale" = 1;
        "syncModeWithPortal" = true;
        # "iconTheme" = "System Default";

        # Power & Security
        "lockScreenShowPowerActions" = true;
        "loginctlLockIntegration" = true;
        "lockBeforeSuspend" = true;
        "enableFprint" = false; # TODO: does not work?
        "preventIdleForMedia" = true;
        "acLockTimeout" = 2 * 60;
        "acMonitorTimeout" = 5 * 60;
        "acSuspendTimeout" = 0; # value: Never
        "acSuspendBehavior" = 0; # value: Suspend
        "batteryLockTimeout" = 2 * 60;
        "batteryMonitorTimeout" = 5 * 60;
        "batterySuspendTimeout" = 0; # value: Never
        "batterySuspendBehavior" = 0; # value: Suspend
        "powerActionConfirm" = true;
      };
    };
  };
}