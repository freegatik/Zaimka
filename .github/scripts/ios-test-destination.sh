#!/bin/bash
set -euo pipefail
ROOT="${GITHUB_WORKSPACE:-$(pwd)}"
cd "$ROOT"

PROJECT="${1:-Zaimka.xcodeproj}"
SCHEME="${2:-Zaimka}"

OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT

xcodebuild -project "$PROJECT" -scheme "$SCHEME" -showdestinations >"$OUT" 2>&1 || true

python3 - "$OUT" <<'PY'
import json, os, re, subprocess, sys
from itertools import zip_longest

MIN_IOS = os.environ.get("IPHONEOS_DEPLOYMENT_TARGET", "17.6")
_PREF = os.environ.get(
    "IOS_SIMULATOR_PREFERRED_NAMES",
    "iPhone 15,iPhone 16,iPhone 16 Pro,iPhone 17,iPhone 14",
)

DEFAULT_FALLBACK = os.environ.get(
    "IOS_SIMULATOR_FALLBACK_DESTINATION",
    "platform=iOS Simulator,name=iPhone 15,OS=18.1",
)


def ver_parts(s):
    return [int(x) for x in s.replace(" ", "").split(".") if x.isdigit()]


def ver_ge(a, b):
    for x, y in zip_longest(ver_parts(a), ver_parts(b), fillvalue=0):
        if x != y:
            return x >= y
    return True


def ver_tuple(s):
    return tuple(int(p) for p in s.split(".") if p.isdigit())


def parse_showdestinations_pairs(text):
    pairs = []
    for line in text.splitlines():
        s = line.strip()
        if "platform:iOS Simulator" not in s:
            continue
        if "dvtdevice-DVTiOSDeviceSimulatorPlaceholder" in s:
            continue
        if "error:" in s:
            continue
        m_name = re.search(r"name:\s*([^,}]+)", s)
        m_os = re.search(r"OS:\s*([^,}]+)", s)
        if not m_name or not m_os:
            continue
        name = m_name.group(1).strip()
        os_ver = m_os.group(1).strip()
        if not ver_ge(os_ver, MIN_IOS):
            continue
        pairs.append((name, os_ver))
    return pairs


def runtime_id_to_os(runtime_id):
    m = re.search(r"\.iOS-([\d\-]+)$", runtime_id)
    if not m:
        return None
    return ".".join(m.group(1).split("-"))


def simctl_iphone_pairs():
    raw = subprocess.check_output(
        ["xcrun", "simctl", "list", "devices", "available", "-j"],
        text=True,
    )
    data = json.loads(raw)
    out = []
    for runtime_id, devices in data.get("devices", {}).items():
        os_ver = runtime_id_to_os(runtime_id)
        if not os_ver or not ver_ge(os_ver, MIN_IOS):
            continue
        for d in devices:
            if not d.get("isAvailable", False):
                continue
            name = (d.get("name") or "").strip()
            if "iPhone" not in name:
                continue
            out.append((name, os_ver))
    return out


def preferred_names():
    return [p.strip() for p in _PREF.split(",") if p.strip()]


def pref_rank(name):
    for i, p in enumerate(preferred_names()):
        if name == p or name.startswith(p):
            return i
    return len(preferred_names()) + 50


def os_key_desc(os_s):
    return tuple(-x for x in ver_tuple(os_s))


def pick_intersection(show_text):
    xcode_pairs = parse_showdestinations_pairs(show_text)
    if not xcode_pairs:
        return None
    allowed = set(xcode_pairs)
    sim_pairs = simctl_iphone_pairs()
    good = [(n, o) for n, o in sim_pairs if (n, o) in allowed]
    if not good:
        return None
    good.sort(key=lambda t: (pref_rank(t[0]), os_key_desc(t[1])))
    name, os_ver = good[0]
    return f"platform=iOS Simulator,name={name},OS={os_ver}"


def pick_simctl_only():
    sim_pairs = simctl_iphone_pairs()
    if not sim_pairs:
        return None
    good = list(dict.fromkeys(sim_pairs))
    good.sort(key=lambda t: (pref_rank(t[0]), os_key_desc(t[1])))
    name, os_ver = good[0]
    return f"platform=iOS Simulator,name={name},OS={os_ver}"


def pick_showdestinations_only(text):
    pairs = parse_showdestinations_pairs(text)
    if not pairs:
        return None
    pairs.sort(key=lambda t: (pref_rank(t[0]), os_key_desc(t[1])))
    name, os_ver = pairs[0]
    return f"platform=iOS Simulator,name={name},OS={os_ver}"


path = sys.argv[1]
with open(path, encoding="utf-8", errors="replace") as f:
    text = f.read()

spec = pick_intersection(text)
if spec:
    print(spec)
    raise SystemExit(0)

spec = pick_simctl_only()
if spec:
    print(spec)
    raise SystemExit(0)

spec = pick_showdestinations_only(text)
if spec:
    print(spec)
    raise SystemExit(0)

override = (os.environ.get("IOS_SIMULATOR_DESTINATION") or os.environ.get("CI_XCODE_DESTINATION") or "").strip()
if override:
    print(override)
    raise SystemExit(0)

print("min iOS: %s — using fallback %s" % (MIN_IOS, DEFAULT_FALLBACK), file=sys.stderr)
print(DEFAULT_FALLBACK)
raise SystemExit(0)

PY
