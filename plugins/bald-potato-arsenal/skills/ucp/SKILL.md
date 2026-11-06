---
name: ucp
description: >-
  Expert-level implementation assistant for the Universal Commerce Protocol
  (UCP). Provides comprehensive tooling for adding UCP support to Next.js
  ecommerce codebases — from initial consultation through full implementation,
  testing, and validation.
arguments:
  Optional sub-command: init | consult | plan | gaps | scaffold | validate | profile | test | docs
user_invocable: true
---

# UCP Skill — Universal Commerce Protocol Implementation

## Core Principles

1. **Edge runtime is NOT USED** — Only Node.js (default) or Bun (opt-in) runtimes
2. **Interactive error handling** — When ambiguous, ask the user how to proceed
3. **Config-driven** — All decisions persist in `ucp.config.json`
4. **Spec-grounded** — All implementations reference the canonical UCP specification
5. **Next.js conventions** — Follow App Router patterns for code organization
6. **Deep analysis** — Use AST parsing and data flow tracing for gap detection

---

## Spec Repository Handling

### Location Priority
Check in this order:
1. `./ucp/` — User's local copy (use as-is)
2. `./.ucp-spec/` — Previously cloned spec (update it)
3. Neither exists — Clone fresh

### Clone Procedure
When cloning is needed:
```bash
git clone --depth 1 https://github.com/Universal-Commerce-Protocol/ucp.git .ucp-spec
```

If HTTPS fails, try SSH:
```bash
git clone --depth 1 git@github.com:Universal-Commerce-Protocol/ucp.git .ucp-spec
```

### Update Procedure
When `./.ucp-spec/` exists:
```bash
cd .ucp-spec && git pull && cd ..
```

### Gitignore Management
After cloning, ensure `.ucp-spec/` is in `.gitignore`:
- Read `.gitignore` if it exists
- Check if `.ucp-spec/` or `.ucp-spec` is already listed
- If not, append `.ucp-spec/` on a new line

### Spec File Locations (read on demand)
```
docs/specification/overview.md
docs/specification/checkout.md
docs/specification/checkout-rest.md
docs/specification/checkout-mcp.md
docs/specification/checkout-a2a.md
docs/specification/embedded-checkout.md
docs/specification/order.md
docs/specification/fulfillment.md
docs/specification/discount.md
docs/specification/buyer-consent.md
docs/specification/identity-linking.md
docs/specification/ap2-mandates.md
docs/specification/payment-handler-guide.md
docs/specification/tokenization-guide.md
spec/services/shopping/rest.openapi.json
spec/services/shopping/mcp.openrpc.json
spec/services/shopping/embedded.openrpc.json
spec/handlers/tokenization/openapi.json
spec/schemas/shopping/*
spec/discovery/profile_schema.json
```

---

## Configuration File

### Location
`./ucp.config.json` at project root

### Schema
```json
{
  "$schema": "./ucp.config.schema.json",
  "ucp_version": "2026-01-11",
  "roles": ["business"],
  "runtime": "nodejs",
  "capabilities": {
    "core": ["dev.ucp.shopping.checkout"],
    "extensions": []
  },
  "transports": ["rest"],
  "transport_priority": ["rest", "mcp", "a2a", "embedded"],
  "payment_handlers": [],
  "features": {
    "ap2_mandates": false,
    "identity_linking": false,
    "multi_destination_fulfillment": false
  },
  "domain": "",
  "existing_apis": {},
  "policy_urls": {
    "privacy": "",
    "terms": "",
    "refunds": "",
    "shipping": ""
  },
  "scaffold_depth": "full",
  "generated_files": [],
  "answers": {},
  "deployment": {
    "platform": "vercel",
    "region": "iad1",
    "mcp": {
      "enabled": false,
      "max_duration": 60
    }
  }
}
```

### Field Descriptions
| Field | Type | Description |
|-------|------|-------------|
| `ucp_version` | string | UCP spec version (date-based) |
| `roles` | string[] | One or more of: `business`, `platform`, `payment_provider`, `host_embedded` |
| `runtime` | string | `nodejs` (default) or `bun` |
| `capabilities.core` | string[] | Required capabilities to implement |
| `capabilities.extensions` | string[] | Optional extensions to implement |
| `transports` | string[] | Enabled transports: `rest`, `mcp`, `a2a`, `embedded` |
| `transport_priority` | string[] | Order to implement transports |
| `payment_handlers` | string[] | Payment handler IDs to support |
| `features.ap2_mandates` | boolean | Enable AP2 mandate signing |
| `features.identity_linking` | boolean | Enable OAuth identity linking |
| `features.multi_destination_fulfillment` | boolean | Enable multi-destination shipping |
| `domain` | string | Business domain for `/.well-known/ucp` |
| `existing_apis` | object | Map of existing API endpoints to analyze |
| `policy_urls` | object | URLs for privacy, terms, refunds, shipping policies |
| `scaffold_depth` | string | `types` \| `scaffolding` \| `full` |
| `generated_files` | string[] | Files created by scaffold (for tracking) |
| `answers` | object | Raw answers to qualifying questions |

---

## Sub-command: (no argument)

### Trigger
User runs `/ucp` with no sub-command

### Behavior
Display help listing all available sub-commands:

```
UCP Skill — Universal Commerce Protocol Implementation

Available commands:
  /ucp init      — Initialize UCP in this project (clone spec, create config)
  /ucp consult   — Full consultation: answer qualifying questions, build roadmap
  /ucp plan      — Generate detailed implementation plan
  /ucp gaps      — Analyze existing code against UCP requirements
  /ucp scaffold  — Generate full working UCP implementation
  /ucp validate  — Validate implementation against UCP schemas
  /ucp profile   — Generate /.well-known/ucp discovery profile
  /ucp test      — Generate unit tests for UCP handlers
  /ucp docs      — Generate internal documentation

Typical workflow:
  /ucp init → /ucp consult → /ucp plan → /ucp scaffold → /ucp profile → /ucp test → /ucp validate

Configuration: ./ucp.config.json
Spec location: ./ucp/ or ./.ucp-spec/
```

---

## Sub-command: init

### Trigger
User runs `/ucp init`

### Purpose
Bootstrap UCP in a project: clone spec, create config, ask essential questions.

### Procedure

#### Step 1: Check/Clone Spec Repository
1. Check if `./ucp/` exists
   - If yes: "Found local UCP spec at ./ucp/"
2. If not, check if `./.ucp-spec/` exists
   - If yes: Run `git pull` to update
   - If no: Clone the repo (see Spec Repository Handling)
3. After cloning, add `.ucp-spec/` to `.gitignore`

#### Step 2: Check for Existing Config
1. Check if `./ucp.config.json` exists
2. If yes, ask: "Config file exists. Overwrite, merge, or abort?"
   - Overwrite: Delete and create fresh
   - Merge: Keep existing values as defaults
   - Abort: Stop init

#### Step 3: Ask Essential Questions (4 questions)

**Q1: What role(s) are you implementing?**
- Business (merchant of record)
- Platform (consumer app or agent)
- Payment credential provider
- Host embedding checkout
- Multiple (specify)

If user selects multiple roles, WARN:
> "Implementing multiple roles is unusual. This is typically for marketplace/aggregator scenarios. Are you sure?"

**Q2: What runtime will you use?**
- Node.js (recommended, stable)
- Bun (opt-in, experimental)

NOTE: If user mentions Edge, respond:
> "Edge runtime is not supported for UCP implementations. Please choose Node.js or Bun."

**Q3: What is your business domain?**
- The domain that will host `/.well-known/ucp`
- Example: `shop.example.com`

**Q4: Which transports do you need at launch?**
- REST (recommended baseline)
- MCP (Model Context Protocol)
- A2A (Agent-to-Agent)
- Embedded (iframe checkout)

#### Step 4: Create Config File
Create `./ucp.config.json` with:
- Answers from essential questions
- Sensible defaults for other fields
- `ucp_version` set to latest from spec

#### Step 5: Output Ready Message
```
UCP initialized successfully!

Config: ./ucp.config.json
Spec:   ./.ucp-spec/ (or ./ucp/)
Role:   {role}
Domain: {domain}

Next steps:
  /ucp consult  — Complete full consultation (recommended)
  /ucp plan     — Skip to implementation planning
  /ucp gaps     — Analyze existing code first
```

---

## Sub-command: consult

### Trigger
User runs `/ucp consult`

### Purpose
Walk through all 12 qualifying questions, update config, produce implementation roadmap.

### Prerequisites
- Config file must exist (run `/ucp init` first)
- Spec must be available

### Procedure

#### Step 1: Load Existing Config
Read `./ucp.config.json` and use existing answers as defaults.

#### Step 2: Walk Through 12 Qualifying Questions

Ask each question. If already answered in config, show current value and ask to confirm or change.

**Q1: Are we implementing the business side, the platform side, or both?**
- Map to `roles` in config
- If both/multiple, warn about unusual scenario

**Q2: Which UCP version and which capabilities/extensions are in scope?**
- Read available versions from spec
- Present capability options:
  - Core: `dev.ucp.shopping.checkout` (required)
  - Extensions:
    - `dev.ucp.shopping.fulfillment`
    - `dev.ucp.shopping.discount`
    - `dev.ucp.shopping.buyer_consent`
    - `dev.ucp.shopping.ap2_mandate`
    - `dev.ucp.shopping.order`
    - `dev.ucp.common.identity_linking`

**Q3: Which payment handlers do we need?**
- Wallets (Apple Pay, Google Pay)
- PSP tokenization (Stripe, Adyen, etc.)
- Custom handler
- None yet (decide later)

**Q4: Do we need AP2 mandates and signing key infrastructure?**
- Yes → set `features.ap2_mandates: true`
- No → set `features.ap2_mandates: false`
- If yes, explain: "You'll need to provide JWS signing keys (ES256 recommended)"

**Q5: Do we need fulfillment options and multi-group/multi-destination support?**
- No fulfillment needed
- Single destination only
- Multi-destination support → set `features.multi_destination_fulfillment: true`

**Q6: Do we need discounts, buyer consent capture, or identity linking?**
- Discounts → add `dev.ucp.shopping.discount` to extensions
- Buyer consent → add `dev.ucp.shopping.buyer_consent` to extensions
- Identity linking → add `dev.ucp.common.identity_linking`, set `features.identity_linking: true`

**Q7: What are the existing checkout and order APIs we should map to UCP?**
- Ask for existing endpoint paths
- Store in `existing_apis` object
- Examples: `/api/checkout`, `/api/cart`, `/api/orders`

**Q8: What are the required policy URLs?**
- Privacy policy URL
- Terms of service URL
- Refund policy URL
- Shipping policy URL
- Store in `policy_urls` object

**Q9: What authentication model is required for checkout endpoints?**
- None (anonymous checkout)
- API key
- OAuth 2.0
- Session-based
- Store in `answers.authentication_model`

**Q10: Who will receive order webhooks and what event cadence is required?**
- Webhook URL for order events
- Event types needed: `order.created`, `order.updated`, `order.fulfilled`, `order.canceled`
- Store in `answers.webhook_config`

**Q11: Do we need to support MCP, A2A, or embedded checkout at launch?**
- Confirm/update `transports` array
- Set `transport_priority` order

**Q12: What is the business domain that will host /.well-known/ucp?**
- Confirm/update `domain` field

#### Step 3: Update Config
Write all answers to `./ucp.config.json`

#### Step 4: Generate Implementation Roadmap
Based on answers, produce a roadmap:

```
UCP Implementation Roadmap
==========================

Role: Business (merchant)
Version: 2026-01-11
Domain: shop.example.com

Capabilities to implement:
  ✓ dev.ucp.shopping.checkout (core)
  ✓ dev.ucp.shopping.fulfillment
  ✓ dev.ucp.shopping.discount
  ○ dev.ucp.shopping.order

Transports (in order):
  1. REST
  2. MCP

Payment handlers:
  - Stripe tokenization

Key implementation tasks:
  1. Create /.well-known/ucp discovery profile
  2. Implement checkout session endpoints (create, get, update, complete)
  3. Implement fulfillment options logic
  4. Implement discount code application
  5. Set up payment handler integration
  6. Implement order webhooks
  7. Add MCP transport layer

Estimated files to create/modify: ~15-20

Run /ucp plan for detailed file-by-file plan.
```

---

## Sub-command: plan

### Trigger
User runs `/ucp plan`

### Purpose
Generate detailed implementation plan with specific files and order of operations.

### Prerequisites
- Config file must exist with completed consultation
- Spec must be available

### Procedure

#### Step 1: Load Config and Spec
- Read `./ucp.config.json`
- Read relevant spec files based on capabilities/transports

#### Step 2: Analyze Existing Codebase Structure
- Detect Next.js version (App Router vs Pages Router)
- Find existing API routes
- Find existing lib/utils structure
- Find existing types/schemas
- Identify package manager (npm, yarn, pnpm, bun)

#### Step 3: Generate File Plan
For each capability/transport, list files to create/modify.

**Example output:**

```
UCP Implementation Plan
=======================

Phase 1: Core Types and Schemas
-------------------------------
CREATE  lib/ucp/types/checkout.ts
        - CheckoutSession interface
        - LineItem, Totals, Payment types
        - Status enum

CREATE  lib/ucp/types/index.ts
        - Re-export all types

CREATE  lib/ucp/schemas/checkout.ts
        - Zod schemas for validation

Phase 2: Discovery Profile
--------------------------
CREATE  app/.well-known/ucp/route.ts
        - GET handler returning profile JSON
        - Read capabilities from config

CREATE  lib/ucp/profile.ts
        - Profile generation logic

Phase 3: Checkout Endpoints (REST)
----------------------------------
CREATE  app/api/ucp/checkout/route.ts
        - POST: Create checkout session
        - Capability negotiation logic

CREATE  app/api/ucp/checkout/[id]/route.ts
        - GET: Retrieve checkout
        - PATCH: Update checkout
        - POST: Complete checkout (action=complete)

CREATE  lib/ucp/handlers/checkout.ts
        - Business logic for checkout operations
        - State machine implementation

Phase 4: Fulfillment Extension
------------------------------
CREATE  lib/ucp/handlers/fulfillment.ts
        - Fulfillment options calculation
        - Destination validation

MODIFY  lib/ucp/handlers/checkout.ts
        - Integrate fulfillment into checkout response

Phase 5: Discount Extension
---------------------------
CREATE  lib/ucp/handlers/discount.ts
        - Discount code validation
        - Applied discount calculation

MODIFY  lib/ucp/handlers/checkout.ts
        - Integrate discounts into checkout

Phase 6: Payment Integration
----------------------------
CREATE  lib/ucp/handlers/payment.ts
        - Payment handler registry
        - payment_data processing

CREATE  lib/ucp/handlers/stripe.ts
        - Stripe-specific tokenization

Phase 7: Order Webhooks
-----------------------
CREATE  lib/ucp/handlers/order.ts
        - Order event emission
        - Webhook signing (JWS)

CREATE  lib/ucp/webhooks/sender.ts
        - Webhook delivery with retries

Phase 8: MCP Transport (if enabled)
-----------------------------------
CREATE  lib/ucp/transports/mcp.ts
        - MCP tool definitions
        - JSON-RPC handlers

Dependencies to install:
------------------------
  zod          — Schema validation
  jose         — JWS signing (if AP2/webhooks enabled)

Run /ucp scaffold to generate these files.
```

#### Step 4: Save Plan to Config
Store the plan in `answers.implementation_plan` for scaffold reference.

---

## Sub-command: gaps

### Trigger
User runs `/ucp gaps`

### Purpose
Deep analysis of existing codebase against UCP requirements. Uses AST parsing and data flow tracing.

### Prerequisites
- Config file should exist (for role/capability context)
- Spec must be available

### Procedure

#### Step 1: Load Context
- Read config for declared capabilities
- Read relevant spec files

#### Step 2: Discover Existing Code
Scan for:
- API routes (`app/api/**`, `pages/api/**`)
- Checkout-related files (search for "checkout", "cart", "order")
- Payment handling code
- Webhook implementations

#### Step 3: Deep Analysis (AST-based)
For each relevant file:
- Parse AST
- Trace data flow for checkout objects
- Identify existing patterns

**Analyze against UCP requirements:**

| Requirement | Status | Finding |
|-------------|--------|---------|
| Discovery profile at /.well-known/ucp | MISSING | No route found |
| Checkout session creation | PARTIAL | Found /api/checkout but missing UCP fields |
| Status lifecycle | MISSING | No status state machine |
| Capability negotiation | MISSING | No UCP-Agent header handling |
| Payment handler support | PARTIAL | Stripe exists but not UCP-compliant |
| Response metadata (ucp object) | MISSING | Responses don't include ucp field |

#### Step 4: Generate Gap Report

```
UCP Gap Analysis Report
=======================

Existing codebase: Next.js 14 (App Router)
Target role: Business
Target capabilities: checkout, fulfillment, discount

CRITICAL GAPS (must fix)
------------------------
[GAP-001] Missing discovery profile
  - Required: /.well-known/ucp endpoint
  - Status: NOT FOUND
  - Fix: Create app/.well-known/ucp/route.ts

[GAP-002] Missing UCP response envelope
  - Required: All responses must include `ucp` object with version/capabilities
  - Found: app/api/checkout/route.ts returns raw checkout data
  - Fix: Wrap responses with UCP metadata

[GAP-003] Missing capability negotiation
  - Required: Read UCP-Agent header, compute intersection
  - Found: No header processing in checkout routes
  - Fix: Add middleware or handler logic

PARTIAL IMPLEMENTATIONS
-----------------------
[PARTIAL-001] Checkout session exists but non-compliant
  - File: app/api/checkout/route.ts
  - Missing: id, status, currency, totals.grand_total, links, payment fields
  - Has: line_items (needs schema adjustment)

[PARTIAL-002] Payment integration exists
  - File: lib/stripe.ts
  - Issue: Direct Stripe API, not UCP payment_data flow
  - Fix: Wrap with UCP payment handler abstraction

COMPLIANT AREAS
---------------
[OK] Policy URLs configured in existing checkout
[OK] HTTPS enforced
[OK] Idempotency key support in POST handlers

RECOMMENDATIONS
---------------
1. Start with /ucp scaffold to generate compliant structure
2. Migrate existing checkout logic into new handlers
3. Run /ucp validate after migration

Total: 3 critical gaps, 2 partial, 3 compliant
```

---

## Sub-command: scaffold

### Trigger
User runs `/ucp scaffold`

### Purpose
Generate full working UCP implementation based on config and plan.

### Prerequisites
- Config file must exist
- Plan should exist (run `/ucp plan` first, or scaffold will generate one)

### Procedure

#### Step 1: Confirm Scaffold Depth
Ask user:
> "What level of code generation do you want?"
> - **types**: TypeScript interfaces and Zod schemas only
> - **scaffolding**: Structure with TODO markers for business logic
> - **full**: Complete working implementation (recommended)

Store choice in `config.scaffold_depth`

#### Step 2: Check Dependencies
Identify required packages based on config:
- `zod` — Always needed
- `jose` — If AP2 mandates or webhook signing enabled
- `uuid` — For session ID generation

Ask before installing:
> "The following packages are required: zod, jose, uuid"
> "Install now? (npm install / bun add)"

If yes, run appropriate install command.

#### Step 3: Generate Code
Generate files according to plan. For each file:
1. Create parent directories if needed
2. Write file content
3. Track in `config.generated_files`

### Code Generation Templates

#### lib/ucp/types/checkout.ts
```typescript
/**
 * UCP Checkout Types
 * Generated by /ucp scaffold
 * Spec: {spec_version}
 */

export type CheckoutStatus =
  | 'incomplete'
  | 'requires_escalation'
  | 'ready_for_complete'
  | 'complete_in_progress'
  | 'completed'
  | 'canceled';

export type MessageSeverity =
  | 'recoverable'
  | 'requires_buyer_input'
  | 'requires_buyer_review';

export interface UCPMetadata {
  version: string;
  capabilities: string[];
}

export interface LineItem {
  id: string;
  name: string;
  quantity: number;
  unit_price: number;
  total_price: number;
  currency: string;
  // Extension fields added based on config
}

export interface Totals {
  subtotal: number;
  tax: number;
  shipping: number;
  discount: number;
  grand_total: number;
  currency: string;
}

export interface PaymentInfo {
  status: 'pending' | 'authorized' | 'captured' | 'failed';
  handlers: PaymentHandler[];
  amount_due: number;
  currency: string;
}

export interface PaymentHandler {
  id: string;
  type: string;
  config?: Record<string, unknown>;
}

export interface CheckoutMessage {
  code: string;
  severity: MessageSeverity;
  message: string;
  field?: string;
}

export interface CheckoutLinks {
  self: string;
  continue_url?: string;
  privacy_policy: string;
  terms_of_service: string;
  refund_policy?: string;
  shipping_policy?: string;
}

export interface CheckoutSession {
  ucp: UCPMetadata;
  id: string;
  status: CheckoutStatus;
  currency: string;
  line_items: LineItem[];
  totals: Totals;
  payment: PaymentInfo;
  links: CheckoutLinks;
  messages: CheckoutMessage[];
  expires_at: string;
  created_at: string;
  updated_at: string;
  // Extension fields populated based on negotiated capabilities
  buyer?: BuyerInfo;
  fulfillment?: FulfillmentInfo;
  discounts?: DiscountInfo;
}

export interface BuyerInfo {
  email?: string;
  phone?: string;
  name?: string;
  // consent fields if buyer_consent extension enabled
}

// Conditional types based on extensions...
```

#### lib/ucp/schemas/checkout.ts
```typescript
/**
 * UCP Checkout Zod Schemas
 * Generated by /ucp scaffold
 */

import { z } from 'zod';

export const LineItemSchema = z.object({
  id: z.string(),
  name: z.string(),
  quantity: z.number().int().positive(),
  unit_price: z.number().int(), // minor units (cents)
  total_price: z.number().int(),
  currency: z.string().length(3),
});

export const TotalsSchema = z.object({
  subtotal: z.number().int(),
  tax: z.number().int(),
  shipping: z.number().int(),
  discount: z.number().int(),
  grand_total: z.number().int(),
  currency: z.string().length(3),
});

export const CreateCheckoutRequestSchema = z.object({
  line_items: z.array(LineItemSchema).min(1),
  currency: z.string().length(3),
  buyer: z.object({
    email: z.string().email().optional(),
    phone: z.string().optional(),
  }).optional(),
  // Extension fields...
});

export const UpdateCheckoutRequestSchema = z.object({
  line_items: z.array(LineItemSchema).optional(),
  buyer: z.object({
    email: z.string().email().optional(),

---

> **Full Reference**: Read `references/FULL_SKILL.md` in this skill directory for the remaining sections of this skill.
