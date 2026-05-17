# SSH inbound (Remote Login)

How to make a Mac accept incoming SSH connections, then push a key from your laptop with `ssh-copy-id` so you stop typing passwords.

Assumes you've already generated a key on the client machine — see [ssh-keys.md](ssh-keys.md).

## 1. Enable Remote Login on the host

**System Settings → General → Sharing → toggle Remote Login on.**

Click the **(i)** next to it and choose **Allow access for: Only these users**, then add your user. "All users" works but breaks least-privilege if you ever add a guest or family account.

## 2. Find the machine's address

From the host, pick one:

**Local network (IP):**

```bash
ipconfig getifaddr en0   # wired
ipconfig getifaddr en1   # wifi
```

**mDNS (hostname):**

```bash
scutil --get HostName    # if empty, set it: sudo scutil --set HostName my-mac
```

The machine is then reachable as `my-mac.local` from other devices on the same LAN.

**Public address:** if the host is on a server with a routable IP or DNS name, use that directly.

## 3. Push your key with `ssh-copy-id`

From the client (your laptop), with `<address>` being whatever step 2 returned:

```bash
ssh-copy-id izaias@<address>
```

You'll be asked for the host's login password once. `ssh-copy-id` reads your public key (`~/.ssh/id_ed25519.pub`) and appends it to `~/.ssh/authorized_keys` on the host with the right permissions.

## 4. Verify

```bash
ssh izaias@<address>
```

Should drop you into a shell without prompting for a password. If it still prompts, jump to [Troubleshooting](#7-troubleshooting).

## 5. (Optional) Disable password authentication

After key auth works — and only after — you can refuse password logins entirely. Right call for a server that's always on.

On the host, create `/etc/ssh/sshd_config.d/99-local.conf`:

```
PasswordAuthentication no
ChallengeResponseAuthentication no
```

Reload sshd:

```bash
sudo launchctl kickstart -k system/com.openssh.sshd
```

> ⚠️ Do not skip step 4. If you disable passwords before keys work, your only way back in is local console access.

## 6. Network exposure

Where the host lives changes how aggressive you should be about hardening:

- **Trusted private network only** (home LAN, VPN, mesh network like Tailscale/ZeroTier) — Remote Login is generally safe. Step 5 (disable password auth) is still a good idea but not urgent.
- **Public internet** (cloud VM, port-forwarded home machine) — disable password auth (step 5) before you do anything else. Consider also: non-default SSH port, `fail2ban` or `sshguard`, restricting source IPs in `sshd_config`. Every internet-facing sshd is being brute-forced constantly.

If you don't need internet-wide reach, don't expose port 22 to the internet. A mesh VPN (Tailscale, ZeroTier, WireGuard) gives you the same "SSH from anywhere" without the attack surface.

## 7. Troubleshooting

| Symptom | Likely cause |
|---------|--------------|
| `Permission denied (publickey)` | Wrong key on client, or wrong `authorized_keys` content on host. Run `ssh -v <host>` to see which key is being offered. |
| `ssh-copy-id`: `ERROR: No identities found` | No public key in `~/.ssh/`. Generate one first — see [ssh-keys.md](ssh-keys.md). |
| Still prompts for password after `ssh-copy-id` | Wrong permissions on the host. `~/.ssh/` must be `700`, `~/.ssh/authorized_keys` must be `600`. Fix: `chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys`. |
| `Connection refused` | Remote Login not enabled, or sshd not running. Re-check step 1. |
| Can't reach the host at all | Wrong address. `ping <address>` to confirm reachability before debugging anything else. |

For verbose diagnostics: `ssh -v izaias@<host>` (or `-vv` / `-vvv` for more noise).
