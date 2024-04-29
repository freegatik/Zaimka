#!/bin/bash
set -euo pipefail
VERSION="${SWIFTFORMAT_VERSION:-0.61.0}"
curl -fsSL "https://github.com/nicklockwood/SwiftFormat/releases/download/${VERSION}/swiftformat.zip" -o /tmp/swiftformat.zip
unzip -o /tmp/swiftformat.zip -d /tmp
sudo mkdir -p /usr/local/bin
sudo mv /tmp/swiftformat /usr/local/bin/swiftformat
sudo chmod +x /usr/local/bin/swiftformat
swiftformat --version
