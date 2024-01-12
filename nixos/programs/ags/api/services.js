import ServiceApplications from "resource:///com/github/Aylur/ags/service/applications.js";
import ServiceHyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";
import ServiceBattery from "resource:///com/github/Aylur/ags/service/battery.js";
import ServiceNetwork from "resource:///com/github/Aylur/ags/service/network.js";
import Variable from "resource:///com/github/Aylur/ags/variable.js";

export const Applications = ServiceApplications;
export const Audio = Variable(undefined, {
    listen: [["sysd", "audio", "-m"],
        out => {
            let split = out.split(":");

            return {
                volume: Number(split[0]),
                isMuted: split[1] === "[MUTED]"
            };
        }
    ]
});
export const Backlight = Variable(undefined, {
    listen: [["sysd", "backlight", "-m"],
        out => {
            return {
                percent: Number(out)
            };
        }
    ]
});
export const Battery = ServiceBattery;
export const Hyprland = ServiceHyprland;
export const Network = ServiceNetwork;
