import re, os, sys, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import audit_env

DOCS = audit_env.docs_root()
UPLOAD = re.compile(r'uses:\s*m00nyONE/esoui-upload@')
FILE_INPUT = re.compile(r"(description_file|changelog_file):\s*'([^']*)'")

bad = []
for path in glob.glob(os.path.join(DOCS, "**", ".github", "workflows", "*.yml"), recursive=True):
    text = open(path, encoding="utf-8", errors="replace").read()
    if not UPLOAD.search(text):
        continue
    for m in FILE_INPUT.finditer(text):
        value = m.group(2)
        if value and not value.startswith("esoui-upload-text/"):
            bad.append((path, text[:m.start()].count("\n") + 1, "%s: '%s'" % (m.group(1), value)))
    if any(m.group(2) for m in FILE_INPUT.finditer(text)) and "esoui-safe-text" not in text:
        bad.append((path, 1, "uploads to ESOUI without the esoui-safe-text step"))

for path in sorted(glob.glob(os.path.join(DOCS, "*", "README_BBCODE.txt")) + glob.glob(os.path.join(DOCS, "*", "CHANGELOG_BBCODE.txt"))):
    for number, line in enumerate(open(path, encoding="utf-8", errors="replace"), 1):
        odd = sorted({c for c in line if ord(c) >= 128})
        if odd:
            bad.append((path, number, "non-ASCII %s; write it as &#%d;" % (" ".join(repr(c) for c in odd), ord(odd[0]))))

if bad:
    print("ESOUI UPLOAD TEXT CHECK FAILED: ESOUI reads uploads as ISO-8859-1, so raw UTF-8 shows up as \u00c2\u00a9; upload the esoui-safe-text copies (esoui-upload-text/...) instead")
    for path, line, why in bad:
        print("  %s:%d  %s" % (path, line, why))
    sys.exit(1)
print("ESOUI UPLOAD TEXT CHECK OK: every ESOUI upload sends the entity-encoded copies and every local BBCode file is plain ASCII")
