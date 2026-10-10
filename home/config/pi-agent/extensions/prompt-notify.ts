/**
 * Prompt Notify — desktop notification when Pi waits on user input.
 *
 * pi-notify covers `agent_end` (agent finished). This covers the other
 * waiting state: blocking UI prompts (permission dialogs, path-access
 * asks, ask-user-question). All of them route through ctx.ui.select /
 * confirm / input / editor / custom, which pi wraps in `ui_prompt_start`.
 *
 * OSC plumbing mirrors pi-notify (same terminals, same behavior).
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// ponytail: duplicates pi-notify's OSC plumbing; extract a shared helper if a third notifier appears.
function wrapForTmux(sequence: string): string {
	if (!process.env.TMUX) return sequence;
	const escaped = sequence.split("\x1b").join("\x1b\x1b");
	return `\x1bPtmux;${escaped}\x1b\\`;
}

function notifyOSC777(title: string, body: string): void {
	process.stdout.write(wrapForTmux(`\x1b]777;notify;${title};${body}\x07`));
}

function notifyOSC9(message: string): void {
	process.stdout.write(wrapForTmux(`\x1b]9;${message}\x07`));
}

function notifyOSC99(title: string, body: string): void {
	process.stdout.write(wrapForTmux(`\x1b]99;i=1:d=0;${title}\x1b\\`));
	process.stdout.write(wrapForTmux(`\x1b]99;i=1:p=body;${body}\x1b\\`));
}

function notifyWindows(title: string, body: string): void {
	const type = "Windows.UI.Notifications";
	const mgr = `[${type}.ToastNotificationManager, ${type}, ContentType = WindowsRuntime]`;
	const template = `[${type}.ToastTemplateType]::ToastText01`;
	const toast = `[${type}.ToastNotification]::new($xml)`;
	const script = [
		`${mgr} > $null`,
		`$xml = [${type}.ToastNotificationManager]::GetTemplateContent(${template})`,
		`$xml.GetElementsByTagName('text')[0].AppendChild($xml.CreateTextNode('${body}')) > $null`,
		`[${type}.ToastNotificationManager]::CreateToastNotifier('${title}').Show(${toast})`,
	].join("; ");
	const { execFile } = require("node:child_process");
	execFile("powershell.exe", ["-NoProfile", "-Command", script]);
}

function notify(title: string, body: string): void {
	const isIterm2 = process.env.TERM_PROGRAM === "iTerm.app" || Boolean(process.env.ITERM_SESSION_ID);

	if (process.env.WT_SESSION) {
		notifyWindows(title, body);
	} else if (process.env.KITTY_WINDOW_ID) {
		notifyOSC99(title, body);
	} else if (isIterm2) {
		notifyOSC9(`${title}: ${body}`);
	} else {
		notifyOSC777(title, body);
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("ui_prompt_start", async (event) => {
		const { kind, title } = event as { kind?: string; title?: string };
		notify("Pi needs input", title || kind || "waiting for you");
	});
}
