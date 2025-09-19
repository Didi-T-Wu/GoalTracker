#!/usr/bin/env bash
set -euo pipefail

# Auto-redeploy watcher for MAUI Android
# Usage:
#   ./scripts/dev-android-watch.sh [emulator-5554]
# Environment variables supported:
#   ANDROID_SDK (default /Users/didiwu/Library/Android/sdk)
#   JAVA_SDK    (default /Library/Java/JavaVirtualMachines/microsoft-17.jdk/Contents/Home)
#   CONFIG      (Debug or Release, default Debug)
#   PROJECT_DIR (path to the GoalTracker project folder, default autodetected)

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_DIR="${PROJECT_DIR:-${ROOT_DIR}}"
PROJECT_FILE="${PROJECT_FILE:-${PROJECT_DIR}/GoalTracker.csproj}"
ANDROID_SDK="${ANDROID_SDK:-/Users/didiwu/Library/Android/sdk}"
JAVA_SDK="${JAVA_SDK:-/Library/Java/JavaVirtualMachines/microsoft-17.jdk/Contents/Home}"
ADB_TARGET_ARG="${1:-emulator-5554}"
CONFIG="${CONFIG:-Debug}"
TFM="${TFM:-net9.0-android}"
DEBOUNCE="${DEBOUNCE:-1}"

echo "Watcher starting. Project: ${PROJECT_FILE}"
echo "Android SDK: ${ANDROID_SDK}  Java SDK: ${JAVA_SDK}  AdbTarget: ${ADB_TARGET_ARG}"

function do_build() {
  echo "[watcher] $(date '+%H:%M:%S') - Running build+deploy..."
  dotnet build -t:Run -f "${TFM}" \
    -p:Configuration=${CONFIG} \
    -p:AndroidSdkDirectory="${ANDROID_SDK}" \
    -p:JavaSdkDirectory="${JAVA_SDK}" \
    -p:AdbTarget="-s ${ADB_TARGET_ARG}" \
    "${PROJECT_FILE}"
  echo "[watcher] $(date '+%H:%M:%S') - Done. Waiting for changes..."
}

# Prevent overlapping builds
BUILD_LOCK="/tmp/dev-android-watch.lock"
function schedule_build() {
  if [ -f "$BUILD_LOCK" ]; then
    echo "[watcher] build already running, skipping"
    return
  fi
  touch "$BUILD_LOCK"
  ( sleep ${DEBOUNCE}; do_build; rm -f "$BUILD_LOCK" ) &
}

# File watch implementation: prefer fswatch, then entr, else fallback polling
if command -v fswatch >/dev/null 2>&1; then
  echo "[watcher] using fswatch"
  # watch recursive excluding bin/obj and .git
  fswatch -0 -r --exclude ".*/(bin|obj|.git)/.*" "${PROJECT_DIR}" | while read -d "" _; do
    schedule_build
  done
elif command -v entr >/dev/null 2>&1; then
  echo "[watcher] using entr"
  # generate file list
  while true; do
    find "${PROJECT_DIR}" -type f \( -name "*.xaml" -o -name "*.cs" -o -name "*.csproj" -o -name "*.resx" \) \
      | grep -vE "(bin|obj|.git)/" | entr -d sh -c 'echo "[watcher] change detected"; exit 0'
    schedule_build
  done
else
  echo "[watcher] using polling fallback (no fswatch or entr found)"
  # portable polling: compute a checksum of file mtimes+paths
  PREV_HASH=""
  while true; do
    # build a newline-separated list of "mtime path" for relevant files (portable)
    FILE_LIST=""
    while IFS= read -r -d '' f; do
      case "$f" in */bin/*|*/obj/*|*/.git/*) continue ;; esac
      mtime=$(stat -f "%m" "$f" 2>/dev/null || stat -c "%Y" "$f" 2>/dev/null || echo 0)
      FILE_LIST+="$mtime $f\n"
    done < <(find "${PROJECT_DIR}" -type f \( -name "*.xaml" -o -name "*.cs" -o -name "*.csproj" -o -name "*.resx" \) -print0)

    # compute hash (use shasum if available, else md5)
    if command -v shasum >/dev/null 2>&1; then
      HASH=$(printf "%s" "$FILE_LIST" | shasum -a 1 | awk '{print $1}')
    else
      HASH=$(printf "%s" "$FILE_LIST" | md5 -q 2>/dev/null || printf "%s" "$FILE_LIST" | md5sum | awk '{print $1}')
    fi

    if [ "${HASH}" != "${PREV_HASH}" ]; then
      PREV_HASH="${HASH}"
      echo "[watcher] changes detected"
      schedule_build
    fi
    sleep 1
  done
fi
