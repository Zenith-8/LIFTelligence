#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
app_dir="$repo_root/app"
package_dir="$repo_root/packages/phone_app"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Missing required command 'flutter'. Install Flutter and ensure it is on PATH." >&2
  exit 1
fi

if [[ ! -d "$package_dir" ]]; then
  echo "Expected Flutter package not found: $package_dir" >&2
  exit 1
fi

platforms="android,ios"
uname_s="$(uname -s || true)"
if [[ "$uname_s" == "Linux" ]]; then
  platforms="android"
fi

if [[ ! -f "$app_dir/pubspec.yaml" ]]; then
  mkdir -p "$app_dir"
  pushd "$app_dir" >/dev/null
  flutter create --platforms="$platforms" .
  popd >/dev/null
fi

mkdir -p "$app_dir/lib"
cat >"$app_dir/lib/main.dart" <<'DART'
import 'package:flutter/material.dart';
import 'package:phone_app/phone_app.dart';

void main() {
  runApp(const PhoneAppRoot());
}
DART

python3 - "$app_dir/pubspec.yaml" <<'PY'
import re
import sys

path = sys.argv[1]
text = open(path, "r", encoding="utf-8").read()

if re.search(r"(?m)^\s*phone_app\s*:", text):
  sys.exit(0)

m = re.search(r"(?m)^dependencies\s*:\s*$", text)
if not m:
  raise SystemExit(f"Unexpected pubspec.yaml format; missing dependencies section: {path}")

insert_at = m.end()
insertion = "\n  phone_app:\n    path: ../packages/phone_app\n"
text = text[:insert_at] + insertion + text[insert_at:]
open(path, "w", encoding="utf-8").write(text)
PY

echo "Bootstrap complete."
echo "Next:"
echo "  cd $app_dir"
echo "  flutter pub get"
echo "  flutter run"
