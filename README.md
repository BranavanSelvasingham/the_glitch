# Aidan's Game Rush

A native iPad arcade-flight game built with Swift and SpriteKit.

## Current playable

- Hold anywhere to fire Aidan's booster and climb; release to dive and charge Rush Energy.
- When the meter fills, tap to trigger Star Rush: surge forward, pull in chips, and smash through hazards and Glitch creatures.
- Follow a three-part story about Aidan, his booster, and The Glitch.
- Fly through Cloud Kingdom, Dino Jungle, Candy Canyon, and Storybook Castle.
- Outsmart four world-specific enemies: Cloud Swooper, Jungle Snapper, Candy Bouncer, and Castle Gargoyle.
- Chase curved Adventure Trails of Spark Chips and collect shield-bubble and chip-magnet power-ups.
- Chain chips, close calls, and Star Rush smashes into a time-limited Flow multiplier worth up to 5×.
- Earn score bonuses for skillful near misses and enemy smashes, with dedicated visual, sound, haptic, camera-shake, and impact feedback.
- See animated boost/glide poses, physically aligned world-space booster exhaust, pickup reactions, lively enemies, and dedicated defeat and boss-victory sequences.
- Defeat The Glitch in a booster-blast boss battle after completing all four worlds.
- Permanently unlock and equip four richly illustrated booster styles with saved Spark Chips.
- Complete a daily chip quest and earn five persistent adventure badges.
- Chase a persistent high score, pause at any time, and restart instantly.
- Hear distinct title, world, and boss music plus layered action sounds, with a persistent mute control and pickup/collision haptics.

The four playable worlds are rendered with SpriteKit using original illustrated assets. Original key art and an app icon give the game a polished identity while keeping gameplay lightweight and responsive.

## Play on the Mac first

Open the project in Xcode, choose an iPad Simulator as the run destination, and press **Run**. A mouse click acts like a finger: click and hold to rise, then release to glide down.

## Run on an iPad

1. Open `AidanGameRush.xcodeproj` in Xcode.
2. Select the **AidanGameRush** target, open **Signing & Capabilities**, and choose your Apple development team.
3. Connect and trust the iPad, then select it as the run destination.
4. Press **Run**.

The app is iPad-only, uses landscape orientation, and supports iPadOS 17 or later.

## Project layout

- `AppDelegate.swift` starts the native UIKit app.
- `GameViewController.swift` hosts the SpriteKit view.
- `GameScene.swift` owns game flow, spawning, scoring, contacts, and progression.
- `GameModels.swift` defines worlds, game phases, power-ups, and physics categories.
- `Progression.swift` owns booster unlocks, daily quests, and achievements.
- `WorldArt.swift` draws the worlds, Aidan, enemies, hazards, and pickups.
- `GameAudio.swift` generates lightweight arcade sound effects.
- `ARTWORK.md` records the generated-art sources and exact production prompts.
