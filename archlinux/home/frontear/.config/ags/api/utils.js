import * as Utils from "resource:///com/github/Aylur/ags/utils.js";
import App from "resource:///com/github/Aylur/ags/app.js";

export const exec = Utils.exec;
export const execAsync = Utils.execAsync;

export const configDir = App.configDir;
export const closeWindow = (x) => App.closeWindow(x);
