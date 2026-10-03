# Known issues

### K1 · `scripts/check-dark.jl` counts no near-black pixel that has a hue, so a dark fill on the dark background passes as a colour fill.

- location: `scripts/check-dark.jl:23`
- evidence: the check exempts every pixel with HSL saturation ≥ 0.3, as the conversion rule of the
  figures defines a colour fill. A pure hue has saturation 1 at any lightness: rgb(0, 0, 47) has
  lightness 0.09 and saturation 1.0, so it does not count. A fill such as `blue!40!bg` is
  rgb(0, 0, 102) in the dark theme, lightness 0.2, and the check counts none of its pixels.
- kind: found late
- found: 2026-10-03
