---
name: frost-sequence-camera-orbit
description: An orbiting camera follows an ice logo as it breaks apart, reforms into two text moments, and fades. HyperFrames block, 1920×1080, 22.5s, 216 variables.
---

# Frost Sequence Camera Orbit

A complete 22.5-second ice sequence: logo, first text, second text, breakup, and fade. The camera orbits the fixed objects with slower front-facing passes for reading. The same particle field carries each transition. Customize the two text moments and SVG logo; the source includes editable camera and assembly timing.

Composition id: `frost-sequence-rig`. Duration 22.5 s at 30 fps, 1920×1080.

## Files

- `frost-sequence-camera-orbit.html` (131 KB)
- `assets/example-logo.svg` (1 KB)
- `assets/fonts/Geist-Bold.ttf` (65 KB)
- `assets/fonts/Geist-OFL.txt` (4 KB)
- `assets/fonts/Geist-Regular.ttf` (65 KB)
- `assets/fonts/Geist-SemiBold.ttf` (65 KB)
- `assets/frost.js` (1.5 MB)
- `assets/Three-LICENSE.txt` (1 KB)
- `assets/ThreeMeshBVH-LICENSE.txt` (1 KB)
- `assets/OpentypeJS-LICENSE.txt` (1 KB)
- `assets/Clipper-LICENSE.txt` (3 KB)
- `assets/gsap-3.14.2.min.js` (128 KB)
- `assets/GSAP-NOTICE.txt` (1 KB)
- `assets/logo.svg` (1 KB)
- `assets/shards-atlas.png` (fetched from the CDN at install)
- `assets/test-mark.svg` (1 KB)
- `assets/textures/bluenoise64.png` (12 KB)
- `assets/textures/ice-inclusions-generated.png` (fetched from the CDN at install)

## Install

Install with `npx hyperframes add frost-sequence-camera-orbit`; by default the files above land under `compositions/frost-sequence-camera-orbit/`. Then mount the block from the host `index.html`:

```html
<div
  data-composition-id="frost-sequence-rig"
  data-composition-src="compositions/frost-sequence-camera-orbit/frost-sequence-camera-orbit.html"
  data-start="0"
  data-duration="22.5"
  data-track-index="1"
  data-width="1920"
  data-height="1080"
></div>
```

Render with custom values by targeting the composition file directly:

```sh
npx --yes hyperframes@0.8.12 render 'compositions/frost-sequence-camera-orbit/frost-sequence-camera-orbit.html' --variables '{"headline1":"Hard to|break.","headline2":"Easy to|remember."}'
```

## Variables

Read at runtime via `window.__hyperframes.getVariables()`; declared on the composition root as `data-composition-variables` (single-quoted attribute, plain JSON).

| id                          | type    | default             | label / range                                                                                 |
| --------------------------- | ------- | ------------------- | --------------------------------------------------------------------------------------------- | ------------- | -------------------------- | ------- | ------- |
| `headline1`                 | string  | `"Hard to           | break."`                                                                                      | First text (  | = line break) max 60 chars |
| `headline2`                 | string  | `"Easy to           | remember."`                                                                                   | Second text ( | = line break) max 60 chars |
| `logoUrl`                   | string  | `"assets/logo.svg"` | Logo SVG asset path (upload in Assets, then paste path) max 200 chars                         |
| `assemblyMode`              | enum    | `"hybrid"`          | Assembly response (physical                                                                   | directed      | hybrid)                    |
| `materialBaseColor`         | color   | `"#ffffff"`         | Base color                                                                                    |
| `baseRoughness`             | number  | `0.31`              | Base roughness 0–0.5 step 0.005                                                               |
| `materialTransmission`      | boolean | `true`              | Transmission                                                                                  |
| `materialBacklight`         | number  | `0.27`              | Backlight through ice 0–2 step 0.01                                                           |
| `ior`                       | number  | `1.675`             | Index of refraction 1–2 step 0.005                                                            |
| `thicknessScale`            | number  | `2.04`              | Thickness scale 0.1–3 step 0.01                                                               |
| `materialAbsorption`        | boolean | `true`              | Absorption / tint                                                                             |
| `attenuationColor`          | color   | `"#d5f4ff"`         | Attenuation colour (white = no absorption, clear glass)                                       |
| `attenuationDistance`       | number  | `6.54`              | Attenuation distance 0.05–12 step 0.01                                                        |
| `materialDispersion`        | boolean | `false`             | Dispersion                                                                                    |
| `dispersion`                | number  | `0.12`              | Dispersion (0 = off; on/off reloads) 0–0.3 step 0.005                                         |
| `materialReflections`       | boolean | `true`              | Reflections                                                                                   |
| `envIntensity`              | number  | `2.04`              | Environment intensity 0–3 step 0.01                                                           |
| `specularIntensity`         | number  | `1.44`              | Specular intensity 0–2 step 0.01                                                              |
| `materialFrost`             | boolean | `true`              | Frost                                                                                         |
| `materialInteriorFrost`     | number  | `0`                 | Uniform frost 0–1 step 0.01                                                                   |
| `frostScale`                | number  | `0.7`               | Scale 0.2–6 step 0.05                                                                         |
| `frostThreshold`            | number  | `0.62`              | Threshold (1 = no frost, clear glass) 0–1 step 0.01                                           |
| `frostSoftness`             | number  | `0.24`              | Softness 0.01–1 step 0.01                                                                     |
| `frostRoughness`            | number  | `0.73`              | Roughness 0–1 step 0.01                                                                       |
| `frostDiffuse`              | number  | `0.11`              | Diffuse (how much light frosted areas catch) 0–1 step 0.01                                    |
| `materialSurfaceBumps`      | boolean | `false`             | Object surface bumps / crack notches                                                          |
| `materialCrystals`          | boolean | `true`              | Crystal bumps                                                                                 |
| `crystalBump`               | number  | `0.01`              | Crystal bump 0–1 step 0.01                                                                    |
| `crystalScale`              | number  | `4`                 | Crystal scale 4–80 step 1                                                                     |
| `materialGrain`             | boolean | `true`              | Grain bumps                                                                                   |
| `materialGrainAmount`       | number  | `0.47`              | Grain strength 0–2 step 0.01                                                                  |
| `materialGrainScale`        | number  | `150`               | Grain scale 1–150 step 1                                                                      |
| `materialCutNormals`        | boolean | `true`              | Fracture normals                                                                              |
| `materialMicro`             | boolean | `true`              | Micro bumps                                                                                   |
| `microBump`                 | number  | `0.445`             | Micro bump 0–1 step 0.005                                                                     |
| `microScale`                | number  | `10`                | Micro scale 10–200 step 1                                                                     |
| `microCoverage`             | number  | `0.25`              | Micro coverage 0–1 step 0.01                                                                  |
| `bumpMaskScale`             | number  | `1.45`              | Mask scale 0.1–6 step 0.05                                                                    |
| `materialRipples`           | boolean | `true`              | Ripples                                                                                       |
| `rippleBump`                | number  | `0.22`              | Ripple bump 0–1 step 0.01                                                                     |
| `rippleScale`               | number  | `23`                | Ripple scale 2–30 step 0.5                                                                    |
| `materialSmudges`           | boolean | `true`              | Smudges                                                                                       |
| `smudgeAmount`              | number  | `0.78`              | Amount 0–1 step 0.01                                                                          |
| `smudgeCoverage`            | number  | `0.58`              | Coverage 0–1 step 0.01                                                                        |
| `smudgeMaskScale`           | number  | `1.85`              | Mask scale 0.1–6 step 0.05                                                                    |
| `smudgeAnisotropy`          | number  | `16.5`              | Anisotropy 1–20 step 0.5                                                                      |
| `smudgeRoughness`           | number  | `0.75`              | Roughness 0–1 step 0.01                                                                       |
| `smudgeWhiteness`           | number  | `0.035`             | Whiteness 0–0.5 step 0.005                                                                    |
| `smudgeScale`               | number  | `1.3`               | Scale 0.5–10 step 0.1                                                                         |
| `materialCracks`            | boolean | `true`              | Cracks                                                                                        |
| `crackLargeScale`           | number  | `2.45`              | Large scale 0.3–8 step 0.05                                                                   |
| `crackWarp`                 | number  | `0.22`              | Warp 0–1.5 step 0.01                                                                          |
| `crackCoverage`             | number  | `0.19`              | Coverage 0–1 step 0.01                                                                        |
| `crackRegionScale`          | number  | `1.8`               | Region scale 0.1–4 step 0.05                                                                  |
| `crackRegionCoverage`       | number  | `0.6`               | Region coverage 0–1 step 0.01                                                                 |
| `veinScale`                 | number  | `8`                 | Vein scale 1–20 step 0.25                                                                     |
| `veinContrast`              | number  | `0.55`              | Vein contrast 0–1 step 0.01                                                                   |
| `crackWidth`                | number  | `0.0025`            | Width 0.0005–0.02 step 0.0005                                                                 |
| `crackBrightness`           | number  | `0.65`              | Brightness 0–3 step 0.01                                                                      |
| `crackDarkness`             | number  | `0.69`              | Darkness 0–1 step 0.01                                                                        |
| `crackRefraction`           | number  | `0.076`             | Refraction 0–0.1 step 0.001                                                                   |
| `crackSurfaceStrength`      | number  | `0.16`              | Surface strength 0–1 step 0.01                                                                |
| `fineScale`                 | number  | `18.4`              | Fine scale 2–20 step 0.1                                                                      |
| `fineAmount`                | number  | `0.52`              | Fine amount 0–1 step 0.01                                                                     |
| `fineCoverage`              | number  | `1`                 | Fine coverage 0–1 step 0.01                                                                   |
| `materialScatter`           | boolean | `true`              | Internal scattering                                                                           |
| `materialInclusionScale`    | number  | `0.05`              | Inclusion scale 0.05–3 step 0.01                                                              |
| `materialInclusionAmount`   | number  | `2`                 | Photographic inclusions 0–2 step 0.01                                                         |
| `interiorScatter`           | number  | `0.09`              | Interior scatter 0–1 step 0.01                                                                |
| `materialClearcoat`         | boolean | `true`              | Clearcoat                                                                                     |
| `clearcoat`                 | number  | `0`                 | Clearcoat 0–1 step 0.01                                                                       |
| `clearcoatRoughness`        | number  | `0`                 | Clearcoat roughness 0–1 step 0.005                                                            |
| `materialShardNormals`      | boolean | `true`              | Shard normals                                                                                 |
| `spriteNormal`              | number  | `0.15`              | Sprite normal strength 0–2.5 step 0.05                                                        |
| `materialShardFrost`        | boolean | `true`              | Shard frost                                                                                   |
| `materialShardTransmission` | boolean | `true`              | Shard transparency                                                                            |
| `spriteSeeThrough`          | number  | `1`                 | See-through (0 = off; on/off reloads) 0–1 step 0.01                                           |
| `materialShardReflections`  | boolean | `true`              | Shard reflections                                                                             |
| `minPixelSize`              | number  | `0.25`              | Minimum pixel size 0–4 step 0.05                                                              |
| `grainSizeMultiplier`       | number  | `1.05`              | Grain size multiplier 0.2–4 step 0.05                                                         |
| `spriteSize`                | number  | `1.9`               | Sprite size 0.3–4 step 0.05                                                                   |
| `spriteTilt`                | number  | `12`                | Sprite tilt 0–70 step 1                                                                       |
| `spriteAlphaCut`            | number  | `0.6`               | Alpha cut 0.05–0.6 step 0.01                                                                  |
| `fontWeight`                | enum    | `"600"`             | Type · Weight (Geist) (400                                                                    | 600           | 700)                       |
| `letterSpacing`             | number  | `0.01`              | Type · Letter spacing -0.1–0.4 step 0.005                                                     |
| `shardAmount`               | number  | `0.44`              | Shards · Visible fraction of the broken volume (Powder amount) 0.02–1 step 0.01               |
| `strayDust`                 | number  | `24`                | Shards · Ambient dust motes around the object (the experiment had 40) 0–200 step 1            |
| `sliceRadius`               | number  | `0.6`               | Break · First (diagonal) slice radius 0.05–1.5 step 0.01                                      |
| `sliceStrength`             | number  | `21.5`              | Break · First slice strength 1–40 step 0.5                                                    |
| `finalEjectBoost`           | number  | `2.5`               | Break · Last break: eject speed and speed cap multiplier 1–6 step 0.1                         |
| `shatterRadius`             | number  | `0.45`              | Break · Follow-up slice radius (sets their spacing too) 0.1–1.5 step 0.01                     |
| `shatterStrength`           | number  | `32.5`              | Break · Follow-up slice strength 1–40 step 0.5                                                |
| `cutThreshold`              | number  | `0.3`               | Tune break · Cut threshold (surface gone above this erosion) 0.3–0.98 step 0.01               |
| `cutSoftness`               | number  | `0.19`              | Tune break · Cut softness 0.005–0.3 step 0.005                                                |
| `edgeWidth`                 | number  | `0.19`              | Tune break · Crumbly edge band width 0.05–0.8 step 0.01                                       |
| `edgeInset`                 | number  | `0`                 | Tune break · Edge inset 0–0.3 step 0.005                                                      |
| `brushSoftness`             | number  | `0.15`              | Tune break · Brush softness (edge falloff of a slice) 0.02–1 step 0.01                        |
| `brushNoise`                | number  | `0.4`               | Tune break · Brush noise (ragged boundary) 0–1 step 0.01                                      |
| `crumbleRate`               | number  | `4.3`               | Tune break · Crumble rate along cracks (high = the whole shape goes at once) 0–6 step 0.05    |
| `crumbleCrackBias`          | number  | `5.1`               | Tune break · Crumble crack bias 0–6 step 0.05                                                 |
| `crumbleDuration`           | number  | `0.35`              | Tune break · Crumble duration after a stroke 0–2 step 0.01                                    |
| `ejectSpeed`                | number  | `0.91`              | Flight · Eject speed 0–4 step 0.01                                                            |
| `ejectSpread`               | number  | `0.48`              | Flight · Eject spread along the normal 0–3 step 0.01                                          |
| `ejectTurbulence`           | number  | `4`                 | Flight · Eject turbulence 0–4 step 0.01                                                       |
| `drag`                      | number  | `0`                 | Flight · Drag (speed decays by this per second) 0–8 step 0.01                                 |
| `gravity`                   | number  | `0`                 | Flight · Gravity (0 = shards never fall) 0–2 step 0.005                                       |
| `turbulence`                | number  | `4`                 | Flight · Turbulence strength (curl noise) 0–4 step 0.01                                       |
| `turbulenceScale`           | number  | `2.65`              | Flight · Turbulence scale 0.2–8 step 0.05                                                     |
| `turbulenceDecay`           | number  | `3.65`              | Flight · Turbulence decay with age (low = keeps swirling) 0.05–4 step 0.01                    |
| `clumpCohesion`             | number  | `0.9`               | Flight · Clump cohesion (shards orbit a leader; 0 = none) 0–10 step 0.05                      |
| `followObject`              | number  | `30`                | Flight · Shards follow the object motion for (s; 30 = whole flight) 0–30 step 0.5             |
| `settleTime`                | number  | `2.2`               | Flight · Settle time (velocity is killed after this; 12 = never) 0.3–12 step 0.05             |
| `settledDrift`              | number  | `1`                 | Flight · Organic drift once settled (curl noise) 0–1 step 0.005                               |
| `maxSpeed`                  | number  | `26.3`              | Flight · Speed cap 1–40 step 0.1                                                              |
| `repelStrength`             | number  | `30`                | Flight · Push out of the solid shape while it breaks 0–30 step 0.1                            |
| `repelRange`                | number  | `0.97`              | Flight · Push range outside the surface 0.02–2 step 0.01                                      |
| `repelRadial`               | number  | `17.5`              | Flight · Push away from the shape centre (clears pockets and the hole) 0–60 step 0.5          |
| `repelRadialRange`          | number  | `3.3`               | Flight · Radial push range (object radii) 1–4 step 0.05                                       |
| `tumble`                    | number  | `1.05`              | Flight · Tumble rate 0–12 step 0.05                                                           |

---

> **Full Reference**: Read `references/FULL_SKILL.md` in this skill directory for the remaining sections of this skill.
