import os
from pathlib import Path
from dotenv import load_dotenv
from google import genai

load_dotenv(dotenv_path=Path(__file__).resolve().parents[1] / ".env")

api_key = os.environ.get("GEMINI_API_KEY")
if not api_key:
    raise RuntimeError("GEMINI_API_KEY is not set")

client = genai.Client(api_key=api_key)

for model in client.models.list():
    name = getattr(model, "name", "")
    supported = getattr(model, "supported_actions", None)
    if "imagen" in name.lower() or "image" in name.lower():
        print(name, supported)
