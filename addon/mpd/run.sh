#!/usr/bin/env bash
set -e

# Load options (bashio optional; fallback to jq)
CONFIG=/data/options.json
if [ -f "$CONFIG" ]; then
  MEDIA_FOLDER=$(jq -r '.media_folder // "/media"' "$CONFIG")
  PLAYLIST_FOLDER=$(jq -r '.playlist_folder // "/media/playlists"' "$CONFIG")
  PORT=$(jq -r '.port // 6600' "$CONFIG")
  ZEROCONF=$(jq -r '.zeroconf_enabled // true' "$CONFIG")
else
  MEDIA_FOLDER=/media
  PLAYLIST_FOLDER=/media/playlists
  PORT=6600
  ZEROCONF=true
fi

# Persistent dirs
mkdir -p /data/state /data/playlists
[ -d "$PLAYLIST_FOLDER" ] || mkdir -p "$PLAYLIST_FOLDER"

# Generate mpd.conf
CONF=/data/mpd.conf
cat > "$CONF" << EOF
music_directory     "$MEDIA_FOLDER"
playlist_directory  "$PLAYLIST_FOLDER"
state_file          "/data/state/state"
bind_to_address     "any"
port                "$PORT"
zeroconf_enabled    "$( [ "$ZEROCONF" = "true" ] && echo yes || echo no )"

# Audio
audio_output {
    type            "alsa"
    name            "ALSA default"
}
EOF

exec mpd --no-daemon "$CONF"
