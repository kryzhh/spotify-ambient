# Spotify Ambient for Noctalia

A local Noctalia plugin that follows Spotify playback, creates an ambient wallpaper from the album cover, and generates a dynamic Noctalia palette from the original artwork.

**Current package: 0.4.0** · **Noctalia 5.5.0+ / plugin API 25**

**OFFICIALLY PART OF NOCTALIA'S COMMUNITY PLUGINS. SEARCH `kryzhh/spotify-ambient`**

This repository contains the versioned source distribution under `releases/`. The full source, tests, translations, and development guide are included in that archive.

## Features

- Spotify MPRIS integration through `playerctl`; no Spotify API credentials or OAuth.
- Blurred ambient wallpaper generated from the album cover.
- Native Noctalia M3 Content palette generation from the original, unblurred cover.
- Dark and light palette variants; the user's Noctalia mode (including auto) remains in control.
- Palette includes album-derived terminal ANSI colours for Noctalia app templates such as Kitty.
- Saves the original color scheme and per-monitor wallpaper, then restores them on pause, stop, or Spotify disappearing.
- Does not overwrite user palettes or remove persistent state during an update.
- Better diagnostics: `doctor` report, process exit codes, captured stdout/stderr, Python tracebacks, and retry of failed render/apply operations.

## Requirements

- Noctalia Shell 5.5.0 or newer with plugin API 25 and the `noctalia theme` CLI.
- Spotify running in the same user session and exposing MPRIS player `spotify`.
- `playerctl`, Python 3.10+, and Pillow.
- A Linux desktop session where Noctalia and Spotify run as the same user.

### Install dependencies

Arch / CachyOS:

```bash
sudo pacman -S --needed git xz playerctl python python-pillow
```

Debian / Ubuntu:

```bash
sudo apt install git xz-utils playerctl python3 python3-pil
```

Fedora:

```bash
sudo dnf install git xz playerctl python3 python3-pillow
```

## Install

1. Clone this repository:

   ```bash
   git clone https://github.com/kryzhh/noctalia-spotify.git
   cd noctalia-spotify
   ```

2. Install the packaged plugin files:

   ```bash
   ./install.sh
   ```

   By default, this installs to:

   ```text
   ~/.local/share/noctalia/plugins/spotify-ambient/
   ```

   To use a non-default local plugin directory:

   ```bash
   NOCTALIA_PLUGIN_DIR="$HOME/.config/noctalia/plugins/spotify-ambient" ./install.sh
   ```

3. Enable it in **Noctalia Settings → Plugins**. Refresh/reload local plugins if it does not appear, then enable **Spotify Ambient** (`kryzhh/spotify-ambient`).

4. Start Spotify playback. No separate systemd user service is required.

The installer only copies plugin source files. It does not modify your persistent session state, wallpaper cache, palettes, Noctalia theme mode, or Spotify launcher/service.

## Verify and diagnose

Run the report using the installed plugin helper:

```bash
python3 ~/.local/share/noctalia/plugins/spotify-ambient/ambient.py doctor
```

Machine-readable form:

```bash
python3 ~/.local/share/noctalia/plugins/spotify-ambient/ambient.py doctor --json
```

When you use a custom `NOCTALIA_PLUGIN_DIR`, replace the path above with that install directory.

The report checks Python/Pillow, `playerctl`, Spotify MPRIS availability/status, Noctalia IPC, and the native image-theme CLI. A missing Spotify player is a warning when Spotify is simply closed. It intentionally excludes track titles, artwork URLs, credentials, and private file contents.

To inspect plugin logs:

```bash
journalctl --user -b --no-pager | grep -i 'spotify-ambient' | tail -n 150
```

The logs identify the failing stage and include child-process exit status and captured output. Python errors include tracebacks. Failed palette/wallpaper steps are retried on the next playback poll.

## Updating

Pull the latest repository and rerun the installer:

```bash
cd noctalia-spotify
git pull --ff-only
./install.sh
```

Then reload/refresh local plugins in Noctalia or restart Noctalia if required. Existing persistent state and wallpaper cache are intentionally retained.

## Uninstall

Disable **Spotify Ambient** in Noctalia Settings → Plugins first. Then:

```bash
rm -rf ~/.local/share/noctalia/plugins/spotify-ambient
```

This removes the plugin code only. To remove its generated data as well, inspect and then delete the plugin-owned directory:

```bash
rm -rf ~/.local/state/noctalia/plugins/data/kryzhh/spotify-ambient
```

Do not remove that state directory while playback is active; disable the plugin first so it can restore your original theme and wallpaper.

## Development and tests

The complete source and test suite are bundled in an XZ archive. For local development, reconstruct and extract it into a temporary directory:

```bash
WORK_DIR="$(mktemp -d)"
cat releases/parts/*.b64 | base64 --decode > "$WORK_DIR/spotify-noctalia-ambient.tar.xz"
xz --test "$WORK_DIR/spotify-noctalia-ambient.tar.xz"
tar -xJf "$WORK_DIR/spotify-noctalia-ambient.tar.xz" -C "$WORK_DIR"
cd "$WORK_DIR"

python3 -m unittest discover -s tests -v
python3 -m py_compile ambient.py tests/test_ambient.py
bash -n install.sh
```

The current Python suite contains 18 tests. The Luau service has been manually reviewed, but this release has not yet been verified with a standalone Luau compiler.

## Reporting bugs

Please include the output of `python3 ambient.py doctor`, the relevant `spotify-ambient` journal entries, Noctalia version, and the action that triggered the issue (first play, track switch, pause, resume, Spotify close, Noctalia reload, or display change).

Do not attach `state.json`, full Spotify metadata, credentials, or private artwork.

## Release contents

- `ambient.py` — artwork rendering, native palette generation, diagnostics.
- `service.luau` — Noctalia plugin service, MPRIS polling, snapshot/restore, failure retry.
- `plugin.toml` — plugin metadata and API version.
- `translations/en.json` — English strings.
- `tests/` — Python unit tests.
- `CONTRIBUTING.md` and `.github/` — contributor workflow and issue template.

The root `./install.sh` reconstructs the v0.4.0 source archive from the ordered text chunks in `releases/parts/`, verifies its XZ integrity, and runs the bundled installer. You do not need to decode or edit those chunks manually.

## License

MIT. See [LICENSE](LICENSE).
