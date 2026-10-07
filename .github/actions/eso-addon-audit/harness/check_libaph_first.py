import glob
import os
import re
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import audit_env

DOCS = audit_env.docs_root()
LIBAPH = os.path.join(DOCS, "LibAPH", ".github", "workflows")
WAIT = "./.github/actions/eso-wait-for-libaph"
READERS = {
    "version-refresh.yml": "./.github/actions/version-refresh",
    "dependency-check.yml": "./.github/actions/eso-dependency-check",
    "api-version-refresh.yml": "./.github/actions/eso-api-version-refresh",
    "readme-badge-check.yml": "./.github/actions/eso-readme-badge-check",
}
SCHEDULED = {
    "api-version-refresh.yml": "api-version-refresh.yml",
    "dependency-check.yml": "api-version-refresh.yml",
    "esoui-auto-release.yml": "esoui-auto-release.yml",
    "github-auto-release.yml": "github-auto-release.yml",
    "bethesda-auto-release.yml": "bethesda-auto-release.yml",
}
DAILY = re.compile(r"cron:\s*['\"](\d{1,2})\s+(\d{1,2})\s+\*\s+\*\s+\*['\"]")


def read(path):
    return open(path, encoding="utf-8", errors="replace").read() if os.path.exists(path) else ""


def daily_minutes(text):
    return [int(h) * 60 + int(m) for m, h in DAILY.findall(text)]


def follows_libaph(folder):
    workflows = os.path.join(folder, ".github", "workflows")
    text = read(os.path.join(workflows, "version-refresh.yml")) + read(os.path.join(workflows, "dependency-check.yml"))
    return "MPHONlC/LibAPH" in text or "dependency_name: 'LibAPH'" in text


bad = []
if not os.path.isdir(LIBAPH):
    print("LIBAPH FIRST CHECK OK: no LibAPH workflows here to compare against")
    sys.exit(0)
for folder in sorted(glob.glob(os.path.join(DOCS, "*"))):
    name = os.path.basename(folder)
    if name == "LibAPH" or not os.path.isdir(os.path.join(folder, ".github", "workflows")) or not follows_libaph(folder):
        continue
    workflows = os.path.join(folder, ".github", "workflows")
    if not os.path.exists(os.path.join(folder, ".github", "actions", "eso-wait-for-libaph", "wait_for_libaph.py")):
        bad.append("%s: .github/actions/eso-wait-for-libaph is missing" % name)
    calver = read(os.path.join(folder, ".github", "actions", "version-refresh", "calver_refresh.py"))
    if calver and "api.github.com/repos/%s/contents" not in calver:
        bad.append("%s: version-refresh reads LibAPH from raw.githubusercontent.com, which can be minutes old; copy the current Github-Actions/version-refresh" % name)
    for workflow, reader in READERS.items():
        text = read(os.path.join(workflows, workflow))
        if not text or reader not in text:
            continue
        if WAIT not in text or text.index(WAIT) > text.index(reader):
            bad.append("%s/%s: %s runs without waiting for LibAPH first (add '- uses: %s' before it)" % (name, workflow, reader, WAIT))
    for workflow, libaph_workflow in SCHEDULED.items():
        mine = daily_minutes(read(os.path.join(workflows, workflow)))
        theirs = daily_minutes(read(os.path.join(LIBAPH, libaph_workflow)))
        if mine and theirs and min(mine) < max(theirs) + 60:
            bad.append("%s/%s: daily cron at %02d:%02d UTC is less than an hour after LibAPH's %s (%02d:%02d UTC)"
                       % (name, workflow, min(mine) // 60, min(mine) % 60, libaph_workflow, max(theirs) // 60, max(theirs) % 60))

if bad:
    print("LIBAPH FIRST CHECK FAILED: LibAPH must stamp and release before the add-ons that follow it")
    for entry in bad:
        print("  " + entry)
    sys.exit(1)
print("LIBAPH FIRST CHECK OK: every add-on that follows LibAPH waits for it and runs its daily jobs at least an hour later")
