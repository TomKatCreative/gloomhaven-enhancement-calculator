#!/usr/bin/env bash
# Installs a release APK on the connected emulator, launches it, and fails if
# the app doesn't start cleanly.
#
# This catches release-only breakage that `flutter test` and debug builds
# can't see, such as R8 renaming classes a plugin looks up through JNI
# (internal build 594 failed at startup this way).
#
# Usage: android_smoke_test.sh <path/to/app-release.apk>
set -euo pipefail

apk="$1"
package="tomkatcreative.gloomhavenenhancementcalc"
wait_seconds="${SMOKE_WAIT_SECONDS:-20}"

adb install -r "$apk"
adb logcat -c
adb shell monkey -p "$package" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
sleep "$wait_seconds"

log="$(adb logcat -d)"
failed=0

# lib/main.dart logs this line when startup throws, before showing the
# "Startup failed" screen.
if grep -q "Startup initialization failed" <<<"$log"; then
  echo "::error::App reported a startup failure"
  failed=1
fi

if grep -A1 "FATAL EXCEPTION" <<<"$log" | grep -q "Process: $package"; then
  echo "::error::App crashed with an uncaught exception"
  failed=1
fi

if ! adb shell pidof "$package" >/dev/null; then
  echo "::error::App process is not running ${wait_seconds}s after launch"
  failed=1
fi

if ! adb shell dumpsys activity activities | grep -E "mResumedActivity|topResumedActivity" | grep -q "$package"; then
  echo "::error::App is not the foreground activity ${wait_seconds}s after launch"
  failed=1
fi

if [ "$failed" -ne 0 ]; then
  echo "--- flutter / crash log ---"
  grep " flutter " <<<"$log" || true
  grep -A20 "FATAL EXCEPTION" <<<"$log" || true
  exit 1
fi

echo "Smoke test passed: app started and is in the foreground."
