import os
from pathlib import Path

from dotenv import load_dotenv
from google import genai
from google.genai import types

load_dotenv(dotenv_path=Path(__file__).resolve().parents[1] / ".env")

api_key = os.environ.get("GEMINI_API_KEY")
if not api_key:
    raise RuntimeError(
        "GEMINI_API_KEY is not set. Add it to .env or export it in Terminal."
    )

client = genai.Client(api_key=api_key)

output_dir = Path("Flame_Fleur/Flame_Fleur/Resources/GeneratedAssets/Gemini/raw")
output_dir.mkdir(parents=True, exist_ok=True)

prompt = """
Create a hyperrealistic premium food photograph for a high-end cooking app.

Subject:
A beautifully plated Italian pasta dish with tomato sauce, fresh basil, parmesan, and elegant presentation.

Visual style:
hyperrealistic food photography, premium editorial cookbook photography, warm natural daylight, clean white or warm off-white background, soft natural shadows, elegant plating, realistic food texture, appetizing, refined, fresh, luxurious but natural, clear composition, high-end culinary magazine style.

Composition:
square image, centered main subject, enough breathing room for circular crop, food should remain readable at small app-icon size, no clutter, no excessive props, no hands, no people, no packaging.

Strict constraints:
no text, no title, no letters, no logo, no watermark, no border, no illustration, no cartoon, no digital painting, no 3D render, no collage, no messy background, no dark background.
""".strip()

response = client.models.generate_images(
    model="imagen-4.0-fast-generate-001",
    prompt=prompt,
    config=types.GenerateImagesConfig(
        number_of_images=1,
        aspect_ratio="1:1"
    )
)

if not response.generated_images:
    raise RuntimeError("No image was generated.")

image = response.generated_images[0].image

output_path = output_dir / "gemini_test_italian.png"
image.save(output_path)

print(f"Saved: {output_path}")
