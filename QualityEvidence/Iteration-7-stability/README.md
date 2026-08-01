# Iteration 7 — 100-Session Stability Evidence

## Result

- Sessions checked: **100**
- Sessions alive at the gameplay check: **100**
- Early exits or crashes: **0**
- Distribution: **25 starts per world** across Cloud Kingdom, Dino Jungle,
  Candy Canyon, and Storybook Castle.

## Method

The signed-source-equivalent Debug simulator build from `14fdbf9` was launched
100 times on the iPad Pro 11-inch (M5), iPadOS 26.5 simulator. Each launch used
demo flight and rotated the requested starting world. After 1.7 seconds—long
enough for scene construction and automatic gameplay entry—the returned process
ID was checked on the host. The next session deliberately terminated the prior
process before launching a fresh one.

This is direct evidence for repeated launch and early-game stability. It does
not substitute for long-duration runs, crash-free target-player sessions, or
physical-iPad thermal and lifecycle testing.
