# Known issues

### K1 · `scripts/check-dark.jl` counts no near-black pixel with HSL saturation ≥ 0.3, so a dark fill on the dark background passes as a colour fill.

- location: `scripts/check-dark.jl:37`
- evidence: the check exempts every pixel with HSL saturation ≥ 0.3 as a colour fill, as its
  header states. A pure hue has saturation 1 at any lightness: rgb(0, 0, 47) has lightness 0.09
  and saturation 1.0, so it does not count. A fill that mixes a hue with `bg` is no such case:
  it is at least as light as `bg`, which the check exempts by design.
- kind: found late
- found: 2026-10-03
