#!/bin/bash
# Builds the native launcher into the app bundle for the current architecture.
set -euo pipefail
cd "$(dirname "$0")"

APP="GeForce NOW Anti-Lag.app"
OUT="$APP/Contents/MacOS/GeForceNOWAntiLag"

swiftc -O -target "$(uname -m)-apple-macos11" -o "$OUT" src/main.swift
codesign --force --deep --sign - "$APP"
echo "Built $OUT"
