# Syncing iTerm2 UI changes into the dotfiles

When you tweak something in **iTerm2 → Settings**, the change goes into your live prefs file (`~/Library/Preferences/com.googlecode.iterm2.plist`). The committed plist in this repo (`iterm2/com.googlecode.iterm2.plist`) is loaded at iTerm2 startup but isn't automatically updated from the UI — that's deliberate, so the committed file stays clean.

This is the workflow to capture those UI changes back into the repo.

## Why not just `cp` the live plist?

iTerm2's live plist accumulates **runtime state every time it runs**: window positions, recent commands, installation IDs, "last OS version seen", telemetry counters, color-panel sizes. None of that belongs in a versioned dotfiles repo, and you'd see it constantly polluting your diffs.

The clean approach is to **only sync the keys you actually changed**.

## The script

[`skills/iterm2-sync/scripts/iterm2-sync.py`](../skills/iterm2-sync/scripts/iterm2-sync.py) does the whole flow:

1. Reads the committed and live plists.
2. Deep-diffs them, filtering out runtime-noise keys (`NSWindow Frame*`, `NoSync*`, `SULastCheckTime`, etc.).
3. Prints the meaningful changes and asks for confirmation.
4. Applies just those keys to the committed plist, preserving binary plist format.

### Usage

```bash
# 1. Make your changes in iTerm2 → Settings.
# 2. Quit iTerm2 completely:
osascript -e 'quit app "iTerm"'      # or Cmd+Q from inside iTerm2

# 3. Sync:
python3 skills/iterm2-sync/scripts/iterm2-sync.py
```

The script will refuse to run if iTerm2 is still up — UI changes live in memory until quit, so a sync now would miss them.

### Example output

```
Total diffs: 4 (3 filtered as runtime noise)

Meaningful changes (1):

  OpenBookmark
    committed: True
    live:      False

Apply these 1 change(s) to iterm2/com.googlecode.iterm2.plist? [y/N] y

✅ Updated iterm2/com.googlecode.iterm2.plist

Next steps:
  git diff --stat iterm2/com.googlecode.iterm2.plist
  git add iterm2/com.googlecode.iterm2.plist
  git commit -m "feat(iterm2): <describe change>"
```

## Doing it manually (without the script)

If you want to understand what the script is doing — or you only have a one-off tweak — the same workflow in raw commands:

```bash
# 1. Quit iTerm2 (Cmd+Q).

# 2. Diff committed vs live:
python3 -c "
import plistlib, os
def load(p):
    with open(p, 'rb') as f: return plistlib.load(f)
c = load('iterm2/com.googlecode.iterm2.plist')
l = load(os.path.expanduser('~/Library/Preferences/com.googlecode.iterm2.plist'))
# (write deep_diff here, or eyeball top-level keys)
"

# 3. Apply just the key you care about:
python3 -c "
import plistlib
p = 'iterm2/com.googlecode.iterm2.plist'
with open(p, 'rb') as f: d = plistlib.load(f)
d['OpenBookmark'] = False     # your change here
with open(p, 'wb') as f: plistlib.dump(d, f, fmt=plistlib.FMT_BINARY)
"

# 4. Verify exactly one line changed in the textual plist representation:
git show HEAD:iterm2/com.googlecode.iterm2.plist > /tmp/iterm2-head.plist
diff <(plutil -p /tmp/iterm2-head.plist) <(plutil -p iterm2/com.googlecode.iterm2.plist)

# 5. Commit.
```

The textual diff (`diff` between two `plutil -p` outputs) is the truth — the binary plist size will often shrink because Python's `plistlib` writes a more compact encoding than Apple's writer, even though the logical content is identical.

## Adding new noisy keys to the filter

If the script reports something as a "meaningful change" that's clearly runtime state (you'll know because it shows up every time you sync, regardless of what you did), add it to `NOISE_PATTERNS` at the top of [`skills/iterm2-sync/scripts/iterm2-sync.py`](../skills/iterm2-sync/scripts/iterm2-sync.py). The match is a substring against the dotted path.

## Troubleshooting

| Symptom | Cause / Fix |
|---------|-------------|
| Script bails with "iTerm2 is currently running" | You didn't quit iTerm2 fully. `Cmd+Q` (or `osascript -e 'quit app "iTerm"'`) and re-run. |
| "Nothing meaningful to sync" but you _did_ change something | iTerm2 might not have flushed yet — wait a second after quit and retry. Or you changed something inside `NOISE_PATTERNS` and the script is filtering it; check the raw diff with plutil. |
| Script shows a list-length change for `New Bookmarks` | You added or deleted a whole profile. Confirming the sync copies the entire new list of profiles. |
| Committed file shrunk a lot after sync | Normal — `plistlib` writes a more compact binary encoding than the macOS writer. Verify with `diff <(plutil -p HEAD-version) <(plutil -p current)` — only the logical changes should show up. |
