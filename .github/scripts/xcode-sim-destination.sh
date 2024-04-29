#!/bin/bash
set -euo pipefail
PROJECT="${1:?}"
SCHEME="${2:?}"
UDID="${3:?}"

for _attempt in $(seq 1 25); do
  OUT="$(mktemp)"
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -showdestinations >"$OUT" 2>&1 || true
  if D="$(python3 - "$OUT" "$UDID" <<'PY'
import re, sys
path, udid = sys.argv[1], sys.argv[2].strip()
text = open(path, encoding="utf-8", errors="replace").read()
for line in text.splitlines():
    if udid not in line:
        continue
    if "platform:iOS Simulator" not in line:
        continue
    if "error:" in line:
        continue
    m_os = re.search(r"OS:\s*([^,}]+)", line)
    m_name = re.search(r"name:\s*([^,}]+)", line)
    if m_os and m_name:
        print(
            "platform=iOS Simulator,name=%s,OS=%s"
            % (m_name.group(1).strip(), m_os.group(1).strip())
        )
        raise SystemExit(0)
raise SystemExit(1)
PY
  )"; then
    rm -f "$OUT"
    echo "$D"
    exit 0
  fi
  rm -f "$OUT"
  sleep 3
done

if D="$(python3 - "$UDID" <<'PY'
import json, re, subprocess, sys

udid = sys.argv[1].strip()

def runtime_id_to_os(rid):
    m = re.search(r"\.iOS-([\d\-]+)$", rid)
    if not m:
        return None
    return ".".join(m.group(1).split("-"))


devices = json.loads(
    subprocess.check_output(["xcrun", "simctl", "list", "devices", "-j"], text=True)
)
name = None
rid = None
for rkey, devs in devices.get("devices", {}).items():
    for d in devs:
        if d.get("udid") == udid:
            name = (d.get("name") or "").strip()
            rid = rkey
            break
    if name:
        break
if not name or not rid:
    sys.exit(1)

os_ver = runtime_id_to_os(rid)
if not os_ver:
    sys.exit(1)

rdata = json.loads(
    subprocess.check_output(["xcrun", "simctl", "list", "runtimes", "-j"], text=True)
)
for r in rdata.get("runtimes", []):
    if r.get("identifier") == rid and r.get("version"):
        os_ver = r["version"]
        break

print("platform=iOS Simulator,name=%s,OS=%s" % (name, os_ver))
PY
  )"; then
  echo "destination from simctl (showdestinations had no UDID yet): ${D}" >&2
  echo "$D"
  exit 0
fi

echo "warning: using id= fallback for ${UDID}" >&2
echo "platform=iOS Simulator,id=${UDID}"
