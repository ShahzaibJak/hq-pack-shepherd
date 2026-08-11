#!/usr/bin/env bash
set -euo pipefail

PACK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALIDATOR="$PACK/skills/shepherd-setup/scripts/validate_config.py"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

grep -q '^  entrypoint: shepherd-setup$' "$PACK/package.yaml" || fail "missing setup initialization"
grep -q '^    - shepherd$' "$PACK/package.yaml" || fail "missing run skill contribution"
grep -q '^    - shepherd-setup$' "$PACK/package.yaml" || fail "missing setup skill contribution"

python3 - "$PACK/package.yaml" <<'PY'
import pathlib
import re
import sys

manifest = pathlib.Path(sys.argv[1]).read_text()
match = re.search(r"^version: ([^\n]+)$", manifest, re.MULTILINE)
if not match:
    raise SystemExit("package version is missing")
if "publisher: '@shahzaibjak'" not in manifest:
    raise SystemExit("creator publisher is missing")
if "github:ShahzaibJak/hq-pack-shepherd" not in manifest:
    raise SystemExit("standalone source is missing")
PY

python3 - "$PACK/skills/shepherd-setup/assets/config-template.json" "$TMP/valid.json" <<'PY'
import json
import pathlib
import sys

config = json.loads(pathlib.Path(sys.argv[1]).read_text())
config["company"] = "example"
config["agent"] = {"id": "triage-agent", "displayName": "Triage Agent"}
config["goals"] = ["Every eligible report has an owner within one business day"]
config["nonGoals"] = ["No comments, status changes, merges, deployments, or resolution"]
config["sources"] = [{
    "id": "dev-issues",
    "type": "github",
    "locator": "example/project#label:needs-triage",
    "secretKeys": ["GITHUB_APP_INSTALLATION"],
    "readPolicy": "open root issues with needs-triage",
    "identityKey": "github:repository:issue-number",
    "canonicalLocation": "GitHub issue URL"
}]
config["handoff"]["destination"] = "project triage queue"
pathlib.Path(sys.argv[2]).write_text(json.dumps(config, indent=2) + "\n")
PY

python3 "$VALIDATOR" "$TMP/valid.json" >/dev/null

python3 - "$TMP/valid.json" "$TMP/unsafe.json" <<'PY'
import json
import pathlib
import sys

config = json.loads(pathlib.Path(sys.argv[1]).read_text())
config["permissions"]["comment"] = True
pathlib.Path(sys.argv[2]).write_text(json.dumps(config))
PY

if python3 "$VALIDATOR" "$TMP/unsafe.json" >/dev/null 2>&1; then
  fail "pilot configuration accepted a write permission"
fi

python3 - "$TMP/valid.json" "$TMP/secret.json" <<'PY'
import json
import pathlib
import sys

config = json.loads(pathlib.Path(sys.argv[1]).read_text())
config["sources"][0]["secretKeys"] = ["not-a-valid-key-name"]
pathlib.Path(sys.argv[2]).write_text(json.dumps(config))
PY

if python3 "$VALIDATOR" "$TMP/secret.json" >/dev/null 2>&1; then
  fail "configuration accepted a credential-looking secret value"
fi

echo "shepherd pack tests passed"
