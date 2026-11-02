#!/usr/bin/env python3
"""Rename the clicked workspace without changing its numeric shortcut.

Waybar's first click focuses the workspace; its double-click opens this prompt.
Capture the workspace ID before opening the dialog so later focus changes cannot
rename the wrong workspace. Names last for the lifetime of the workspace.
"""

import fcntl
import json
import os
from pathlib import Path
import subprocess
import unicodedata


def workspaces():
    return json.loads(subprocess.check_output(["swaymsg", "-t", "get_workspaces"]))


def rename(workspace, label):
    label = label.strip()
    # Sway command punctuation is deliberately excluded; names never become
    # shell commands or extra IPC commands. Pango markup is disabled in Waybar.
    if any(c in '\\";,\n\r' or unicodedata.category(c).startswith("C") for c in label):
        raise ValueError("Use a name without quotes, backslashes, commas or semicolons.")
    number = workspace["num"]
    if number < 1:
        raise ValueError("This workspace has no numeric shortcut to preserve.")
    current = next((w for w in workspaces() if w["id"] == workspace["id"]), None)
    if current is None:
        raise ValueError("That workspace closed while the name prompt was open.")
    new_name = f"{number}:{label}" if label else str(number)
    if current["name"] == new_name:
        return
    command = f'rename workspace {json.dumps(current["name"], ensure_ascii=False)} to {json.dumps(new_name, ensure_ascii=False)}'
    result = json.loads(subprocess.check_output(["swaymsg", command]))
    if not all(item.get("success") for item in result):
        raise ValueError("Sway could not rename the workspace.")


def main():
    runtime = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))
    with (runtime / "workspace-rename.lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        workspace = next((w for w in workspaces() if w["focused"]), None)
        if workspace is None:
            return
        label = workspace["name"].partition(":")[2]
        prompt = subprocess.run(
            ["rofi", "-dmenu", "-p", f'Workspace {workspace["num"]} name',
             "-filter", label, "-lines", "0",
             "-kb-remove-char-forward", "Control+d", "-kb-clear-line", "Delete,Control+w",
             "-mesg", "Delete: clear · Enter: save · Esc: cancel · Empty: number only"],
            input="", capture_output=True, text=True,
        )
        if prompt.returncode != 0:
            return
        try:
            rename(workspace, prompt.stdout.rstrip("\n"))
        except ValueError as error:
            subprocess.run(["notify-send", "Workspace name", str(error)], check=False)


if __name__ == "__main__":
    main()
