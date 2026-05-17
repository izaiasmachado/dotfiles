#!/usr/bin/env python3
"""
Sync iTerm2 UI changes into the committed plist, surgically.

Reads the committed plist (this repo) and the live one
(~/Library/Preferences/com.googlecode.iterm2.plist), deep-diffs them while
filtering out keys that are macOS/iTerm2 runtime state (window frames,
NoSync* machine-local values, last-update timestamps, etc.), shows the
meaningful changes, and applies just those keys after confirmation.

Why not just `cp` the live plist over the committed one: the live plist
accumulates runtime state every time iTerm2 runs. None of that belongs
in a versioned dotfiles repo. This script only touches keys you actually
changed in the UI.

Prerequisite: quit iTerm2 completely (Cmd+Q) before running. Changes
made in the UI live in memory until iTerm2 quits, then flush to the
live plist.

Usage:
    python3 scripts/iterm2-sync.py
"""

import plistlib
import subprocess
import sys
from pathlib import Path

# Keys (substring match on the dotted path) that are runtime state and
# should never be synced back into the repo. Extend when you find new ones.
NOISE_PATTERNS = (
    "NoSyncLast",
    "NoSyncNextAnnoyance",
    "NoSyncLaunchExperience",
    "NoSyncRestoreWindowsCount",
    "NoSyncTipOfTheDay",
    "NoSyncRecordedVariables",
    "NoSyncFrame_",
    "NoSyncInstallationId",
    "NoSyncPermissionToShowTip",
    "NoSyncRemoveDeprecatedKeyMappings",
    "NoSyncWindowRestoresWorkspaceAtLaunch",
    "NoSyncUserHasSelectedCommand",
    "NoSyncHaveUsedCopyMode",
    "NoSyncIgnoreSystemWindowRestoration",
    "NoSyncScrollingHorizontally",
    "NoSyncAllAppVersions",
    "SULastCheckTime",
    "NSWindow Frame",
    "NSSplitView Subview Frames",
    "iTerm Version",
)


def deep_diff(a, b, path=()):
    """Yield (path_tuple, committed_value, live_value) for every leaf that differs."""
    if type(a) != type(b):
        yield (path, a, b)
        return
    if isinstance(a, dict):
        for k in sorted(set(a) | set(b)):
            sub = path + (k,)
            if k not in a:
                yield (sub, None, b[k])
            elif k not in b:
                yield (sub, a[k], None)
            else:
                yield from deep_diff(a[k], b[k], sub)
    elif isinstance(a, list):
        if len(a) != len(b):
            yield (path, a, b)
            return
        for i, (x, y) in enumerate(zip(a, b)):
            yield from deep_diff(x, y, path + (i,))
    else:
        if a != b:
            yield (path, a, b)


def format_path(path):
    out = ""
    for p in path:
        if isinstance(p, int):
            out += f"[{p}]"
        else:
            out += ("." if out else "") + p
    return out


def is_noise(path_str):
    return any(n in path_str for n in NOISE_PATTERNS)


def short(v):
    s = repr(v)
    return s if len(s) <= 80 else s[:77] + "..."


def is_iterm_running():
    try:
        out = subprocess.check_output(
            ["pgrep", "-x", "iTerm2"], stderr=subprocess.DEVNULL
        )
        return bool(out.strip())
    except subprocess.CalledProcessError:
        return False


def repo_root():
    cur = Path(__file__).resolve().parent
    while cur != cur.parent:
        if (cur / "Makefile").exists() and (cur / "iterm2").is_dir():
            return cur
        cur = cur.parent
    raise SystemExit("Cannot locate dotfiles root (looking for Makefile + iterm2/)")


def main():
    root = repo_root()
    committed_path = root / "iterm2" / "com.googlecode.iterm2.plist"
    live_path = Path.home() / "Library/Preferences/com.googlecode.iterm2.plist"

    if not live_path.exists():
        sys.exit(f"Live prefs not found at {live_path}. Has iTerm2 ever been run?")

    if is_iterm_running():
        print("⚠️  iTerm2 is currently running.")
        print("    In-memory changes flush to disk only on quit.")
        print("    Cmd+Q in iTerm2, then re-run this script.")
        sys.exit(1)

    with open(committed_path, "rb") as f:
        committed = plistlib.load(f)
    with open(live_path, "rb") as f:
        live = plistlib.load(f)

    diffs = list(deep_diff(committed, live))
    meaningful = [(p, a, b) for (p, a, b) in diffs if not is_noise(format_path(p))]
    noisy = len(diffs) - len(meaningful)

    print(f"Total diffs: {len(diffs)} ({noisy} filtered as runtime noise)")
    if not meaningful:
        print("✅ Nothing meaningful to sync. Committed plist is up to date.")
        return

    print(f"\nMeaningful changes ({len(meaningful)}):\n")
    for path, old, new in meaningful:
        print(f"  {format_path(path)}")
        print(f"    committed: {short(old)}")
        print(f"    live:      {short(new)}")

    rel = committed_path.relative_to(root)
    ans = input(f"\nApply these {len(meaningful)} change(s) to {rel}? [y/N] ").strip().lower()
    if ans != "y":
        print("Aborted.")
        sys.exit(0)

    for path, _, new in meaningful:
        cur = committed
        for p in path[:-1]:
            cur = cur[p]
        cur[path[-1]] = new

    with open(committed_path, "wb") as f:
        plistlib.dump(committed, f, fmt=plistlib.FMT_BINARY)
    print(f"\n✅ Updated {rel}")
    print("\nNext steps:")
    print(f"  git diff --stat {rel}")
    print(f"  git add {rel}")
    print(f'  git commit -m "feat(iterm2): <describe change>"')


if __name__ == "__main__":
    main()
