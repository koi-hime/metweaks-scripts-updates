#!/usr/bin/env bash
set -euo pipefail

APP_ID="1328670"
DOWNLOAD_URL="https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/63f7af19-5d22-43ab-af18-239a7b23b84c/MicrosoftEdgeWebView2RuntimeInstallerX64.exe"

find_mele_prefix() {
  local steam_root library candidate libraryfolders
  local steam_roots=()

  if [[ -n "${STEAM_DIR:-}" ]]; then
    steam_roots+=("$STEAM_DIR")
  fi
  steam_roots+=(
    "$HOME/.steam/steam"
    "$HOME/.local/share/Steam"
    "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"
  )

  for steam_root in "${steam_roots[@]}"; do
    [[ -d "$steam_root/steamapps" ]] || continue

    candidate="$steam_root/steamapps/compatdata/$APP_ID/pfx"
    if [[ -d "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi

    libraryfolders="$steam_root/steamapps/libraryfolders.vdf"
    [[ -f "$libraryfolders" ]] || continue
    while IFS= read -r library; do
      candidate="$library/steamapps/compatdata/$APP_ID/pfx"
      if [[ -d "$candidate" ]]; then
        printf '%s\n' "$candidate"
        return 0
      fi
    done < <(awk -F '"' '/"path"[[:space:]]*"/ { print $4 }' "$libraryfolders")
  done

  return 1
}

if ! command -v protontricks-launch >/dev/null 2>&1; then
  echo "Error: Protontricks is required to launch the WebView2 installer." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required to download the WebView2 installer." >&2
  exit 1
fi

if ! PREFIX="$(find_mele_prefix)"; then
  echo "Error: could not find the MELE Proton prefix for Steam AppID $APP_ID." >&2
  exit 1
fi

DOWNLOADS_DIR="$PREFIX/drive_c/users/steamuser/Downloads"
if [[ ! -d "$PREFIX/drive_c/users/steamuser" ]]; then
  echo "Error: Proton prefix has no steamuser profile: $PREFIX" >&2
  exit 1
fi
mkdir -p "$DOWNLOADS_DIR"
INSTALLER_PATH="$(mktemp --tmpdir="$DOWNLOADS_DIR" --suffix=.exe WebView2Installer.XXXXXX)"
cleanup() {
  if [[ -n "${INSTALLER_PATH:-}" ]]; then
    rm -f -- "$INSTALLER_PATH"
  fi
}
trap cleanup EXIT

echo "Downloading WebView2 installer..."
curl -fsSL "$DOWNLOAD_URL" -o "$INSTALLER_PATH"

echo "Installing WebView2 into the MELE prefix ($PREFIX)..."
protontricks-launch --appid "$APP_ID" "$INSTALLER_PATH"
