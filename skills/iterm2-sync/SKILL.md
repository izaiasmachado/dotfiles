---
name: iterm2-sync
description: Use when the user has tweaked iTerm2 settings (profile colors, fonts, keymaps, hotkeys, dock behavior) and wants to capture those changes back into the committed plist in their dotfiles repo (~/dev/dotfiles/iterm2/com.googlecode.iterm2.plist). Runs skills/iterm2-sync/scripts/iterm2-sync.py to deep-diff committed vs live plist, filter runtime noise (window positions, telemetry, NSWindow Frame*, SULastCheckTime), confirm the meaningful changes, and apply them in place — preserves binary plist format. Refuses to run while iTerm2 is alive.
---

# iterm2-sync

## When to use this

You'll know it's time to use this skill when:
- The user says they tweaked something in iTerm2 → Settings and wants it versioned
- The user mentions iTerm2 prefs/profile drift between machines
- The user asks "how do I commit my iTerm2 settings"

The committed plist (`~/dev/dotfiles/iterm2/com.googlecode.iterm2.plist`) is the one iTerm2 loads at startup via its "Load preferences from custom folder" feature, but UI tweaks land in `~/Library/Preferences/com.googlecode.iterm2.plist` until synced back.

## Workflow

```bash
cd ~/dev/dotfiles                         # or wherever the dotfiles repo lives

# 1. Quit iTerm2 completely — UI changes live in memory until quit.
osascript -e 'quit app "iTerm"'

# 2. Run the sync script.
python3 skills/iterm2-sync/scripts/iterm2-sync.py
```

The script:
1. Reads committed and live plists.
2. Deep-diffs them, filtering runtime noise (`NSWindow Frame*`, `NoSync*`, `SULastCheckTime`, telemetry counters, etc).
3. Prints meaningful changes and asks for confirmation.
4. Applies only those keys to the committed plist, preserving binary plist format.

It will refuse to run if iTerm2 is still open.

## After confirming the sync

```bash
git diff --stat iterm2/com.googlecode.iterm2.plist
git add iterm2/com.googlecode.iterm2.plist
git commit -m "feat(iterm2): <describe the user-visible change>"
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| "iTerm2 is currently running" | The user didn't fully quit iTerm2. `Cmd+Q` (or `osascript -e 'quit app "iTerm"'`) and re-run. |
| "Nothing meaningful to sync" but the user did change something | The key they touched is in `NOISE_PATTERNS` (runtime state) and got filtered out. Inspect raw diff via `plutil -p` on both plists. |
| List-length change for `New Bookmarks` | The user added or deleted a whole profile. Confirming the sync copies the entire new list. |
| Committed file shrank a lot after sync | Normal — Python's `plistlib` writes a more compact encoding than Apple's writer. Verify only logical changes via `diff <(plutil -p old) <(plutil -p new)`. |

## Where everything lives

- Script: `~/dev/dotfiles/skills/iterm2-sync/scripts/iterm2-sync.py`
- Full doc with manual fallback (raw `plistlib` commands): `~/dev/dotfiles/docs/iterm2-sync.md`
- Live plist: `~/Library/Preferences/com.googlecode.iterm2.plist`
- Committed plist: `~/dev/dotfiles/iterm2/com.googlecode.iterm2.plist`
- Noise filter location (when you need to add more filtered keys): `NOISE_PATTERNS` at the top of `skills/iterm2-sync/scripts/iterm2-sync.py`
