import { Audio, Backlight, Battery, Hyprland, Network } from "../api/services.js";
import { Box, Button, CenterBox, Label, Window } from "../api/widgets.js";
import { exec, execAsync } from "../api/utils.js";

const os_logo = Button({
    className: "os_logo",
    css: "color: rgb(73, 214, 255);",
    child: Label({
        className: "icon",
        label: "󰣇"
    })
});

const separator = () => Label({
    className: "text",
    label: "|"
});

const workspaces = Box({
    hpack: "fill"
});

// setup -- box
const max_workspaces = 10;
for (let i = 1; i <= max_workspaces; ++i) {
    workspaces.add(Button({
        className: "workspace",
        connections: [[Hyprland, button => {
            button.toggleClassName("exists", Hyprland.getWorkspace(i) !== undefined);
            button.toggleClassName("active", i === Hyprland.active.workspace["id"]);
        }, "changed"]],
        child: Label({
            className: "icon",
            label: ""
        }),
        onClicked: () => execAsync(`hyprctl dispatch workspace ${i}`).catch(err => print(err))
    }));
}

// end setup -- box

const left_modules = Box({
    className: "modules",
    hpack: "start",
    children: [
        os_logo,
        separator(),
        workspaces
    ]
});

const title = Label({
    className: "text",
    connections: [[Hyprland, label => {
        label.label = Hyprland.active.client["title"] || "...";
    }]],
    maxWidthChars: 40
});

const center_modules = Box({
    className: "modules",
    hpack: "center",
    children: [
        title
    ]
});

const network = Label({
    className: "icon",
    connections: [[Network, label => {
        switch (Network.primary) {
            case "wired":
                label.label = "󰈀";
                break;
            case "wifi":
                let strength = Network.wifi?.strength;

                label.label = strength >= 80 ? "󰤨" : strength >= 60 ? "󰤥" : strength >= 40 ? "󰤢" : strength >= 20 ? "󰤟" : "󰤯";
                break;
            default:
                label.label = "󰤫";
                break;
        }
    }, "changed"]],
});

const volume = Label({
    className: "icon",
    connections: [[Audio, label => {
        let volume = Audio.value?.volume;

        if (Audio.value?.isMuted) {
            label.label = "󰝟";
        }
        else {
            label.label = volume >= 66 ? "󰕾" : volume >= 33 ? "󰖀" : "󰕿";
        }
    }]],
});

const backlight = Label({
    className: "icon",
    connections: [[Backlight, label => {
        let percent = Backlight.value?.percent;
        label.label = percent >= 95 ? "󰛨" : percent >= 90 ? "󱩖" : percent >= 80 ? "󱩕" : percent >= 70 ? "󱩔" : percent >= 60 ? "󱩓" : percent >= 50 ? "󱩒" : percent >= 40 ? "󱩑" : percent >= 30 ? "󱩐" : percent >= 20 ? "󱩏" : percent >= 10 ? "󱩎" : "󰛩";
    }]]
});

const battery = Label({
    className: "icon",
    connections: [[Battery, label => {
        let level = Battery.percent;

        if (Battery.charged) {
            label.label = "󱟢";
        }
        else if (Battery.charging) {
            label.label = level >= 98 ? "󰂅" : level >= 90 ? "󰂋" : level >= 80 ? "󰂊" : level >= 70 ? "󰢞" : level >= 60 ? "󰂉" : level >= 50 ? "󰢝" : level >= 40 ? "󰂈" : level >= 30 ? "󰂇" : level >= 20 ? "󰂆" : level >= 10 ? "󰢜" : "󰢟";
        }
        else {
            label.label = level >= 98 ? "󰁹" : level >= 90 ? "󰂂" : level >= 80 ? "󰂁" : level >= 70 ? "󰂀" : level >= 60 ? "󰁿" : level >= 50 ? "󰁾" : level >= 40 ? "󰁽" : level >= 30 ? "󰁼" : level >= 20 ? "󰁻" : level >= 10 ? "󰁺" : "󱃍";
        }
    }]],
});

const clock = Label({
    className: "text",
    connections: [[1000, label => {
        // TODO: Date object?
        execAsync(["date", "+%H:%M:%S"])
            .then(out => label.label = out)
            .catch(err => print(err));
    }]]
});

const right_modules = Box({
    className: "modules",
    hpack: "end",
    children: [
        network,
        volume,
        backlight,
        battery,
        separator(),
        clock
    ]
});

export const hyprbar = Window({
    hpack: "fill",
    child: CenterBox({
        startWidget: left_modules,
        centerWidget: center_modules,
        endWidget: right_modules
    }),
    name: "hyprbar",
    anchor: [ "top", "left", "right" ],
    exclusive: true
});

let gaps_out = JSON.parse(exec("hyprctl -j getoption general:gaps_out"))["int"];
hyprbar.margins = [ gaps_out, gaps_out, 0, gaps_out ]; // TOP, RIGHT, BOTTOM, LEFT
