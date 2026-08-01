# Artwork generation record

The original illustrated assets in this repository were created with Codex's built-in `image_gen` tool.

## App icon and key art

Final files:

- `AidanGameRush/Assets.xcassets/AppIcon.appiconset/AppIcon.png`
- `AidanGameRush/Assets.xcassets/KeyArt.imageset/KeyArt.png`

Original generated file:

- `/Users/branavan/.codex/generated_images/019fbd77-a43b-7651-81d0-6462c5d04bd8/exec-d2f069a7-8f9d-4ea2-af55-86e654629360.png`

Exact prompt:

```text
Use case: stylized-concept
Asset type: 1024x1024 iPad game app icon
Primary request: Create a polished, joyful app icon for a kid-friendly arcade flight adventure called Aidan's World Rush.
Subject: A brave brown-skinned boy hero named Aidan wearing a bright blue flight suit with a white letter A, cyan visor goggles, and a purple booster pack, soaring diagonally upward. A playful black star-shaped Glitch creature with magenta and cyan edges chases behind him.
Scene/backdrop: A single magical swirl subtly divided into four adventure-world motifs: fluffy cloud islands, lush dinosaur jungle leaves, colorful candy hills, and a storybook castle. The worlds must feel magical and natural, not like a techno or cyber environment.
Style/medium: Premium modern 3D-cartoon game icon, clean readable silhouettes, expressive and friendly, suitable for children, polished mobile game key art.
Composition/framing: Square icon, close heroic composition, Aidan large and centered, face and booster readable at small size, strong depth, safe margins, no border.
Lighting/mood: Bright golden adventure lighting, optimistic, exciting, playful.
Color palette: Sky blue, leafy green, candy pink, royal purple, gold accents; The Glitch uses black, magenta and cyan only as a small antagonist accent.
Constraints: No words, no title lettering, no logos, no UI, no watermark. Exactly one Aidan and one Glitch creature. Avoid weapons, fear, menace, photorealism, pixel-art, circuit boards, neon grids, arcade cabinets, or an overall techno-glitch environment.
```

## Flying Aidan sprite

Final file:

- `AidanGameRush/Assets.xcassets/AidanFlying.imageset/AidanFlying.png`

Original generated file:

- `/Users/branavan/.codex/generated_images/019fbd77-a43b-7651-81d0-6462c5d04bd8/exec-af148cbe-b6e4-477e-89b1-f28b78424057.png`

Generation method: built-in `image_gen`, using the key art as a visual reference. The flat green background was removed with the bundled `remove_chroma_key.py` helper, then the transparent sprite was resized to 768 × 384.

Exact prompt:

```text
Use case: game-production
Asset type: single 2D character sprite on a chroma-key background
Primary request: Create a polished side-view flying sprite of Aidan for the kid-friendly iPad game Aidan's World Rush.
Subject: One cheerful brown-skinned boy hero, about 9 years old, flying toward the right with one fist forward and a determined happy smile. He has high swept dark-brown hair, large cyan visor goggles, a bright royal-blue flight suit with a bold white capital A on the chest, white gloves, dark boots, and a compact purple booster pack on his back. Match the friendly premium 3D-cartoon proportions and identity of the game's illustrated key art.
Pose: Clean horizontal superhero flight pose, head and torso slightly upright, both legs swept backward, booster clearly visible behind his left shoulder, readable silhouette at 90 pixels tall.
Composition: Exactly one full-body character, centered, generous empty margin, no crop, no ground, no cast shadow.
Lighting: Bright warm adventure lighting, soft dimensional shading, crisp mobile-game rendering.
Background: perfectly uniform flat pure green #00FF00 extending edge-to-edge, with no texture, gradient, glow, shadow, halo, vignette, or green reflections on the character.
Constraints: no words except the single white letter A printed on his suit, no title, no logo, no UI, no enemies, no scenery, no extra objects, no weapons, no photorealism, no pixel art, no watermark. Keep outlines and hair edges crisp enough for chroma-key background removal.
```

If Aidan's design changes later, regenerate the key art and flying sprite together so his suit, goggles, hair, and booster remain consistent.
