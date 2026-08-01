# Iteration 6 — Performance Evidence

The debug-only `--performance-probe` mode drives Aidan through Cloud Kingdom,
Dino Jungle, Candy Canyon, Storybook Castle, and into The Glitch boss while
recording raw frame intervals after a two-second warm-up.

## Repair trail

| Probe | P95 FPS | Worst frame | Hitches >50 ms | Launch | Memory | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Initial | 60.0 | 243.5 ms | 4 | 0.39 s | 186 MB | Fail |
| Cached synthesized audio | 60.0 | 63.0 ms | 1 | 1.30 s | 203 MB | Fail |
| Cached audio + prebuilt scenery | 60.0 | 36.6 ms | 0 | 1.27 s | 229 MB | Pass |

The initial trace exposed synchronous music generation at world changes. Audio
buffers are now synthesized once during launch. Prebuilding the four scenery
graphs removed the remaining transition hitch. Both changes trade a bounded
increase in launch time and memory for smooth play, while remaining inside the
goal thresholds.

`performance-probe-pass.png` is the directly inspected final simulator result.

The final sources also passed a clean signed build for the connected iPad and
were installed over the preceding build successfully. Automatic launch was
denied because the iPad remained locked, so physical runtime and Instruments
evidence remain required for goal completion.
