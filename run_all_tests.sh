#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NS_BIN="$ROOT_DIR/../ns/bin/ns"

if [[ ! -x "$NS_BIN" ]]; then
  echo "NS runtime not found or not executable at: $NS_BIN"
  exit 1
fi

echo "== Running predict tests =="
(
  cd "$ROOT_DIR/predict"
  "$NS_BIN" tests/run_tests.ns
)

echo
echo "== Running decision-tree tests =="
(
  cd "$ROOT_DIR/decision-tree"
  "$NS_BIN" tests/run_tests.ns
)

echo
echo "== Running text-stat tests =="
(
  cd "$ROOT_DIR/text-stat"
  "$NS_BIN" tests/run_tests.ns
)

echo
echo "== Running embed tests =="
(
  cd "$ROOT_DIR/embed"
  "$NS_BIN" tests/run_tests.ns
)

echo
echo "== Running prob-stat tests =="
(
  cd "$ROOT_DIR/prob-stat"
  "$NS_BIN" tests/run_tests.ns
)

echo
echo "All test suites passed."
