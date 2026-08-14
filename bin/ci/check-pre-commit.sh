#!/usr/bin/env bash

set -euo pipefail

plan_path="$(basename "$1")"

echo "--- :python: Install pre-commit"
if [[ "${CI:-}" == "true" ]]; then
  # Bootstrap pip without apt-get (avoids dependency on EOL focal-pgdg repo).
  # Use ensurepip (stdlib) first; fall back to the version-specific get-pip.py
  # since the generic script requires Python 3.10+.
  PY_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
  python3 -m ensurepip --upgrade 2>/dev/null || curl -sS "https://bootstrap.pypa.io/pip/${PY_VER}/get-pip.py" | python3
  python3 -m pip install --quiet pre-commit
else
  echo "Not in CI! Skipping installation of pre-commit. Please install it manually if executing this on your workstation"
fi
pre-commit migrate-config
pre-commit --version

echo "--- :git: [${plan_path}] Running checks provided by pre-commit hooks"
find "$plan_path" -type f -print0 | xargs -0 pre-commit run --files
