---
name: schiller-behavioral
description: >-
  Behavioral-economics + crypto-gamification lens for DeFi. Decomposes a
  product, token, reward loop, fee/VIP/referral mechanic, quest, or growth
  funnel into the FIVE Shiller engines — narrative, feedback loop, animal
  spirits, phishing-for-phools, and money illusion — then maps each to a hard
  unit-economics number (CAC, LTV, payback, churn, k-factor, NRR, contribution
  margin) and tunes it. The core question it answers is "are we SHILLING or
  BUILDING?": is growth a contagious story backed by real fundamentals, or a
  naturally-occurring Ponzi feedback loop that extracts from our own users. Use
  whenever the user wants to improve unit economics, design or audit tokenomics,
  points/streaks/tiers/leaderboards, referral or win-back mechanics, pricing,
  subscriptions, airdrops, or any growth/retention loop — and especially when
  they ask "what's the narrative", "is this a Ponzi", "model the contagion",
  "tune our unit economics", "is this a dark pattern", "are we phishing our
  users", "design a positive-sum game", "should we launch a token", "do we need a
  token", "improve LTV/CAC", "behavioral economics of X", "are we shilling", or
  "run schiller". Trigger even when the framework
  isn't named but the user is reasoning about why a growth loop pumps then dies,
  or whether a reward is economically backed. By principle we NEVER phish our own
  users: the skill recognizes manipulation / dark patterns and rejects them,
  replacing extraction with positive-sum games where the user wins when we win.
  Carries BUFI's token rule — a sustainable product needs neither a token nor VC;
  yield comes on-chain from protocol fees + Morpho; a token only later, if real
  community demand exists and the product is consolidated ("earn the token, don't
  need it"). Based on the work of Robert J. Shiller (Yale; Nobel 2013), especially
  *Phishing for Phools* (with George Akerlof).
metadata:
  author: tcxcx
  version: "1.0.0"
  argument-hint: <feature | token | loop | funnel | metric | path>
---

# Schiller-Behavioral

> "The ability of the market to crash is not a flaw; it is a feature of a market
> driven by human psychology." — paraphrase of the spirit of *Irrational
> Exuberance*

A diagnostic lens for DeFi products and protocols that treats every growth loop
as a piece of **applied psychology with a P&L attached**. It decomposes a
mechanism into the behavioral engines that actually move it, then forces each
engine to answer to a **hard unit-economics number** — because a behavioral
insight you can't tie to CAC, LTV, churn, or margin is just a vibe.

The name is a pun, and the pun *is* the thesis. Robert **Shiller** is the Yale
economist who showed markets run on contagious stories and animal spirits; to
**shill** is to pump a story with nothing under it. This skill exists to tell the
two apart in *your own* product:

> **The core question: are we SHILLING or BUILDING?**
> Shilling = a contagious narrative + a feedback loop with no fundamental
> underneath (a naturally-occurring Ponzi). Building = a contagious narrative
> *backed by real cash flows*, with the behavioral mechanics tuned to align —
> not extract from — the user. Same dashboard going up-and-to-the-right; opposite
> destiny.

> **Source material.** Built on Robert J. Shiller's body of work. Re-skim if you
> need the underlying argument:
> - *Narrative Economics* (2019) + the 2017 AEA presidential address — economic
>   events spread like epidemics; model them with the Kermack–McKendrick SIR
>   contagion model. Bitcoin is his canonical narrative.
> - *Irrational Exuberance* (2000; 2nd ed. 2005; 3rd 2015) — price-to-price
>   feedback loops, "new era" thinking, the **naturally occurring Ponzi
>   process**. He called the dot-com and housing tops.
> - *Animal Spirits* (2009, with George Akerlof) — confidence, fairness,
>   corruption/bad faith, money illusion, and stories as macro drivers.
> - *Phishing for Phools* (2015, with Akerlof) — the **phishing equilibrium**:
>   if a manipulable human weakness is profitable to exploit, a free market will
>   produce someone who exploits it. Maybe you.

---

## The five engines

ALWAYS reason with this table first, then write prose. Each engine ties to a
behavioral mechanism, a place it shows up in DeFi, the unit-economics number it
moves, and how it kills you when untuned.

| Engine | Shiller concept | Signature in DeFi / gamification | Unit-econ lever | Characteristic failure |
|---|---|---|---|---|
| **Narrative** | *Narrative Economics* — contagious stories spread SIR-style (R₀, decay, recurrence) | the pitch, ticker, meme, "number go up", airdrop hype, the Floor, social feed | **CAC ↓, k-factor ↑** (story does the acquiring) | the epidemic peaks and decays; CAC spikes when the story tires; no story = paid-only growth |
| **Feedback loop** | *Irrational Exuberance* — price→attention→price reflexivity | TVL flywheels, emissions→APY→TVL, points→volume→points, leaderboard climbs | **LTV, retention** (loops compound value) | a loop with no external cash inflow is a **Ponzi**; reverses as fast as it pumped |
| **Animal spirits** | confidence · fairness · money illusion · bad faith · stories | trust in the peg/team, "is this fair?", token-denominated PnL, audits | **churn ↓, NRR ↑** (trust retains) | a fairness breach or confidence shock → bank-run churn, non-linear |
| **Phishing-for-phools** | manipulation exploits a profitable bias | dark patterns, hidden fees, FOMO timers, confusing slippage, mercenary airdrops | **short-term ARPU ↑ / long-term LTV ↓** | extraction shows up as churn + reputational decay; the equilibrium *forces* it on you |
| **Money illusion** | nominal vs. real confusion | APY in a token that's down 80%, "free" gas paid in volatility, $ vs. token NAV | **reported vs. real margin** | users (and you) optimize a nominal number while real value leaks |

### The distinctions that matter most

- **Narrative vs. feedback loop** is the bubble cut. A narrative *recruits* (it
  spreads person-to-person); a feedback loop *compounds* (price/points/TVL feed
  themselves). A bubble is a narrative and a feedback loop reinforcing each
  other. You want the narrative; you want the loop *only if a real cash flow
  closes it*.
- **Feedback loop: virtuous vs. Ponzi** is the single highest-value cut, and the
  easiest to flinch from because both look identical while pumping. The test:
  **trace the dollar.** If new participants' money is the *only* thing paying
  existing participants, it's a Ponzi loop. If an external cash flow (real yield,
  fees, spread, T-bills) closes the loop, it's virtuous. (BUFI's "Yield Machine"
  is the archetype of the virtuous version: every dollar earns spread or
  yield — the loop is closed by *fundamentals*, not by the next buyer.)
- **Phishing is not optional — it's an equilibrium.** Shiller's hardest point:
  you don't decide whether phishing exists in your market; the market does. If a
  bias is profitable to exploit, competition produces an exploiter. The only
  choice is whether *you* exploit your users or *defend* them — and defending is
  a moat precisely because the equilibrium pushes everyone else to extract.

---

## The core move: shilling or building?

The whole value of this skill is forcing one honest answer:

> **Strip the narrative and the feedback loop. What real cash flow is left?**

Builders narrate the *intended* machine ("sustainable yield", "real rewards",
"community-owned"). The *actual* machine is whatever the money flow reveals. The
gap is invisible while the loop pumps because a shill and a builder post the
**same chart** — until the narrative's epidemic curve rolls over and the loop
runs in reverse.

Two tests, run them both:

1. **The dollar-trace (Ponzi test).** Follow one dollar of reward/yield/points
   value back to its source. Does it come from an external cash flow (fees,
   spread, lending APY, USYC) or from the next participant's deposit? "Emissions"
   that aren't backed by revenue are the next participant's deposit wearing a
   costume.
2. **The private test (phishing test).** Would the mechanic still work if the
   user *fully understood it and could see it privately*? A fee that survives
   disclosure is a price; a fee that needs obfuscation (hidden slippage, a
   confusing timer, a default opt-in) is a phish. If understanding kills it, it's
   extraction.

**Calibration — not everything is a Ponzi or a phish.** Crying "Ponzi!" or "dark
pattern!" at every incentive is this skill's primary failure mode; guard against
it actively. Emissions backed by real fee revenue are a *customer-acquisition
cost*, not a Ponzi — saying so is a valid result. A FOMO timer on a genuinely
limited mint is *information*, not a phish. Loss aversion harnessed by a streak
the user *wants to keep* is engagement, not manipulation. The honest diagnosis is
often "the narrative is real and the loop is closed by fundamentals — fund the
narrative harder." Do not manufacture a scandal where the unit economics are
sound. When the dollar-trace is ambiguous, say what you'd need to see ("what % of
rewards is paid from fees vs. token emission?") rather than guessing the
spicier answer.

---

## The house rule — we never phish (positive-sum only)

> "We wrote this book as admirers of the free market system, but hoping to help
> people better find their way in it. The economic system is filled with
> trickery, and everyone needs to know that. We all have to navigate this system
> in order to maintain our dignity and integrity, and we all have to find
> inspiration to go on despite the craziness all around us."
> — George A. Akerlof & Robert J. Shiller, *Phishing for Phools: The Economics
> of Manipulation and Deception* (2015)

Akerlof and Shiller wrote *Phishing for Phools* as admirers of free markets who
wanted people to keep their **dignity and integrity** while navigating a system
full of trickery. This skill inherits that posture, and BUFI takes it as a hard
rule, not a preference:

> **By principle, we never phish our own users.**

The phishing equilibrium says a free market will *produce* an exploiter for every
profitable human weakness. Our answer is to refuse to be that exploiter — and to
make the refusal a moat, because in an equilibrium that pushes everyone else to
extract, the one who doesn't earns the trust that compounds.

So when the phishing self-audit finds extraction in *our* design, the verdict is
**never** "tune it for more ARPU." The mandate is **recognize → reject →
replace**:

1. **Recognize it.** Name the bias being exploited and the short-term number it
   inflates. Don't soften it because it's ours — *especially* because it's ours.
2. **Reject it.** Remove the dark pattern, even at a short-term revenue cost.
   Extraction inflates this quarter's ARPU and inoculates the user forever — in
   SIR terms a phished user becomes permanently *immune* to every future
   campaign. A phish is a loan against your own retention at a usurious rate.
3. **Replace it with a positive-sum game.** Don't leave a hole where the dark
   pattern was; fill it with a mechanic whose dollar-trace terminates in real
   value *for the user* and that survives full disclosure. Redesign so the user
   wins when we win.

**The positive-sum test (run it alongside the dollar-trace and the private
test):** *does this mechanic make the pie bigger, or just move a slice from the
user to us?* Zero-sum extraction is a phish with better PR. Only ship mechanics
where the user's win and ours are the **same** win — real yield shared, real
discounts earned, real privacy delivered, real status that is also real value the
user keeps. Fairness and transparency are not taxes on the model; under a phishing
equilibrium they are the **durable competitive advantage**.

This reframes the whole skill: it is *not* a manual for manipulating users more
efficiently. It is a manual for **finding where the market would tempt us to
phish, refusing, and building the positive-sum version instead** — so growth comes
from the narrative being *true* and the loop being *closed by real value*, never
from a phool who didn't understand.

---

## The token rule — earn the token, don't need it

> "A meta é criar um produto sustentável sem a necessidade imediata de um token
> ou de investimento de capital de risco. O rendimento (yield) deve ser gerado
> on-chain através de taxas do protocolo e das atividades da Morpho. A
> possibilidade de lançamento de um token futuro será considerada apenas se
> houver demanda real da comunidade e se o produto estiver devidamente
> consolidado."
> — BUFI guiding principle

In English: **the goal is a sustainable product that needs neither a token nor
venture capital to stand up.** Yield is generated *on-chain* from protocol fees
and Morpho activity. A token is considered only *later*, and only if (a) there is
real community demand **and** (b) the product is already consolidated.

This is the shilling-or-building thesis applied to the **capital structure
itself**, and it is BUFI's standing answer:

- **A token is the strongest Narrative engine and the most dangerous feedback
  loop at once.** Launched early it *is* the naturally-occurring Ponzi: the loop
  closes on the next buyer, the narrative is "number go up", and the product is an
  afterthought. The token rule forbids exactly that ordering.
- **VC capital is a feedback loop closed by investors, not users.** It can buy CAC
  and subsidize yield, but it is **runway, not a fundamental**. Mistaking
  investor-subsidized growth for product-market fit is a money illusion you run on
  yourself. If used at all, book it as temporary fuel — disclosed in the model,
  never counted as a closed loop.
- **The only fundamentals that count are protocol fees + Morpho/on-chain yield.**
  Run the dollar-trace on the *whole company*: if the product is sustainable when
  the only inflows are fees and on-chain yield, you are building. If it needs a
  token sale or a raise to survive the next quarter, you are pre-product — and no
  behavioral tuning fixes that.
- **Sequencing is the integrity test.** A token *after* a consolidated product
  with real demand shares ownership of a working machine (positive-sum). A token
  *before* it sells a story (extractive). Same instrument, opposite ethics; the
  difference is whether the fundamentals already exist. **Earn the token, don't
  need it.**

**Operational rule for this skill:** when auditing any growth/retention loop,
treat a (hypothetical) token and any VC subsidy as **non-fundamental** cash flows
— they fail the dollar-trace by definition. A loop that only closes *with* a token
or VC money is a Ponzi/runway loop in a flywheel costume. Before ever recommending
a token mechanic, check the two gates explicitly — **real community demand** and
**product consolidated** — and if either is missing, the recommendation is "don't;
keep earning from fees + Morpho until both are true."

---

## Unit-economics map (the part you came for)

Every behavioral engine moves a number. This is the translation layer — wire the
psychology to the P&L, then tune the number, not the vibe.

| Behavioral mechanism (canon) | Moves | Tuning move |
|---|---|---|
| Narrative virality / social proof (Shiller; Cialdini) | **k-factor** = invites × conversion; **CAC** | make the *product event* screenshot-worthy so the story spreads itself; instrument R₀ (see below) |
| Endowed progress + goal gradient (Nunes & Drèze; Hull) | **activation, D1/D7 retention** | start streaks/quests pre-advanced ("2/10 done"); accelerate reward density near the goal |
| Loss aversion / streaks (Kahneman & Tversky) | **retention, churn ↓** | frame as "don't lose your 14-day streak / your tier"; but make the thing-at-risk *real*, not a fabricated penalty (else it's a phish) |
| Variable reward (Skinner; Eyal *Hooked*) | **DAU/MAU, session freq** | randomize *delight*, never randomize *money owed*; gacha on cosmetics, never on yield |
| Anchoring + framing (Tversky & Kahneman) | **conversion, ARPU** | show annual vs monthly savings; anchor the win-back discount against full price (our 20% Ghost coupon is an anchor play) |
| Default / status-quo bias (Thaler & Sunstein) | **attach rate, NRR** | default the *aligned* choice (auto-compound, private routing); never default a *paid* opt-in (that's the phish line) |
| Mental accounting (Thaler) | **deposit size, ARPU** | let users earmark ("yield wallet" vs "spend wallet"); reduces withdrawal friction-of-conscience |
| Fairness / confidence (Akerlof & Shiller) | **churn, NRR, LTV** | publish the take rate; symmetric clawbacks; transparent peg — fairness is the cheapest retention you can buy |
| Reciprocity (Cialdini) | **referral conversion** | give value *before* asking (a real airdrop to active users converts better than a points IOU) |
| Money illusion (Shiller) | **real vs reported margin** | denominate user-facing APY/PnL in **USD**, not a falling token; price your own margin in real terms too |

**The five numbers this skill is ultimately tuning:**

- **CAC** (cost to acquire) — narrative and virality drive it *down*; paid-only
  growth and a tired story drive it *up*.
- **LTV** = ARPU × gross-margin × lifetime, where lifetime ≈ 1 / churn.
  Feedback loops and animal spirits (trust) extend lifetime; phishing shortens it.
- **LTV : CAC** — the verdict ratio. Below ~3:1 the loop is leaking; a phishing
  design inflates the numerator short-term then collapses it.
- **Payback period** = CAC / (ARPU × gross-margin). Token incentives that aren't
  expensed honestly hide a payback period that never arrives.
- **k-factor** (viral coefficient) = invites/user × invite→activation rate.
  k>1 is epidemic growth; this is where Narrative Economics earns its keep.

> **Honesty rule:** count token/points emissions as a real cost at the price you
> actually pay (or will pay) to redeem them. A unit-economics model that treats
> emissions as free is itself a money illusion — you are phishing *yourself*.

---

## Narrative Economics → model the contagion

Shiller's operational gift: treat an adoption story like an epidemic
(Kermack–McKendrick SIR). You don't need a simulation — you need the four
parameters and the shape they imply.

- **R₀ (basic reproduction number)** ≈ your **k-factor**. R₀>1 → the story
  spreads on its own; R₀<1 → it dies without paid fuel. Estimate it: average
  invites/shares per active user × the conversion rate of those.
- **Infection rate** — how fast a susceptible user catches the story (time-to-
  activation; onboarding friction is a *contagion suppressant*).
- **Recovery/removal rate** — how fast users go cold (churn). In SIR, recovered
  users are *immune* — a churned-with-a-bad-taste user is inoculated against the
  next campaign. Phishing raises permanent immunity; fairness keeps people
  re-susceptible.
- **Recurrence** — narratives mutate and return (Bitcoin's narrative has peaked
  and returned for 15 years). Design the story so it can *re-infect* (new
  chapters: new chains, new assets, seasons) instead of one-shot hype.

The practical output: name the narrative in one sentence, estimate R₀, identify
what raises infection (lower friction, better story) and what lowers removal
(real value, fairness), and decide whether to **fund the narrative** (R₀>1, loop
closed by fundamentals) or **fix the leak first** (R₀<1 or Ponzi loop).

---

## Workflow

When given a product, feature, token, loop, funnel, or metric:

1. **Name the surfaces.** List every place the system touches a user decision:
   pricing, rewards, emissions, points, tiers, streaks, quests, referrals,
   leaderboards, defaults, timers, disclosures. If given code/a repo, read the
   incentive-bearing parts (fee logic, reward/emission math, tier logic, the UI
   that *frames* the choice). The feature name is often a confession — parse it.
2. **Type each surface** into one or more of the five engines, using the
   signature column. Note where you're unsure.
3. **Name the narrative** in one sentence and estimate **R₀** (≈ k-factor).
4. **Trace the dollar** through every feedback loop (Ponzi test). Where does
   reward value actually come from? Mark each loop virtuous / Ponzi / unknown.
5. **Audit the animal spirits.** Which does the design *rely on* (confidence,
   fairness, money illusion)? What single event would break each?
6. **Run the phishing self-audit** (private test) on every surface. Where does
   the design profit from a user *not* understanding? Be specific and honest —
   this is about *your* product, not competitors. Where you find a phish, the
   mandate is **recognize → reject → replace** with a positive-sum mechanic (see
   *The house rule*) — never "tune it for more ARPU."
7. **Map to unit economics.** For each engine, write the number it moves and the
   current direction. Build the LTV:CAC sketch with **emissions counted as
   cost**.
8. **Tune.** Prescribe the moves from the patterns below, in priority order,
   each tied to a specific surface and the number it should move.

---

## Recomposition / tuning patterns

In rough priority order.

- **Close the loop with a real cash flow (de-Ponzify).** If rewards are paid in
  unbacked emissions, route a real revenue share (fees, spread, lending APY,
  USYC float) into the reward so the dollar-trace terminates in cash, not in the
  next deposit. A loop closed by fundamentals can run forever; an open one is
  borrowed time. (This is the whole point of routing the *yield* into the
  rewards rather than printing a token.)
- **Convert positional rewards into kept value (anti-churn anchor).** Pure
  status/leaderboard rewards are mercenary — they leave when a shinier number
  appears (the Girardian failure; see `/cyber-kantics`). Anchor *retention* to
  something the user keeps regardless of rank: vested rebates, real fee discounts
  they've earned, durable tenure. Use the narrative/status pull for
  *acquisition*, kept-value for *retention*.
- **Price honestly; let disclosure be the moat.** Move every fee above the fold.
  In a phishing equilibrium, the competitor who hides fees wins short-term ARPU
  and loses LTV; the one who discloses builds the trust that compounds NRR.
  Fairness is a *cheaper* retention mechanism than any incentive.
- **Denominate in USD, kill money illusion.** Show APY, PnL, rewards, and *your
  own margins* in real (USD) terms. A token-denominated 200% APY on a token down
  80% is a lie you'll start believing too.
- **Harness loss aversion only on real stakes.** Streaks and tier-decay are the
  strongest retention tools in the canon — but only ethical when the thing at
  risk is real and the user chose it. A fabricated "you'll lose X" is a phish and
  inoculates the user on discovery.
- **Make the product event the share event (lower CAC).** The cheapest k-factor
  comes from a moment worth screenshotting that *is* the product working (a clean
  fill, a mint, a Floor win), not a bolted-on "refer for points" IOU.
- **Design the narrative to recur.** Seasons, chapters, new assets/chains — so
  the epidemic re-infects instead of decaying to zero. One-shot hype has R₀ that
  goes to zero by design.

---

## Output structure

Default to this unless the user wants otherwise. Lead with the engine table and
the shill/build verdict; keep prose tight.

```
## Engine inventory
[table: surface → engine → unit-econ number → note]

## Narrative & contagion
- The narrative (one sentence) · estimated R₀ (≈ k-factor) · infection / removal drivers

## Shilling or building?
- Dollar-trace (Ponzi test): where reward value actually comes from
- Phishing self-audit (private test): where the design profits from confusion
- Verdict: BUILDING / SHILLING / MIXED — with the one fact that decides it

## Animal-spirits risk
- Confidence / fairness / money-illusion the design relies on, and the breaking event

## Unit economics
- Engine → number → direction; LTV:CAC sketch with emissions counted as cost

## Tuning (priority order)
[ordered, concrete moves mapped to surfaces and the number each should move]
```

---

## Worked example — Ghost Mode subscription + 20% win-back (a real BUFI surface)

**Input:** the Ghost Mode privacy subscription ($12/mo Personal, Starter+ unlock),
its "Check prices" plan dialog, and the **20% win-back coupon** emailed 20h after
a user views pricing without subscribing.

### Engine inventory

| Surface | Engine | Unit-econ number | Note |
|---|---|---|---|
| "Private trading / ghost mode" pitch | Narrative | CAC, k-factor | privacy-as-status story; spreads if the *product* feels exclusive |
| Monthly vs. annual toggle w/ savings | Anchoring/framing | conversion, ARPU | annual price anchored against 12× monthly is textbook framing |
| 20% win-back coupon, 7-day expiry | Loss aversion + anchoring + scarcity | conversion, CAC | the expiry is real → information, not a phish; the anchor is the full price |
| $12 Personal as the entry tier | Mental accounting | attach rate | small, earmark-able "privacy" line item; low friction-of-conscience |
| Subscription = recurring | Feedback loop (mild) | LTV, NRR | recurring revenue compounds LTV; not a Ponzi — paid by the user, for a service |

### Narrative & contagion

- **Narrative:** "trade privately — your positions are nobody's business." R₀ is
  currently **low** (privacy is a benefit you tell people about, not one they see
  others using). Lever: make a *visible* artifact of privacy (a ghost badge, a
  shielded-PnL share card) so the benefit becomes social and R₀ rises.

### Shilling or building?

- **Dollar-trace:** reward/value = an actual recurring service (private routing,
  KYC'd entitlement). The dollar comes from the **user paying for a service**, not
  from the next subscriber. **Not a Ponzi.** ✅
- **Phishing self-audit (private test):** the 20% coupon survives full
  disclosure — it's a real discount on a real price with a real expiry. The
  monthly/annual anchor survives disclosure (the savings are genuine). **No
  phish** *provided* the win-back doesn't manufacture false urgency and the
  expiry is honored. One watch-item: the coupon code is single-use and CSPRNG —
  good; don't add a fake "only 3 left" counter (that would cross into phishing).
- **Verdict: BUILDING.** A priced service with honest framing. The deciding fact:
  the dollar terminates in a service, not in the next buyer.

### Animal-spirits risk

- **Fairness/confidence:** the entire product is "trust us with your privacy."
  A single confidence breach (a leak, a deanonymization) is a non-linear churn
  event — fairness here *is* the LTV. Over-invest in the privacy guarantee and
  its disclosure.

### Unit economics

- ARPU ≈ $12/mo Personal. Win-back coupon is a **CAC instrument**: 20% off month
  one = ~$2.40 CAC per converted lead — cheap if LTV is months of $12. Count it
  as CAC, not as lost revenue.
- LTV gate is **churn**: at $12/mo, 5% monthly churn → 20-month lifetime → ~$240
  gross LTV (pre-margin). LTV:CAC is healthy *if* the privacy promise holds
  (animal-spirits risk is the real LTV risk, not CAC).

### Tuning (priority order)

1. **Raise R₀:** ship a shareable, *visible* privacy artifact so the narrative
   spreads peer-to-peer instead of via paid email only.
2. **Protect the fairness asset:** make the privacy guarantee and its limits
   legible in-product; one breach is a bank-run on trust, not a normal churn tick.
3. **Keep the win-back honest:** real expiry, real discount, no fabricated
   scarcity — it's currently on the right side of the phishing line; keep it there.
4. **Anchor annual harder:** the monthly→annual frame is your highest-ROI ARPU
   lever; surface the savings number prominently.

---

## Worked example — unified rewards "Rain" points, USYC-backed float (real BUFI)

**Input:** the unified rewards ledger that folds three reward currencies into one
points balance keyed on the user's wallet, with a **USYC-backed float that
self-funds at ~1.19×** on interchange + breakage.

- **Engine inventory.** *Points* → feedback loop (earn→spend→earn) + narrative
  ("one rewards balance"). *USYC float* → the cash flow that *closes the loop*.
  *Breakage* → money-illusion-adjacent (unredeemed points are a liability you
  profit from; honest only if redemption is genuinely possible).
- **Dollar-trace.** Reward value is funded by **interchange + breakage + T-bill
  yield on the float**, *not* by new users' deposits. **This is the virtuous
  case** — the loop terminates in real cash flow. The 1.19× self-funding ratio is
  the literal proof the loop is closed. ✅ **BUILDING**, not shilling — the rare
  rewards program that isn't borrowing from the next cohort.
- **Phishing self-audit.** The one place to stay honest is **breakage**:
  profiting from points users *can't realistically redeem* is a phish; profiting
  from points users *chose not to* redeem is fine. Keep redemption genuinely
  easy, denominate point value in USD, and breakage stays on the ethical side.
- **Money-illusion check.** Show point value in **USD**. A "10,000 points!"
  balance that's worth $4 is a nominal number that will train users to distrust
  you when they discover the real value.
- **Unit economics.** Because the float self-funds >1×, rewards are a *negative-
  cost* CAC/retention instrument (it pays for itself) — the strongest possible
  position. Tune for *redemption-driven retention*, not for maximizing breakage;
  the durable LTV is in people who redeem and come back.
- **Tuning.** (1) Denominate points in USD everywhere. (2) Make redemption
  one-tap to protect the fairness asset and keep breakage ethical. (3) Market the
  "backed by real yield, not emissions" story explicitly — it's a *true*
  narrative and a moat in a market full of Ponzi points.

---

## Worked example — the USYC "donation" (compliance-clean, regime-aware yield)

**Input:** USYC (tokenized US T-bill money-market fund, Reg-S → institutions
only) held by the **BUFI LLC**, with the institutional yield "donated" into the
protocol's retail reward pool — *without* retail ever holding the Reg-S
instrument.

### Why it's building, not shilling

- **Dollar-trace.** The donated value terminates in **US Treasury yield** — the
  risk-free rate itself. There is no harder fundamental on earth: the loop is
  closed by the Fed, not by the next depositor. ✅ **BUILDING.**
- **The compliance-clean structure is the whole trick.** USYC is Reg-S; retail
  can't touch it (the on-chain invariant `retailAssets ∩ USYC = ∅`). Embedding it
  via the **company LLC** (KYB'd, owns 100% of the shares) unlocks the
  institutional benefits — **M0 / base money-market (T-bill) yield, on-chain
  composability, and near-instant redemption** — and the LLC **donates the carry**
  into the retail pool as plain USDC. Retail receives the *upside* of an asset it
  is legally barred from holding. Positive-sum *and* compliant: nobody is phished,
  nobody is exposed to a Reg-S instrument, and the yield is real.
- **Animal spirits.** The narrative — "we pass the Fed's rate through to you" — is
  *true*, which is why it retains. Fairness and confidence, not hype.

### Regime awareness — same machine, two yield sources

The USYC donation is **a powerful tool in a HIGH-interest-rate world**: when
T-bills pay 4–5%, the donated carry is large and nearly free to source. But the
risk-free rate is **exogenous — not yours to keep.** When rates fall toward zero
the donation shrinks to nothing, and any mechanism that *depended* on it quietly
turns into a shill (a "yield" narrative with no yield behind it). So the
positive-sum design must **flip its source with the regime** — exactly what the
Yield Machine already does (every dollar is *either* earning spread *or* earning
yield):

| Regime | The world pays you to… | The "donation" becomes |
|---|---|---|
| **High rates** | *hold cash* → USYC / T-bill carry | donate the **risk-free carry** ("we pass the Fed's rate to you") |
| **Low rates** | take *risk + velocity* → AMM spread, perp funding/fees, lending spread | donate **real fee/spread revenue** — a maker rebate / fee-share / LP distribution |

**Low-rate worked mechanism.** When the risk-free rate is ≈0, replace "donate the
T-bill carry" with **"donate the spread you actually earn."** Concretely: route a
fixed share of *realized* protocol revenue — the 30bps FX-swap spread, perp
funding and trading fees, the Morpho lending spread — into the same retail reward
pool the USYC carry used to fund (this is what **TurboFeeVault** is for: 40% of
perp+swap fees distributed back to LPs/users). The dollar-trace still terminates
in a real cash flow (fees paid by takers and borrowers), so it stays *building*;
only the **source** rotated from carry to flow. The narrative rotates with it:
from "we pass through the Fed's rate" (high rates) to "we pay you out of every
swap and trade" (low rates). And note *why* this works as a hedge — low rates
usually mean cheap money and **high speculative velocity**, so fee/spread revenue
tends to *rise* exactly when carry collapses. The two sources are naturally
counter-cyclical.

**The trap to refuse.** The low-rate gap is the precise moment a sustainable
product is tempted to paper over a vanished yield with **token emissions** — print
a "reward token" to keep the APY number up. That is the canonical shill, and *The
token rule* forbids it: when carry dries up, rotate to real fee revenue, do not
manufacture a token. A "yield" funded by emissions is the next buyer's deposit
wearing the Fed's costume.

**One-line diagnosis:** the USYC donation is a fundamentals-backed,
compliance-clean, positive-sum yield pass-through that is *rate-regime-dependent*
— the durable design keeps a non-token revenue source for **both** regimes
(risk-free carry when rates are high, real fee/spread revenue when they're low),
so the donation is always backed by something real, never by the next buyer.

---

## Heuristics

- The feature/branch name is the fastest read on the intended narrative. Parse it
  before the code.
- "APY", "emissions", "flywheel", "TVL", "points" → suspect a feedback loop;
  **trace the dollar** before believing it's virtuous.
- "Limited", "ends in", "only N left", "exclusive", "FOMO" → suspect phishing or
  scarcity; apply the private test — is the limit *real*?
- "Refer", "invite", "share to earn" → narrative/k-factor surface; ask whether the
  *product event* is shareable or only a bolted-on IOU.
- "Streak", "don't lose", "tier decay" → loss aversion; powerful and ethical
  *only* if the stake is real and chosen.
- A reward program whose payouts you can't trace to an external cash flow is a
  Ponzi loop until proven otherwise — but proven-virtuous loops exist (Rain), so
  prove, don't assume.
- A behavioral claim with no unit-economics number attached is incomplete. Always
  name the metric.
- **Calibration check before crying Ponzi/phish:** confirm the dollar actually
  comes from the next participant (Ponzi) or the design actually needs confusion
  to work (phish). If neither, the honest finding is "this is a sound,
  fundamentals-backed loop — fund it harder." That is a real result, not a
  failure to dig.
- Count emissions as cost. Always. The most common self-phish in DeFi is a
  unit-economics model that treats printed tokens as free.
- "Should we launch a token?" → apply *The token rule*: fees + Morpho/on-chain
  yield are the only fundamentals that count; a token before a consolidated
  product with real demand is the canonical shill. Treat any token or VC subsidy
  as non-fundamental in the dollar-trace. **Earn the token, don't need it.**
- "Where does the yield come from?" → name the **rate regime**. High rates →
  risk-free carry is viable (e.g. the USYC donation: an LLC holds the Reg-S T-bill
  instrument and donates the carry, compliance-clean). Low rates → carry vanishes,
  so rotate the source to real fee/spread revenue (TurboFeeVault), never to token
  emissions. A yield mechanism that only works in one regime is half-built — and
  the half that's missing is where it starts to shill.

---

## What this skill is NOT

- **Not** financial, investment, or legal advice. It's a design lens for *your
  own* product's behavioral mechanics and unit economics.
- **Not** a license to manipulate — the opposite. The *house rule* is that we
  never phish our own users; when the self-audit finds extraction the mandate is
  recognize → reject → replace with a positive-sum game, never optimize the dark
  pattern. Fairness compounds; extraction inoculates. A skill that taught
  manipulation would betray the book it's named for.
- **Not** a substitute for measurement. Estimate R₀, LTV, CAC, churn — then go
  instrument them. The lens tells you which number to watch; the data tells you
  the truth.
- **Not** `/cyber-kantics`. That skill types the *logic* of a mechanism
  (Humean/Girardian/…); this one types the *psychology + the P&L*. Run them
  together: cyber-kantics tells you a VIP tier is Girardian; schiller-behavioral
  tells you that means mercenary churn and prices the fix. They compose.
- **Not** `/gateman-analysis`. That audits the *code* for correctness before
  ship; this audits the *incentive* for sustainability and honesty. Gateman asks
  "is it correct?"; Schiller asks "is it building or shilling?"

---

## Lineage and attribution

The spine is **Robert J. Shiller** (Sterling Professor of Economics, Yale; Nobel
Memorial Prize in Economic Sciences, 2013; creator of the CAPE ratio and
co-creator of the Case–Shiller index). The five engines draw on:

- *Narrative Economics: How Stories Go Viral and Drive Major Economic Events*
  (2019) and the 2017 AEA presidential address — the SIR/contagion model of
  narratives.
- *Irrational Exuberance* (2000; 2005; 2015) — feedback-loop bubble theory and
  the "naturally occurring Ponzi process."
- *Animal Spirits* (2009) and *Phishing for Phools* (2015), both with **George
  A. Akerlof** — animal spirits and the phishing equilibrium.

The **gamification and unit-economics mechanics** honestly draw on the broader
behavioral canon, attributed where used: Daniel **Kahneman** & Amos **Tversky**
(prospect theory, loss aversion, anchoring); Richard **Thaler** (mental
accounting, nudge, defaults, endowment); Robert **Cialdini** (reciprocity, social
proof, scarcity, commitment); Nir **Eyal** (*Hooked*: trigger→action→variable
reward→investment); Nunes & **Drèze** (endowed progress); Leon **Festinger**
(social comparison). Shiller is the macro-narrative-and-feedback frame; these
supply the micro-mechanisms it tunes.

Use the framework as a generative lens, not a fixed taxonomy. And remember the
pun is a warning: the line between Shiller and *shill* is exactly one closed
feedback loop and one honest disclosure. Build on the right side of it.

> **Remember.** Name the narrative. Trace the dollar. Audit the phish — then
> recognize, reject, and replace it with a positive-sum game. Price the
> psychology. We never phish; we build. Earn the token, don't need it — fees +
> Morpho yield are the only fundamentals that count. **Are you shilling, or
> building?**
