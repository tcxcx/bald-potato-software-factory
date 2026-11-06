# schiller-behavioral

A Claude skill — a **behavioral-economics + crypto-gamification lens for DeFi**.
It decomposes a product, token, reward loop, fee/VIP/referral mechanic, quest, or
growth funnel into **five Shiller engines** — narrative, feedback loop, animal
spirits, phishing-for-phools, and money illusion — then maps each to a hard
**unit-economics** number (CAC, LTV, payback, churn, k-factor, NRR, contribution
margin) and tunes it.

The name is a pun, and the pun is the thesis. Robert **Shiller** is the Yale
economist (Nobel 2013) who showed markets run on contagious stories and animal
spirits; to **shill** is to pump a story with nothing under it. The skill exists
to tell the two apart in your *own* product:

> **Are we SHILLING or BUILDING?** — is growth a contagious story backed by real
> cash flow, or a naturally-occurring Ponzi feedback loop that extracts from your
> own users?

## What's inside

- **The five engines** — a diagnostic table (concept → DeFi signature →
  unit-econ lever → failure mode).
- **The core move** — strip the narrative and the feedback loop; trace the
  dollar; run the private (phishing) test.
- **The house rule** — *we never phish.* When the self-audit finds extraction:
  recognize → reject → replace with a **positive-sum game**. Grounded in Akerlof
  & Shiller's *Phishing for Phools*.
- **The token rule** — *earn the token, don't need it.* Sustainability from
  protocol fees + on-chain yield; a token only later, if real demand exists and
  the product is consolidated.
- **Unit-economics map**, **narrative contagion (SIR / R₀)**, a **workflow**,
  **recomposition patterns**, an **output template**, **worked examples**, and
  **heuristics**.

## Install

Drop the folder into your Claude skills directory:

```bash
git clone https://github.com/tcxcx/schiller-behavioral.git \
  ~/.claude/skills/schiller-behavioral
```

Then invoke it: `/schiller-behavioral <feature | token | loop | funnel | metric>`

## Lineage

Built on the work of **Robert J. Shiller** (Yale; Nobel 2013) — *Narrative
Economics*, *Irrational Exuberance*, *Animal Spirits* and *Phishing for Phools*
(both with George Akerlof) — with the gamification micro-mechanics attributed to
the broader behavioral canon (Kahneman & Tversky, Thaler, Cialdini, Eyal). A
companion to [`cyber-kantics`](https://github.com/tcxcx/cyber-kantics).

## License

MIT — see [`LICENSE`](./LICENSE). Dedication in [`NOTICE`](./NOTICE).
