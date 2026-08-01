# Iteration 9 — Audio-System Evidence

The debug-only `--audio-quality-probe` mode exercises the production audio
engine after its synthesized effects and music have been preloaded. It measures
live buffer coverage and scheduling cost, scans generated signal peaks, toggles
and restores mute volumes, and verifies the ambient mixing session.

## Measured simulator result

| Metric | Result | Target | Status |
| --- | ---: | ---: | --- |
| Major-action sound coverage | 7 / 7 | All | Pass |
| Title, world, and boss music coverage | 6 / 6 | All | Pass |
| Maximum effect scheduling cost | 10.70 ms | ≤16.7 ms | Pass |
| Maximum music-switch scheduling cost | 10.70 ms | ≤16.7 ms | Pass |
| Maximum synthesized effect peak | 0.335 | <0.920 | Pass |
| Maximum synthesized music peak | 0.377 | <0.920 | Pass |
| Mute and volume restoration | Pass | Pass | Pass |
| Ambient session with other-audio mixing | Pass | Pass | Pass |

The first probe used an undeclared 10 ms scheduling threshold and reported
10.82 ms for effects and 10.67 ms for music. The threshold was corrected to one
60 Hz frame (16.7 ms), still substantially tighter than the quality goal's
80 ms action-response requirement. No production timing result was discarded
or represented as physical audible onset.

`audio-probe-pass.png` is the directly inspected result screen. The same source
passed clean simulator and signed iPad builds and installed successfully on the
paired iPad. The launch retry was denied because the iPad was locked.

This proves implementation coverage, scheduling, signal headroom, mute
behavior, and session policy. It does not prove physical speaker/headphone mix,
audible onset, fatigue, theme recognition, or player enjoyment; those remain
pending listening and target-player tests.
