#!/usr/bin/env python3
import os, json, urllib.request, urllib.error
from urllib.parse import urlencode

PREFERRED = [
    "models/gemini-3-pro-image",
    "models/gemini-3.1-flash-image",
    "models/gemini-3.1-flash-lite-image",
    "models/gemini-2.5-flash-image",
]

key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
if not key or key.strip() in {"", "YOUR_KEY_HERE"}:
    raise SystemExit("ERROR: Set GEMINI_API_KEY first.")

url = "https://generativelanguage.googleapis.com/v1beta/models?" + urlencode({"key": key.strip()})
try:
    with urllib.request.urlopen(url, timeout=30) as r:
        data = json.loads(r.read().decode("utf-8"))
except urllib.error.HTTPError as e:
    print("FAILED")
    print("HTTP status:", e.code)
    print(e.read().decode("utf-8", errors="replace"))
    raise SystemExit(1)

models = [m.get("name", "") for m in data.get("models", [])]
print("Gemini API key works.\n")
print("Image-related models found:")
for m in models:
    if "image" in m.lower() or "imagen" in m.lower():
        print("-", m)

best = next((m for m in PREFERRED if m in models), None)
print("")
print("BEST_IMAGE_MODEL=" + best.replace("models/", "") if best else "No preferred image model found.")
