# Zsh autocomplete cheat-sheet

This dotfiles' [`.zshrc`](../zsh/.zshrc) loads four plugins that together make the shell much more helpful. This is a quick reference for what each does and how to drive it.

## The stack

| Plugin | Purpose |
|--------|---------|
| oh-my-zsh built-in | Tab completion for commands, flags, paths |
| **fzf-tab** | Replaces Tab with an `fzf` fuzzy picker over completions |
| **zsh-autosuggestions** | Faint gray inline suggestion of a past command |
| **zsh-syntax-highlighting** | Colors commands as you type (green = exists on PATH, red = does not) |
| **fzf** keybindings | `Ctrl-R` history, `Ctrl-T` files, `Alt-C` cd |

## Keybindings

| Key | What it does |
|-----|--------------|
| `Tab` | Open fzf picker over completions (fzf-tab) |
| `Tab`, then type | Fuzzy-filter the picker |
| `Enter` | Accept the highlighted completion |
| `Esc` | Cancel the picker |
| `→` or `End` | Accept the whole gray inline suggestion |
| `Ctrl-E` | Same — accept inline suggestion to end of line |
| `Ctrl-→` | Accept inline suggestion one word at a time |
| `Ctrl-R` | Fuzzy-search shell history |
| `Ctrl-T` | Fuzzy-search files under the current directory |
| `Alt-C` | Fuzzy-pick a subdirectory and `cd` into it |

## How each plugin behaves

### fzf-tab (the big upgrade)

When you start typing a command and hit `Tab`, fzf-tab kicks in:

1. Collects the completions zsh would normally offer.
2. Opens an `fzf` picker so you can fuzzy-filter them.
3. `Enter` picks one, `Esc` cancels.

Instead of cycling through 50 options, type a few letters and pick.

### zsh-autosuggestions

As you type, a faint gray suggestion appears showing a past command that starts the same way:

- `→` or `End` — accept the whole suggestion.
- `Ctrl-→` — accept just the next word.
- Keep typing to ignore it (it updates as you type).

This is **different from Tab completion**. Autosuggestions come from your history. Tab completion comes from what zsh knows about commands and files.

### zsh-syntax-highlighting

Cosmetic. Colors commands green if they exist on your PATH, red if they don't. No keybindings.

> Must be the **last** plugin in the `plugins=(...)` array — it hooks into the rendering pipeline last so other plugins don't override its colors.

### fzf keybindings (`Ctrl-R` / `Ctrl-T` / `Alt-C`)

These are global, not tied to any specific command:

- `Ctrl-R` — search every command you've ever run. Type to filter, `Enter` to fill it in, `Enter` again to run.
- `Ctrl-T` — search files under the current directory. Useful inside any command: type `vim `, hit `Ctrl-T`, pick a file.
- `Alt-C` — same idea but for `cd`. Picks a subdirectory and changes into it.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Tab` cycles options instead of opening fzf picker | fzf-tab not loaded. Check `plugins=(... fzf-tab ...)` in `~/.zshrc`, start a new shell. If still missing, re-run `make zsh` to clone the plugin into `~/.oh-my-zsh/custom/plugins/fzf-tab/`. |
| Gray suggestions don't appear | Plugin not loaded, or terminal theme makes them invisible. Try `export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'` in `~/.zshrc`. |
| `→` doesn't accept inline suggestion | Some terminals send a different escape for `→`. Use `End` or `Ctrl-E` instead. |
| `Ctrl-R` doesn't open fzf picker | fzf keybindings not sourced. `~/.zshrc` must include `source /opt/homebrew/opt/fzf/shell/key-bindings.zsh`. Confirm fzf is installed (`brew list fzf`). |
| `Alt-C` does nothing | macOS terminals often need Option set as `Meta`. In iTerm2: Settings → Profiles → Keys → set **Left Option** as `Esc+`. Apple Terminal: Settings → Profiles → Keyboard → **Use Option as Meta key**. |
| Syntax highlighting colors don't update | zsh-syntax-highlighting isn't last in the `plugins=(...)` array. Move it to the end. |
| Changes to `~/.zshrc` don't take effect | Reload: `source ~/.zshrc`, or open a new shell. |
