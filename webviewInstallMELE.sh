# TMP_DIR="$(mktemp -d -p ~/.cache)"

# Flatpak
# TMP_DIR="$(mktemp -d -p ~/.var/app/com.valvesoftware.Steam/.local/share/Steam)"

# I don't even know
TMP_DIR="$(mktemp -d -p ~/.local/share/Steam)"
DOWNLOAD_URL="https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/63f7af19-5d22-43ab-af18-239a7b23b84c/MicrosoftEdgeWebView2RuntimeInstallerX64.exe"


cleanup_tmp() {
  echo
  echo "Cleaning up..."
  rm -rf "$TMP_DIR"
}
#trap cleanup_tmp EXIT

install_webview() {
  echo "Downloading WebView2 installer..."
  curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/WebView2Installer.exe"
  if ! command -v protontricks-launch >/dev/null 2>&1; then
    echo "Protontricks not found, please install it and try again."
  else 
    echo "Installing WebView into the MELE prefix (1328670)..."
    protontricks-launch --appid 1328670 "$TMP_DIR/WebView2Installer.exe"
  fi
}

echo "Using tmp dir: $TMP_DIR"
install_webview

