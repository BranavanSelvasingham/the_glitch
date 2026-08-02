# Iteration 13 — Gameplay Variety and Player Dynamics

## Goal and hypothesis

Normal runs should feel more varied and skillful when each world has a readable
local creature, close calls are rewarded, and the booster exhaust behaves as
one coherent physical effect attached to the illustrated pack.

The executable acceptance loop is defined in `GAMEPLAY_FUN_GOAL.md`.

## Implemented

| World | Enemy | Warning and counterplay | Motion |
| --- | --- | --- | --- |
| Cloud Kingdom | Cloud Swooper | 0.72 s warning at its entry lane; change altitude before the dive | Swoops down, then climbs away |
| Dino Jungle | Jungle Snapper | 0.72 s warning plus a visible aim line at Aidan's sampled height | Locks a lane, then lunges straight |
| Candy Canyon | Candy Bouncer | 0.72 s warning; rhythm and vertical range are visible before contact | Six rounded alternating hops |
| Storybook Castle | Castle Gargoyle | 0.72 s warning; broad weave remains inside the flight lane | Repeating angular zigzag |

- A hazard-separation timer prevents a creature, barrier, or falling hazard
  from entering as an unavoidable stack.
- Passing a creature safely within the near-miss window awards one bounded
  `NEAR MISS` bonus with a burst, generated sound, and haptic. Collision marks
  the creature ineligible, and each creature can trigger at most once.
- The old floating decorative booster pack was removed. Nozzle trim, flame,
  flame core, attached emission, and loose sparks derive from one named nozzle
  anchor located at the rear outlet in `AidanFlying`.
- Exhaust length and density respond to boosting and vertical effort. Released
  particles target the gameplay layer, so they remain in world space while
  Aidan moves; emission becomes zero immediately on release.

## Validation results

- Clean current-source iPad A16 simulator build: **PASS**.
- Clean signed physical-iPad build, install, launch, and live-process check:
  **PASS** on the paired iPad (A16).
- Four production enemy assets: **visually inspected at gameplay scale**.
- Enemy warning time: **0.72 s**, above the 0.6 s goal.
- Near-miss production path: **PASS**, one event and `+35` observed in the
  deterministic capture.
- Booster alignment: **PASS in inspected simulator close-up**; flame and
  particles meet the illustrated rear outlet with no detached pack.
- Mechanics probe: **PASS** — 16.0 ms boost input, 1.80 s first chip, 8.23 s
  first power-up, 28.2 ms restart, 245-point gap, 175-point excess clearance,
  and 24 s world cadence.
- Audio probe: **PASS** — 8/8 effects, 6/6 themes, 10.71 ms maximum effect
  scheduling, 10.72 ms maximum music scheduling, 0.335/0.377 peaks, and correct
  mute/session behavior.
- Layout inspection: **PASS** on iPad A16 and iPad mini (A17 Pro) simulator
  sizes for the tested gameplay states.

## Evidence files

- `cloud-swooper.jpg`, `jungle-snapper.jpg`, `candy-bouncer.jpg`, and
  `castle-gargoyle.jpg` — each world encounter.
- `cloud-showcase.mp4` and `cloud-contact-sheet.jpg` — nominal-60-fps encounter
  motion and sampled frames.
- `booster-alignment.jpg` — close view of the shared nozzle origin.
- `near-miss-feedback.jpg` — one-shot score and visual feedback.
- `ipad-mini-candy.jpg` — smaller-iPad fit check.
- `mechanics-probe.jpg` and `audio-probe.jpg` — live diagnostic result screens.

## Visibility limits

The successful physical launch does not by itself establish touch feel, speaker
balance, thermal behavior, or whether target-age players find the encounters
fun, fair, and replayable. Those ratings remain unchanged and pending direct
observation and the consented player sessions required by `QUALITY_GOAL.md`.
