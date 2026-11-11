#!/usr/bin/env python3
"""
Static consistency checks between the JSDoc comments and the implementation of gooey.

Fails (exit code 1) when:
  * a documented `@method`/`@function` does not exist in the code (e.g. a misspelled name),
  * a documented `@param` list does not match the real parameter list of the function/method,
  * a `@constructor` line does not match the constructor signature,
  * a getter returns a field whose name does not match (e.g. getImage returning __image_).

No dependencies besides the Python standard library. Run from anywhere:  python tools/check_docs.py
"""
import glob
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
FILES = sorted(glob.glob(os.path.join(ROOT, "scripts", "scr_UI_*", "*.gml")) + [os.path.join(ROOT, "objects", "UI", "Create_0.gml")])
errors = []


def norm(s):
    return re.sub(r"[^a-z]", "", s.lower())


def err(path, line, msg):
    errors.append(f"{os.path.relpath(path, ROOT)}:{line}: {msg}")


for path in FILES:
    text = open(path, encoding="utf-8", errors="replace").read()
    lines = text.split("\n")
    implemented = set(re.findall(r"(?:self\.|static\s+)(\w+)\s*=\s*function", text)) | set(re.findall(r"^\s*function\s+(\w+)", text, re.M))

    for i, l in enumerate(lines):
        m = re.search(r"///\s*@(?:method|function)\s+(\w+)", l)
        if m and m.group(1) not in implemented and not m.group(1).startswith("_"):
            err(path, i + 1, f"documented '{m.group(1)}' is not implemented")

        m = re.search(r"(?:function\s+(\w+)|(?:self\.|static\s+)(\w+)\s*=\s*function)\s*\(([^)]*)\)", l)
        if not m:
            continue
        name = m.group(1) or m.group(2)
        if name.startswith("__"):
            continue
        sig = [re.split(r"\s*=", a.strip())[0].lstrip("_") for a in m.group(3).split(",") if a.strip()]
        j = i - 1
        doc = []
        while j >= 0 and lines[j].strip().startswith("///"):
            doc.append(lines[j].strip())
            j -= 1
        if not doc:
            continue
        doc.reverse()
        params = []
        for d in doc:
            pm = re.match(r"///\s*@param\s+(?:\{[^}]*\}\s*)?\[?(\w+)", d)
            if pm:
                params.append(pm.group(1).lstrip("_"))
        if any("@param" in d for d in doc) and sig != params:
            err(path, i + 1, f"'{name}' signature {sig} does not match documented @param {params}")
        cm = [re.search(r"@constructor\s+(\w+)\(([^)]*)\)", d) for d in doc]
        cm = [c for c in cm if c]
        if cm:
            doc_sig = [re.split(r"\s*=", re.sub(r"[\[\]]", "", a.strip()))[0].lstrip("_") for a in cm[0].group(2).split(",") if a.strip()]
            if doc_sig != sig:
                err(path, i + 1, f"@constructor {cm[0].group(1)}{doc_sig} does not match the signature {sig}")

    state_words = {"true", "false", "mouseover", "click", "disabled", "selected", "unselected"}
    for m in re.finditer(r"(?:self\.|static\s+)get(\w+)\s*=\s*function\s*\([^)]*\)\s*\{\s*return\s+self\.__(\w+)\s*;?\s*\}", text):
        rest, field = m.groups()
        words = lambda s: re.findall(r"[A-Z]+(?![a-z])|[A-Z]?[a-z0-9]+", s)
        g_tokens = {w.lower().rstrip("s") for w in words(rest)}
        f_tokens = {w.lower().rstrip("s") for w in words(field)}
        missing_state = {w for w in f_tokens if w.rstrip("s") in state_words} - g_tokens
        if not (g_tokens & f_tokens) or missing_state:
            line = text[: m.start()].count(chr(10)) + 1
            err(path, line, f"getter get{rest} returns __{field}")

if errors:
    print("Documentation/implementation mismatches found:\n")
    print("\n".join(errors))
    sys.exit(1)
print(f"Docs check OK ({len(FILES)} files)")
