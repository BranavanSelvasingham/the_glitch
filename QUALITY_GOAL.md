# Aidan's World Rush Quality Goal Loop

## Goal

Create a polished iPad game that target-age players immediately understand, describe as beautiful and exciting, and voluntarily replay, while maintaining reliable performance, fair controls, rich world identity, and child-appropriate presentation.

## Scope

- **In:** Visual composition, production assets, animation, sound and music, control feel, collision fairness, pacing, progression, story clarity, accessibility, persistence, performance, physical-iPad validation, and target-player playtesting.
- **Out:** Advertising, monetization, online accounts, social features, analytics involving children, Android support, and unrelated new game modes.
- **Requires approval:** Paid services or assets, publishing, collecting any player data, contacting testers, or destructive changes to saved/user data.

## North-Star Test

After five minutes, at least 80% of target-age players must be able to control Aidan without help, recognize at least two worlds, explain Aidan's goal and The Glitch's role, rate both appearance and fun at least 4/5, and start another run without prompting.

## Scoring

Rate each category from 0–5:

- 0: missing or broken
- 1: rough prototype
- 2: functional but inconsistent
- 3: competent
- 4: polished
- 5: memorable commercial quality

Weighted score: `category rating / 5 × weight`.

| Category | Weight | Measurable pass target |
| --- | ---: | --- |
| Visual composition | 15 | Human rating ≥4.3/5; ≥90% identify the player, pickups, and hazards within one second; no clipping, overlap, or unreadable text |
| Asset richness and consistency | 15 | Production art covers every major character, enemy, hazard, pickup, power-up, menu, and boss; each world has ≥3 depth layers, ≥6 distinct motifs, and unique obstacle treatment |
| Animation and game feel | 10 | Aidan communicates boost, glide, hit, shield, magnet, victory, and defeat; important actions produce visual feedback within 100 ms; animation rating ≥4.2/5 |
| Sound and music | 10 | 100% of major actions have distinct sounds; every world and the boss have recognizable musical identity; response ≤80 ms; zero clipping; rating ≥4.2/5 |
| Controls | 15 | Touch response ≤50 ms; ≥90% understand controls within 15 seconds; ≥80% survive 20 seconds on their first run; control rating ≥4.3/5 |
| Fairness and pacing | 10 | ≥90% of deaths are understood and considered fair; first chip ≤5 seconds; first power-up ≤25 seconds; meaningful change every 20–30 seconds; restart ≤1 second |
| Fun and replayability | 10 | Fun rating ≥4.2/5; ≥75% want another run; ≥70% restart without prompting; median ≥3 runs in ten minutes; frustration quits ≤10% |
| Story and world identity | 5 | ≥80% recall Aidan, The Glitch, and the goal; ≥90% distinguish all four worlds; ≥80% describe the worlds using fantasy/nature rather than techno/cyber terms |
| Usability and accessibility | 5 | Touch targets ≥44 points; ≥90% report readable text; information is not color-only; sound can be muted; one-handed play works throughout |
| Technical quality | 5 | 58–60 FPS at the 95th percentile; no visible hitch over 50 ms; launch ≤2 seconds; memory ≤250 MB; zero crashes in 100 sessions; saves survive relaunch/update |

## Hard Gates

The goal cannot complete with any of the following:

- A crash, progression blocker, lost save, or unfinishable boss/world cycle.
- Unfair or invisible collision, unreadable interface, or clipped content on a supported iPad.
- Missing feedback for a major action or placeholder art in normal gameplay.
- Restart longer than one second or controls requiring adult explanation.
- Inappropriate silent-mode, volume, privacy, or child-safety behavior.
- A claimed visual, audio, physical-device, or enjoyment result without direct evidence.

## Required Context

Before each iteration, read this file and inspect:

- `README.md`
- `AidanGameRush/GameScene.swift`
- `AidanGameRush/WorldArt.swift`
- `AidanGameRush/GameAudio.swift`
- `AidanGameRush/Progression.swift`
- Latest simulator/physical-iPad screenshots, build result, scorecard, and playtest notes.

## Evidence Ledger

| Obligation | Evidence | Pass condition | Fallback |
| --- | --- | --- | --- |
| Visual quality | Screenshots of every menu, world, power-up, game-over state, and boss on at least two iPad sizes | No visible defects and ratings meet targets | Record untested size as a visibility gap |
| Motion and feedback | Gameplay video or frame sequence | State changes are readable and effects do not obscure hazards | Use simulator capture provisionally, then verify physically |
| Performance | Xcode Instruments/frame-time capture on a physical iPad | Frame, launch, memory, crash, and thermal targets pass | Simulator evidence is not sufficient for completion |
| Sound | Physical iPad speaker/headphone listening plus level inspection | Clear, responsive, distinct, non-fatiguing mix with no clipping | Record physical listening as pending |
| Controls and fairness | Uncoached first-run observations | Understanding, survival, response, and fair-death targets pass | Adult proxy tests are provisional only |
| Enjoyment and replay | Target-player score sheets and observed restarts | North-star, fun, and replay targets pass | Enjoyment must remain unverified until human testing |
| Persistence | Relaunch, update, date-change, gear, badge, score, and quest tests | All saved state behaves correctly | Preserve reproduction steps for failures |
| Build integrity | Clean simulator and unsigned device builds; signed physical-device install | All builds succeed without warnings attributable to the project | Report signing/external blockers separately |

## Execution Loop

1. **Orient:** Inspect the current build, evidence, scorecard, source, and known visibility gaps before changing anything.
2. **Plan:** Select the smallest work package that fixes a hard gate or improves the lowest/highest-impact score. Attach a validation method before implementation.
3. **Act:** Make one coherent improvement hypothesis per commit. Preserve unrelated work and progression compatibility.
4. **Verify:** Run clean builds, inspect screenshots/video, listen physically when sound changes, test persistence when stored state changes, and perform the applicable human playtest.
5. **Repair:** Fix the cause of any failed gate or regression and rerun its evidence checks. Do not average away a hard failure.
6. **Commit:** Commit only a cohesive, validated increment with a message describing the player-visible outcome.
7. **Report:** Record score changes, direct evidence, residual risks, and visibility gaps in `QUALITY_SCORECARD.md`.
8. **Repeat:** Prioritize hard gates, then weakest weighted category, then most frequent player pain.

## Acceptance Criteria

- Weighted score ≥90/100 for two consecutive validated builds.
- No category below 3.5/5 and every hard gate passes.
- At least 8 target-age players, with guardian consent, are included in at least 30 total sessions.
- Appearance, sound, controls, and fun each average ≥4.2/5.
- At least 70% of target players restart voluntarily.
- Physical-iPad performance, sound, touch response, persistence, full world cycle, and boss completion are directly verified.
- Remaining limitations are explicitly documented and accepted.

## Visibility Gaps

- Automated builds and simulator screenshots cannot prove enjoyment, physical touch feel, speaker quality, thermal performance, or child comprehension.
- Those gaps close only through physical-iPad testing and uncoached target-age playtests with guardian consent.
