# MPD add-on – Documentation

## Running MPD on Home Assistant OS

This add-on runs the **Music Player Daemon** (MPD) on the same device as Home Assistant (e.g. Home Assistant Yellow, Green, Blue, or any Supervised/OS install). After installation you get an MPD server that Home Assistant can control via the built-in **MPD** integration.

## Install steps

1. **Add the repository**
   - Go to **Settings** → **Add-ons** → **Add-on store**
   - Click the ⋮ menu (top right) → **Repositories**
   - Add: `https://github.com/MusicPlayerDaemon/MPD`
   - Save

2. **Install and start the add-on**
   - Find **MPD** in the add-on list and install it
   - Configure **Media folder** (and optionally **Playlist folder**) if needed
   - Start the add-on

3. **Add the MPD integration in Home Assistant**
   - **Settings** → **Devices & services** → **Add Integration**
   - Search for **MPD** or **Music Player Daemon**
   - Host: `127.0.0.1` (when MPD runs on the same host as HA)
   - Port: `6600` (or the port you set in the add-on options)

You will then have a `media_player` entity for MPD that you can use in dashboards, automations, and scripts.

## Using HA media as music library

The add-on mounts Home Assistant’s **media** and **share** directories. To use the same files as your HA media library:

- Set **Media folder** in the add-on options to `/media` (or e.g. `/media/local` if you use a subfolder).
- Put your music files in HA’s media area (e.g. via Samba or the HA file editor in the right place). MPD will use them as `music_directory`.

## Multiple streams (partitions)

MPD supports multiple partitions (separate playlists/players). The official Home Assistant MPD integration currently exposes one media player per MPD host. To use partitions you can switch them via MPD protocol (e.g. `mpc -h 127.0.0.1 -p 6600 partition <name>` then play). See the main [HOMEASSISTANT.md](https://github.com/MusicPlayerDaemon/MPD/blob/master/docs/HOMEASSISTANT.md) in this repo for more.
