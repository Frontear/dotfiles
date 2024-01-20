import { exec, configDir } from "./api/utils.js";

import { hyprbar } from "./windows/bar.js";
import { hyprosd } from "./windows/osd.js";
import { hyprrunner } from "./windows/runner.js";

exec(`sassc ${configDir}/style.scss /tmp/style.css`);
export default {
    style: "/tmp/style.css",
    windows: [
        hyprbar,
        hyprosd,
        hyprrunner
    ]
}
