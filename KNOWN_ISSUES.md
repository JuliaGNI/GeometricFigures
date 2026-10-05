# Known issues

### K1 · `scripts/check-dark.jl` counts no near-black pixel with HSL saturation ≥ 0.3, so a dark fill on the dark background passes as a colour fill.

- location: `scripts/check-dark.jl:39`
- evidence: the check exempts every pixel with HSL saturation ≥ 0.3 as a colour fill, as its
  header states. A pure hue has saturation 1 at any lightness: rgb(0, 0, 47) has lightness 0.09
  and saturation 1.0, so it does not count. A fill that mixes a hue with `bg`, such as
  `blue!20!bg` (no figure uses it), is rgb(25, 29, 80) in the dark theme, lightness 0.21 and
  saturation 0.52, and the check would count none of its pixels.
- kind: found late
- found: 2026-10-03
