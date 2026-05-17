# SSH keys

How to generate an SSH key on a fresh Mac and use it for GitHub, GitLab, or any server you SSH into.

## 1. Check for existing keys

```bash
ls -al ~/.ssh/
```

If you see `id_ed25519` and `id_ed25519.pub`, you already have a key — skip to [step 3](#3-add-to-the-keychain). RSA keys (`id_rsa`) still work, but ed25519 is shorter, faster, and stronger — generate a fresh one if you only have RSA.

## 2. Generate a new key

```bash
ssh-keygen -t ed25519 -C "izaiasmachado.dev@gmail.com"
```

- `-t ed25519` — modern algorithm, preferred over RSA on any host built in the last decade.
- `-C` — comment shown next to the key on remote servers. Your email is the convention.

Press **Enter** to accept the default path (`~/.ssh/id_ed25519`). You'll be asked for a passphrase — a passphrase is recommended, since the macOS keychain (next step) means you only type it once per login.

Two files appear:

- `~/.ssh/id_ed25519` — **private** key. Never share, never commit.
- `~/.ssh/id_ed25519.pub` — **public** key. Safe to share, paste anywhere.

## 3. Add to the keychain

Load the key into ssh-agent and store the passphrase in the macOS keychain:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

Then add this to `~/.ssh/config` so the key auto-loads in every session and the passphrase comes from the keychain:

```
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

Create the file if it doesn't exist:

```bash
touch ~/.ssh/config && chmod 600 ~/.ssh/config
```

## 4. Copy your public key to the clipboard

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

The key is now on your clipboard, ready to paste into a web form or `authorized_keys` file.

## 5. Register with GitHub

The `gh` CLI (already in this dotfiles' [Brewfile](../Brewfile)) does it in one command:

```bash
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(scutil --get LocalHostName)"
```

Test:

```bash
ssh -T git@github.com
```

You should see `Hi <username>! You've successfully authenticated…`.

## 6. Register with GitLab

```bash
glab ssh-key add ~/.ssh/id_ed25519.pub --title "$(scutil --get LocalHostName)"
```

Test:

```bash
ssh -T git@gitlab.com
```

## 7. What lives where

| File | Purpose | Permissions |
|------|---------|-------------|
| `~/.ssh/` | The directory itself | `700` |
| `~/.ssh/id_ed25519` | Private key. Never share, never commit. | `600` |
| `~/.ssh/id_ed25519.pub` | Public key. Safe to share. | `644` |
| `~/.ssh/config` | Per-user client config (hosts, keys, options). | `600` |
| `~/.ssh/known_hosts` | Servers you've connected to. Used to detect MITM. | `644` |
| `~/.ssh/authorized_keys` | Public keys allowed to log into _this_ machine — see [ssh-remote-login.md](ssh-remote-login.md). | `600` |

If permissions are too open, sshd silently refuses to use anything in `~/.ssh/`. Fix with:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/{id_ed25519,config,authorized_keys}
chmod 644 ~/.ssh/{id_ed25519.pub,known_hosts}
```
