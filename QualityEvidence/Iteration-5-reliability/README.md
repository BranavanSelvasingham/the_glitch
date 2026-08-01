# Iteration 5 — Reliability Evidence

This folder records direct evidence for persistence and runtime reliability work.

## Persistence self-test

The debug-only `--persistence-self-test` mode exercises an isolated temporary
`UserDefaults` suite, never the player's real save. It verifies clean defaults,
score and chip round-trips, gear selection, achievement idempotency and count,
daily quest initialization, target capping, single reward delivery, and next-day
reset behavior.

`persistence-self-test.png` is a simulator capture of the self-test result.

## Build and physical-install results

- Clean Debug simulator build: pass.
- Clean unsigned generic-iPad build: pass.
- Signed Debug build for the connected iPad: pass.
- Install on the paired iPad (A16), iPadOS 26.5.2: pass.
- Automatic launch attempt: pending because the iPad was locked; `devicectl`
  reached the device and reported `FBSOpenApplicationErrorDomain` code 7
  (`Locked`). This is not counted as an app launch or gameplay pass.
