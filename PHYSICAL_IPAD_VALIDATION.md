# Physical iPad Validation Runbook

Use this only on the dedicated development build. Do not erase app data unless
the owner explicitly approves it.

## Before starting

- Unlock the connected iPad and keep it awake on the Home Screen.
- Set brightness near 70%, volume near 50%, and disconnect Bluetooth audio.
- Confirm the game is installed as **Aidan's World Rush**.
- Record the device model, iPadOS version, date, and build commit in
  `QualityEvidence/Physical-iPad/VALIDATION_LOG.md`.

## Required physical checks

1. Launch the game and time first visible frame. Confirm no clipping, black app
   bars, wrong orientation, or unreadable title text.
2. With sound on, listen through the iPad speaker to the title, one pickup, one
   power-up, one shield hit, one defeat, two different worlds, and the boss.
3. Repeat a short section with wired/USB-C headphones if available. Confirm
   effects are clear over music, no crackle/clipping is audible, and repeated
   pickups are not tiring.
4. Toggle sound off and on from both a menu and gameplay. Confirm silence,
   visible state, restoration, and persistence after relaunch.
5. Play one complete cycle through all four worlds and defeat The Glitch. Check
   touch response, collision readability, pause/resume, one-handed reach, and
   whether the device becomes uncomfortably warm.
6. Cause a defeat, restart immediately, collect chips, unlock/equip gear if
   possible, then background and reopen the app. Confirm state survives.
7. Lock/unlock once during a run and once on a menu. Confirm the app resumes
   safely and audio does not duplicate.
8. Install the next signed update without deleting the app, relaunch, and
   confirm best score, chips, badges, daily quest, and selected gear persist.

## Pass conditions

- Physical performance meets the frame, hitch, launch, memory, crash, and
  thermal targets in `QUALITY_GOAL.md`.
- Touch feels immediate, controls work one-handed, and collisions match the art.
- Speaker and headphone audio are distinct, balanced, non-fatiguing, and free of
  audible clipping.
- Every critical screen is readable and unclipped in landscape.
- Full world/boss progression, pause, restart, lifecycle, and persistence pass.

Any failed item is a hard stop: record it, repair the cause, and rerun the same
check before raising the score.
