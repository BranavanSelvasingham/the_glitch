# Iteration 12 — Illustrated Booster Gear

## Hypothesis

Replacing the garage's abstract rounded-rectangle boosters with cohesive,
world-specific collectible art will close a visible production-asset gap and
make progression rewards feel materially richer.

## Production change

- Added four original transparent 512 × 768 booster textures: Blue Comet,
  Jungle Jet, Candy Burst, and Royal Rocket.
- Each design reflects a different adventure-world identity rather than a
  generic technological/glitch theme.
- Replaced the placeholder body/flame shapes in the real gear screen with the
  illustrated textures.
- Added a restrained floating motion and selected-gear halo.
- Locked gear keeps the same silhouette and is desaturated by the production
  rendering path; existing simulator progress was preserved, so the captured
  cards are all unlocked.
- Downsampled the original 1024 × 1536 cutouts to 512 × 768 after alpha cleanup.
  The four source PNGs total about 1.6 MB and retain alpha.

Generation prompts and original built-in image-generation paths are recorded
in `ARTWORK.md`.

## Direct visual inspection

| Target | Evidence | Result |
| --- | --- | --- |
| iPad (A16), iPadOS 26.5 simulator | `gear-ipad-a16.png` | Four distinct sprites render sharply; selected halo, labels, cards, badges, and controls remain clear with no overlap or missing texture |
| iPad mini (A17 Pro), iPadOS 26.5 simulator | `gear-ipad-mini.png` | Same result at the smaller supported layout; no clipping, edge fringe, or unreadable critical text found |

Both screenshots were captured from the final optimized source and cropped only
to remove the simulator's black portrait-frame bars. The image cutouts were also
inspected directly after chroma-key removal; their silhouettes and transparency
were clean against a dark viewer background.

## Build and device validation

- Clean simulator build: passed.
- Current optimized build launched on both simulator sizes: passed.
- Signed build for the connected iPad (A16, iPadOS 26.5.2): passed.
- Signed update installation on that iPad: passed.
- Physical launch: pending because the iPad remained locked; the verbose device
  response was `FBSOpenApplicationErrorDomain` code 7 (`Locked`).

## Score result

Asset richness and consistency rises from 4.2 to 4.4. The weighted score moves
from 71.7 to 72.3. No physical-device, target-player, or enjoyment score was
raised.
