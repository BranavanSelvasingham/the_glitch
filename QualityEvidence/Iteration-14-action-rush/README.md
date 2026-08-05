# Iteration 14 — Dive, Charge, and Star Rush

## Goal and hypothesis

Replace the passive hold/release survival rhythm with a one-finger action loop:
dive deliberately to charge Rush Energy, chase chip trails and close calls to
build Flow, then spend the full meter on a short Star Rush that can smash
hazards and Glitch creatures.

## Implemented

- Diving charges a persistent Rush Energy meter; chips, power-ups, and close
  calls add smaller boosts.
- A full meter makes the next touch trigger a 2.65-second Star Rush with forward
  movement, a stabilised flight lane, faster scenery, chip attraction, and
  temporary collision-breaking power.
- Star Rush has a large aura, draining meter, speed lines, stronger nozzle
  exhaust, impact flash, camera shake, haptics, and dedicated ready/rush/smash
  sounds.
- Chips, near misses, and smashes extend a 2.4-second Flow chain worth up to 5x.
- Curved Adventure Trails periodically place 12 existing Spark Chip assets into
  three alternating chase formations.
- Star Rush can damage the boss for two health while ordinary play keeps the
  existing shield, magnet, projectile, and flight rules.

## Validation results

- Clean current-source iPad A16 simulator build: **PASS**.
- Star Rush executable probe: **PASS** — 0.0 ms input-to-mode response, 2.67 s
  attack window, one hazard smashed, Flow x3 reached, and the run survived.
- Mechanics regression probe: **PASS** — 16.0 ms boost response, 1.85 s first
  chip course, 8.23 s first power-up, 19.5 ms restart, 245-point gap,
  175-point excess clearance, and 24 s world cadence.
- Audio regression probe: **PASS** — 11/11 effects and 6/6 themes, 10.78 ms
  maximum effect scheduling, 10.73 ms maximum music switching, 0.335/0.377
  peaks, and correct mute/session behavior.
- Visual inspection: **PASS** on iPad A16 and iPad mini simulator sizes. The
  charge state, active countdown, draining meter, Flow score, smash callout,
  player aura, enemy silhouettes, and pause/sound controls remain readable.
- Signed physical-iPad build and install: **PASS**. Automatic launch was blocked
  because the connected iPad was locked, so physical touch/audio inspection is
  still pending.

## Evidence files

- `star-rush-showcase.mp4` — ten-second, 60 fps Candy Canyon sequence from
  ready state through activation, smash, recovery, and continuing encounters.
- `star-rush-contact-sheet.jpg` — sampled frames from the showcase.
- `star-rush-active.jpg` and `star-rush-smash.jpg` — active attack and collision
  feedback at gameplay scale.
- `ipad-mini-star-rush.jpg` — smaller-iPad HUD and action-fit check.
- `star-rush-probe.jpg`, `mechanics-probe.jpg`, and `audio-probe.jpg` — live
  executable result screens from the exact source iteration.

## Visibility limits

The probes establish implementation timing, regression safety, and visual fit;
they do not establish whether Aidan finds the new loop more exciting. The fun
rating remains deliberately unchanged until an uncoached physical-iPad session
records comprehension, voluntary restarts, favorite moments, and a direct
excitement score.
