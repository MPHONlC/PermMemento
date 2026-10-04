import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import audit_env

SKIP_DIRS = {".git", "__pycache__", "node_modules", "out", "backups", "#Secrets", "esoui-upload-text"}
BINARY = (".xlsx", ".dds", ".png", ".ico", ".zip", ".db", ".jpg", ".jpeg", ".npy", ".gz", ".exe", ".dll",
          ".ttf", ".otf", ".pdf", ".gif", ".webp", ".mp4", ".wav", ".ogg")
HOW = {
    ".lua": "Lua strings take \\ddd byte escapes; comments and [[long strings]] take &#NNNN;",
    ".py": "Python strings take \\uXXXX",
    ".yml": "quote the value and use \\uXXXX",
    ".yaml": "quote the value and use \\uXXXX",
    ".sh": "shell strings take octal escapes such as \\0342\\0234\\0223",
}


def roots():
    workspace = audit_env.workspace_root()
    projects = audit_env.projects_root()
    if audit_env.only_targets():
        found = [os.path.join(projects, name) for name in audit_env.targets()]
    else:
        found = [projects]
    found.append(audit_env.docs_root())
    for extra in ("#Scripts", os.path.join("#Backups", "Harness")):
        found.append(os.path.join(workspace, extra))
    outer = os.path.dirname(workspace)
    for extra in ("Github-Actions", "APH-Search-Guide-Assets"):
        found.append(os.path.join(outer, extra))
    return [r for r in found if os.path.isdir(r)]


def files():
    seen = set()
    for root in roots():
        for folder, dirs, names in os.walk(root):
            dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
            for name in names:
                path = os.path.realpath(os.path.join(folder, name))
                if path in seen or name.lower().endswith(BINARY):
                    continue
                seen.add(path)
                yield os.path.join(folder, name)
    repo_scripts = os.path.join(os.path.dirname(audit_env.workspace_root()), "Github-Repo")
    if os.path.isdir(repo_scripts):
        for name in os.listdir(repo_scripts):
            path = os.path.join(repo_scripts, name)
            if os.path.isfile(path) and not name.lower().endswith(BINARY):
                yield path


bad = []
for path in files():
    try:
        data = open(path, "rb").read()
    except OSError:
        continue
    if b"\0" in data or all(b < 128 for b in data):
        continue
    text = data.decode("utf-8", errors="replace")
    for number, line in enumerate(text.split("\n"), 1):
        odd = sorted({c for c in line if ord(c) > 127})
        if odd:
            hint = HOW.get(os.path.splitext(path)[1].lower(), "write it as &#NNNN;")
            bad.append("%s:%d  %s (%s)" % (path, number, " ".join("U+%04X" % ord(c) for c in odd), hint))
            break

if bad:
    print("ASCII FILES CHECK FAILED: every text file is plain ASCII; anything else is written as an escape or &#NNNN; so no site, game or editor can turn it into mojibake like \u00c2\u00a9")
    for entry in bad:
        print("  " + entry)
    sys.exit(1)
print("ASCII FILES CHECK OK: every text file in every project is plain ASCII")
