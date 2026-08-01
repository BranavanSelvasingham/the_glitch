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

## Illustrated world backdrops

Final files:

- `AidanGameRush/Assets.xcassets/CloudBackdrop.imageset/CloudBackdrop.png`
- `AidanGameRush/Assets.xcassets/DinoBackdrop.imageset/DinoBackdrop.png`
- `AidanGameRush/Assets.xcassets/CandyBackdrop.imageset/CandyBackdrop.png`
- `AidanGameRush/Assets.xcassets/CastleBackdrop.imageset/CastleBackdrop.png`

Generation method: four separate calls to the built-in `image_gen` tool, using the key art as a style and lighting reference only. All outputs are 1774 × 887 landscape PNGs. The original generated files remain in `/Users/branavan/.codex/generated_images/019fbd77-a43b-7651-81d0-6462c5d04bd8`.

### Cloud Kingdom prompt

```text
Use case: stylized-concept.
Asset type: production-ready 2D landscape background for a side-scrolling iPad game.
Create the Cloud Kingdom world for Aidan's World Rush: a brilliant blue sky, enormous fluffy cloud banks, floating grassy islands, distant whimsical white-and-gold towers, waterfalls falling into the clouds, soft rainbow mist, and a few tiny distant birds. Premium modern 3D-cartoon illustration with cinematic depth, polished materials, warm sunlight from the upper right, joyful kid-friendly adventure tone. Palette: sky blue, white, sunlit gold, fresh green.
Composition: wide landscape; side-on layered deep background, midground, and foreground; leave a broad, visually quiet central aerial flight corridor so a small flying player, pickups, and hazards remain clearly readable. Interesting detail should frame the upper and lower edges rather than clutter the flight lane.
Do not include Aidan, The Glitch, any main character, UI, text, logos, pickups, hazards, techno or cyber elements, neon grids, pixels, arcade cabinets, circuit boards, or watermark. This is a natural magical world, not a glitch environment.
Use the reference only for the premium 3D-cartoon rendering style, palette harmony, and upper-right lighting; do not copy its composition or characters.
```

### Dino Jungle prompt

```text
Use case: stylized-concept.
Asset type: production-ready 2D landscape background for a side-scrolling iPad game.
Create the Dino Jungle world for Aidan's World Rush: a vast lush prehistoric jungle with layered giant ferns, palms, broad leaves and vines, misty waterfalls, mossy rock arches, a warm distant volcano, and a few tiny friendly long-neck dinosaur silhouettes far in the distance. Premium modern 3D-cartoon illustration with cinematic atmospheric depth, polished natural materials, warm sunlight from the upper right, exciting but safe kid-friendly adventure tone. Palette: emerald green, teal, jungle gold, warm stone, touches of turquoise water.
Composition: wide landscape; side-on layered deep background, midground, and foreground; leave a broad, visually quiet central aerial flight corridor so a small flying player, pickups, and hazards remain clearly readable. Dense foliage and rock detail should frame the upper and lower edges rather than clutter the flight lane.
Do not include Aidan, The Glitch, any main character, close-up dinosaur, UI, text, logos, pickups, hazards, techno or cyber elements, neon grids, pixels, arcade cabinets, circuit boards, or watermark. This is a natural prehistoric adventure world, not a glitch environment.
Use the reference only for the premium 3D-cartoon rendering style, palette harmony, and upper-right lighting; do not copy its composition or characters.
```

### Candy Canyon prompt

```text
Use case: stylized-concept.
Asset type: production-ready 2D landscape background for a side-scrolling iPad game.
Create the Candy Canyon world for Aidan's World Rush: rolling frosting hills, gumdrop cliffs, cookie and wafer rock formations, a distant lollipop grove, a sparkling syrup river, candy-cane bridges, and cotton-candy clouds. Premium modern 3D-cartoon illustration with cinematic atmospheric depth, polished delicious-looking materials, warm sunlight from the upper right, exuberant kid-friendly adventure tone. Palette: strawberry pink, cyan, sunny gold, grape purple, cream, and small mint accents.
Composition: wide landscape; side-on layered deep background, midground, and foreground; leave a broad, visually quiet central aerial flight corridor so a small flying player, pickups, and hazards remain clearly readable. Colorful candy detail should frame the upper and lower edges rather than clutter the flight lane.
Do not include Aidan, The Glitch, any main character, UI, text, logos, pickups, hazards, techno or cyber elements, neon grids, pixels, arcade cabinets, circuit boards, or watermark. This is a whimsical edible fantasy world, not a glitch environment.
Use the reference only for the premium 3D-cartoon rendering style, palette harmony, and upper-right lighting; do not copy its composition or characters.
```

### Storybook Castle prompt

```text
Use case: stylized-concept.
Asset type: production-ready 2D landscape background for a side-scrolling iPad game.
Create the Storybook Castle world for Aidan's World Rush: an enchanted royal valley with a grand fairytale castle and slender towers in the distance, cloud bridges, layered purple hills, luminous waterfalls, an old magical forest, and warm lantern-lit windows. Premium modern 3D-cartoon illustration with cinematic atmospheric depth, polished storybook materials, warm sunlight and magical rays from the upper right, heroic kid-friendly adventure tone. Palette: lavender, royal blue, warm gold, teal, moonlit stone, and soft peach light.
Composition: wide landscape; side-on layered deep background, midground, and foreground; leave a broad, visually quiet central aerial flight corridor so a small flying player, pickups, and hazards remain clearly readable. Castle, forest, and decorative detail should frame the upper and lower edges rather than clutter the flight lane.
Do not include Aidan, The Glitch, any main character, UI, text, logos, pickups, hazards, techno or cyber elements, neon grids, pixels, arcade cabinets, circuit boards, or watermark. This is a magical storybook kingdom, not a glitch environment.
Use the reference only for the premium 3D-cartoon rendering style, palette harmony, and upper-right lighting; do not copy its composition or characters.
```
