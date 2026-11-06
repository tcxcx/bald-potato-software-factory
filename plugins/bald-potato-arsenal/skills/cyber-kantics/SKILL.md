---
name: cyber-kantics
description: >-
  Decompose a product, feature, protocol, or growth loop into the philosophical
  "thinking-machine" types it runs on — Cartesian, Humean, Kantian, decisionist,
  and Girardian — to find the gap between the machine the builder THINKS they
  built and the one actually running, then recompose the stack. Use whenever the
  user wants to analyze incentive design, tokenomics, fee/loyalty/VIP mechanics,
  recommender or feed logic, engagement or status loops, referral mechanics,
  agent behavior, or any system that shapes desire — and especially when they
  ask "what machine is this", "is this Humean or Girardian", "why does this loop
  burn out", "review the behavioral logic of X", "decompose this product", or
  want a critique of a feature, branch, or architecture's underlying logic.
  Trigger even when the user doesn't name the framework but is reasoning about
  why a mechanic drives (or fails to drive) behavior. Based on Yuk Hui's Kant
  Machine (2026) and Fernando Wirtz's "Cyber-Kantianism and Dark
  Girardianism" (421.news, 2026).
---

# Cyber-Kantics

![Cyber-Kantics banner](banner.png)

A diagnostic lens for products and protocols. It treats every behavior-shaping
system as a stack of **thinking-machines**, each defined by *how it relates
desire/data to action*. The point is not to label things cutely — it is to
expose the **hidden machine**: the logic actually driving behavior, which is
usually not the one the builder intended.

The deep claim (from Hui) is that machine-learning architectures are
engineering answers to old epistemological questions — *how does cognition turn
input into output?* That is why classical epistemologies map cleanly onto
machines: both answer the same question in different materials. Wirtz extends
the taxonomy from epistemology into politics (decisionism) and desire
(Girard). All five are framed as kinds of **cybernetic** machine — systems with
feedback — which is why the failure modes are almost always *loops*. The name
"cyber-kantics" comes from Wirtz's coinage *Cyber-Kantianism*.

> **Source material.** This skill is built on two texts. Read or re-skim them
> if you need the underlying argument:
> - Yuk Hui, *Kant Machine: Critical Philosophy after AI* (2026) — the
>   Cartesian / Humean / Kantian → cybernetics core.
> - Fernando Wirtz, "The Philosophy Behind Artificial Intelligence:
>   Cyber-Kantianism and Dark Girardianism," *421.news*, 5 June 2026 —
>   the decisionist and Girardian extensions, and the "dark Girardianism"
>   reading of the tech-right.
>   https://www.421.news/en/ia-thiel-yuk-hui-kant-girardi-philosophy-en/

---

## The five machines

ALWAYS reason with this table first, then write prose.

| Machine | Relates action to… | Signature in a product | Characteristic failure |
|---|---|---|---|
| **Cartesian** | fixed a-priori rules | hard-coded thresholds, "code is law", deductive logic, explicit if/else | brittle, gameable, "limited by its original settings" |
| **Humean** | quantified own-history data | frequency/volume tiers, surge pricing, "more usage → cheaper/more visible", pure induction | can't escape its probability space; can't predict the unseen; optimizes what it can already measure |
| **Kantian** | rules *derived* from cases under a-priori constraints | reflective judgment, a "constitution" that filters a raw engine, generalizes from particulars | expensive; the constraint can ossify back into a Cartesian rulebook |
| **Decisionist** | the *exception* | freeze/blacklist, circuit breaker, admin override, "break glass", manual intervention | the exception normalizes — the override becomes the de-facto rule |
| **Girardian** | *mimetic* desire (I want it because others want it) | status tiers, VIP, leaderboards, social proof, badges, anything whose value is positional | the loop amplifies to mutual destruction; mercenary, portable, non-sticky |

### The distinctions that matter most

- **Humean vs. Girardian** is the highest-value cut and the easiest to miss.
  Humean: a thing becomes more desirable *the more it is used* (frequency,
  clickbait) — individualizing. Girardian: a thing becomes more desirable
  *because others desire it* (imitation, status) — organizing. A feed, a VIP
  tier, or a token can look like one and be the other. Most "engagement
  optimizers" are quietly Girardian.
- **Cartesian vs. Kantian** is the robustness cut. A fixed threshold
  (`volume > X → tier`) is Cartesian and farmable. A tier *derived* from the
  behavior you actually want, without a fixed cutoff, is Kantian and resists
  gaming.
- **Decisionist** is orthogonal: it is the layer that suspends the normal rule.
  Almost every adversarial system *needs* one and many ship without it.

---

## The core move: find the hidden machine

The whole value of this skill is one question:

> **Which machine is actually running under the one they think they built?**

Builders narrate their *intended* machine ("we're just a neutral optimizer
surfacing what people want" = Humean). The *actual* machine is whatever
behavior the design rewards. The gap is usually invisible from inside the
build, because the intended and actual machines often produce the *same
dashboard going up and to the right* — until the actual machine's failure mode
hits.

Headline pattern to watch for: **a Humean intention masking a Girardian
engine.** "We reward usage" (Humean) that in practice rewards *being seen to
out-rank others* (Girardian). The tell: would the mechanic still drive behavior
if the user's standing were private? If not, it's Girardian.

**Calibration — the hidden machine is NOT always Girardian, and sometimes
there isn't one.** Crying "Girardian" everywhere is this skill's primary failure
mode; guard against it actively. The hidden machine can be **decisionist** (a
"neutral, code-is-law" protocol whose freeze/override function reveals an
issuer-sovereign — the freeze is the soul, "code is law" the alibi). Or the
honest diagnosis may simply be *the intended machine itself* — a genuinely
Humean optimizer is genuinely Humean, and saying so is a valid result. Do not
manufacture a Girardian read where the mechanism is own-history Humean: a feed
ranked purely on *your* past behavior is Humean, and its real danger is the
Humean failure (self-consumption, preference collapse, filter bubble), not
mimesis.

**Operational test — whose data is in the function?** This is the crisp
discriminator behind the privacy test. *Humean* reads **your** history.
*Girardian* reads **other people's** desire — like counts, "trending", "N people
bought this", rank-vs-peers. Inspect the actual ranking/pricing/reward function:
if it consumes only the user's own data, it is Humean even when engagement is
sky-high; the Girardian layer is real only if others' behavior enters as signal.
When the inputs are ambiguous, say what you'd need to see ("does social proof
enter ranking?") rather than guessing the flashier answer.

---

## Workflow

When given a product, feature, branch, protocol, or loop:

1. **Inventory the surfaces.** List every place the system touches a user
   decision: pricing, ranking, rewards, gating, badges, refunds, freezes,
   defaults. If given code or a repo, read the incentive-bearing parts (fee
   logic, tier logic, ranking/sort, any admin/guardian functions, the UI that
   *displays* standing). The branch/feature name itself is often a confession —
   parse it.
2. **Type each surface.** Assign one (or more) of the five machines to each,
   using the signature column. Note where you're unsure.
3. **State the intended machine.** What does the builder believe they built?
   Infer from naming, comments, and framing.
4. **Name the hidden machine.** Where do intended and actual diverge? Apply the
   "would it work in private?" test and the Humean-vs-Girardian cut.
5. **Locate the missing machines.** Almost every real system is an incomplete
   stack. Two are missing most often: a **Kantian** layer (so rewards track
   *wanted* behavior, not gameable proxies) and a **decisionist** layer (so the
   system survives adversaries). Flag absences explicitly — an absent machine is
   a vulnerability.
6. **Diagnose the failure loop.** Every machine here is cybernetic; name the
   specific feedback loop and how it ends. Girardian → status race → mercenary
   churn. Humean → self-consumption / model collapse. Cartesian → first
   sophisticated farmer defines your economics. Decisionist → exception
   normalizes.
7. **Recompose.** Prescribe how to add the missing machines and rebalance,
   using the recomposition patterns below. The goal is a *composed* stack, not
   "more of the dominant machine."

---

## Recomposition patterns

These are the standard upgrades, in rough priority order.

- **Add the Kantian layer to kill gaming.** Replace fixed Cartesian thresholds
  with a tier/score *derived* from behavior you actually value (net liquidity,
  tenure, retention, counterparty quality) rather than a raw, farmable proxy
  (throughput, clicks). Reflective judgment beats a static cutoff precisely
  because there is no fixed number to game.
- **Add the decisionist layer to survive adversaries.** Any rewards/status
  system is an invitation to Sybil and self-dealing. Add a sovereign exception
  path — clawback, tier-revocation, circuit breaker — *separate* from the
  normal rule. If the normal rule is the only rule, the first competent attacker
  sets your economics.
- **Bind status to a non-positional good (the anti-mimetic hook).** Wirtz's
  sharpest practical point: the one who *manages* mimetic desire stays outside
  the loop. Pure status races burn out and churn. Use the Girardian pull for
  *acquisition*, but anchor *retention* to something the user keeps regardless
  of others — vested rebates, durable tenure, real governance weight. This is
  the difference between a memecoin (pure Girardian → rug) and a brand
  (Girardian acquisition + a real moat).
- **Don't over-Humeanize.** If the dominant machine is already Humean
  (pure optimization on measured frequency), beware the self-consumption loop:
  the system feeds on its own outputs and collapses into a narrow probability
  space. The fix is usually a Kantian constraint, not more data.

---

## Output structure

Default to this template unless the user wants something else. Keep prose tight;
lead with the table and the hidden machine.

```
## Stack inventory
[table: surface → machine type → note]

## Intended vs. actual
- Intended machine: ...
- Hidden machine: ... (with the "would it work in private?" test)

## Failure loop
[the specific cybernetic loop and how it ends]

## Missing machines
- [absent machine] → [the vulnerability it leaves open]

## Recomposition
[ordered, concrete moves mapped to specific surfaces/functions]
```

---

## Worked example

**Input:** a DeFi branch named `feat/kawaii-vip-fee-discount`.

**Output (abridged):**

- **Stack inventory.** *Fee discount* → Humean (volume → lower price, desire
  quantified into a tier). *VIP* → Girardian (a badge's value is that others
  lack it). *Kawaii* → Girardian distribution layer (cuteness makes the badge
  screenshottable and identity-expressive — a desire-triangulation skin).
- **Intended vs. actual.** Intended: a Humean loyalty/pricing optimization
  ("we reward volume"). Hidden: a Girardian status engine. The "would it work in
  private?" test fails — a *secret* VIP tier wouldn't drive the same behavior, so
  the real driver is positional, not volumetric.
- **Failure loop.** Mimetic status race pulls in mercenary volume that
  evaporates the instant a competitor ships a shinier tier. The mimetic good is
  *portable*; nothing is sticky to the product.
- **Missing machines.** No **Kantian** layer → the `volume > X` cutoff is
  Cartesian and wash-trade-farmable. No **decisionist** layer → no clawback or
  revocation path for detected gaming, so the first farmer defines the
  economics.
- **Recomposition.** Derive the tier from net liquidity + tenure + retention,
  not raw throughput (Kantian, kills wash farms). Add a guardian
  clawback/revocation exception (decisionist). Bind the kawaii badge to a vested
  rebate the user keeps regardless of rank (anti-mimetic retention anchor), while
  letting the VIP pull do the acquisition work.

---

## Heuristics

- The branch/feature/product name is often the fastest read on the intended
  stack. Parse it before the code.
- "Engagement", "viral", "VIP", "leaderboard", "status", "exclusive" →
  suspect Girardian, test for it.
- "Optimize", "personalize", "surge", "volume", "frequency" → suspect Humean.
- "Threshold", "code is law", "immutable", "hard-coded" → Cartesian; ask what
  happens when it's gamed.
- "Freeze", "blacklist", "pause", "guardian", "admin", "override" →
  decisionist; ask whether the exception is becoming the rule.
- A system with *no* decisionist layer in an adversarial setting is almost
  always under-built, not elegantly minimal.
- **Calibration check before assigning Girardian:** confirm *other people's*
  signal is actually inside the mechanism. If it isn't, resist — name the Humean
  or decisionist reality instead. "The intended machine is the actual machine"
  is a legitimate finding, not a failure to dig deep enough.
- Resist forcing a single label. Real systems are composed; the insight is in
  the *layering* and the *gap*, not the taxonomy badge.

---

## Lineage and attribution

The three-machine core (Cartesian / Humean / Kantian, culminating in
cybernetics) is from **Yuk Hui, *Kant Machine: Critical Philosophy after AI*
(2026)**. Hui's surrounding apparatus — mechanism vs. organicism, the reading
of Kant's *Critique of Judgment* as anticipating cybernetics, *technodiversity*
— sits behind the table.

The **decisionist machine** (via Carl Schmitt's "sovereign is he who decides on
the exception") and the **Girardian machine** (via René Girard's mimetic
theory), plus the **"dark Girardianism"** reading of the contemporary
tech-right (Thiel, Vance, Karp), are the contribution of **Fernando Wirtz, "The
Philosophy Behind Artificial Intelligence: Cyber-Kantianism and Dark
Girardianism," *421.news*, 5 June 2026**
(https://www.421.news/en/ia-thiel-yuk-hui-kant-girardi-philosophy-en/). The
skill's name borrows Wirtz's term *Cyber-Kantianism*.

Use the framework as a generative lens, not a fixed taxonomy — Hui's own
principle of *technodiversity* implies there are always more machines to name.
