# MPD – Music Player Daemon

This add-on runs [Music Player Daemon](https://www.musicpd.org/) on your Home Assistant host (e.g. **Home Assistant Yellow**, Green, Blue, or any HA OS / Supervised install).

**Two ways to run it:**

- **Standard (Alpine package):** Add this repo in HA and install the add-on. You get the distro’s MPD (no build step).
- **Your modified MPD (from source):** Build the add-on image from your repo, push it to a container registry, and point the add-on at that image in your fork. Then add your fork as the repo in HA. See [Running your modified MPD on HA Yellow](#running-your-modified-mpd-on-ha-yellow) below.

## Installation

1. Add this repository in Home Assistant:
   - **Settings** → **Add-ons** → **Add-on store** → ⋮ (top right) → **Repositories**
   - Add: `https://github.com/MusicPlayerDaemon/MPD` or **your repo** (e.g. `https://github.com/FromAbyssStudio/MPD`)
   - Click **Save**

2. Install the **MPD** add-on from the list, then **Start** it.

3. Add the MPD integration so Home Assistant can control it:
   - **Settings** → **Devices & services** → **Add Integration**
   - Search for **MPD** (or **Music Player Daemon**)
   - **Host:** `127.0.0.1` (same machine)
   - **Port:** `6600`

## Configuration

| Option | Description | Default |
|--------|-------------|---------|
| `media_folder` | Path used as MPD `music_directory` (use HA media path to share with HA) | `/media` |
| `playlist_folder` | Path for MPD playlists | `/media/playlists` |
| `port` | MPD TCP port | `6600` |
| `zeroconf_enabled` | Advertise MPD via Zeroconf/mDNS | `true` |

The add-on mounts Home Assistant’s **share** and **media** into the container. Set `media_folder` to e.g. `/media` or `/share/music` so MPD can see your files. If you use **Media Source** in HA, `/media` is the usual location.

## Usage

- Control playback from **Settings** → **Devices & services** → your MPD **media_player** entity (cards, automations, scripts).
- Use any MPD client (e.g. `mpc`, ncmpcpp, Cantata) pointing at your HA host and port `6600`.

For more details and MCP/Cursor setup, see [docs/HOMEASSISTANT.md](https://github.com/MusicPlayerDaemon/MPD/blob/master/docs/HOMEASSISTANT.md) in this repo.

---

## Running your modified MPD on HA Yellow

You have your own copy of the MPD repo with your changes and want that build running on **Home Assistant Yellow** (or any HA host). Do this:

1. **Build the add-on image from your repo** (from the repo root). HA Yellow is **aarch64**:
   ```bash
   cd /path/to/your/mpd/repo
   chmod +x addon/mpd/build-fromsource.sh
   ./addon/mpd/build-fromsource.sh aarch64
   ```
   Or with Docker directly:
   ```bash
   docker build -f addon/mpd/Dockerfile.fromsource \
     --build-arg BUILD_FROM=alpine:3.19 \
     --platform linux/aarch64 \
     -t ghcr.io/YOUR_USERNAME/mpd-aarch64 .
   ```

2. **Push the image** to a container registry (e.g. GitHub Container Registry):
   ```bash
   docker push ghcr.io/YOUR_USERNAME/mpd-aarch64
   ```
   (Create other arches if needed: `armhf`, `amd64`, etc., with the same tag pattern.)

3. **In your fork**, set the add-on to use your image so Supervisor pulls it instead of building from the default Dockerfile. Edit `addon/mpd/config.yaml` and add (adjust the registry path to yours):
   ```yaml
   image: ghcr.io/YOUR_USERNAME/mpd-{arch}
   ```
   Commit and push.

4. **In Home Assistant** (on your Yellow):
   - **Settings** → **Add-ons** → **Add-on store** → ⋮ → **Repositories**
   - Add your repo URL: `https://github.com/YOUR_USERNAME/MPD`
   - Install **MPD**, configure options, then **Start**.
   - **Settings** → **Devices & services** → **Add Integration** → **MPD** → Host `127.0.0.1`, Port `6600`.

The add-on will then run **your** MPD build (from your repo) on the Yellow. Rebuild and push the image whenever you change MPD and want to update the add-on.
