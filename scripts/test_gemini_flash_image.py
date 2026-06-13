import os
from pathlib import Path
from dotenv import load_dotenv
from google import genai
from google.genai import types

load_dotenv(dotenv_path=Path(__file__).resolve().parents[1] / ".env")

api_key = os.environ.get("GEMINI_API_KEY")
if not api_key:
    raise RuntimeError("GEMINI_API_KEY is not set")

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

# This call will work seamlessly once you add billing to your AI Studio project
response = client.models.generate_images(
    model="imagen-4.0-fast-generate-001",
    prompt=prompt,
    config=types.GenerateImagesConfig(
        number_of_images=1,
        aspect_ratio="1:1"
    )
)

saved = False

# FIXED: Correct way to extract image data from the new Google GenAI SDK response
if hasattr(response, "generated_images") and response.generated_images:
    for i, generated_image in enumerate(response.generated_images):
        # Extract the raw binary image data
        image_bytes = generated_image.image.image_bytes
        output_path = output_dir / "gemini_flash_test_italian.png"
        
        with open(output_path, "wb") as f:
            f.write(image_bytes)
            
        print(f"Saved: {output_path}")
        saved = True
        break

if not saved:
    raise RuntimeError("No image part was returned in the response.")
