# Aidan's World Rush Gameplay-Fun Goal Loop

## Goal

Make normal runs feel more playful, skillful, and alive by replacing the single
repeated enemy encounter with readable world-specific enemy archetypes, adding
a rewarding close-call loop, and making every booster flame, glow, and trail
originate from the booster actually shown on Aidan's back.

## Scope

- **In:** Normal-run enemy variety and behavior, enemy telegraphs and
  counterplay, close-call feedback, Aidan's booster/nozzle alignment, exhaust
  motion, supporting production art and sound, simulator/device builds, visual
  evidence, and quality-score reporting.
- **Out:** New control schemes, weapons outside the existing boss sequence,
  monetization, online systems, and changes to the four-world story structure.
- **Requires approval:** Paid assets or services, publishing, destructive save
  changes, contacting testers, or collecting player-identifying information.

## Required Context

Before each iteration, inspect:

- `QUALITY_GOAL.md` and `QUALITY_SCORECARD.md`
- `README.md`
- `AidanGameRush/GameScene.swift`
- `AidanGameRush/GameModels.swift`
- `AidanGameRush/WorldArt.swift`
- `AidanGameRush/GameAudio.swift`
- `AidanGameRush/Progression.swift`
- The current `AidanFlying` sprite, enemy art, latest gameplay footage, and the
  most recent simulator/device build evidence

## Obligation Matrix

| Obligation | Evidence | Pass condition | Fallback |
| --- | --- | --- | --- |
| More enemy variety | Source audit plus screenshots/video from every world | Normal play contains at least four production-sprite enemy archetypes with clearly different silhouettes and movement patterns | Record any unobserved archetype as unverified; do not count source alone as visual proof |
| Readable counterplay | Frame sequence/video and executable path audit | Fast or targeted movement has at least 0.6 seconds of visible warning; paths remain inside the flight lane; no enemy appears on top of Aidan | Slow or disable the failed pattern and recapture it |
| Fair encounter cadence | Runtime diagnostic and spawn-source audit | Enemy spawns do not stack into an unavoidable barrier entrance; existing obstacle-gap, first-chip, first-power-up, and restart targets continue to pass | Rebalance timers and rerun the mechanics probe |
| Rewarded skill | Runtime capture and source audit | A collision-free close pass produces an immediate, bounded score bonus with distinct visual, sound, and haptic feedback, at most once per enemy | Remove or simplify the reward if it can double-trigger or obscure hazards |
| Booster alignment | Actual-scale boost/glide frames plus named-anchor source audit | The decorative pack formerly floating behind Aidan is gone; nozzle trim, flame core, exhaust particles, and loose trail sparks share one anchor within the illustrated pack's rear outlet | Keep the anchor explicit and mark physical alignment pending if exact frames cannot be inspected |
| Dynamic exhaust | Nominal-60-fps video/frame sequence | Exhaust length/intensity responds to boost state and vertical effort; released particles remain in world space; emission stops within 100 ms of release | Fall back to a simpler anchored effect and document the missing behavior |
| Production consistency | Direct alpha inspection and actual-scale world captures | New enemies match the friendly premium 3D-cartoon world art, remain non-scary, and avoid turning the worlds into techno/cyber environments | Reject or regenerate inconsistent art before integration |
| Regression safety | Clean builds, mechanics/audio diagnostics, persistence checks where relevant, and simulator soak | No new project warnings, crash, save regression, control regression, missing texture, or hard-gate failure | Repair the cause and rerun the affected evidence before commit |
| Enjoyment claim | Target-age playtest ledger | Fun/replay and enemy-readability targets in `QUALITY_GOAL.md` pass with the required consented sample | Keep enjoyment and human ratings explicitly unverified |

## Execution Loop

1. **Orient:** Inspect the current enemy, player, exhaust, scoring, audio, and
   evidence paths before changing behavior.
2. **Plan:** Select one cohesive enemy/dynamics package and attach runtime,
   visual, build, and regression checks.
3. **Act:** Add production enemy art and predictable behavior; route every
   exhaust effect through one illustrated-nozzle anchor; preserve one-touch
   flight and progression compatibility.
4. **Verify:** Clean-build the exact source, run every enemy encounter, record
   boost/glide footage, inspect frames on two iPad simulator sizes, and rerun
   mechanics/audio checks affected by the change.
5. **Repair:** Fix unreadable paths, unfair overlaps, visual misalignment,
   missing feedback, or regressions and repeat the relevant checks.
6. **Commit:** Commit only a cohesive package whose implementation and direct
   evidence agree.
7. **Report:** Update `QUALITY_SCORECARD.md` with evidence, score change,
   residual risk, and physical/player visibility gaps.

## Acceptance Criteria

- At least four normal-run enemy archetypes have distinct production art,
  behavior, and readable counterplay across the four worlds.
- Targeted or rapid enemy attacks visibly telegraph for at least 0.6 seconds.
- Each enemy can award no more than one near-miss bonus, and only after passing
  Aidan without collision.
- All booster flame and particle effects originate from one nozzle anchor that
  visually matches the pack in `AidanFlying`; the old detached pack is absent.
- Boost-to-visual feedback remains within 100 ms and one-touch controls are
  unchanged.
- Clean simulator and signed-device builds pass; directly inspected captures
  show no missing art, clipping, obscured hazard, or unreadable UI.
- Existing hard gates remain passing or provisional; no player-derived rating
  is raised without direct target-age evidence.

## Visibility Gaps

- Simulator footage cannot prove physical touch feel, speaker balance, thermal
  behavior, or whether target-age players find the new encounters fun and fair.
- Those claims remain pending until the connected iPad is unlocked and the
  consented playtest sample required by `QUALITY_GOAL.md` is completed.
