# Iteration 8 — Controls and Pacing Evidence

The debug-only `--gameplay-quality-probe` mode uses the production input helper,
spawners, obstacle geometry, defeat transition, and restart path. It drives the
game automatically only so the measurements are repeatable.

## Measured simulator result

| Metric | Result | Target | Status |
| --- | ---: | ---: | --- |
| Boost input to processed frame | 16.3 ms | ≤50 ms | Pass |
| First chip course | 1.82 s | ≤5 s | Pass |
| First power-up | 8.22 s | ≤25 s | Pass |
| Restart request to playing frame | 21.1 ms | ≤1,000 ms | Pass |
| Minimum obstacle gap | 245 pt | Player body: 70 pt | Pass |
| Clearance beyond player body | 175 pt | ≥70 pt | Pass |
| Meaningful world change | 24 s | 20–30 s | Pass |

`mechanics-probe-pass.png` is the directly inspected result screen.

The same source also passed a clean signed iPad build and installed successfully
on the paired iPad. The automated launch attempt was denied because the iPad was
locked, so this iteration does not claim physical-device runtime evidence.

This evidence covers implementation timing and geometry. It does not prove that
children understand the controls uncoached, survive their first run, or consider
deaths fair; those requirements remain pending target-player observation.
