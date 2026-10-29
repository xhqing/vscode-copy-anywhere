<div align="center">
  <img src="assets/logo.svg" alt="vscode-copy-anywhere" width="640">

  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](LICENSE.md)
  [![Version](https://img.shields.io/badge/Version-0.1.1-blue)](CHANGELOG.md)
  [![Type](https://img.shields.io/badge/Type-macOS%20Tool-0D9488)](#)
  [![Visitors](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/xhqing/xhqing/main/traffic/badges/vscode-copy-anywhere.json)](https://github.com/xhqing)

  [简体中文](README_cn.md)
</div>

# vscode-copy-anywhere

`vscode-copy-anywhere` is a tiny background macOS helper: **copy a file in VSCode's Explorer (⌘C), then paste it anywhere** — Finder, WeChat, a browser upload box, any app that accepts files. VSCode file copies normally only paste back inside VSCode; vscode-copy-anywhere quietly fixes that in the background.

## The problem it solves

When you copy a file in VSCode's Explorer, VSCode writes only its **private clipboard format** (`code/file-list`) — a format designed for pasting *inside VSCode*. System apps don't understand it, so copying a file and pasting it into Finder (or anywhere outside VSCode) does nothing at all — regardless of file type (mp4, py, anything).

Verified by direct inspection with a native macOS pasteboard probe:

- After ⌘C in VSCode, the clipboard contains only `code/file-list` (macOS stores it under a dynamic UTI, `dyn.…`) — no `public.file-url`, no `NSFilenamesPboardType`, no text;
- Pressing ⌘V in a Finder folder afterwards: nothing is pasted;
- Writing the same file with native macOS formats instead: Finder pastes it correctly.

(The reverse direction — copying in Finder and pasting into VSCode's Explorer — is a long-standing VSCode limitation too, tracked as microsoft/vscode#239898.)

## How it works

A tiny LaunchAgent (`vscode-copy-anywhere`) polls the system clipboard every 0.2 s. When it sees VSCode's private `code/file-list` format (and the clipboard does not yet contain native file formats), it:

1. parses the file paths out of the URI list;
2. adds the formats macOS apps understand — `NSFilenamesPboardType` (Finder's classic file format), `public.file-url`, `text/uri-list` and plain-text paths;
3. keeps VSCode's original private data byte-for-byte (re-written under its original dynamic UTI) — so **pasting inside VSCode still works exactly as before** (verified).

Anything else you copy (plain text, images, content from any other app) is never touched. If VSCode ever adds native clipboard support itself, vscode-copy-anywhere detects the system formats already present and simply steps aside.

Implementation note: macOS converts the invalid UTI string `code/file-list` into a dynamic UTI (`dyn.…`) at the *item* level — invisible to item-level queries, but readable via the pasteboard-level API. vscode-copy-anywhere handles both sides of that mapping.

## Install & Requirements

- macOS (built and tested on Apple Silicon);
- Building from source requires the Xcode command line tools (`swiftc`) — or grab the prebuilt arm64 binary attached to each release;
- Then:

```bash
git clone https://github.com/xhqing/vscode-copy-anywhere.git
cd vscode-copy-anywhere
bash install.sh          # compile + install to ~/.local/bin + register the LaunchAgent (no sudo)
```

`install.sh` does three things: compile, copy the binary to `~/.local/bin/vscode-copy-anywhere`, and register the user-level LaunchAgent `com.xhq.vscode-copy-anywhere` (auto-starts at login).

Uninstall:

```bash
bash uninstall.sh        # stop + remove the LaunchAgent and the binary
```

## Verify it works

1. In VSCode's Explorer, select any file and press ⌘C;
2. Switch to Finder and press ⌘V — the file appears;
3. `tail -f ~/Library/Logs/vscode-copy-anywhere.log` shows a `bridged 1 file(s) to system clipboard` line.

## Managing the service

```bash
launchctl print gui/$UID/com.xhq.vscode-copy-anywhere | grep -E "state|pid"   # status
tail -f ~/Library/Logs/vscode-copy-anywhere.log                              # log
launchctl bootout gui/$UID/com.xhq.vscode-copy-anywhere                      # stop (reloads at next login)
launchctl bootstrap gui/$UID ~/Library/LaunchAgents/com.xhq.vscode-copy-anywhere.plist   # start again
bash uninstall.sh                                                  # remove entirely
```

## Limitations

- **Local workspaces only**: files copied from remote windows (SSH / WSL / containers) are skipped (logged as `skip: non-local uri`) — those files can't reach Finder anyway.
- Pasting within ~0.2 s of copying is an extreme race (a human normally can't); the bridge fires within about 0.2 s.
- Whether a target app accepts a pasted file is up to that app — vscode-copy-anywhere puts a proper file on the clipboard; consuming it is the app's part.

## Development vs Production

- **Development directory** = this repo (`~/Developer/vscode-copy-anywhere`); all changes happen here.
- **Production copy** = `~/.local/bin/vscode-copy-anywhere` — the binary the LaunchAgent actually runs.
- The production copy must come from a released artifact (tag + GitHub Release, built with `build.sh`) or from `install.sh` (which compiles a fresh copy); never symlink the dev directory into place or point the service at dev sources.
- Version markers: the source constant (`let version = "…"`) and the repo's `VERSION` file are kept in sync (enforced by CI).

## License & Attribution

Copyright (c) 2026 All Contributors. Released under the [MIT License](LICENSE.md).

Attribution: if you use or reference this project, please keep the copyright notice and credit the source: [vscode-copy-anywhere](https://github.com/xhqing/vscode-copy-anywhere).
