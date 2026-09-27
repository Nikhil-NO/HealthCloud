# HealthCloud — Interview Mastery Handbook

> **Your single, self-contained study document for explaining and defending HealthCloud in software-engineering interviews.**
>
> This is not marketing copy and not a re-spec of the project. It teaches you the *why* and the *how* behind everything you (with Claude Code's help) built, from fundamentals up to senior-level reasoning, so you can reason on your feet instead of reciting scripts. Everything is in this one file — explanations, code references, interview questions with conversational answers and follow-ups, exercises, mock interviews, and revision sheets.

---

## How to use this handbook

- **Read it in the order under "Recommended reading order" below**, not front-to-back blindly. The chapters are sequenced so each one builds on the last.
- **Every spoken answer is written the way you'd actually say it out loud** — plain, first-person, one concrete HealthCloud example. Read them aloud. Don't memorize them word-for-word; memorize the *shape* (direct answer → mechanism → example → trade-off) so you can rebuild the answer under any phrasing.
- **The "Understand this behind the answer" blocks are the real study material.** The spoken answer is what you say; the block is what you need to *know* so a follow-up doesn't knock you over.
- **Code references live outside the spoken answers**, in `path:thing` form. Use them to go read the real code — the fastest way to make an answer yours is to have actually looked at the file.
- **Do the exercises before reading their solutions** (solutions are collected near the end so you can't peek by accident).
- **The "Needs My Confirmation" chapter** collects the few personal details this handbook can't know (your own motivation, how you split work with the AI, etc.). Fill those in yourself — don't let the handbook put words in your mouth.

### A word on honesty (this matters in interviews)

This handbook is careful to distinguish six different things, and you should be too:

| Word | What it means here |
|---|---|
| **Implemented** | The code exists and does this. |
| **Tested** | There's an automated test that exercises it. |
| **Measured** | A real number was captured under a stated setup (e.g. the k6 load run). |
| **Configured** | Infrastructure/config declares it (e.g. Terraform), which is *not* the same as a running, verified deployment. |
| **Deployed / demonstrated** | It was actually stood up and observed working. |
| **Proposed** | A future improvement — say "I'd do X", never imply it's done. |

If an interviewer asks for a number you never measured, the strong answer is *"I didn't measure that — here's how I'd measure it."* That reads as senior. Inventing a percentage reads as junior and collapses under one follow-up.

---

## Recommended reading order & study priorities

**If you have one evening**, read these five chapters — they carry the project:
1. Ch. 1 — Project pitch & purpose (you'll open every interview with this)
2. Ch. 3 — Architecture & system design
3. Ch. 6 — Authorization layering (the flagship — this is what makes HealthCloud memorable)
4. Ch. 10 — The adjudication engine (the other flagship — deterministic money math)
5. Ch. 24 — Hard engineering challenges (the questions that separate deep from shallow)

**Priority tiers for deeper study:**

- **Must know cold (P0):** Chapters 1, 3, 4, 5, 6, 7, 10, 15. These are your differentiators — multi-tenancy, the layered authorization + consent, the adjudication engine, and the event-driven outbox. Expect the hardest follow-ups here.
- **Should be fluent (P1):** Chapters 8, 9, 11, 14, 16, 17, 18, 21. Core CRUD-plus-workflow, advanced claims, security/governance, frontend, backend/DB internals, testing.
- **Be able to speak to (P2):** Chapters 12, 13, 19, 20, 22. Documents, search/export/accessibility, cloud, CI/CD, observability. You configured and in most cases demonstrated these; know the shape and the honest limits.

**Full study path (recommended sequence):** 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 15 → 16 → 17 → 18 → 19 → 20 → 21 → 22 → 23 (walkthroughs tie it all together) → 24 → 25. Then drill with 26 (exercises) and 27 (mock interviews), and revise from 28 the day before.

---

## Table of contents

**Part I — The story**
- [1. Project pitch & purpose](#1-project-pitch--purpose)
- [2. Domain primer: care coordination & claims](#2-domain-primer-care-coordination--claims)

**Part II — Architecture & data**
- [3. Architecture & system design](#3-architecture--system-design)
- [4. Multi-tenancy & the data model](#4-multi-tenancy--the-data-model)

**Part III — Security (the flagship)**
- [5. Authentication & session management](#5-authentication--session-management)
- [6. Authorization layering](#6-authorization-layering)
- [7. Consent & purpose-of-use](#7-consent--purpose-of-use)
- [14. Security governance: audit, break-glass, retention](#14-security-governance-audit-break-glass-retention)

**Part IV — The business domain**
- [8. Care-coordination workflow & state machines](#8-care-coordination-workflow--state-machines)
- [9. Clinical context & claims intake](#9-clinical-context--claims-intake)
- [10. The adjudication engine](#10-the-adjudication-engine)
- [11. Advanced claims](#11-advanced-claims)
- [12. Documents & object storage](#12-documents--object-storage)
- [13. Search, reporting, export & accessibility](#13-search-reporting-export--accessibility)

**Part V — Distributed systems & platform**
- [15. Event-driven architecture: outbox, Kafka, DLQ](#15-event-driven-architecture-outbox-kafka-dlq)

**Part VI — Engineering craft**
- [16. Frontend engineering](#16-frontend-engineering)
- [17. Backend & API deep dive](#17-backend--api-deep-dive)
- [18. Database deep dive](#18-database-deep-dive)

**Part VII — Cloud, delivery & operations**
- [19. Cloud & infrastructure (AWS + Terraform)](#19-cloud--infrastructure-aws--terraform)
- [20. CI/CD & delivery](#20-cicd--delivery)
- [21. Testing strategy](#21-testing-strategy)
- [22. Observability & operations](#22-observability--operations)

**Part VIII — Synthesis & interview craft**
- [23. End-to-end cross-system walkthroughs](#23-end-to-end-cross-system-walkthroughs)
- [24. Hard engineering challenges](#24-hard-engineering-challenges)
- [25. Ownership & AI-assisted development](#25-ownership--ai-assisted-development)

**Part IX — Practice & revision**
- [26. Practical exercises](#26-practical-exercises)
- [27. Mock interviews](#27-mock-interviews)
- [28. Quick-revision material](#28-quick-revision-material)
- [29. Self-assessment rubric](#29-self-assessment-rubric)
- [30. Exercise solutions](#30-exercise-solutions)
- [31. Needs my confirmation](#31-needs-my-confirmation)
- [32. Coverage appendix](#32-coverage-appendix)

---

# 1. Project pitch & purpose

## What HealthCloud is (in one breath)

HealthCloud is a multi-tenant, production-style **healthcare care-coordination and claims platform** built on **synthetic data only**. Two fictional healthcare organizations (NorthCare and Green Valley) share one deployment; inside each, six kinds of users — patients, providers, care coordinators, claims reviewers, org admins, and auditors — coordinate patient care requests, manage consent, submit and adjudicate insurance claims, and review a tamper-evident audit trail. The whole thing runs locally on Docker and has a production-shape AWS deployment defined in Terraform, plus an always-on live demo.

The one sentence to lead with in an interview: *"It's a consent-aware care-coordination and claims platform where every protected read passes through five independent authorization layers on the backend, and where insurance claims are adjudicated by a deterministic, fully explainable rules engine."* Those two things — **layered consent-aware authorization** and **explainable adjudication** — are what make it more than a CRUD app, and they're what you want the conversation to gravitate toward.

## The problem it solves

Real healthcare software has two hard properties that ordinary business apps don't:

1. **Who is allowed to see what is genuinely complicated.** It's not "admins see everything, users see their own stuff." A provider can see a patient *only if they're actively assigned to that patient*, and even then only the *fields* the patient has consented to share for *this purpose*. Two users with the identical job title can get different results for the same patient because their *relationship* to that patient differs. That's the real domain, and most portfolio projects never touch it.

2. **Money decisions have to be defensible.** When an insurance claim is adjudicated — the plan pays some, the member owes some — you have to be able to show *exactly* which plan applied and how every dollar was computed: the allowed amount, the copay, how much of the deductible was consumed, the coinsurance, the out-of-pocket cap. "The system said so" is not acceptable. So the adjudication has to be deterministic and self-explaining.

HealthCloud is built specifically to demonstrate that I can handle both of those correctly.

## Users, roles, and organizations

- **Organizations (tenants):** two synthetic orgs, `northcare.example.org` and `greenvalley.example.org`. They share one PostgreSQL database and one running application, but no user in one org can ever see the other's data.
- **Roles (six):** `PATIENT`, `PROVIDER`, `CARE_COORDINATOR`, `CLAIMS_REVIEWER`, `ORG_ADMIN`, `AUDITOR`. Each of the two orgs is seeded with seven demo logins (the seventh is a second provider, `provider2`, so I can demonstrate the "unassigned provider" case) — 14 synthetic users total.
- **A patient** sees only their own record and their own requests/consent. **A provider** sees only patients they're actively assigned to. **A care coordinator / org admin** sees the whole tenant (they're the broad roles). **A claims reviewer** works the claims queues. **An auditor** reads the tamper-evident audit trail. Every one of those boundaries is enforced on the backend, not just hidden in the UI.

## Scope and deliberate simplifications

I was disciplined about what's real and what's a stand-in, and being upfront about that is itself a selling point:

- **Synthetic data only.** No real patient data ever. The demo passwords are intentionally published in the source (they're throwaway Cognito accounts reaching no real data) so recruiters can self-serve.
- **Healthcare-*inspired*, HIPAA-*aligned* — not HIPAA-certified.** I never claim certification. The security *patterns* are modeled on what HIPAA asks for (minimum necessary, audit trails, break-glass), but this is a portfolio system, not a covered entity.
- **The adjudication engine is a realistic but simplified model** — calendar-year = plan-year, one rendering provider per claim, no multi-procedure prior-auth bundling. I know exactly where the simplifications are, which matters more than pretending they aren't there.
- **Kafka runs locally; MSK is deliberately *not* used in the cloud deploy** because it's too expensive for a portfolio — the event-driven design is proven locally and documented as production-shape.

## Why it's more than CRUD

If someone says "isn't this just forms over a database?", here's the honest differentiation:

- **The authorization is a five-layer pipeline**, not a role check. Tenant → role → relationship → consent+purpose → field-level masking, each an independent narrowing gate, all on the backend.
- **The adjudication engine is a pure, deterministic, explainable calculator** with real financial invariants (BigDecimal money, deductible/OOP accumulators that carry across claims under a row lock).
- **It's event-driven with a transactional outbox** — I solved the dual-write problem properly rather than just calling Kafka from a service method.
- **The audit trail is a per-organization HMAC hash chain** — tamper-evident, not just an append-only log.
- **It has six real state machines** (requests, claims, prior-auth, referrals, appeals, claim-reviews) with the transition logic in pure, unit-tested policy classes.

Any one of those is a 20-minute conversation. That's the opposite of CRUD.

## The synthetic-data portfolio boundary vs a real production system

Worth being able to articulate crisply, because a sharp interviewer will ask "how is this different from real healthcare software?":

- **Data:** synthetic, seeded; a real system has real PHI with legal obligations.
- **Auth identity:** real Amazon Cognito OIDC login, but the user set is fixed and admin-provisioned; a real system integrates enterprise IdPs, enforces MFA, has real onboarding.
- **Availability:** the live demo is a single box, single AZ, no backups by design; the *production-shape* design (ECS Fargate across AZs, RDS, CloudFront) is in Terraform and was demonstrated on-demand, then torn down for cost.
- **Compliance:** aligned patterns, zero certification, no BAA, no real risk assessment.

The move in an interview is to *volunteer* these boundaries. It signals judgment.

## The pitches (rehearse these out loud)

**30 seconds (the elevator):**
> "HealthCloud is a multi-tenant healthcare platform I built — care coordination plus insurance claims, on synthetic data. The two things I'm proudest of are the authorization model, where every protected read goes through five independent backend checks including patient consent, and the claims adjudication engine, which is a deterministic calculator that can explain exactly how every dollar of a decision was computed. It's a Spring Boot modular monolith with a React front end, event-driven with Kafka, and deployed on AWS with Terraform."

**90 seconds (the recruiter / first-round):**
> "So HealthCloud is a portfolio project that looks and behaves like real healthcare software, but on synthetic data. The setup is two healthcare organizations sharing one system — multi-tenant — with six kinds of users like patients, providers, and claims reviewers.
>
> The hard part of healthcare software is that access control is genuinely complicated: a provider can only see a patient they're actively assigned to, and even then only the fields the patient consented to share. So I built authorization as a five-layer pipeline on the backend — tenant, role, relationship, consent, and field-level masking — where two users with the same job title can legitimately get different results.
>
> The other centerpiece is the claims engine. When an insurance claim comes in, it runs through a deterministic set of rules — eligibility, allowed amounts, deductible, copay, coinsurance, out-of-pocket cap — and it records exactly how every number was derived, so any decision is fully explainable.
>
> Technically it's a Spring Boot modular monolith, React and TypeScript on the front, PostgreSQL, Kafka for events using a transactional outbox, and it's containerized and deployed on AWS with Terraform. It's got about 700 automated tests, including the negative security tests that are really the proof it works."

**3–5 minutes (the engineer / hiring manager deep intro):** use the 90-second version, then continue:
> "Let me go one level deeper on the two hard parts.
>
> On authorization — the reason it's five layers and not one role check is that in healthcare, 'same role' doesn't mean 'same access.' The layers run in order and each one can only *narrow* access: first tenant isolation, so you physically can't load another org's row — a cross-tenant request just 404s, it doesn't 403, because a 403 would confirm the record exists. Then a role/permission check. Then the relationship gate — is this provider actually assigned to this patient? Then consent and purpose — did the patient grant access to this category of data for this purpose of use, defaulting to deny. And finally field-level masking, where individual fields like date of birth get blanked out on the backend if consent doesn't cover them. All of that lives behind one guard class so a new endpoint can't accidentally skip it.
>
> On adjudication — the calculator is a pure function with no Spring or database in it, so it's trivially unit-testable, and all money is BigDecimal at scale two with half-up rounding. The interesting bit is that a deductible and an out-of-pocket max have to carry *across* claims within a benefit year, so there's a per-patient-per-plan-per-year accumulator row, and the engine reads-and-updates it under a pessimistic row lock inside the same transaction as the adjudication, so two claims for the same patient can't both consume the same last hundred dollars of deductible. And it's versioned — you can re-adjudicate a claim after a plan config change, and it backs out the old version's contribution to the accumulator before recomputing.
>
> The rest of the system supports those two: care requests and claims each have real state machines, documents live behind an S3 abstraction with authorization on every read, there's a tamper-evident audit trail using a per-org HMAC hash chain, and the whole thing is event-driven through a transactional outbox so I never have the dual-write problem where the database commits but the Kafka publish is lost.
>
> I built it one verified slice at a time with Claude Code as a pair, but I made the architectural calls and I reviewed and tested everything — I can walk through any of this code without the AI."

## Tailoring by audience

- **Recruiter:** lead with the story and the scale ("multi-tenant healthcare, ~700 tests, deployed on AWS"), keep jargon light, land on "two things I'm proud of."
- **Engineer:** get to a concrete mechanism fast (the secure-404, the outbox, the accumulator lock) — they want to see you think, not pitch.
- **Hiring manager:** emphasize judgment and trade-offs (why a monolith, why no MSK in the cloud, why synthetic data, how I kept scope honest) — they're assessing decision-making, not syntax.

## Interview Q&A

**Q (basic): What is HealthCloud, in a sentence or two?**
> "It's a multi-tenant healthcare care-coordination and claims platform on synthetic data. The parts I'd point to are a five-layer consent-aware authorization model and a deterministic, explainable insurance-claims adjudication engine, built as a Spring Boot and React system that's event-driven and deployed on AWS."

**Q (basic): Who uses it and what can they do?**
> "Two synthetic healthcare organizations share the system. Inside each, there are patients who see their own record, providers who see patients they're assigned to, care coordinators and admins who see the whole org, claims reviewers who work the claims queues, and auditors who read the audit trail. Every one of those limits is enforced on the backend."

**Q (intermediate): What makes this more than a CRUD app?**
> "A few things that aren't 'forms over a table.' Authorization is a five-stage pipeline, not a role flag — including patient consent and per-field masking. Claims are adjudicated by a deterministic engine that explains its math and keeps deductible accumulators consistent across claims under a row lock. It's event-driven with a transactional outbox to avoid the dual-write problem. And the audit log is a tamper-evident HMAC hash chain. Each of those is a real engineering problem, not CRUD."

**Q (intermediate): Why synthetic data — doesn't that make it less impressive?**
> "The opposite, I'd argue. Using synthetic data let me build the *hard* parts — the consent model, the audit chain, break-glass emergency access — honestly and out in the open, including publishing the demo credentials, without any risk. The engineering is identical whether the data is real or synthetic; what changes with real data is the compliance and operational burden, and I'm careful to say it's HIPAA-*aligned*, not certified. Being explicit about that boundary is part of the point."

**Q (hard): If I said this is over-engineered for a portfolio, how would you respond?**
> "I'd partly agree, and that's deliberate — the goal was to demonstrate range, so I intentionally built things a minimal app wouldn't need, like the outbox or the HMAC chain. But I'd push back on the premise that it's *gratuitously* complex: every piece maps to a real property of the healthcare domain. The consent layering exists because 'same role, different access' is genuinely how healthcare works. The accumulator lock exists because two concurrent claims really can race on a deductible. I can also point to the places I *chose* to keep it simple — a modular monolith instead of microservices, no MSK in the cloud, calendar-year plans — so it's not complexity for its own sake."

### Remember these points
- Lead with the **two differentiators**: layered consent-aware authorization, and explainable adjudication.
- "Same role, different access" is the one-liner that captures the authorization model.
- Always volunteer the **synthetic / HIPAA-aligned-not-certified** boundary — it signals judgment.
- More-than-CRUD proof = five-layer authz, explainable engine, transactional outbox, HMAC audit chain, six state machines.
- Have the 30/90/300-second versions ready; scale to the audience.

---

# 2. Domain primer: care coordination & claims

You don't need to be a healthcare expert, but you *do* need to speak the vocabulary confidently, because half of explaining this project is explaining the domain it models. Here's the minimum that makes you sound fluent.

## The two halves of the domain

**Care coordination** is the "get the patient the care they need" side: a patient is assigned to providers, someone raises a *service request* (a referral-like ask to get something done), it moves through a workflow, people comment on it, it gets assigned and resolved. Think of it as healthcare's version of a ticketing/case-management system, but with consent and clinical context attached.

**Claims** is the "who pays for it" side: after care happens, a *claim* is submitted describing what was done (as billing codes and dollar amounts). The claim is validated, then *adjudicated* against the patient's insurance *coverage plan* — the system decides how much the plan pays and how much the patient owes.

The two halves meet at the patient and at consent: the same authorization and audit machinery guards both.

## Glossary (say these naturally)

- **Tenant / organization:** one healthcare org. The isolation boundary. Everything tenant-owned carries an `organization_id`.
- **Patient / provider / care coordinator / claims reviewer / auditor / org admin:** the six roles.
- **Assignment (care relationship):** an effective-dated link making a provider (or coordinator) responsible for a patient. This is what the "relationship" authorization layer checks.
- **Consent directive:** a patient's rule about who can see which category of their data, for which purpose. Versioned; deny-by-default.
- **Purpose of use:** *why* data is being accessed (e.g. care coordination). The backend fixes the purpose per action; the client never picks it.
- **Service request:** a care-coordination work item with a state machine (DRAFT → SUBMITTED → TRIAGED → ASSIGNED → … → APPROVED/REJECTED/CANCELLED).
- **Clinical summary:** a short, coded clinical note (points at an ICD-10 diagnosis). The free-text narrative is the one consent-masked field.
- **Medical code:** a standardized code. **ICD-10-CM** = diagnoses ("what's wrong"). **CPT/HCPCS** = procedures ("what was done"). Global reference data, not tenant-owned.
- **Claim / claim line:** a claim header owns one or more lines; each line bills one procedure code for an amount. Money is computed on the backend.
- **Coverage plan:** an insurance benefit plan (PPO/HMO/EPO/HDHP) with parameters: deductible, coinsurance rate, copay, optional out-of-pocket max.
- **Eligibility:** a patient's enrollment in a coverage plan for an effective-dated period. Non-overlapping, so "coverage on a date" is deterministic.
- **Deductible:** the amount the member pays out of pocket before the plan starts sharing cost.
- **Copay:** a flat per-service member charge.
- **Coinsurance:** the member's *percentage* share of the cost after the deductible.
- **Out-of-pocket (OOP) max:** once the member's yearly cost-sharing hits this, the plan pays 100%.
- **Allowed amount:** the price the plan recognizes for a procedure (from a fee schedule); the member/plan split is computed off *allowed*, not the raw charge. The difference is a provider write-off.
- **Adjudication:** the act of computing the plan-pays / member-owes split for a claim, line by line.
- **Prior authorization:** pre-approval a plan requires for certain procedures before it'll cover them.
- **Referral:** a request to send a patient to a specialty.
- **Appeal:** a dispute of a claim's decision.
- **Break-glass:** emergency access — a provider self-grants time-boxed access to a patient they're not assigned to, with a recorded reason. HIPAA calls this "break the glass."
- **Audit event / hash chain:** an append-only, tamper-evident record of security-relevant actions.

## A patient's journey (the happy path, end to end)

1. A **care coordinator** at NorthCare assigns provider Dana to patient Sam (creates a care relationship).
2. Sam sets a **consent directive** — say, allowing their care team to see demographic/contact data for care coordination.
3. Dana, now assigned, can **read Sam's patient record** — but a field Sam hasn't consented to (date of birth) comes back masked.
4. A **service request** is raised for Sam and moves through its workflow.
5. Later a **claim** is submitted for a procedure Dana performed. It's validated and **accepted** by a claims reviewer.
6. A reviewer **adjudicates** the claim: the engine finds Sam's coverage on the service date, applies the plan's deductible/copay/coinsurance/OOP, and records the full breakdown.
7. Every money and privacy step writes an **audit event** into the tamper-evident chain.
8. If Sam later disagrees with a decision, an **appeal** can be filed; an overturned appeal triggers a **re-adjudication** that appends a new immutable version.

If you can narrate that journey and name the authorization and audit touchpoints along the way, you've demonstrated you understand the whole system — not just isolated features.

### Remember these points
- Two halves: **care coordination** (get care) and **claims** (pay for care); they meet at the patient + consent.
- ICD-10 = diagnoses, CPT/HCPCS = procedures. Deductible → copay → coinsurance → OOP max is the cost-share order.
- **Allowed amount** (not raw charge) is what the split is computed from.
- Consent is **deny-by-default** and **purpose-scoped**; purpose is fixed by the backend.
- Be able to narrate the one patient journey end to end and point at each authz/audit touchpoint.

---

# 3. Architecture & system design

> **P0 chapter.** Expect "walk me through the architecture" as an opener, and expect the monolith-vs-microservices question. Own both.

## Concept: what "architecture" means here

The architecture is the set of big structural decisions: how the system is split into parts, which parts talk synchronously vs asynchronously, where the trust boundaries are, and where transactions begin and end. Get these right and the details fall into place; get them wrong and no amount of clean code saves you.

## The topology (say this when asked "walk me through it")

There are four moving pieces at runtime:

```
   Browser (React SPA)
        │  session cookie + CSRF header, same-origin
        ▼
   Frontend (nginx)  ── serves the SPA, reverse-proxies /api, /actuator, /oauth2 ──▶
        ▼
   Backend (Spring Boot BFF, modular monolith)
        │                         │                     │
        ▼                         ▼                     ▼
   PostgreSQL 17           Kafka (outbox relay)    Amazon Cognito (OIDC)
   (shared, multi-tenant)  + consumers/DLQ         (identity only)
```

1. **The React SPA** runs in the browser and holds *no tokens* — it authenticates purely by a session cookie. Its notion of "am I logged in" is simply "does `GET /api/v1/me` return 200."
2. **nginx (the frontend container)** serves the built SPA and reverse-proxies `/api`, `/actuator`, and `/oauth2` to the backend, so everything is same-origin and the session + CSRF cookies stay first-party. This is the production mirror of the Vite dev proxy.
3. **The Spring Boot backend** is a **modular monolith** and also the **Backend-for-Frontend (BFF)**: it holds the OAuth2 client, owns the session, and is the single security boundary. Inside it are ~30 domain packages under `com.healthcloud`.
4. **PostgreSQL** is a single shared database with tenant-keyed rows. **Kafka** carries domain events (via the outbox). **Cognito** is the identity provider — it authenticates a person but supplies *no roles*; roles come from our DB.

The single most important architectural sentence: **the backend is the only security boundary; the frontend only hides UI.**

## Module responsibilities (the modular monolith)

The backend is one deployable, but internally it's organized into ~30 domain packages, each owning a slice of the domain: `organization`, `identity`, `auth`, `context`, `patient`, `relationship`, `consent`, `request`, `clinical`, `coding`, `coverage`, `claim`, `adjudication`, `priorauth`, `referral`, `appeal`, `anomaly`, `claimreview`, `reprocessing`, `document`, `audit`, `breakglass`, `retention`, `outbox`, `notification`, `deadletter`, `common`, `error`, `observability`, `devdata`. Each package follows the same internal shape: **thin controller → service (business rules, authorization, transactions) → tenant-safe repository → entity**, plus DTOs and, where there's decision logic, a **pure policy class**.

The discipline that keeps a modular monolith from rotting into a "big ball of mud" is that packages depend on each other through **services and repositories**, not by reaching into each other's tables, and cross-cutting concerns (the tenant context, the access guard, the audit service, the outbox) are shared components everyone routes through rather than re-implements.

## Modular monolith vs microservices (the decision)

**Problem:** HealthCloud has many closely-related domains that constantly need to act together in one atomic step — adjudicating a claim writes the adjudication, a status-history row, an audit event, and an outbox event, all-or-nothing.

**Constraints:** it's a solo portfolio project; the domains are tightly coupled around the patient and around money; I need strong transactional consistency for the money and audit paths.

**Chosen approach:** a **modular monolith** — one deployable, internally modular. (This is ADR-001.)

**Why it wins here:**
- **Transactions are trivial.** That four-way atomic write is just one `@Transactional` method. Across microservices it'd be a saga with compensations — enormous accidental complexity for no benefit at this scale.
- **Refactoring is cheap.** With the domain still evolving, moving a boundary is an in-process change, not a cross-service contract renegotiation.
- **One thing to run, test, and deploy.** Testcontainers spins up the whole app against a real Postgres; there's no fleet to orchestrate.

**Alternatives and their disadvantages *here*:**
- *Microservices:* independent scaling and deploy, at the cost of distributed transactions, network failure modes, and operational overhead I don't need for a single-node portfolio system.
- *A single unstructured monolith:* simpler still, but it'd blur the domain boundaries that make the code legible — the modular structure is what lets me point at "the consent package" or "the adjudication engine."

**When I'd reconsider:** if one module had a genuinely different scaling profile or needed independent deployment cadence — a heavy analytics/search workload, or the adjudication engine needing to scale separately from the CRUD paths — I'd extract *that* module first, and the clean package boundaries mean I could. I wouldn't shard on day one.

## BFF and worker responsibilities

- **BFF (Backend-for-Frontend):** the backend is purpose-built for this one SPA. It holds the OAuth2 client and the server-side session, so the browser never touches a token — that's the whole point of the BFF pattern for a public web client (tokens in a browser are an XSS liability). The SPA talks to a small, session-authenticated REST API shaped for its screens.
- **Worker:** there's a `worker/` module in the repo layout for background processing, but in practice the async work runs *inside* the monolith today — the outbox relay is a `@Scheduled` poller in the same process, and the Kafka consumers are `@KafkaListener`s in the same app. Be honest about that: the event-driven design is real and proven, but it's not a separate deployed worker fleet. Extracting the relay/consumers into a standalone worker is a clean future step because they're already isolated packages.

## Synchronous vs asynchronous interactions

- **Synchronous (request/response):** everything the user waits on — reads, writes, adjudication. These are ordinary HTTP calls returning within the request.
- **Asynchronous (events):** things that *react* to a domain change but don't need to happen before the user gets their response — e.g. building a notification feed when a claim is adjudicated. These flow through the transactional outbox → Kafka → consumers. The rule of thumb: if the caller must see the result now, it's synchronous; if it's a downstream reaction that can be eventually consistent, it's an event.

## Data ownership and trust boundaries

- **Tenant context is derived on the backend, never trusted from the client.** The client can send whatever it wants; the org comes from the authenticated session. This is the load-bearing trust boundary.
- **Cognito is trusted for *identity only*** — it proves "this is the person with this email." Roles, tenant, and every permission are looked up in *our* database by email. So even a valid Cognito login can't escalate privileges.
- **The browser is untrusted.** Role-aware UI is a convenience; the backend re-checks every protected operation.

## Transaction boundaries and consistency

The core pattern (ADR / §31.6) is **one transaction per important state change**: the domain row + its status/history row + the audit event + the outbox event all commit together or roll back together. This gives:
- **Atomic audit:** you can never have a money decision without its audit event, or vice versa.
- **No dual-write problem:** the Kafka publish isn't in the transaction (you can't transactionally write to a DB and a broker); instead the *outbox row* is in the transaction, and a separate relay publishes it after commit. More on this in Ch. 15.

Consistency model: **strong/transactional within the monolith** (single Postgres, ACID), **eventually consistent across the event boundary** (the notification feed catches up shortly after commit).

## Coupling, maintainability, extensibility, bottlenecks

- **Coupling** is intentionally high *within* the patient-centric core (that's the domain) but managed through shared choke points (the access guard, the tenant context) so it's not tangled.
- **Extensibility** is proven empirically: the six state machines, the several advanced-claims aggregates, and the eight paged work queues were all added by *repeating the same patterns*, which is the sign the architecture generalizes.
- **The likely first bottleneck** under load is the database (single shared Postgres, single node) — specifically the hot rows: the per-org audit chain head and the per-patient benefit accumulator, both of which serialize writers by design (a pessimistic lock). That's a correctness-over-throughput trade I made deliberately, and I can talk about how I'd measure and relieve it (see Ch. 24).

## Local vs demonstrated-cloud vs proposed-scale architecture

Keep these three distinct — conflating them is a credibility trap:
- **Local architecture:** Docker Compose — Postgres + Kafka + the app; everything on one machine. This is what runs in CI and what I develop against.
- **Demonstrated cloud architecture:** the production-*shape* deploy — ECS Fargate, RDS, S3/CloudFront, Cognito, ALB — defined in Terraform, stood up on-demand, evidence captured, then torn down for cost. Plus a permanent single-box EC2 demo for the always-on link.
- **Proposed larger-scale architecture:** what I'd change for real scale/availability — multi-AZ RDS, autoscaling Fargate, a real MSK/Kafka cluster, extracting the worker, read replicas. These are *proposals*, and I label them as such.

## Interview Q&A

**Q (basic): Give me the high-level architecture.**
> "It's a React single-page app in the browser talking over a session cookie to a Spring Boot backend, which is both a modular monolith and a Backend-for-Frontend. The backend is the only security boundary. It uses PostgreSQL as a shared multi-tenant database, Kafka for domain events via a transactional outbox, and Amazon Cognito purely for identity. nginx serves the SPA and proxies the API so everything's same-origin."

**Q (intermediate): Why a modular monolith instead of microservices?**
> "HealthCloud has several closely connected areas — consent, care requests, claims — and operations that need to update business data, write history, an audit event, and an outbox event all in one atomic step. A modular monolith let me keep those areas separate in the code while running as one service, which made those transactions a single `@Transactional` method instead of a distributed saga. The trade-off is those modules can't be scaled or deployed independently. If one of them genuinely needed that — say the adjudication engine had to scale separately — the clean package boundaries mean I could extract it. But sharding on day one would have been complexity with no payoff at this scale."

**Q (intermediate): What's the BFF and why use it?**
> "The backend is a Backend-for-Frontend — it's built specifically for this one SPA, it holds the OAuth2 client, and it owns a server-side session. The reason is security: a public web client shouldn't hold OAuth tokens, because anything in the browser is exposed to XSS. So the browser only ever has an HttpOnly session cookie, and the backend does the token exchange with Cognito behind the scenes."

**Q (advanced): Where are the trust boundaries, exactly?**
> "Two that matter. First, tenant context — the organization a request acts in is derived from the authenticated session on the backend, never read from anything the client sends, so a client can't ask for another org's data by changing an ID. Second, Cognito is trusted only for identity — it tells me *who* the person is, but every role and permission is looked up in our own database by email. That means a valid login still can't grant itself a role. The browser itself is fully untrusted; the role-aware UI is just convenience and the backend re-checks everything."

**Q (advanced): What breaks first as load grows, and how do you know?**
> "The database, and specifically two hot rows I serialize on purpose: the per-organization audit hash-chain head and the per-patient benefit accumulator. Both take a pessimistic lock because correctness matters more than throughput there — I can't have two claims racing on the same deductible. Under heavy concurrent adjudication for one patient, those locks would be the contention point. How I'd know: the request latency histogram and DB connection-pool metrics are already exported to Prometheus, so I'd watch p95 on the adjudication endpoint and Hikari pool saturation, and confirm with a trace. Then I'd relieve it — but I'd measure before optimizing."

**Q (advanced): You have a `worker/` folder but say the async work runs in the monolith — reconcile that.**
> "Fair catch. The event-driven design is real — there's a transactional outbox, a relay, Kafka, idempotent consumers, retries, a dead-letter topic, and replay — but today the relay is a scheduled poller inside the monolith and the consumers are listeners in the same process, not a separately deployed worker fleet. I kept it in-process because at this scale a separate deployment buys nothing but operational overhead. Because the relay and consumers are already isolated packages, pulling them into a standalone worker is a clean change if the load ever justified it."

### Remember these points
- Four runtime pieces: SPA, nginx/BFF-frontend, Spring backend (monolith+BFF), and Postgres/Kafka/Cognito.
- **The backend is the only security boundary** — the single most important sentence.
- Monolith rationale = one atomic transaction across domains; trade-off = no independent scaling; extract-a-module is the escape hatch.
- Cognito = identity only; roles come from our DB. Tenant = derived on backend.
- One-transaction-per-change; async only for downstream reactions; DB is the first bottleneck (hot serialized rows).
- Keep local / demonstrated-cloud / proposed-scale distinct.

---

# 4. Multi-tenancy & the data model

> **P0 chapter.** The Phase-1 acceptance test was literally "a NorthCare user cannot access Green Valley data." Be able to prove it.

## Concept: multi-tenancy

Multi-tenancy means one running system serves multiple isolated customers (tenants) — here, healthcare organizations. The central question is *how* you keep tenant A from ever seeing tenant B's data. There are three common models:
1. **Shared database, shared schema, tenant key** — one DB, every tenant-owned row carries an `organization_id`, and every query filters on it. (What HealthCloud uses — ADR-002.)
2. **Database (or schema) per tenant** — physical isolation, higher operational cost.
3. **Row-Level Security (RLS)** — the database enforces the tenant filter itself via policies.

## Why HealthCloud uses shared-DB-with-a-tenant-key

**Problem:** isolate two orgs cheaply and simply while sharing one deployment.

**Chosen approach:** shared database, shared schema, an `organization_id` column on every tenant-owned table, and the discipline that **every tenant-owned query is scoped by the organization derived from the session**.

**How it's actually enforced (the mechanism that makes it true, not aspirational):**
- Tenant-owned entities hold `organizationId`. Their repositories expose **only org-scoped finders** — `findByIdAndOrganizationId`, `findByOrganizationId…` — and business code never calls a bare `findById`.
- Services get the org from `UserContextAccessor.requireOrganizationId()`, which reads the backend-derived `UserContext`. The client can't supply it.
- Because rows are loaded by `(organizationId, id)`, another tenant's row **simply isn't found** — you get a **secure 404**, not a 403. A 403 would confirm the row exists; a 404 reveals nothing. (See Ch. 6 for why that distinction matters.)
- Child tables carry `organization_id` too and FK back to the parent's composite `UNIQUE(id, organization_id)`, so tenancy is enforced *structurally* by foreign keys, not just by careful querying.

**Alternatives and trade-offs:**
- *DB-per-tenant:* stronger blast-radius isolation and per-tenant backup/restore, but you multiply operational cost and lose easy cross-tenant reference data. Overkill for two synthetic orgs; the right call for a real multi-org SaaS with compliance isolation needs — I'd name it as the upgrade path.
- *Postgres RLS:* the database enforces the filter, so a forgotten `WHERE org_id = ?` can't leak data — a strong defense-in-depth. I *didn't* use it, and I'm honest about that: my isolation is enforced in the repository layer and proven by tests, and RLS would be a good hardening addition. (This is a great "what would you add" answer.)

## The data model (shape, not every table)

The schema is **owned by Flyway** — 43 versioned migrations in `db/migration/V*.sql`, and Hibernate runs `ddl-auto: validate`, so Hibernate never generates DDL; it only checks that the entities match the migrated schema. The model is roughly 50 tables across the domains. The key structural patterns:

- **UUID primary keys** (`@GeneratedValue(strategy = UUID)`) everywhere — no guessable sequential ids, and safe to expose in URLs.
- **`@Version` columns** on mutable rows for optimistic locking.
- **Enums stored as strings** (`EnumType.STRING`) — readable in the DB, order-independent.
- **`OffsetDateTime` timestamps** set via `@PrePersist`/`@PreUpdate`.
- **Composite `UNIQUE(id, organization_id)`** on tenant-owned tables so children can FK-with-org (the structural tenancy guarantee).
- **Append-only history tables** for state machines (e.g. `request_status_history`, `claim_status_history`) and immutable records for decisions (`adjudication`, `audit_event`, `claim_anomaly_signal`).
- **Partial unique indexes** to enforce "at most one current row" invariants (e.g. one ACTIVE assignment per pair; one OPEN review per claim).

## Constraints and indexes as correctness tools

A theme worth articulating: I push invariants into the database rather than trusting application code alone.
- `claim_number` is `UNIQUE` per tenant → duplicates are impossible even under a race.
- The benefit accumulator's `UNIQUE(organization_id, patient_id, coverage_plan_id, benefit_year)` is the target of an `INSERT … ON CONFLICT DO NOTHING`, guaranteeing exactly one accumulator row before the lock.
- Partial unique index `WHERE status = 'ACTIVE'` enforces the "one current assignment" rule and backstops a concurrent double-insert.
- The dead-letter table has `UNIQUE(dlt_topic, dlt_partition, dlt_offset)` so draining is idempotent.
- The notification table has `UNIQUE(event_id)` so consuming is idempotent.

These aren't decoration — they're the last line of defense when two requests race and the application-level pre-check both pass.

## Tenant isolation across *every* surface (the part people forget)

Isolation isn't just API reads. It has to hold in:
- **APIs** — org-scoped finders (the default).
- **Workers/consumers** — a Kafka event carries its `organizationId` in a header; the consumer scopes to it. Events are PHI-free so even a misroute leaks nothing sensitive.
- **Search and exports** — the CSV export *reuses the same masked, tenant-scoped read* as the JSON API, so an export can't become a back door around masking or tenancy.
- **The audit trail** — the hash chain is *per organization* (a per-org key and a per-org sequence), so tenants can't even be correlated through the audit log.

## Verification (how I *prove* isolation)

There are dedicated tests — `TenantIsolationIntegrationTest` (full HTTP/session flow) and `TenantIsolationRepositoryTest` (repository layer) — and the rule is that **every new tenant-owned resource gets a cross-tenant test proving another tenant's id returns a secure 404.** That test suite *is* the acceptance criterion from Phase 1, kept alive as the system grew.

## Interview Q&A

**Q (basic): How does multi-tenancy work in HealthCloud?**
> "It's a shared database with a tenant key. Every tenant-owned row has an `organization_id`, and every query is scoped by the organization I derive from the authenticated session — never from anything the client sends. So when a NorthCare user asks for a Green Valley record by id, the row just isn't found under their org and they get a 404. I also FK child tables to a composite unique key on `(id, organization_id)`, so tenancy is enforced by foreign keys structurally, not only by careful querying."

**Q (intermediate): Why a secure 404 instead of a 403 for cross-tenant access?**
> "Because a 403 says 'this exists but you can't have it,' which leaks the existence of the record. In healthcare even *knowing a patient exists* at another org is a disclosure. So a cross-tenant or otherwise unauthorized object access returns the same 404 as a nonexistent record — the caller can't tell the difference, so nothing leaks."

**Q (intermediate): Why shared-DB tenancy and not a database per tenant?**
> "For this system, simplicity and cost. Two synthetic orgs sharing one Postgres is trivial to run, test, and reason about, and shared reference data like the medical-code catalog is naturally global. Database-per-tenant gives you stronger blast-radius isolation and per-tenant backups, which I'd want for a real multi-org product with compliance isolation requirements — I'd call that the upgrade path — but it multiplies operational cost for no benefit here."

**Q (advanced): A developer adds a new endpoint and forgets to scope by org. What stops the leak?**
> "Several things, layered. The repositories for tenant-owned entities don't *expose* a bare `findById` — the finders all take an organization id — so the forgetful path doesn't compile as easily. Anything patient-scoped has to go through the shared access guard, which loads by `(org, id)`. And there are cross-tenant isolation tests that every new tenant-owned resource is supposed to extend. The honest gap is that this is discipline plus tests, not database-enforced — Postgres Row-Level Security would make the tenant filter impossible to forget, and that's the hardening I'd add if this were handling real data."

**Q (advanced): How do you keep isolation in the async and export paths, not just the API?**
> "The Kafka events carry the `organizationId` in a header and are deliberately PHI-free, so a consumer scopes to that org and even a misrouted event leaks nothing sensitive. The CSV export is the interesting one — instead of writing a second query, it calls the exact same tenant-scoped, consent-masked service read the JSON API uses, so a masked date-of-birth exports as a blank cell and the export can't become a back door around tenancy or masking. And the audit trail is chained per-organization, so you can't even correlate tenants through it."

### Remember these points
- Shared DB + `organization_id` tenant key; every query scoped by the **session-derived** org.
- Cross-tenant / unauthorized object → **secure 404**, never 403 (don't leak existence).
- Structural enforcement: composite `UNIQUE(id, organization_id)` + child FK-with-org; not just careful `WHERE`s.
- Invariants pushed into the DB: unique claim number, accumulator upsert target, partial-unique "one current row," idempotency uniques.
- Isolation must hold in APIs, consumers, exports, and the (per-org) audit chain.
- **RLS is the honest "what I'd add"** for real data; today it's repository discipline + `TenantIsolation*` tests.

---

# 5. Authentication & session management

> **P0 chapter.** The Cognito + BFF + session + CSRF story is a common deep-dive. Know the difference between authentication and authorization cold.

## Concept: authentication vs authorization

- **Authentication** = *who are you?* Proving identity.
- **Authorization** = *what are you allowed to do?* Deciding access.

HealthCloud does authentication with Amazon Cognito (OIDC) and does authorization entirely in its own backend. Keeping these separate is a design principle here: **Cognito proves identity; it never grants a role.**

## The two login paths

1. **Real Cognito OIDC login (the production path).** Amazon Cognito is the identity provider; the Spring backend is an OAuth2 **Backend-for-Frontend**. It uses the OIDC **authorization-code flow**: the browser is redirected to Cognito's hosted login, the user authenticates there, Cognito redirects back with a `code`, and the *backend* exchanges that code for tokens — the browser never sees a token.
2. **Local dev-login stand-in (`POST /api/v1/dev-login`, `local` profile only).** For fast local development, a bypass that logs in by email with no password. It's ADR-018, and critically it's **gated to the `local` Spring profile** — the deployed app runs `demo,cognito`, where the dev-login controller isn't even registered and Spring Security doesn't permit the path. There's a test, `DeployProfileNoDevLoginTest`, that boots under `demo` and asserts the bypass is absent.

Both paths converge on the **same email-keyed session**: the Cognito registration sets `user-name-attribute: email`, so `authentication.getName()` is the email in *both* cases, and `UserContextFilter.resolveByEmail(...)` + all role/tenant logic work identically. That's an elegant bit of design — real auth and dev auth produce the same downstream context.

## Why a BFF with server-side sessions (not tokens in the browser)

**Problem:** a public web SPA needs to call an authenticated API.

**Constraint:** anything stored in the browser (localStorage, JS-readable cookies) is reachable by XSS. Bearer tokens in the browser are a well-known liability.

**Chosen approach (ADR-004):** the backend holds the OAuth2 client and a **server-side session** (Spring Session JDBC — session state lives in Postgres in a `spring_session` schema). The browser gets only an **HttpOnly `SESSION` cookie** it can't read from JavaScript. The backend does the token exchange and keeps any tokens server-side.

**Why it wins:** the blast radius of front-end XSS drops dramatically — there's no token to steal, and the session cookie is HttpOnly. Session invalidation is also trivial (delete the server-side session), unlike a stateless JWT you can't easily revoke.

**Trade-off:** it's stateful — sessions live in the database, so horizontal scaling needs shared session storage (which we have, in Postgres) rather than being purely stateless. For a BFF that's the right trade; for a huge stateless API you might choose short-lived JWTs plus a revocation list.

## CSRF protection (why it's needed *because* we use cookies)

Because auth is a cookie the browser sends automatically, the API is exposed to **Cross-Site Request Forgery** — a malicious page could trigger a state-changing request that rides your cookie. The defense is the **double-submit cookie** pattern:
- The backend issues a readable `XSRF-TOKEN` cookie (`CookieCsrfTokenRepository.withHttpOnlyFalse()` — readable so JS can echo it).
- State-changing requests must send that value back in an `X-XSRF-TOKEN` header. A forged cross-site request can send the cookie but *can't read it to set the header* (same-origin policy), so it fails.
- `dev-login` is CSRF-exempt (only under `local`) because it's the bootstrap call before a token exists.
- A `CsrfCookieFilter` ensures the token cookie is materialized for the SPA.

## The security filter chain (what's public vs authenticated)

`SecurityConfig` builds one `SecurityFilterChain`:
- **permitAll:** `/actuator/health` and `/health/**`, `/actuator/info`, the public capability probe `GET /api/v1/auth/config`, and the OIDC entry paths `/oauth2/**` + `/login/oauth2/**`. Only under `local`: `/api/v1/dev-login` and `/actuator/prometheus`.
- **Everything else:** `authenticated()`.
- **oauth2Login is added conditionally** — only if a `ClientRegistrationRepository` bean exists (guarded via `ObjectProvider`). So with no Cognito config (offline/CI/local-without-cognito), the app still boots and just doesn't offer OIDC. This is why tests and offline dev aren't coupled to Cognito.
- **401/403 rendering:** a `RestAuthenticationEntryPoint` (401) and `RestAccessDeniedHandler` (403) render the *same* `ApiError` JSON shape as controller errors, so filter-level and controller-level errors speak one contract.
- **The `UserContextFilter` is placed *after* the authorization filter**, so by the time it resolves the user context, authentication has already succeeded.

## Rejecting un-provisioned identities

A subtle but important control: `CognitoOidcUserService` (extends `OidcUserService`) overrides `loadUser` and, after loading the OIDC user, **rejects any login for which there's no ACTIVE `AppUser` in our database** (matched by email) — throwing an `access_denied` OAuth2 error with a generic message (no email echo). So a person could authenticate to Cognito and *still* be refused a session because they're not a provisioned HealthCloud user. Identity ≠ authorization, enforced right at the door.

## The capability probe and logout

- **`GET /api/v1/auth/config`** (public) returns `{ cognitoEnabled, cognitoLogoutUrl }`. The SPA reads it *before* auth to decide whether to enable the "Sign in with Cognito" button — so a misconfigured environment disables the button with an explanation instead of throwing a 500 on click.
- **RP-initiated logout:** logging out clears the Spring `SESSION` cookie *and* redirects to Cognito's hosted-UI logout URL, so Cognito's own SSO cookie is cleared too. Without that second step, the next "sign in" would silently re-authenticate the same user (you'd need an incognito window to switch users). Cognito's logout is non-standard (it's not the OIDC `end_session_endpoint`), so the URL is built by hand from config.

## MFA

MFA is *available* in the Cognito pool (OPTIONAL / TOTP) but **not enforced** — a deliberate demo simplification, and a documented hardening follow-up. Say it plainly: "MFA is configured as optional; enforcing it is a one-line pool change I'd make for a real deployment."

## Interview Q&A

**Q (basic): How does login work?**
> "The real path is Amazon Cognito using OIDC authorization-code flow, with my Spring backend acting as a Backend-for-Frontend. The browser gets redirected to Cognito's hosted login, authenticates there, and comes back with a code; the backend — not the browser — exchanges that code for tokens and establishes a server-side session. The browser only ever holds an HttpOnly session cookie. There's also a local-only dev-login bypass for fast development, but it's gated to the `local` profile and provably absent from the deployed app."

**Q (basic): Authentication vs authorization — where's the line in your system?**
> "Authentication is Cognito's job — it proves you're the person with this email. Authorization is entirely my backend's job — roles, tenant, and every permission come from my own database, looked up by that email. So even a completely valid Cognito login can't grant itself a role, and in fact I reject a login outright if there's no active user record for that email."

**Q (intermediate): Why server-side sessions instead of JWTs in the browser?**
> "Because anything the browser can hold, XSS can steal, and a bearer token is the worst thing to leak. With the BFF pattern the token stays server-side and the browser only gets an HttpOnly session cookie it can't read from JavaScript, so front-end XSS has nothing valuable to grab. It also makes logout real — I just kill the server-side session — whereas a stateless JWT is hard to revoke. The cost is that it's stateful, so I keep sessions in Postgres via Spring Session JDBC, which also means multiple backend instances share the session store."

**Q (intermediate): You use cookies for auth — how do you handle CSRF?**
> "Double-submit cookie. The backend sets a readable `XSRF-TOKEN` cookie, and every state-changing request has to echo that value back in an `X-XSRF-TOKEN` header. A cross-site forgery can ride the session cookie because the browser sends it automatically, but it can't *read* the CSRF cookie to set the header, thanks to same-origin policy, so it fails. In tests I do the same handshake — log in, read the token, send it back."

**Q (advanced): Someone finds the `/api/v1/dev-login` endpoint on your live demo. What happens?**
> "Nothing — it's not there. The deployed app runs the `demo,cognito` profiles, and dev-login is gated to `local`: the controller isn't registered, and Spring Security doesn't permit or CSRF-exempt the path outside `local`. I have a test, `DeployProfileNoDevLoginTest`, that boots the app under the deploy profile and asserts the bypass is gone and the seeder is still present, so that separation can't silently regress."

**Q (advanced): How do you prevent someone who authenticates to Cognito but isn't your user from getting in?**
> "My `CognitoOidcUserService` overrides the OIDC user loading and checks that there's an ACTIVE user record in my database for that email before allowing the session. If there isn't, I throw an access-denied error with a generic message — no session, no orphan account. Cognito can vouch for identity, but provisioning is mine."

**Q (advanced): Cognito gives roles/groups too — why not use them?**
> "I deliberately keep roles out of Cognito. If roles lived in the token, then whoever controls the identity provider controls authorization, and rotating or correcting a role means round-tripping the IdP. By resolving roles from my own database by email, identity and authorization stay decoupled — Cognito is swappable, and role changes are just data. It also matches my rule that the backend is the only authorization authority."

### Remember these points
- Cognito = **identity only**, OIDC **auth-code** flow, backend is the **BFF** (token exchange server-side).
- Browser holds only an **HttpOnly SESSION cookie**; sessions in Postgres via **Spring Session JDBC**.
- **CSRF** = double-submit cookie (`XSRF-TOKEN` cookie ↔ `X-XSRF-TOKEN` header) because auth is cookie-based.
- dev-login is **`local`-only** and provably absent from deploy (`DeployProfileNoDevLoginTest`).
- Un-provisioned identities are **rejected at login** (`CognitoOidcUserService`).
- MFA is optional/configured, not enforced — honest follow-up.

---

# 6. Authorization layering

> **P0 flagship chapter.** This is the single most distinctive thing in HealthCloud. If you can teach the five layers and the secure-404, you've won most interviews. Slow down here.

## Concept: layered ("defense in depth") authorization

Most apps authorize with one check: a role. HealthCloud authorizes with **five independent layers**, applied in order, where **each layer can only narrow access, never widen it.** The point is that "same role" does not mean "same access" in healthcare — a provider's access depends on their *relationship* to the patient and the patient's *consent*, not just their job title.

The five layers (ADR / §21.1), in order:

1. **Tenant** — you can only touch your own organization's rows (Ch. 4). Cross-tenant → secure 404.
2. **Role / function** — do you hold a role permitted to do this operation at all? (e.g. only `CLAIMS_REVIEWER`/`ORG_ADMIN` can adjudicate.) Fail → 403.
3. **Object / relationship** — for patient-scoped data: is this provider *actively assigned* to this patient? Is this patient looking at *their own* record? Fail → **secure 404**.
4. **Consent + purpose** — did the patient grant access to this data category, for this backend-fixed purpose, right now? Deny-by-default. (Ch. 7.)
5. **Field-level masking** — even on an allowed read, individual consent-controlled fields (e.g. date of birth) are blanked on the backend if consent doesn't cover them.

A **broad role** (care coordinator, org admin — and, until a finer permission matrix lands, claims reviewer) *skips the relationship layer* but still faces consent and field masking. So breadth is bounded, never total.

## Why HealthCloud needs all five

Because the real access rule is genuinely multi-dimensional. Consider two providers, both with the exact same `PROVIDER` role, both in the same org, both looking at the same patient:
- Provider A is actively assigned to the patient → passes the relationship layer.
- Provider B is not → gets a secure 404, as if the patient didn't exist.

And even Provider A might see the patient's date of birth masked if the patient's consent doesn't cover demographics for care coordination. **That's the "same role, different result" property**, and a single role check physically cannot express it. Five layers can.

## How it's implemented (the mechanism)

The genius is that **the relationship layer has exactly one implementation** — `PatientAccessGuard` (in `com.healthcloud.patient`) — and *every* patient-scoped read routes through it. That's what makes the guarantee hold: there's no second, forgetful code path.

The core method:

```java
Patient requireAccessibleInTenant(UUID patientId) {
    // Layer 1 (tenant): loaded by (org, id) → cross-tenant is already a 404
    Patient patient = patients.findByIdAndOrganizationId(patientId, organizationId)
                              .orElseThrow(NotFoundException::new);

    // Layer 3 (relationship): a provider must be actively assigned OR hold a live break-glass grant
    if (isProviderGated(caller)
            && !isActivelyAssigned(organizationId, caller.userId(), patientId)
            && !hasActiveBreakGlass(organizationId, caller.userId(), patientId)) {
        throw new NotFoundException();          // secure 404, not 403
    }
    // a PATIENT may read only their own linked record
    if (isPatientSelfGated(caller) && !caller.userId().equals(patient.getAppUserId())) {
        throw new NotFoundException();
    }
    return patient;
}
```

Two things to notice:
- **The same `NotFoundException` (404) is thrown for "doesn't exist" and "exists but you can't see it."** The caller cannot distinguish them. That's the secure-404, and it's central.
- **List reads share one scoping source:** `accessiblePatientIdsIfGated(caller, org)` returns the set of patient ids a gated caller may see (a provider → assigned + break-glass ids; a patient → their one linked id) or `Optional.empty()` for a broad role (meaning "no narrowing"). Both `PatientService.list` and `ServiceRequestService.list` filter through it — so the *list* and the *single-get* can never disagree about what you can see. If the accessible set is empty, the query short-circuits with no DB round-trip.

Everything patient-adjacent — the patient record, consent directives, provider/coordinator assignments, service requests, claims, documents, clinical summaries — routes its patient id through this one guard. **A new endpoint that exposes patient data must call the guard, or it doesn't get the gate.** The guard depends only on repositories (not on the services it protects), so any service can use it with no circular-dependency problem.

## Why the secure-404 matters (say this precisely)

A 403 "Forbidden" *confirms the resource exists*. In healthcare, the mere existence of a patient record at an org, or of a specific claim, is itself sensitive. So an object/relationship denial returns the identical 404 a nonexistent id returns. The attacker (or a curious insider) can't enumerate what exists. This is §21.5 in the design and it's applied consistently — cross-tenant, unassigned-provider, and wrong-patient all look the same from outside.

## Edge cases and failure behavior

- **Break-glass** (Ch. 14) is the *one* documented override of the relationship layer: a provider with a live emergency grant passes layer 3 for that patient — but tenant isolation and consent/masking are untouched. So break-glass reaches the patient's *whole* record (because everything routes through the guard) but never crosses tenants and is fully audited.
- **A broad role with an empty tenant?** `requireOrganizationId()` throws if there's no org context — you can't act tenant-less.
- **TOCTOU (time-of-check to time-of-use):** access is re-derived on each request from the current session and current DB state, so if a patient revokes consent or an assignment ends, the *next* request reflects it. Within a single request the check and the use are in the same transaction. (The genuinely hard version of this — a permission change mid-long-operation, or an already-issued document URL — is discussed in Ch. 24.)

## Alternatives and trade-offs

- **Single role check (RBAC only):** simplest, but can't express relationship/consent — wrong for the domain.
- **A policy engine (OPA/Cedar) or Spring Method Security everywhere:** more declarative, centralizes rules in a policy language. I chose *code* — one guard class plus pure policy classes — because the rules are tightly bound to domain data (assignments, consent directives) that a external policy engine would have to be fed anyway, and because a single well-tested guard is easy to reason about and impossible to bypass by construction. For a bigger system with many teams, externalizing policy would be worth it — I'd name that.
- **Enforcing in the database (RLS + views):** strong, and complementary; I enforce in the service layer and prove it with tests instead. RLS is my honest "would add."

## Interview Q&A

**Q (basic): How does authorization work in HealthCloud?**
> "It's five independent layers applied in order, and each one can only narrow access. First tenant — you only see your own org. Then role — do you even have a role allowed to do this. Then relationship — is this provider actually assigned to this patient. Then consent and purpose — did the patient allow this data for this reason. And finally field-level masking, where specific fields get blanked out even on an allowed read. The key idea is that in healthcare, same role doesn't mean same access, so one role check isn't enough."

**Q (intermediate): Walk me through what happens when a provider requests a patient they're not assigned to.**
> "The guard loads the patient by org and id, so tenant is already handled. Then, because the caller is a provider — a gated role — it checks whether they're actively assigned to that patient or hold a live break-glass grant. If neither, it throws a 404 — the exact same 404 you'd get for a patient that doesn't exist. So an unassigned provider literally can't tell whether the patient exists. If instead they *were* assigned, the read proceeds, but consent and field masking still apply, so they might get the record with the date of birth blanked."

**Q (intermediate): Why 404 and not 403 there?**
> "Because 403 leaks existence. 'You're forbidden from this patient' confirms the patient exists at this org, and that's a disclosure in itself. Returning the same 404 as a nonexistent record means the caller learns nothing — they can't enumerate patients or claims by probing. I apply that consistently for cross-tenant, unassigned-provider, and wrong-patient cases so they're indistinguishable."

**Q (advanced): How do you guarantee a new endpoint can't accidentally skip these checks?**
> "The relationship layer has exactly one implementation — a single `PatientAccessGuard` class — and every patient-scoped read routes through it, both the single-get and the list. There's no second code path to forget. The list scoping even comes from the same method that computes accessible patient ids, so the list and the detail view can't disagree. It's a convention enforced by having one choke point. The honest limitation is that it's a convention — nothing in the compiler *forces* a new endpoint to call the guard — which is why I'd add Row-Level Security in the database as defense in depth for real data."

**Q (advanced): Two users have the same role and get different results. Isn't that a bug?**
> "No — that's the whole design, and it's correct for healthcare. Two providers with the identical role can get different results for the same patient because one is assigned and one isn't, or because the patient's consent covers one purpose and not another. Role is only the second of five layers. The relationship and consent layers are what make access depend on the actual clinical relationship, not just the job title. If two same-role users *always* got the same result, I couldn't model real healthcare access at all."

**Q (advanced): Where does break-glass fit without blowing a hole in this?**
> "Break-glass overrides exactly one layer — the relationship layer — and nothing else. A provider can self-grant time-boxed emergency access to a patient they're not assigned to, with a recorded reason, and the guard honors that live grant. But tenant isolation still holds, consent and field masking still apply, and the whole thing writes an audit event. Because everything patient-scoped goes through the one guard, the grant correctly reaches the patient's whole record — but it can never cross tenants, and it expires."

### Remember these points
- Five layers, in order: **tenant → role → relationship → consent+purpose → field masking**; each only *narrows*.
- **"Same role, different access"** is the thesis; a single role check can't express it.
- One `PatientAccessGuard`, one choke point; list scoping and single-get share the same accessible-id source.
- **Secure 404** everywhere object access is denied — never leak existence with a 403.
- Break-glass overrides *only* the relationship layer; RLS is the honest defense-in-depth I'd add.

---

# 7. Consent & purpose-of-use

> **P0 chapter.** Consent is layer 4 of the authorization pipeline and the project's flagship differentiator. The words to nail: *deny-by-default, purpose-scoped, versioned, most-specific-wins.*

## Concept: consent and purpose of use

**Consent** is the patient's own rule about who may access which of their data. **Purpose of use** is *why* the data is being accessed (care coordination, claims, etc.). Real healthcare privacy law (and HIPAA's "minimum necessary") says access should be scoped to a purpose and to what the patient allowed. So a consent decision is a function of *(who is asking, which data category, for what purpose, as of when)* → GRANT or DENY.

## Why HealthCloud needs it

Without consent, "provider assigned to patient" would mean "sees everything." That's not how healthcare privacy works. Consent lets a patient say, for example, "my care team can see my demographics for care coordination, but not for anything else," and the system must honor that on every read — defaulting to *deny* when no rule applies. This is the layer that makes HealthCloud's access model genuinely privacy-aware rather than just relationship-aware.

## The consent lifecycle (versioned, immutable, supersede)

A `consent_directive` is never mutated in place. It follows the **supersede pattern** (§31.7):
- Recording a change for a natural key *(patient × purpose × data category × scope tier)* **supersedes** the current directive (marks it superseded, stamps an end time) and inserts a new version (version + 1). Revoking flips it to `REVOKED`.
- So the full history of every consent decision is retained — you can always answer "what was the consent state on the day this data was accessed?" That auditability is the point.
- "At most one current directive per natural key" is enforced by a **partial unique index** on the natural key (with `COALESCE` for nullable key parts, since Postgres treats NULLs as distinct). A `*_group_id` links the versions of one logical directive.

**Who can write consent:** staff (`CARE_COORDINATOR`/`ORG_ADMIN`) for any patient, **and a `PATIENT` for their own record** (self-service, §22.1) — the patient write path routes through `PatientAccessGuard`, so a patient touching another patient's consent is a secure 404. Providers and reviewers cannot write consent. Reads are open to any same-tenant user who can reach the patient (i.e. they pass the guard first).

## The decision engine (pure policy + a thin service)

The decision logic lives in a **pure policy class**, `ConsentPolicy`, with no Spring or DB — so it's trivially unit-testable — and a thin `ConsentPolicyService` loads the data and calls it. The decision rules (§22.5):

- **Most-specific tier wins.** Directives can be scoped at three tiers: `PROVIDER` (this specific provider) > `CARE_TEAM` (anyone on the patient's care team) > `ORGANIZATION` (the whole org). The most specific applicable tier decides.
- **Deny wins within a tier**, and it's **deny-by-default** overall — if no directive grants access, the answer is DENY.
- **The effective-date window is re-checked at decision time** — a directive that's scheduled for the future or expired doesn't count.
- **CARE_TEAM membership** is evaluated via `CareTeamService.isOnCareTeam` (an active provider- or coordinator-assignment). The pure `ConsentPolicy.decide` takes `actorOnCareTeam` as a *parameter*, so the policy stays DB-free and the service supplies the membership fact.

The entry point field masking calls is `ConsentPolicyService.decideForActor(org, actor, patient, purpose, category)` → returns GRANT/DENY.

## How consent connects to field masking (layers 4 → 5)

Field masking (layer 5) is consent applied at field granularity. `PatientFieldPolicy` maps each consent-controlled field to a `(ConsentDataCategory, DataClassification)`. For each such field, `PatientService.toFieldSafeDto(...)` asks `decideForActor` for `(READ_PURPOSE, category)`; if not granted, the field is added to a `maskedFields` list and blanked to `null` in the DTO. Crucially:
- **The purpose is backend-fixed** (`READ_PURPOSE = CARE_COORDINATION`) — the client never chooses its own purpose to widen access.
- **Deny-by-default** — a field is masked unless an applicable GRANT exists.
- **Write responses are unmasked** — if you just supplied the data, you can see it back.
- Masked values must not resurface in logs, exports, or events — the CSV export reuses the masked read exactly.

The reference field is `dateOfBirth`, and the reference narrative field is the clinical summary's free-text `narrative` (masked while the structured diagnosis *code* stays visible — the §60 "coded but not narrative" proof).

## Edge cases and failure behavior

- **No directive at all →** DENY (deny-by-default). A brand-new patient's sensitive fields are masked until consent is granted.
- **Conflicting directives at different tiers →** most-specific tier wins; within a tier, deny wins.
- **Consent revoked →** the next read reflects it immediately (decision is re-evaluated per request against current directives). In the UI, recording/revoking invalidates the patient query so a masked field flips live.
- **A future-dated grant →** doesn't apply until its effective date (window checked at decision time).
- **Break-glass does *not* override consent** — it overrides only the relationship layer. So even in an emergency, consent/field masking still applies. (Honest note: in real systems break-glass often *does* override more; here it's scoped narrowly by design.)

## Interview Q&A

**Q (basic): What does "consent" mean in your system?**
> "It's the patient's own rule about who can see which category of their data, and for what purpose. Every read of consent-controlled data asks a decision engine 'is this actor allowed this data category for this purpose right now,' and the default is deny — if the patient hasn't granted it, they don't see it. For example, a patient's date of birth comes back blank unless their consent covers demographics for care coordination."

**Q (intermediate): How is a consent decision actually made?**
> "The logic is in a pure policy class so it's easy to test. It's most-specific-tier-wins: a directive can be scoped to a specific provider, to the care team, or to the whole org, and the most specific applicable one decides. Within a tier, deny wins, and overall it's deny-by-default. It also re-checks the effective-date window at decision time, so a scheduled or expired directive doesn't count. The service layer supplies facts the pure policy needs — like whether the actor is on the patient's care team — so the policy itself has no database in it."

**Q (intermediate): Why version consent instead of just updating it?**
> "Because I need to answer 'what was the consent state on the day this data was accessed.' If I mutated the row in place, that history would be gone. So changing consent supersedes the current directive and inserts a new version, and revoking flips status to revoked — nothing is destroyed. A partial unique index enforces that there's only one *current* directive per patient-purpose-category-scope, which also backstops a race."

**Q (advanced): How do consent and field masking relate?**
> "Field masking is consent applied at the field level, and it's the fifth authorization layer. Each consent-controlled field maps to a data category, and when I build the response DTO I ask the consent engine per field; if it's denied, I blank the field to null and list it in a `maskedFields` array so the UI can show 'Restricted.' Two things make it safe: the purpose is fixed on the backend, not chosen by the client, and the masking happens on the backend when building the DTO — the frontend never receives the value and then hides it. And the CSV export reuses that same masked read, so masking can't be bypassed through export."

**Q (advanced): A patient revokes consent while a provider has the record open. What happens?**
> "The provider's already-rendered page still shows what it fetched — that's just stale client state. But the moment they do anything that hits the backend again, the decision is re-evaluated against the now-revoked directive and the field comes back masked. In the UI, the revoke action invalidates the cached patient query so it re-fetches and the field flips to 'Restricted' live. The authorization isn't cached on the server between requests — it's derived fresh each time from current directives."

**Q (advanced): Isn't deny-by-default going to make the app unusable — everything hidden?**
> "Only the consent-*controlled* fields default to hidden, and the demo data seeds sensible directives so the happy path works. The design choice is that the *sensitive* dimensions fail closed — it's much safer to accidentally hide a date of birth than to accidentally leak one. Non-sensitive data isn't consent-gated at all. So deny-by-default applies narrowly, to exactly the fields where a wrong default would be a privacy incident."

### Remember these points
- Consent = *(actor, data category, purpose, as-of date)* → GRANT/DENY; **deny-by-default**.
- **Most-specific tier wins** (PROVIDER > CARE_TEAM > ORGANIZATION); deny wins within a tier.
- **Versioned/supersede** (never mutate) → you can reconstruct consent state at any past date; partial-unique index enforces one current.
- **Purpose is backend-fixed**, never client-chosen; masking happens server-side in the DTO.
- Field masking (layer 5) = consent at field granularity; `dateOfBirth` is the reference; write responses are unmasked.
- Break-glass does **not** override consent — only the relationship layer.

---

# 8. Care-coordination workflow & state machines

> **P1 chapter.** Six state machines share one pattern. Learn the pattern once; you can then speak to any of them.

## Concept: a state machine

A state machine is an object that can only be in one of a fixed set of states, with a defined table of *legal transitions* between them. Trying an illegal move (e.g. adjudicating a DRAFT claim) is rejected, not silently allowed. HealthCloud has **six** of them — service requests, claims, prior authorizations, referrals, appeals, and claim reviews — and they all follow one shared shape, which is itself the lesson: consistent patterns generalize.

## The service-request workflow (the exemplar)

A `service_request` moves through: `DRAFT → SUBMITTED → TRIAGED → ASSIGNED → UNDER_REVIEW → NEEDS_INFORMATION → APPROVED / REJECTED / CANCELLED / CLOSED`. There's a timeline of comments and a status history; changes are optimistically locked.

## The shared pattern (say this once, apply to all six)

**1. The transition table is a pure policy class.** `RequestTransitions` (and `ClaimTransitions`, `PriorAuthTransitions`, `ReferralTransitions`, `AppealTransitions`, `ClaimReviewTransitions`) hold the legal-moves table with no Spring/DB — pure and unit-testable. The service loads data and applies the policy.

**2. The service checks, in a fixed order:** `exists → legal move → role → reason → version`, then updates status *and* appends a history row in **one transaction**.
- **exists:** load by `(org, id)` → secure 404 if not found (tenant layer).
- **legal move:** ask the policy; illegal → `INVALID_STATE_TRANSITION` (409).
- **role:** does the caller hold a role permitted to make *this* move? (e.g. only a reviewer can accept/reject a claim.) → 403.
- **reason:** some transitions require a reason (reject, cancel); missing → 400.
- **version:** the client sends `expectedVersion`; if it doesn't match the row's `@Version`, → `CONFLICT` (409). This is optimistic locking (Ch. 18) and gives double-apply safety without a separate idempotency key.

**3. Some statuses are owned by a dedicated command, not a bare status PATCH.** For requests, `ASSIGNED` is reachable *only* through `PUT .../assignment` — which records the assignee *and* advances the status atomically. A plain `PATCH /status` to `ASSIGNED` is refused. The same idea makes `ADJUDICATED` on a claim reachable only via the adjudication engine command (Ch. 10). The principle: *if reaching a state requires doing extra work, force it through the endpoint that does that work.*

**4. History is append-only.** Every move writes a `*_status_history` row (with the actor and correlation id), and the domain row + history row commit together. Creation writes a `null → DRAFT` history row.

## Two distinct 409s (a favorite follow-up)

- `INVALID_STATE_TRANSITION` (409): you asked for a move the state machine doesn't allow (e.g. DRAFT → ADJUDICATED).
- `CONFLICT` (409): a legal move, but your `expectedVersion` was stale — someone else changed the row first (optimistic lock failure).

Same HTTP status, different `code` in the error body, different meaning. Being able to separate them shows you understand both the workflow and concurrency.

## Assignment and the relationship gate

Service requests are **gated by their patient** — a request's reads and participant writes route the request's `patientId` through `PatientAccessGuard`, so a provider only reaches requests about patients they're assigned to; the unfiltered list is scoped to their accessible patients. Assignment (coordinator/admin-gated) is the only path to `ASSIGNED`, with a candidate-picker read for the UI.

## Interview Q&A

**Q (basic): What's a state machine and where do you use one?**
> "It's an object that can only be in certain states with defined legal moves between them. In HealthCloud a service request goes DRAFT, SUBMITTED, TRIAGED, ASSIGNED, and so on, and a claim has its own set. Trying an illegal move — like adjudicating a claim that was never accepted — is rejected with a specific error, not quietly allowed. I have six of these and they all share one implementation pattern."

**Q (intermediate): How do you implement a transition safely?**
> "The legal-moves table lives in a pure policy class with no database in it, so it's easy to unit test. The service then checks things in a fixed order — does it exist, is the move legal, does the caller have the right role, is a reason supplied if required, and does the client's expected version match — and only then updates the status and writes a status-history row in the same transaction. So every state change is atomic with its own audit trail, and an illegal move and a stale-version conflict are two distinct errors even though both are 409s."

**Q (intermediate): Why can't I just PATCH a request straight to ASSIGNED?**
> "Because reaching ASSIGNED means actually recording who it's assigned to, and I don't want a status that lies about that. So assignment goes through a dedicated endpoint that records the assignee and advances the status in one transaction, and a bare status PATCH to ASSIGNED is refused. I use the same idea for claims — you can't PATCH a claim to ADJUDICATED, because that state is owned by the adjudication engine, which has to compute the money."

**Q (advanced): You have two different 409s. Explain.**
> "One is an invalid state transition — you asked for a move the machine doesn't allow. The other is an optimistic-lock conflict — the move was legal, but the row changed under you, so your expected version was stale. Both are 409 because both are 'conflict with current state,' but they carry different error codes and mean different things: one is 'that's not a valid move ever,' the other is 'valid move, but retry with fresh data.' Distinguishing them lets the client react correctly — a UI can just refetch and retry on the second but must show a real error on the first."

**Q (advanced): Six state machines is a lot of duplication — why not one generic engine?**
> "They share a pattern but differ in the details that matter — different states, different role-per-transition rules, different 'reason required' rules, and some have per-transition reason requirements while others don't. I factored out the *shape* — pure transition-table policy classes plus a consistent check order in the service — rather than a single generic engine, because a generic engine would need so much per-machine configuration that it'd be harder to read than six small explicit policy classes. The duplication is mostly the boilerplate the framework generates; the actual rules are small and explicit, which I prefer for something this correctness-sensitive."

### Remember these points
- Six state machines, one pattern: **pure transition-table policy class** + service check order **exists → legal move → role → reason → version**.
- Status change + **append-only history row** in one transaction; creation writes `null → initial`.
- Dedicated-command states (ASSIGNED, ADJUDICATED) can't be reached by a bare status PATCH.
- Two 409s: **INVALID_STATE_TRANSITION** vs **CONFLICT** (stale optimistic version).
- Requests are patient-gated through the same `PatientAccessGuard`.

---

# 9. Clinical context & claims intake

> **P1 chapter.** The "§60 proof" — coded data visible, clinical narrative masked — is the memorable idea here.

## Concept: separating coded data from clinical narrative

A claim needs to carry *what was done* (procedure codes) and *what it cost* (amounts), but a claims reviewer shouldn't need the patient's full clinical story to do their job. HealthCloud models this split deliberately: the **claim** carries only coded, claim-relevant data (procedure codes, amounts, dates) — **no clinical narrative** — while the narrative lives in a separate **clinical summary**, where it's consent-masked. That's the "minimum necessary" principle made concrete, and it's the acceptance proof for Phase 4 (§60): *a claims reviewer can work claims without unrestricted medical context.*

## Medical codes (the shared vocabulary)

`medical_code` is the catalog of standardized codes — **ICD-10-CM** diagnoses and **CPT/HCPCS** procedures. It's **deliberately global reference data, not tenant-owned**: no `organization_id`, no access guard, no consent, because these are public national standards identical for every tenant (like the `role` table). Reads require an authenticated caller but aren't tenant-scoped; rows are immutable in-app; search is active-only, prefix-or-substring, capped at 50. This is a good example of knowing when *not* to apply the tenancy machinery.

## The claim aggregate (one transaction)

A `claim` header owns one or more `claim_line` children, each billing a procedure code for an amount. Key design points:
- **Money is computed on the backend.** The header `totalChargeAmount` is derived from the lines — the client can't assert a total.
- **Creation is one transaction** (§31.6 aggregate): the header + all lines are written atomically, after each line's procedure code is validated against the global catalog. An unknown code, or a *diagnosis* code where a *procedure* is required, is a 400 `VALIDATION_FAILED`.
- **Two foreign keys enforce integrity structurally:** `(patient_id, organization_id)` → patient (tenancy), and `(procedure_code_system, procedure_code)` → the global catalog. `claim_number` is unique per tenant (server-allocated `CLM-XXXXXXXX`).
- **Gated by its patient:** every read routes through `PatientAccessGuard`; the list scopes via `accessiblePatientIdsIfGated` — a provider sees only assigned patients' claims, while a broad role (coordinator/admin/**claims reviewer**) sees the tenant's claims as a work queue. Cross-tenant → secure 404.
- **Not consent field-masked** — a claim is coded claims data, not clinical narrative. That's the whole point of the split.

## The claim state machine

`DRAFT → SUBMITTED → {ACCEPTED, REJECTED}`, plus `CANCELLED`; `ADJUDICATED` is structurally reachable from `ACCEPTED` but engine-owned. Submitter roles submit/cancel; the **CLAIMS_REVIEWER** (+ ORG_ADMIN) accept/reject. Submitting **validates** the claim (≥1 line, total > 0 → else 400). A bare status change to `ADJUDICATED` is refused — that's the engine's command (Ch. 10). Reason required to reject/cancel.

## Clinical summaries (where the narrative lives, masked)

A `clinical_summary` is a short coded note pointing at an ICD-10-CM diagnosis. It's tenant-owned and patient-scoped, so it reuses the whole Phase-3 stack: reads/writes route through `PatientAccessGuard`, the org comes from the loaded patient, and it FKs the global catalog. Its free-text `narrative` is the **one consent-controlled field** (`CLINICAL_CONTEXT`, read purpose fixed to `CARE_COORDINATION`), masked deny-by-default; the DTO blanks it to `null` and lists it in `maskedFields`. **The structured diagnosis code stays visible** — so a caller sees the coded, claim-relevant diagnosis without the unrestricted narrative. That's the first half of the §60 proof; the claim carrying no narrative at all is the second half.

## Coverage plans and eligibility (the inputs to adjudication)

- **`coverage_plan`** — a benefit plan the org administers, holding the adjudication parameters: `deductibleAmount`, `coinsuranceRate` (0..1), `copayAmount`, optional `outOfPocketMax`, plus `planType`. Tenant-owned but *not* patient-scoped (it's administrative config, not PHI); create requires `ORG_ADMIN`; `plan_code` unique per tenant.
- **`patient_eligibility`** — a patient's enrollment in a plan for an effective-dated period, with a `memberId`. Patient-scoped (routes through the guard); enroll is coordinator/admin. **Periods for a patient are kept non-overlapping** (enforced in the service → 409), so "coverage on a date" is deterministic — exactly one plan (or none) covers any given service date. `findCovering(org, patient, date)` is the hook the adjudication engine calls.

## Interview Q&A

**Q (basic): What's on a claim?**
> "A claim has a header and one or more lines. Each line bills a procedure code — a CPT or HCPCS code from a global catalog — for an amount. The header total is computed on the backend from the lines, not sent by the client. What's deliberately *not* on a claim is any clinical narrative — a claim only carries coded, billing-relevant data, so a reviewer can work it without needing the patient's full medical story."

**Q (intermediate): Why is the medical-code catalog not multi-tenant like everything else?**
> "Because it's public reference data — ICD-10 and CPT codes are national standards, identical for every organization, and they're not PHI. So it has no organization id, no access guard, and no consent — it's global, like my roles table. It's a deliberate exception, and knowing when *not* to apply the tenancy machinery is as important as applying it. Every tenant's claims and clinical summaries foreign-key into that one shared catalog."

**Q (intermediate): How do you make sure a claim's data is internally consistent?**
> "A few structural guarantees. Creation is one transaction — the header and all lines commit together or not at all. Each line's procedure code is validated against the catalog at creation, and a diagnosis code where a procedure is required is a 400. The line FKs both the patient with the org, so tenancy is structural, and the code catalog, so an invalid code can't be stored. And the claim number is unique per tenant, server-allocated, so duplicates are impossible even under a race."

**Q (advanced): Explain the "coded data visible, narrative masked" design and why it matters.**
> "It's the minimum-necessary principle. A claims reviewer needs to know *what procedure* and *what diagnosis* to adjudicate a claim, but they don't need the free-text clinical narrative — that's more than necessary for their job. So I split it: the claim carries only codes and amounts and no narrative at all, and the clinical summary carries the narrative as a consent-masked field while its diagnosis *code* stays visible. The result is that a reviewer sees the coded diagnosis and procedures they need, but the unrestricted medical story is gated behind consent. That was the explicit acceptance proof for that phase."

**Q (advanced): Why must eligibility periods be non-overlapping?**
> "Because adjudication has to be deterministic — for any service date there has to be exactly one coverage plan in effect, or none. If a patient could be enrolled in two overlapping plans, 'which plan pays' would be ambiguous, and the money math would be non-deterministic. So the service enforces non-overlapping periods on enrollment and rejects an overlap with a 409, and the engine's `findCovering(org, patient, serviceDate)` returns zero or one row. Zero means no coverage, which is its own explainable outcome — denied for no eligibility."

### Remember these points
- The **§60 proof:** claim carries codes + amounts, **no narrative**; the clinical summary's narrative is consent-masked, its **diagnosis code stays visible**.
- Medical codes are **global reference data** — no tenancy/consent (deliberate exception).
- Claim = header + lines, **backend-computed total**, one-transaction create, structural FKs, unique claim number.
- Claim states: DRAFT→SUBMITTED→ACCEPTED/REJECTED (+CANCELLED); **ADJUDICATED is engine-owned**.
- **Eligibility periods are non-overlapping** → deterministic "coverage on a date"; `findCovering` is the engine hook.

---

# 10. The adjudication engine

> **P0 flagship chapter.** The other centerpiece besides authorization. Master the calculation order, the money handling, and the accumulator lock — and be able to do one worked example on a whiteboard.

## Concept: what adjudication is

Adjudication is the act of deciding, for a submitted-and-accepted claim, **how much the insurance plan pays and how much the member owes** — line by line — and recording *exactly how every number was computed*. The design requirement (§60) is that any decision is **deterministic and fully explainable**: given the same inputs you always get the same output, and for any output you can show which plan applied and how each dollar was derived.

## Why it's built the way it is

Two forces shape the design:
1. **Explainability + testability →** the actual math lives in a **pure calculator** (`AdjudicationCalculator`) with no Spring and no database. You can unit-test it with plain values, and it can't hide side effects.
2. **Correctness of money across claims →** a deductible and out-of-pocket max accumulate *across* a patient's claims within a benefit year, and two concurrent claims must not both consume the same remaining deductible. That forces a **row-locked accumulator inside the transaction**.

## The calculation, in order (memorize this)

For each **covered** line, in line order (the deductible and OOP remaining are carried across lines within the loop):

1. **Allowed** = `min(feeScheduleAmount ?? charge, charge)` — the plan's recognized price, never above the charge. The gap (charge − allowed) is a provider write-off nobody pays.
2. **Copay** = `min(planCopay, allowed)`.
3. **Deductible applied** = `min(remainingDeductible, allowed − copay)`; decrement `remainingDeductible`.
4. **Coinsurance** = `round((allowed − copay − deductibleApplied) × coinsuranceRate, 2, HALF_UP)` — the member's percentage share of what's left after copay and deductible.
5. **Gross member** = `copay + deductibleApplied + coinsurance`.
6. **OOP cap:** if the plan has an out-of-pocket max, `member = min(grossMember, remainingOop)`, the excess is recorded as `oopMaxApplied` (shifted to the plan), and `remainingOop` is decremented. No cap → `member = grossMember`.
7. **Plan paid** = `allowed − member`.

So the mental model is: **allowed → copay → deductible → coinsurance → OOP cap → plan pays the rest.** And `memberResponsibility = copay + deductibleApplied + coinsurance − oopMaxApplied`.

## Money handling (a details question that separates seniors)

- **All money is `BigDecimal`, scale 2, `RoundingMode.HALF_UP`** — never `double`/`float`, because binary floating point can't represent decimal cents exactly and would drift. The `money()` helper and a `ZERO = BigDecimal.ZERO.setScale(2, HALF_UP)` enforce this everywhere.
- `coinsuranceRate` is a 0..1 fraction; a null plan copay or coinsurance defaults to 0.
- Rounding happens at the coinsurance computation (the one multiplication that can produce fractional cents), consistently HALF_UP, so results are reproducible.

## Non-covered lines and precedence

Excluded / out-of-network / auth-required lines **never reach the calculator** — the service filters them out first and builds a "denied line" for each (allowed 0, plan pays 0, **member owes the full charge**, and they *skip cost-sharing entirely* — no deductible or OOP consumption). The `LineOutcome` enum is `COVERED, NOT_COVERED, AUTH_REQUIRED, OUT_OF_NETWORK`.

**Precedence (fixed):** `exclusion > out-of-network > auth requirement > covered`. In code:
```java
if (excluded.contains(key))                                     excludedLines.add(line);   // NOT_COVERED
else if (outOfNetwork)                                          outOfNetworkLineIds.add(...);
else if (requiresPriorAuth.contains(key) && !approvedAuth)      authRequiredLineIds.add(...);
else                                                            coveredLines.add(line);
```
A **claim with no coverage** on the service date is a header-level `DENIED_NO_ELIGIBILITY` (plan pays 0, member owes the charge) — still a recorded, explainable decision, not an error.

## The engine command (transaction + concurrency)

`AdjudicationService.adjudicate(claimId)` is `@Transactional` and `@Observed(name="healthcloud.adjudicate")`. Roles: `CLAIMS_REVIEWER`/`ORG_ADMIN`. It:
1. Loads the claim (patient-gated → secure 404) and requires state `ACCEPTED` (first adjudication) or `ADJUDICATED` (re-adjudication); anything else → `INVALID_STATE_TRANSITION` (409). Adjudication is a **dedicated engine command**, not a bare status change — like `ASSIGNED` on a request.
2. Finds coverage: `eligibility.findCovering(org, patientId, serviceDate)` → 0 or 1 row (periods are non-overlapping).
3. **Locks the benefit accumulator:**
   ```java
   accumulators.insertIfAbsent(org, patientId, planId, benefitYear);   // native INSERT ... ON CONFLICT DO NOTHING
   BenefitAccumulator acc = accumulators.lockByKey(org, patientId, planId, benefitYear);  // @Lock(PESSIMISTIC_WRITE) → SELECT ... FOR UPDATE
   ```
   The insert-if-absent *guarantees* the row exists before the locked read, so concurrent adjudications for the same patient/plan/year **serialize** on that lock — no lost update. `benefitYear` = the service date's calendar year (MVP: plan year = calendar year).
4. Computes `deductibleRemaining = plan.deductible − acc.deductibleMet` and `oopRemaining = plan.oopMax == null ? null : plan.oopMax − acc.outOfPocketMet`, prices lines from the fee schedule, and calls the calculator.
5. Updates the accumulator: `acc.add(sumDeductibleApplied, sumMemberResponsibility)` over covered lines, and saves.
6. Writes the immutable `adjudication` header + `adjudication_line` rows, and (first adjudication only) the claim status change + `claim_status_history` row.
7. On the same transaction: an **audit event** (`CLAIM_ADJUDICATED`, PHI-free detail) and an **outbox event** (`claim.adjudicated`). On **afterCommit**: a Micrometer counter `healthcloud.adjudications` (tags `outcome`, `type`) — so a rolled-back adjudication is never counted.

All of that is **one transaction**: the adjudication, the history, the accumulator update, the audit, and the outbox row commit or roll back together.

## Re-adjudication (versioned, reverses its own prior contribution)

The same command re-runs on an already-`ADJUDICATED` claim, writing a **new immutable version** (`v = prior max + 1`); prior versions are retained and the claim stays `ADJUDICATED`. The subtle correctness bit: before recomputing, it **backs out the prior version's contribution to the accumulator** — it re-reads the prior version's *own line snapshot*, sums deductible-applied and member-responsibility over its COVERED lines, locks the accumulator, and calls `acc.subtract(...)` (clamped at 0). Otherwise the deductible would be double-counted. A prior *denied* version (no plan) contributed nothing, so it's skipped. `GET .../adjudication` returns the latest; `.../adjudication/versions` lists all.

**Honest MVP limitations** (say these): re-adjudication reverses/recomputes *this claim only*, not other claims in the same benefit year; there's no Idempotency-Key (each call is an intentional new version); plan year = calendar year.

## A worked example (label it "synthetic teaching example")

**Plan (PPO):** deductible $500, coinsurance 20% (0.20), copay $20, OOP max $2000.
**Accumulator before this claim (same patient, plan, year):** deductible met $300, OOP met $300.
**Claim:** 2 covered lines, no fee schedule (so allowed = charge). Line 1 charge $1000, Line 2 charge $300.

Setup: `remainingDeductible = 500 − 300 = 200`; `remainingOop = 2000 − 300 = 1700`.

**Line 1 ($1000):**
- allowed = 1000
- copay = min(20, 1000) = **20**; afterCopay = 980
- deductibleApplied = min(200, 980) = **200** → remainingDeductible = 0; afterDeductible = 780
- coinsurance = 780 × 0.20 = **156.00**
- grossMember = 20 + 200 + 156 = **376**
- OOP: member = min(376, 1700) = 376, oopMaxApplied = 0, remainingOop = 1324
- **planPaid = 1000 − 376 = 624**

**Line 2 ($300):**
- allowed = 300
- copay = min(20, 300) = **20**; afterCopay = 280
- deductibleApplied = min(0, 280) = **0**; afterDeductible = 280
- coinsurance = 280 × 0.20 = **56.00**
- grossMember = 20 + 0 + 56 = **76**
- OOP: member = min(76, 1324) = 76, oopMaxApplied = 0
- **planPaid = 300 − 76 = 224**

**Claim totals:** allowed 1300, **plan paid 848**, **member 452**.
**Accumulator after:** deductible met 300 + 200 = **500 (fully met)**; OOP met 300 + 452 = **752**.

Notice how the deductible was exhausted *on line 1*, so line 2 saw `remainingDeductible = 0` — that's the "carried across lines within the claim" behavior. And because a later claim would start from `deductibleMet = 500`, its deductible step would apply 0 — that's "carried across claims via the accumulator."

**A second example showing the OOP cap:** same plan, but the accumulator already has OOP met $1950 (so remainingOop = $50), and a single covered line charge $1000. allowed 1000; copay 20; suppose deductible fully met so deductibleApplied 0; coinsurance = 1000 × 0.20 = 200; grossMember = 220; but `member = min(220, 50) = 50`, `oopMaxApplied = 170` (shifted to the plan); planPaid = 1000 − 50 = 950. The member hit their out-of-pocket max, so the plan absorbed the rest.

## Edge cases and failure behavior

- **No coverage on the service date →** `DENIED_NO_ELIGIBILITY`, an explainable decision (not a 500).
- **Excluded / out-of-network / auth-required lines →** member owes the full charge, no cost-share consumption; precedence exclusion > OON > auth > covered.
- **Concurrent adjudications, same patient/plan/year →** serialized by the pessimistic accumulator lock; the second waits, then reads the first's committed `deductibleMet`. No double-spend of the deductible.
- **Re-adjudicate after a config change →** new version; prior contribution backed out first so the accumulator stays correct.
- **A claim not in ACCEPTED/ADJUDICATED →** `INVALID_STATE_TRANSITION`.

## Alternatives and trade-offs

- **A rules-engine library (Drools) instead of a hand-written calculator:** more configurable, but far heavier and less transparent; my requirement was *explainability and determinism*, and a small pure function nails both and is easy to test. For a real payer with hundreds of frequently-changing benefit rules, a rules engine (or a rules table) would earn its keep — I'd name that.
- **Optimistic vs pessimistic locking on the accumulator:** I chose **pessimistic** (`SELECT … FOR UPDATE`) because the accumulator is a genuine hot contention point under concurrent claims for one patient, and an optimistic retry loop would just thrash. Pessimistic serializes cleanly. The cost is reduced concurrency on that one row — an acceptable, deliberate correctness-over-throughput trade (see Ch. 18/24).
- **Storing derived amounts vs recomputing:** I store the full immutable breakdown per version rather than recomputing on read, because the plan config can change over time and I need the decision *as it was made* — that's the explainability requirement.

## Interview Q&A

**Q (basic): What does the adjudication engine do?**
> "It takes an accepted claim and computes, line by line, how much the insurance plan pays and how much the patient owes, and records exactly how it got there. It finds the coverage in effect on the service date, then applies the plan's rules in order — allowed amount, copay, deductible, coinsurance, and an out-of-pocket cap — and stores a full breakdown so any decision is completely explainable."

**Q (intermediate): Walk me through the calculation order for one line.**
> "For a covered line: first the allowed amount, which is the minimum of the fee-schedule price and the charge — the difference is a write-off. Then the copay comes off. Then the deductible — up to whatever the member has left this year. Then coinsurance, which is the plan's percentage applied to what remains after copay and deductible. That gives the member's gross responsibility; if they've hit their out-of-pocket max, I cap it there and shift the excess to the plan. And the plan pays the allowed amount minus whatever the member owes. The deductible and OOP remaining carry across the lines within the claim, and across claims through an accumulator."

**Q (intermediate): How do you handle money precisely?**
> "Everything is BigDecimal at scale two with half-up rounding — never doubles. Floating point can't represent decimal cents exactly, so summing a lot of them drifts, and in a money system that's unacceptable. The only place rounding actually happens is the coinsurance multiplication, and it's consistently half-up, so the results are reproducible to the cent."

**Q (advanced): Two claims for the same patient are adjudicated at the same time. Can they both consume the same last $100 of deductible?**
> "No, and that's the reason for the accumulator lock. There's one accumulator row per patient, plan, and benefit year tracking deductible-met and OOP-met. Before computing, the engine does an insert-if-absent to guarantee the row exists, then takes a pessimistic write lock on it — a SELECT FOR UPDATE — inside the adjudication transaction. So if two adjudications race, the second one blocks until the first commits, then reads the first's updated deductible-met. They serialize on that row, so the deductible can't be double-spent. I chose pessimistic locking over optimistic there specifically because it's a hot row and an optimistic retry loop would just thrash."

**Q (advanced): You re-adjudicate a claim after fixing the fee schedule. What happens to the accumulator?**
> "The engine writes a new immutable adjudication version, but before it recomputes, it backs out the *old* version's contribution to the accumulator. It reads the prior version's own stored line breakdown, sums the deductible-applied and member-responsibility from its covered lines, locks the accumulator, and subtracts them — clamped at zero. Then it recomputes under the current config and adds the new contribution. If I didn't reverse first, the deductible would be double-counted. A prior *denied* version contributed nothing, so it's skipped. The honest limitation is that it only reverses *this* claim — it doesn't cascade to reprocess other claims in the same year that might now be affected."

**Q (advanced): Why store the full breakdown instead of recomputing on demand?**
> "Because plan config changes over time, and the whole requirement is explainability — I need to show the decision *as it was made*, with the parameters that applied then. If I recomputed on read, a later plan change would silently rewrite history. So each adjudication version is an immutable snapshot: the allowed, copay, deductible, coinsurance, OOP-applied, plan-paid, and member for every line. Re-adjudication appends a new version rather than mutating the old one."

**Q (advanced): What if there's no coverage on the service date?**
> "That's a first-class outcome, not an error — the claim is adjudicated as denied-for-no-eligibility. The plan pays zero, the member is responsible for the charge, and it's recorded as an explainable decision with that outcome. So 'no coverage' is a determinate result you can show and defend, just like a covered result."

### Remember these points
- Order: **allowed → copay → deductible → coinsurance → OOP cap → plan pays the rest**; deductible/OOP carry across lines *and* claims.
- Money = **BigDecimal scale 2 HALF_UP**, never floats; the calculator is a **pure function** (testable, explainable).
- Accumulator = one row per (patient, plan, benefit year); **insert-if-absent then pessimistic `SELECT … FOR UPDATE`** → concurrent claims serialize, no double-spend.
- One transaction: adjudication + history + accumulator + audit + outbox.
- Re-adjudication = new immutable version; **back out prior contribution first**.
- Non-covered precedence: **exclusion > out-of-network > auth-required > covered**; no-coverage → `DENIED_NO_ELIGIBILITY`.
- Be ready to whiteboard the 2-line example and the OOP-cap example.

---

# 11. Advanced claims

> **P1 chapter.** Six advanced-claims areas, all built on the patterns you already know. The interview value is showing the patterns *generalize*.

## The six areas (what each adds)

All of these are **top-level aggregates gated by their patient** (like `claim`), most with their own state machine, all carrying only coded/claims-domain data (so none are consent-masked), and all with a server-allocated business number:

1. **Prior authorization** (`PA-XXXXXXXX`): pre-approval for a planned procedure under a plan, for a service window. State machine REQUESTED → APPROVED/DENIED (the **CLAIMS_REVIEWER** decision) or CANCELLED. **Wired into adjudication:** a covered line whose procedure the plan requires prior auth for, with no APPROVED authorization covering the service date, adjudicates `AUTH_REQUIRED`.
2. **Referral** (`REF-XXXXXXXX`): a request to send a patient to a specialty for a coded reason (an ICD-10 diagnosis). Decision by the **CARE_COORDINATOR** — *deliberately a different role than prior auth*, to show the state-machine pattern generalizes across roles.
3. **Appeal** (`APL-XXXXXXXX`): a dispute of a claim's decision. SUBMITTED → UPHELD/OVERTURNED (reviewer) or WITHDRAWN. **A reason is required on *every* transition** (a per-domain variation). **Overturn is wired into re-adjudication:** an OVERTURNED decision on an ADJUDICATED claim re-runs the engine in the *same transaction* as the overturn, so they commit together.
4. **Claim anomaly signals**: an advisory fraud/waste detection pass over a claim. The logic is a **pure detector** (`ClaimAnomalyDetector`) — a new policy shape that *emits a list of findings* rather than gating a transition — with two deterministic heuristics: `DUPLICATE_CLAIM` (another claim, same patient, same service date, overlapping procedure) and `HIGH_TOTAL_CHARGE` (exceeds a configurable threshold, default $5000). Purely additive — it never touches claim status or the money.
5. **Manual review** (`MRV-XXXXXXXX`): a review case a coordinator/reviewer opens on a claim and a reviewer resolves. At most one OPEN review per claim (partial unique index → 409). It's a *tracking* record — opening one doesn't hold the claim or change its status.
6. **Reprocessing** (`RPB-XXXXXXXX`): batch re-adjudication of a coverage plan's claims after a config change. A **job, not a state machine** — and a deliberate **transaction-shape departure**: it runs `@Transactional(NOT_SUPPORTED)` so each claim's re-adjudication is its *own* transaction; one claim failing is caught and recorded without rolling back the batch or the others.

## The teaching point

Notice what's reused: the pure-policy-class pattern (5 more state machines + a detector), the patient-gate + list-scoping, the one-transaction-with-history, the engine-owned-status idea (overturn → re-adjudicate). The advanced features were built by *repeating* patterns, which is the real signal that the architecture is sound. And two deliberate *variations* — appeals requiring a reason on every transition, reprocessing using many independent transactions — show I bend the pattern when the domain calls for it.

## Interview Q&A

**Q (intermediate): How does prior authorization affect adjudication?**
> "A plan can flag certain procedures as requiring prior auth. When the engine adjudicates a covered line for such a procedure, it checks whether there's an APPROVED prior authorization whose window covers the service date. If not, that line comes out as AUTH_REQUIRED — the plan pays nothing and the member owes the charge, and it skips cost-sharing. Approve the authorization and re-adjudicate, and the line flips to covered. It's the same 'wire a domain fact into the engine' pattern as exclusions and network."

**Q (intermediate): Why does reprocessing break your one-transaction rule?**
> "Because a batch is fundamentally many independent operations, not one atomic change. If I ran the whole batch in one transaction, a single bad claim would roll back everyone's re-adjudication. So the batch orchestrator runs with NOT_SUPPORTED — no surrounding transaction — and each claim's re-adjudication is its own transaction in its own bean. A failure is caught and recorded as a failed item, and the rest continue. It's a deliberate exception to the rule, and knowing *when* to break the rule is the point."

**Q (advanced): The anomaly detector — is that a fraud model?**
> "No, and I'm careful to say so. It's two deterministic, explainable heuristics — a duplicate-claim check and a high-total-charge threshold — not a trained model, and it's purely advisory: it emits signals a human reviewer sees, and it never changes the claim status or the adjudication math. It's structured as a 'detector' policy class that returns a list of findings rather than gating a transition. A real fraud system would be a measured statistical model; this is a synthetic demonstration of the *plumbing* around signals, and I don't claim it's more than that."

**Q (advanced): How does an overturned appeal stay consistent with the claim?**
> "An overturn on an adjudicated claim re-runs the adjudication engine in the *same transaction* as recording the overturn, so either both happen or neither does — there's no window where the appeal says 'overturned' but the money wasn't recomputed. The appeal service depends on the adjudication service, and since overturning requires reviewer roles — the same roles the engine command requires — there's no authorization mismatch and no bean cycle."

### Remember these points
- Six areas, all **patient-gated aggregates**, coded data only (no consent masking), server-allocated numbers.
- Prior-auth, exclusions, and network are all **domain facts wired into the engine** (AUTH_REQUIRED / NOT_COVERED / OUT_OF_NETWORK line outcomes).
- Deliberate variations: **appeals need a reason on every transition**; **reprocessing = many independent transactions (NOT_SUPPORTED)**.
- Anomaly detector = **advisory, deterministic heuristics, not a fraud model**.
- Overturn → re-adjudicate **in one transaction**. The meta-point: patterns generalize.

---

# 12. Documents & object storage

> **P2 chapter.** The key ideas: an abstraction over where bytes live, authorization on *every* access, and scan/quarantine.

## Concept and design

Patient documents split **metadata** (in Postgres) from **bytes** (behind a storage abstraction). A `patient_document` row holds the tenant key, patient id, filename/content-type/size, an opaque `storage_key`, a `scan_status` (PENDING/CLEAN/QUARANTINED), and the uploader. The bytes live behind a **`DocumentStorage`** interface — a `LocalFileSystemDocumentStorage` stand-in today (a git-ignored `var/` dir, configured by `healthcloud.documents.dir`), **private S3 in the production shape** — so nothing else in the code knows or cares where bytes physically are. That abstraction is the whole design lesson: swap local for S3 without touching business logic.

## Authorization and validation

- **Every read and write routes through `PatientAccessGuard`** — an assigned provider or the patient can access; an unassigned provider or another tenant gets a secure 404. Upload is gated to PATIENT-own / CARE_COORDINATOR / ORG_ADMIN (providers/reviewers → 403).
- **Uploads are validated:** size-limited (`healthcloud.documents.max-size-bytes`, 10 MB) and content-type allowlisted (pdf/png/jpeg/gif/txt/csv → else 400).
- **Bytes never enter a DTO, log, or event** (§23.4). Download re-authorizes, then streams as an attachment.
- **Malware scanning + quarantine:** a `DocumentScanner` (the `FakeDocumentScanner` flags the EICAR test signature) sets `scan_status` on upload; **download withholds anything not CLEAN** — a QUARANTINED/PENDING document is a 409 `DOCUMENT_NOT_AVAILABLE` (not a 404 — the caller already sees it listed with its status). Scanning is synchronous today; an async event-driven scanner is the documented next step.

## Presigned URLs and their limits (a good discussion)

Today, downloads stream through the backend (which re-authorizes each time). A common production pattern is an **S3 presigned URL** — a time-limited signed link the client fetches directly from S3. Be ready to reason about the trade-off: presigned URLs offload bandwidth from the app and are great for large files, but they're a *capability* — once issued, the URL works until it expires **regardless of a later permission or consent change**, and it can be shared. Streaming through the backend keeps authorization on every byte at the cost of app bandwidth. (This connects to a classic Ch. 24 question: "can revocation invalidate an already-issued download URL?" — with presigned URLs, not until expiry; that's the honest answer.)

## Interview Q&A

**Q (basic): How are documents stored?**
> "Metadata in Postgres, bytes behind a storage abstraction. The row has the filename, type, size, an opaque storage key, and a scan status; the actual bytes live behind a `DocumentStorage` interface that's a local filesystem implementation for dev and private S3 in the production shape. Nothing else in the code knows where the bytes physically are, so swapping local for S3 doesn't touch any business logic."

**Q (intermediate): How do you keep document access authorized?**
> "Every upload and download goes through the same patient access guard as everything else, so an unassigned provider or another tenant gets a secure 404. Downloads re-authorize on each request and stream the file rather than exposing a raw path. And bytes never end up in a DTO, log, or event. On upload I validate size and content type against an allowlist, and I run a scanner that sets a scan status — a download only serves a CLEAN file; a pending or quarantined one returns a 409 with its status."

**Q (advanced): Would you use S3 presigned URLs, and what's the catch?**
> "For large files, yes — presigned URLs let the client pull directly from S3 and take that bandwidth off my app. The catch is that a presigned URL is a bearer capability: once I issue it, it works until it expires no matter what happens to the user's permissions or the patient's consent in the meantime, and it can be forwarded to someone else. Streaming through the backend, which is what I do now, keeps authorization on every request at the cost of app bandwidth. So it's a real trade-off — I'd use short expiries and accept that revocation isn't instant, or keep sensitive downloads proxied."

### Remember these points
- **Metadata in Postgres, bytes behind `DocumentStorage`** (local now, S3 in the shape) — swap without touching logic.
- Every access through `PatientAccessGuard`; upload role-gated; size + content-type validated; bytes never in DTO/log/event.
- Scan → `scan_status`; **only CLEAN downloads**, else 409 `DOCUMENT_NOT_AVAILABLE`.
- Presigned URLs = bandwidth win but a **bearer capability that survives revocation until expiry**.

---

# 13. Search, reporting, export & accessibility

> **P2 chapter.** Server-side paging done consistently, search on PHI-free identifiers, export that can't bypass masking, and honest WCAG scope.

## Pagination, filtering, sorting (done the same way everywhere)

All eight work queues are **server-side paged** and return a `common.PageResponse<T>` envelope (`{content, page, size, totalElements, totalPages, first, last}`) — never a bare list, never Spring's `PageImpl` (I own the JSON shape). The controller takes `page`/`size`/`sort` (+ the queue's filter) and builds a `Pageable` via `PageRequests.toPageable(..., allowedSortFields, defaultSort)`, which **clamps** size to 1..100 and page ≥ 0 and **allowlists the sort field** — an unknown sort field is a clean 400, never a `PropertyReferenceException` 500 or an arbitrary-column sort. Filtering is **pushed into SQL** (`... and (:status is null or e.status = :status)`), never an in-memory filter over a fetched list. Authorization is unchanged by paging — a gated caller with an empty accessible-id set short-circuits to an empty page with no DB round-trip.

## Free-text search (on synthetic identifiers only)

Search normalizes the box with `SearchTerms.likeContains(q)` — blank → no filter; otherwise a case-insensitive `%…%` LIKE with the SQL wildcards `\ % _` **escaped**, paired with `escape '\'`. Deliberately **searches a synthetic, PHI-free business number** (claim/auth/referral/appeal/review/batch number), *never patient names* — both a privacy choice (rule 5) and a "no sensitive data in query strings" choice. A real bug the tests caught: the nullable parameter must be `cast(:q as string)` in SQL, or Postgres infers `bytea` and `lower(bytea)` fails at runtime.

## CSV export with masking (the neat one)

`GET /api/v1/patients/export.csv` is a `text/csv` attachment that **reuses the exact same masked, tenant-scoped service read** the JSON list uses — so a masked `dateOfBirth` is already `null` in the DTO and exports as a **blank cell**, never a raw column read. The export can't become a back door around tenancy or consent, because it's not a second query. Formatting uses a pure `common.Csv` helper that RFC-4180-quotes and **defuses CSV formula injection** (a leading `= + - @` gets a `'` prefix so a spreadsheet won't execute it). Honest limit: it builds the whole list in one response (no streaming) — fine at synthetic scale.

## Accessibility (honest WCAG scope)

WCAG 2.2 **AA-*aligned*, not certified.** There's an automated **axe-core** gate in component/page tests (`expectNoAxeViolations`), plus app-shell fixes: a skip-to-content link, a `<nav aria-label="Primary">` landmark, and a shared `PageHeading` so each route has exactly one `<h1>` and correct heading order. The honest caveat: **axe under jsdom can't check color contrast** (no rendering engine), so contrast is verified in the browser on core screens and relies on the AA-designed theme — a full page-by-page audit and a Playwright+axe E2E gate are documented follow-ups.

## Interview Q&A

**Q (intermediate): How does pagination work across your list endpoints?**
> "Every work queue is server-side paged and returns a consistent envelope with content plus page metadata — I own that JSON shape rather than leaking Spring's page class. The controller takes page, size, and sort, clamps them to sane bounds, and allowlists the sort field so an unknown sort is a clean 400 instead of a 500 or an arbitrary-column sort. Filtering is pushed into SQL, not done in memory. And paging never changes authorization — a gated caller who can see nothing just gets an empty page without even hitting the database."

**Q (intermediate): What can users search by, and why that choice?**
> "Only synthetic business numbers — the claim number, auth number, and so on — never patient names. That's two decisions in one: it keeps PHI out of query strings and logs, and it means search can't be used to fish for people. Technically it's a case-insensitive contains match with the SQL wildcards escaped so a literal percent sign matches a percent sign."

**Q (advanced): How do you make sure a CSV export doesn't leak masked fields?**
> "The export calls the exact same service read the JSON API uses — not a separate query. So it inherits the tenant scope, the relationship gate, and the consent masking automatically: a masked date of birth is already null in the DTO, so it comes out as a blank cell. There's no second, unmasked read path to leak through. I also defuse CSV formula injection in the formatter, so a value starting with an equals sign can't execute when someone opens the file in a spreadsheet."

**Q (advanced): Is the app accessible?**
> "It's WCAG 2.2 AA-aligned, and I'm careful to say aligned, not certified. I have an automated axe-core gate in the component tests, plus the structural things — a skip link, a primary-nav landmark, and exactly one h1 per page with correct heading order. The honest gap is that axe running under jsdom can't check color contrast because there's no rendering engine, so I verify contrast in the browser on the core screens and rely on an AA-designed theme. A full page-by-page audit and a Playwright-plus-axe end-to-end gate are the follow-ups I've documented."

### Remember these points
- All 8 queues: server-side paged, `PageResponse` envelope, **sort-field allowlist** (unknown → 400), SQL filtering, empty-accessible-set short-circuit.
- Search = **PHI-free business numbers only**; escaped LIKE; `cast(:q as string)` gotcha.
- CSV export **reuses the masked read** → can't bypass tenancy/consent; **formula-injection defused**.
- Accessibility = **AA-aligned not certified**; axe gate + skip link + landmarks + single h1; **contrast is a browser check** (jsdom can't).

---

# 14. Security governance: audit, break-glass, retention

> **P0-ish chapter.** The HMAC hash chain is a favorite "explain the crypto" topic, and the "what does it *not* protect against" follow-up is where people fall down. Know both.

## The tamper-evident audit trail

**Concept.** An audit trail records security-relevant actions. A plain append-only log tells you *what was recorded*; a **tamper-evident** log lets you *detect* if someone edited, deleted, reordered, inserted, or truncated records after the fact. HealthCloud's audit trail is a **per-organization HMAC-SHA256 hash chain**.

**The structure.** Each `audit_event` is a link in a chain: it carries a per-org monotonic `sequenceNo`, the previous event's fingerprint `prevHash`, and its own `entryHash = HMAC(orgKey, canonical(event, prevHash))`. Because each hash covers the previous hash, changing any row makes its fingerprint no longer match *and* breaks every row after it — the break cascades.

**The canonical serialization** (pure, DB-free, in `AuditHashChain`): the fields — org id, sequence, timestamp (UTC instant, micros-truncated so a DB round-trip reproduces it), actor, action, resource type/id, outcome, correlation id, detail, prevHash — are joined with a `` (ASCII Unit Separator) delimiter, nulls become a sentinel token, and the result is HMAC-SHA256'd to lowercase hex. Genesis prevHash is 64 zeros. This class is shared by the *writer* and the *verifier*, so they can't disagree.

**The key** (this is the crux). The per-org key is **derived**: `orgKey = HMAC(masterSecret, orgId)`, where the `masterSecret` lives in **configuration** (`healthcloud.audit.hmac-secret`, env-overridable; a real deployment uses KMS/HSM), **never in the database it protects.** So an attacker who tampers with the `audit_event` table alone **cannot forge a valid fingerprint** — they don't have the key to recompute one. That's what makes it *tamper-evident* rather than just *append-only*: the integrity secret is out of reach of database tampering.

**Serialized appends.** Appends per org serialize via a `PESSIMISTIC_WRITE`-locked `audit_chain_head` row (insert-if-absent then lock — the same row-lock pattern as the benefit accumulator) that holds the chain tip (`lastHash` + `nextSequence`). So concurrent writers for one org can't interleave and corrupt the sequence.

**Written inside the caller's transaction.** `AuditService.record(action, resourceType, resourceId, outcome, detail)` is deliberately **not** `@Transactional` — it *joins the calling domain service's transaction*, so the audit row commits atomically with the action it records (or both roll back). It derives the tenant and actor from `UserContext` and the id from `CorrelationId` — never the client. Details are **PHI-free** (a claim number, not a diagnosis). Actions so far: `CLAIM_ADJUDICATED`, `CONSENT_REVOKED`, `BREAK_GLASS_INVOKED`, `BREAK_GLASS_REVOKED`, `RETENTION_PURGED`, `DEAD_LETTER_REPLAYED`.

**Verification.** `GET /api/v1/audit-events/verify` (AUDITOR/ORG_ADMIN) walks the chain in sequence order checking, per row: the sequence is as expected, the `prevHash` links, and the recomputed `entryHash` matches the stored one — first failure returns *where* and *why* it broke. Then it cross-checks the head tip to catch **truncation** (deleting the last N rows, which wouldn't otherwise break any surviving link). Returns `{valid, entriesChecked, brokenAtSequence, reason}`.

## What the hash chain does NOT protect against (the killer follow-up)

Be crisp and honest — this is where depth shows:
- **It's tamper-*evident*, not tamper-*proof*.** It doesn't *prevent* anyone from editing the table; it makes editing *detectable* on verification. If nobody runs verify, tampering sits undetected until they do.
- **It doesn't protect against an attacker who has the master secret.** If they can read the config/KMS key *and* write the table, they can recompute a whole valid chain from the tampered point forward. The security rests entirely on the key being out of reach of whoever can write the DB — that's why it's derived from a secret held outside the DB.
- **It doesn't guarantee completeness of what was *logged*** — it protects records that exist. If an action was never audited in the first place, the chain can't reveal the omission (this is why audit calls are inside the domain transaction — so a recorded action can't lose its audit event).
- **It's not a distributed ledger** — a single party controls it. A truly non-repudiable log would need external anchoring (e.g. periodically publishing the head hash somewhere append-only outside the system). That's the honest upgrade.

## Why audit events are never purged

The retention job purges *operational* data but **never audit events** — deleting an audit row would break the hash chain. So the audit trail is permanent; retention is scoped to things like long-expired break-glass grants.

## Break-glass emergency access

**Concept.** HIPAA's "break the glass": in an emergency, a provider needs access to a patient they're not assigned to — but that access must be deliberate, time-boxed, and heavily audited.

**Implementation.** `POST /api/v1/break-glass` lets a **PROVIDER** self-grant access to a patient, with a **required reason**, expiring at `now + grant-duration-minutes` (default 60). The service loads the patient *directly* by `(org, id)` — deliberately **not** through the access guard, since the whole point is reaching a patient the guard would 404 on (a cross-tenant/unknown patient is still a secure 404 — no leak). It writes the grant + a `BREAK_GLASS_INVOKED` audit event in one transaction; the audit detail is PHI-free (grant id + expiry, never the free-text reason, which stays on the grant row for later review).

**How the guard honors it** (Ch. 6): `PatientAccessGuard.requireAccessibleInTenant` allows a provider with no assignment if a *live* grant exists, and `accessiblePatientIdsIfGated` unions assigned + break-glass patient ids. Because everything patient-scoped routes through the one guard, the grant reaches the patient's *whole* record — but it overrides **only** the relationship layer; tenant isolation and consent/masking are untouched.

**Access review + revocation (governance).** A grant supports early revocation (`revoked_at`/`revoked_by`); "live" means `expires_at > now AND revoked_at IS NULL`, and the guard filters on both, so a revocation cuts access off at once. `GET /api/v1/break-glass/all` (AUDITOR/ORG_ADMIN) lists live grants; `POST .../{id}/revoke` (ORG_ADMIN — an auditor is read-only) ends one early and writes a `BREAK_GLASS_REVOKED` audit event.

**Honest limitations:** it's self-service (no approval — intentional for emergencies), and it's audited at *invocation*, not per subsequent read.

## Data retention

`RetentionService.runBreakGlassPurge()` (ORG_ADMIN, tenant-scoped) deletes break-glass grants that expired more than `retention.break-glass-days` (default 90) ago — removing the sensitive free-text reason once a grant is long expired — and records a `RETENTION_PURGED` audit event in the same transaction. The tension it models: **operational data has a lifecycle, but the audit trail is permanent.** Honest limitation: it's a manual admin trigger (a scheduled purge is future work).

## Interview Q&A

**Q (basic): What's in your audit trail and who can read it?**
> "It records security-relevant actions — a claim being adjudicated, consent revoked, break-glass invoked or revoked, a dead-letter replayed, a retention purge — with PHI-free details, so a claim number but never a diagnosis. It's append-only and immutable, scoped per organization, and only auditors and org admins can read it. And it's tamper-evident, which is the interesting part."

**Q (intermediate): What makes it tamper-evident, not just append-only?**
> "It's a hash chain. Each audit event carries a sequence number, the previous event's hash, and its own hash, which is an HMAC over the event's fields including that previous hash. So each record's fingerprint depends on the one before it — edit any row and its hash stops matching, and because the next row's hash included the old one, the break cascades down the chain. A verify endpoint recomputes the whole chain and tells you exactly where and why it broke, and it also checks the head tip so it catches someone deleting the last few rows."

**Q (intermediate): Why HMAC with a secret instead of a plain hash like SHA-256?**
> "Because a plain hash chain can be forged by anyone who can write the table — they'd just recompute all the hashes after their edit, since the algorithm is public. HMAC mixes in a secret key, so you can't compute a valid fingerprint without the key. And critically, I derive a per-org key from a master secret that lives in configuration or KMS, *not* in the database. So someone who compromises the audit table alone still can't forge a valid chain, because the secret isn't in the thing they compromised."

**Q (advanced): What does the hash chain NOT protect against?**
> "Several things, and I try to be upfront about them. It's tamper-*evident*, not tamper-*proof* — it doesn't stop edits, it makes them detectable, and only when someone runs verify. It doesn't help if the attacker also has the master secret — then they can recompute a valid chain, so the whole scheme rests on that key being out of reach of whoever can write the database. It can't reveal an action that was never logged at all — which is exactly why I write the audit event inside the same transaction as the action, so a recorded action can't lose its audit. And it's single-party — for true non-repudiation you'd anchor the head hash in some external append-only place periodically, which would be my upgrade."

**Q (advanced): How does break-glass not become a hole in your authorization model?**
> "It overrides exactly one of the five layers — the relationship layer — and nothing else. A provider self-grants time-boxed access to a patient they're not assigned to, with a required reason, and the access guard honors that live grant. But tenant isolation still holds, consent and field masking still apply, and it's fully audited — an invoke event on grant and a revoke event if an admin cuts it short. It's time-boxed so it expires on its own, an admin can revoke it early and the guard filters on both expiry and revocation so that's immediate, and auditors can list every live grant. The honest limitations are that it's self-service with no approval step — deliberate, because it's for emergencies — and it's audited at invocation rather than on every subsequent read."

**Q (advanced): Can a denial audit record disappear if a transaction rolls back?**
> "It can't get out of sync, because the audit write joins the *same* transaction as the action. `AuditService.record` isn't itself transactional — it enlists in the caller's transaction — so the audit event and the domain change commit together or roll back together. You never get a committed action with no audit event, or a committed audit event for an action that rolled back. The one thing to be careful about is that this means a *rolled-back* action correctly leaves *no* audit event — which is right, because it didn't happen."

### Remember these points
- Audit = **per-org HMAC-SHA256 hash chain**: each row has `sequenceNo`, `prevHash`, `entryHash`; edits cascade and are detectable on verify (which also catches truncation via the head tip).
- **HMAC with a key derived from a master secret held OUTSIDE the DB** is what makes it forge-resistant, not just a public hash.
- Audit write **joins the caller's transaction** (not its own) → atomic with the action; details are **PHI-free**; audit is **never purged**.
- Chain is tamper-**evident** not **proof**; useless if the attacker has the secret; can't show un-logged actions; single-party (external anchoring = upgrade).
- Break-glass overrides **only** the relationship layer; time-boxed, reason-required, audited, admin-revocable; self-service + invoke-time audit are the honest limits.

---

# 15. Event-driven architecture: outbox, Kafka, DLQ

> **P0 chapter.** The "why do you even need Kafka" and "what if the publish succeeds but the app crashes" questions live here. The transactional outbox is the star.

## Concept: the dual-write problem

When a domain change happens (a claim is adjudicated) and you also want to publish an event about it, you have two systems to write to — the database and the message broker — and **you cannot make those two writes atomic**. If you commit the DB then publish, a crash in between loses the event (DB says adjudicated, no one was notified). If you publish then commit, a rollback leaves a phantom event (someone was notified of something that never happened). This is the **dual-write problem**, and naïvely calling `kafkaTemplate.send()` inside a service method has exactly this bug.

## The solution: transactional outbox

**Turn the two-system write into a one-system write.** Instead of publishing to Kafka inside the transaction, write an **outbox row** to the *same database* inside the *same transaction* as the domain change. Now the domain change and the "intent to publish" commit atomically. A separate **relay** reads committed outbox rows *after* commit and publishes them to Kafka, marking each published. (ADR / §31.6.)

**The write side:**
- `OutboxService.record(aggregateType, aggregateId, eventType, payload)` — deliberately **not** `@Transactional`; it joins the caller's transaction (exactly like `AuditService`). It serializes the payload to JSON (Jackson 3), derives the org from `UserContext`, stamps the correlation id, and saves an `OutboxEvent`. The first emitter is `AdjudicationService.adjudicate` → a `claim.adjudicated` event.
- The payload (`ClaimAdjudicatedEvent`) is **minimum-necessary and PHI-free**: `claimId, claimNumber, adjudicationVersion, outcome, totalPlanPaidAmount, totalMemberResponsibility` — deliberately **no patient id, no clinical data.** (rule 5)

**The relay:**
- `OutboxRelay.publishPending()` (`@Transactional`) fetches pending rows **oldest-first, bounded batch** (`findByPublishedAtIsNullOrderByOccurredAtAsc`, a partial index on `published_at IS NULL` backs the poll), sends each to Kafka (topic = `event_type`, key = `aggregate_id`, metadata in headers: `eventId`, `eventType`, `aggregateType`, `organizationId`, `correlationId`), then stamps `published_at`. A send failure **stops the batch** so order is preserved and the row is retried next poll.
- `OutboxRelayScheduler` — a `@Scheduled(fixedDelay = poll-interval-ms)` poller, gated by `healthcloud.outbox.relay.enabled` (and `@EnableScheduling` on the app). Publishing happens **after commit** because it only ever reads *committed* rows.
- **Delivery semantics: at-least-once.** If the relay publishes but crashes before stamping `published_at`, the row is picked up again next poll and re-published. So consumers *must* be idempotent. It's **single-instance** today; multi-instance would need `SELECT … FOR UPDATE SKIP LOCKED` so two relays don't double-publish the same row.

## The read side (consumers, idempotency, retry, DLQ, replay)

**Consumer + idempotency:**
- `ClaimAdjudicatedConsumer` — a `@KafkaListener` on `claim.adjudicated` (group `claim-adjudication-notifier`), builds a PHI-free `claim_adjudication_notification` feed **purely from the event** (payload + headers), never re-reading the claim (loose coupling — the consumer doesn't depend on the producer's tables).
- **Idempotent** for at-least-once: it skips an event it already recorded (`existsByEventId`) *and* a `UNIQUE(event_id)` constraint is the backstop (a `DataIntegrityViolationException` is caught and treated as already-processed). Belt and suspenders — the pre-check handles the common case, the constraint handles the concurrent-duplicate race.

**Retry + backoff + dead-letter:**
- `KafkaConsumerErrorConfig` provides one `DefaultErrorHandler`: a bounded `FixedBackOff` retry (`max-attempts`/`backoff-ms`, defaults 3/500ms), then a `DeadLetterPublishingRecoverer` routes the record to `<topic>.DLT` (e.g. `claim.adjudicated.DLT`).
- **Structural failures are non-retryable** — a bad header (`IllegalArgumentException`) or malformed payload (`JacksonException`) are registered as not-retryable and go **straight to the DLT**, so a poison record never blocks the partition by retrying forever.

**Dead-letter drain + inspection + replay:**
- `DeadLetterDrainer` (`@KafkaListener` on the `.DLT`) drains failed records into a `dead_letter_event` table — original topic/key/payload, the app headers, and Spring's `kafka_dlt-*` failure metadata (exception class + message) — turning "what's dead-lettered" into an ordinary DB read. Idempotent via `UNIQUE(dlt_topic, dlt_partition, dlt_offset)`.
- `GET /api/v1/dead-letter-events` (ORG_ADMIN, tenant-scoped, role-gated → flat 403) lists them.
- **Replay:** `POST .../{id}/replay` re-drives a stored record back onto its source topic. `DeadLetterReplayService.replay` runs `@Transactional(NOT_SUPPORTED)` (no ambient transaction around the Kafka send), role-gates to ORG_ADMIN, loads tenant-scoped (secure 404), refuses an already-replayed record (409), **publishes first, then marks** — it delegates the "stamp replayed + write a `DEAD_LETTER_REPLAYED` audit event" to a separate bean's `@Transactional` method. Publish-first-then-mark means a crash after the send just re-publishes on retry, and the consumer's `event_id` dedupe makes the redelivery harmless.

## Kafka fundamentals (be ready to define these)

- **Topic:** a named stream of events (`claim.adjudicated`). **Partition:** a topic is split into partitions for parallelism; **ordering is guaranteed only within a partition.** **Key:** the record key (here `aggregate_id` = the claim id) determines the partition, so **all events for one claim land on the same partition and stay ordered relative to each other.** **Consumer group:** consumers in a group split the partitions among themselves; each partition is consumed by one member, which is how you scale out consumption. **Offset:** a consumer's position in a partition; committing the offset says "I've processed up to here."

## Tracing failures around the boundary (the classic follow-ups)

- **Publish succeeds, relay crashes before stamping `published_at`:** row still looks pending → re-published next poll → consumer sees a duplicate → **idempotency dedupes it.** Net effect: safe. This is *why* at-least-once + idempotent consumers is the whole design.
- **Domain transaction rolls back after writing the outbox row:** the outbox row rolls back with it (same transaction) → never published. No phantom event.
- **Consumer processes the event, then crashes before committing its offset:** the event is redelivered → consumer's `existsByEventId`/unique constraint dedupes → no double notification.
- **Consumer side effect is itself non-idempotent** (e.g. it *sent* an email): now duplicates *can* leak, because Kafka can't make an external send idempotent for you. Honest answer: my consumer's side effect is an idempotent DB insert keyed on event id, so it's safe; if it were sending email I'd need a dedupe/outbox on the send too. (This is a real Ch. 24 question.)
- **Poison message (malformed):** non-retryable → straight to DLT → drained to a table → an admin can inspect and replay after a fix. Never blocks the partition.

## Why Kafka at all? (the honest answer)

For *this* system's current scale, Kafka isn't strictly necessary — an in-process event or a simple table-driven job would work. I introduced it to (a) demonstrate the **event-driven pattern done correctly** — outbox, idempotency, retry, DLQ, replay — which is a real distributed-systems skill, and (b) model the seam where a real system would fan out to independent consumers (notifications, analytics, downstream services) that shouldn't be coupled to the adjudication transaction. I'm upfront that it's *demonstration-grade* here — I even deliberately **don't** run managed Kafka (MSK) in the cloud deploy because it's too costly for a portfolio, so the event-driven design is proven locally and documented as production-shape.

## Interview Q&A

**Q (basic): Why do you have an outbox instead of just calling Kafka from the service?**
> "Because you can't atomically write to a database and a message broker at the same time — that's the dual-write problem. If I commit the DB then publish and crash in between, the event is lost; if I publish then the transaction rolls back, I've announced something that never happened. The outbox fixes it by making it a single write: I write an outbox row to the same database in the same transaction as the domain change, so they commit together. Then a separate relay reads committed outbox rows and publishes them to Kafka afterward. The publish being lost just means the row stays unpublished and gets retried."

**Q (intermediate): The relay publishes at-least-once — how do you avoid duplicate processing?**
> "Idempotent consumers. If the relay crashes after sending but before marking the row published, it'll re-send next poll, so consumers have to tolerate seeing an event twice. My consumer checks whether it already recorded that event id and skips if so, and there's a unique constraint on event id as a backstop for the concurrent-duplicate case — if two deliveries race, the second insert fails and I treat that as already-processed. So the effect of a duplicate is a no-op."

**Q (intermediate): What happens to a message the consumer can't process?**
> "It depends why. A transient failure gets a bounded retry with backoff. A structural failure — a malformed payload or a bad header — is registered as non-retryable and goes straight to a dead-letter topic, so a poison message doesn't sit there retrying forever and blocking the partition. A drainer moves dead-lettered records into a database table with the failure metadata, so an admin can list them, and there's a replay endpoint to re-drive a record back onto its source topic after the underlying bug is fixed — which is safe because the consumer is idempotent."

**Q (advanced): The relay sends the message to Kafka, then the process dies before it records success. Walk me through the outcome.**
> "The outbox row still has a null published-at, so it looks pending. Next poll, the relay picks it up again and re-publishes. Now the consumer receives the event a second time. Because the consumer dedupes on event id — a pre-check plus a unique constraint — the second delivery is a no-op. So the visible outcome is: the event is delivered at least once, possibly twice, and processed exactly once in effect. That's the entire reason the design is at-least-once delivery with idempotent consumers rather than trying, and failing, to be exactly-once."

**Q (advanced): Can you actually get exactly-once here?**
> "Not end-to-end in the strict sense, and I don't claim it. Kafka has exactly-once *semantics* for Kafka-to-Kafka processing with transactions, but the moment a consumer has an external side effect — writing my notifications table, sending an email — you're back to at-least-once delivery plus idempotency to get effectively-once. My honest framing is: at-least-once delivery, idempotent consumers, so the *effect* is exactly-once for my DB-insert side effect. If the side effect were a non-idempotent external call like email, I'd need a dedupe store or an outbox on that send too."

**Q (advanced): You said single-instance relay — what breaks with two instances?**
> "Two relays would both poll the pending rows and could publish the same outbox row twice — more duplicates, which the consumer would dedupe, but wasteful and it could also reorder. To run multiple relays safely I'd change the poll to `SELECT … FOR UPDATE SKIP LOCKED` so each relay claims a disjoint set of rows, and keep the per-aggregate key so ordering within an aggregate is preserved by the partition. I kept it single-instance because at this scale one relay is plenty and it keeps the reasoning simple."

**Q (advanced): Why is the event payload so minimal — no patient id?**
> "Two reasons. Privacy — events cross a boundary and could be misrouted or logged, so they carry no PHI; the payload is a claim number, a version, an outcome, and the money totals, never a patient or clinical data. And loose coupling — the consumer builds its notification purely from the event and never reads back into the producer's tables, so the producer and consumer don't share a schema. The org id rides in a header so the consumer can stay tenant-scoped even though the payload is minimal."

### Remember these points
- **Dual-write problem** → **transactional outbox**: outbox row in the same DB transaction; relay publishes committed rows after commit.
- **At-least-once delivery + idempotent consumers** (pre-check `existsByEventId` + `UNIQUE(event_id)` backstop) = effectively-once.
- Retry with backoff → **non-retryable structural failures go straight to DLT** → drained to a table → **inspect + replay** (publish-first-then-mark, idempotent).
- Kafka terms: topic/partition/**key sets partition & ordering**/consumer group/offset.
- Payload is **PHI-free + minimal**; org id in a header; consumer never reads back (loose coupling).
- Single-instance relay today; multi-instance = `FOR UPDATE SKIP LOCKED`. **Exactly-once end-to-end is not claimed.**
- Honest: Kafka is **demonstration-grade** here; no MSK in the cloud (cost).

---

# 16. Frontend engineering

> **P1 chapter.** The recurring theme to hammer: **role-aware UI is convenience; the backend is the security.** Everything else is craft.

## The stack

React 19 + TypeScript 6 + **Vite 8** build, **React Router 7** for routing, **TanStack Query 5** for server state, **React Hook Form 7 + Zod 4** for forms, **Material UI 9** for components. Vitest + React Testing Library for tests, with an axe-core accessibility gate. The dev server proxies `/api`, `/actuator`, `/oauth2` to the backend so cookies are same-origin (no CORS); nginx does the same in production.

## Server state vs local UI state (the central frontend idea)

The distinction that organizes the whole front end:
- **Server state** — data that lives on the backend (patients, claims, the current user). Managed by **TanStack Query**, which handles caching, background refetching, staleness, and invalidation. The SPA never treats server data as something it "owns."
- **Local UI state** — ephemeral view state (which tab, a filter value, an unsent form draft). Managed by React `useState`.

Auth state is the cleanest example: there's no "isLoggedIn" flag in a store — **login state is simply whether `GET /api/v1/me` returns 200.** TanStack Query owns that query; if it 401s, you're logged out. The SPA holds no tokens at all.

## Data fetching: query keys, caching, invalidation

- Each server resource has a **query key** (e.g. `['patients', 'page', params]`). Paged hooks include the params in the key so a filter/sort/page change refetches, but stay prefixed with the base key so a create/mutation invalidation catches every variant.
- **Mutations invalidate** the relevant keys so the UI reflects the new server truth — e.g. recording consent invalidates the patient query and the list, so a masked field flips to "Restricted" live without a manual refresh.
- `placeholderData: keepPreviousData` on paged queries avoids a loading-flash when you page.
- This is why the app feels consistent: there's one source of truth (the server), and the client cache is kept honest by invalidation rather than by manually mutating local copies.

## Forms and validation (mirror the backend)

React Hook Form + Zod, wired with `@hookform/resolvers/zod`. The pattern is a Zod schema that **mirrors the backend's Jakarta validation** — so the client gives fast feedback, but the backend re-validates (the client schema is UX, not the security boundary). Server errors surface from `ApiClientError` (showing the `message` and `correlationId`). Dynamic line-item forms (claim lines) use `useFieldArray`. A real gotcha captured: when a Zod schema uses `z.coerce`/`z.preprocess` (number inputs arrive as strings), input and output types differ, so `useForm` needs the 3-generic form or TypeScript rejects the resolver.

## Session and CSRF integration

The typed `fetch` client (`api/`) injects the CSRF header (reads the `XSRF-TOKEN` cookie, sends `X-XSRF-TOKEN`) on state-changing calls, and relies on the session cookie for auth. `ApiClientError` carries the status so components can branch — e.g. a 404 on a patient detail for a PROVIDER caller triggers the break-glass panel instead of a generic error.

## Role-aware UI (convenience, never security)

The UI gates write controls by `useCurrentUser().roles` to match the backend rule — e.g. the "New patient" form shows only to coordinators/admins, the "Adjudicate" button only to reviewers. **But the backend re-enforces every one of those.** The requests UI even mirrors the state-machine transition table in a client `transitions.ts` purely to decide which action buttons to show — and the backend re-validates every move, so drift there is a UX bug, never a security hole. This is the single most important frontend talking point: *if you disabled JavaScript and hand-crafted the request, the backend would still stop you.*

## The full set of states (loading / empty / error / forbidden / conflict)

Good UIs handle more than the happy path:
- **Loading** — query `isLoading`; `keepPreviousData` avoids flashes on paging.
- **Empty** — a shared `EmptyState` component in every empty work-queue table.
- **Error** — a shared `ErrorScreen` showing the message + correlation id (so a user can quote it in a bug report).
- **Forbidden (403)** — nav is gated so users don't land on pages they can't use; a stray 403 renders the error contract.
- **Conflict (409)** — the two flavors from Ch. 8: an optimistic-lock conflict prompts a refetch-and-retry; an invalid-transition shows a real error.
- **Behavior after session/consent/permission change** — a 401 anywhere means logged-out; a consent change invalidates the patient query so masking flips live; a care-team change invalidates assignment + patient queries.

## Accessibility, responsive, performance

- **Accessibility** (Ch. 13): skip link, primary-nav landmark, one `<h1>` per route via a shared `PageHeading`, icon-only buttons have `aria-label`s, an axe-core test gate.
- **Responsive:** the shell is a permanent sidebar on desktop, a temporary drawer + hamburger on mobile (`useMediaQuery`), and forms stack full-width on small screens.
- **Performance:** the app is modest in size; the main levers are TanStack Query's caching/dedup (no redundant fetches) and server-side pagination (never fetch a whole table). Heavy client-side work isn't a factor here.

## Design system ("Care Constellation")

A single MUI theme is the styling source of truth (`theme/index.ts`) — teal primary, indigo accent, specific fonts, soft elevation, with **light + dark color schemes** via MUI CSS variables and `colorSchemes`, a system-following default, and a persisted toggle. The rule: **style via theme tokens/overrides, not per-page CSS**, and scheme-varying styles go through theme vars / `applyStyles('dark', …)`, never a hardcoded hex. The bespoke login page is a deliberate exception — an always-dark landing surface with its own local tokens.

## Testing the frontend

Vitest + React Testing Library, **mocking the `api` object** (but keeping the real `ApiClientError` so `instanceof` checks work). Router-dependent components are wrapped in `MemoryRouter`. The axe gate runs on component/page tests. 183 tests across 40 files.

## Interview Q&A

**Q (basic): How does the frontend know if the user is logged in?**
> "There's no token or login flag in the client — login state is just whether `GET /api/v1/me` returns 200. TanStack Query owns that call; if it comes back 401, the app treats you as logged out and routes to login. The browser only holds an HttpOnly session cookie it can't even read, so there's nothing for the SPA to manage."

**Q (intermediate): How do you manage server data on the client?**
> "TanStack Query. Each resource has a query key, and I let the library handle caching, background refetch, and staleness rather than copying server data into my own store. Mutations invalidate the relevant keys, so after I record consent, the patient query refetches and a masked field flips to 'Restricted' live — I never manually patch a local copy. I keep that server state strictly separate from local UI state like which tab is open or a filter value, which is just React useState."

**Q (intermediate): Your UI hides buttons based on role — isn't that a security risk?**
> "The hiding is pure convenience — it's so a user doesn't see actions they can't take. It is *not* the security control. Every one of those operations is re-checked on the backend, which is the only trust boundary. If someone enabled the hidden button, or hand-crafted the HTTP request, or turned off JavaScript entirely, the backend would still reject it based on their real roles, relationship, and consent. The frontend even mirrors the claim state-machine to decide which buttons to show, and if that mirror drifts from the backend, it's a UX bug, never a hole."

**Q (advanced): How does the UI stay correct when server state changes underneath it — say consent is revoked?**
> "Through query invalidation. The server is the single source of truth, and the client cache is kept honest by invalidating keys on the events that matter. When consent is recorded or revoked, that mutation invalidates the patient query, so it refetches and the masked fields update. A care-team change invalidates the assignment lists and the patient query. A 401 anywhere means the session's gone and the app drops to login. So I don't try to keep a local model in sync by hand — I invalidate and let the refetch reflect the new backend truth."

**Q (advanced): How do you handle the different failure states?**
> "Every API error comes back in one shape — a code, message, and correlation id — surfaced through a typed `ApiClientError` that carries the HTTP status, so components can branch on it. Loading uses the query's loading flag with keep-previous-data to avoid flicker when paging. Empty tables use a shared empty-state component. A 403 mostly can't happen because nav is role-gated, but a stray one renders the standard error screen with the correlation id so it's quotable in a bug report. And I distinguish the two 409s — an optimistic-lock conflict tells the user to refresh and retry, while an invalid state transition is a real error."

### Remember these points
- **Server state (TanStack Query) vs local UI state (useState)**; auth = "does `/me` return 200"; **no tokens in the browser**.
- **Query keys + invalidation** keep the cache honest; consent/care-team changes flip masked fields live.
- Forms = **RHF + Zod mirroring backend Jakarta validation** (UX, not the boundary); server errors via `ApiClientError`.
- **Role-aware UI is convenience; the backend re-enforces everything** — the #1 frontend talking point.
- Handle all states: loading/empty/error/403/409 (two kinds); one error contract with correlation id.
- One MUI theme, light/dark via CSS vars; **style via tokens, not per-page CSS**.

---

# 17. Backend & API deep dive

> **P1 chapter.** Fundamentals you must connect to real HealthCloud code: Spring DI, the request lifecycle, the layered structure, HTTP/REST semantics, idempotency, and JPA pitfalls.

## Java + Spring Boot (the version story)

Java **25 LTS**, Spring Boot **4.1.0**, Maven (wrapper). Boot 4 has some sharp edges I hit and documented: Jackson **3** (`tools.jackson.databind.ObjectMapper`), the OTLP tracing property was renamed (`management.opentelemetry.tracing.export.otlp.endpoint`), tracing is opt-in via dedicated modules, and `spring-boot-starter-aop` was dropped (I add `aspectjweaver` for `@Observed`). Knowing these shows I actually drove a bleeding-edge stack, not a tutorial.

## Dependency injection & configuration

Spring's IoC container wires components: `@Component`/`@Service`/`@RestController`/`@Repository` beans, constructor injection. The value of DI here is testability and the ability to *conditionally* wire — the clearest example is `oauth2Login` only being added when a `ClientRegistrationRepository` bean exists (via `ObjectProvider`), so the app boots with or without Cognito. Configuration is externalized in `application.yml` with profile overrides (`local`, `demo`, `cognito`) and env-var placeholders with dev defaults (`${HEALTHCLOUD_AUDIT_HMAC_SECRET:dev-only-...}`) — secrets never hardcoded, always overridable.

## The request lifecycle (trace one request end to end)

For `GET /api/v1/patients/{id}`:
1. **Filters run first**, in order: `CorrelationIdFilter` (highest precedence — sets the per-request id in MDC before anything logs), then Spring Security's chain (session auth, CSRF for writes), then `UserContextFilter` (placed *after* the authorization filter) resolves the authenticated email into a `UserContext` (user/org/roles) and stashes it request-scoped.
2. **The controller** (thin) receives the request and delegates immediately to a service.
3. **The service** does the real work: reads `UserContextAccessor.requireOrganizationId()`, routes through `PatientAccessGuard`, builds the field-masked DTO, all inside a transaction where relevant.
4. **The repository** loads by `(org, id)`.
5. **The response** is a DTO (never an entity), serialized by Jackson.
6. On error, `GlobalExceptionHandler` (or the security entry point/handler for filter-level 401/403) renders the one `ApiError` shape. The correlation id is echoed on `X-Correlation-Id` and cleared in `finally`.

## The layered structure & why controllers are thin

**Thin controller → service → repository → entity**, plus DTOs and pure policy classes. Business rules, authorization, state transitions, claim math, audit creation, and event creation all live in **services/domain components**, never controllers. Repositories are **tenant-safe by design** (org-scoped finders only). The payoff: the controller is trivial and untestable-by-omission, and all the logic sits in unit- and integration-testable services.

## DTOs vs entities (a deliberate boundary)

The API never returns JPA entities — it returns **DTOs**. This matters for three reasons here: (1) **field masking** happens when building the DTO (`PatientDto.masked(...)`), so a masked value never even leaves the service; (2) it decouples the wire contract from the schema, so a DB change doesn't ripple to clients; (3) it avoids lazy-loading serialization surprises. Write responses use the *unmasked* `PatientDto.from(...)`.

## REST & HTTP semantics

- **Verbs:** GET (read, safe), POST (create/command), PATCH (partial state change, e.g. status), PUT (replace, e.g. assignment). DELETE where a resource is removed.
- **Status codes** map to the `ErrorCode` enum: 400 `VALIDATION_FAILED`, 401 `UNAUTHENTICATED`, 403 `ACCESS_DENIED`, 404 `NOT_FOUND` (incl. secure 404), 409 `CONFLICT` / `INVALID_STATE_TRANSITION`, 500 `INTERNAL_ERROR` (generic message, full stack logged server-side, never leaked).
- **Consistent error contract:** `{code, message, correlationId, details}` for *both* filter-level and controller-level errors.
- **Pagination/filtering** via the `PageResponse` envelope + `page`/`size`/`sort` with a sort allowlist (Ch. 13).

## Idempotency & concurrent requests

- **State-machine transitions** carry a client `expectedVersion` compared to the row's `@Version` — a stale version is a 409, which gives **double-apply safety** (a retried PATCH with the old version fails), so a separate idempotency key isn't needed there.
- **Idempotency-Key** is reserved (by design, §31) for the genuinely *retriable create* commands — create request, submit claim, start adjudication — where a client retry shouldn't create a duplicate. (Honest scope: this is the documented pattern; the primary realized concurrency controls are the `@Version` optimistic lock and the pessimistic locks on hot rows.)
- **Uniqueness pre-checks** give clean 409s (duplicate plan code, claim number) rather than surfacing a raw DB constraint error — with the DB unique constraint as the backstop for a race.

## JPA/Hibernate, N+1, connection pools

- **Schema is owned by Flyway**; Hibernate runs `ddl-auto: validate` — it never generates DDL, only checks entities match the migrated schema.
- **UUID PKs, `@Version` on mutable rows, `EnumType.STRING`, `OffsetDateTime` via `@PrePersist`/`@PreUpdate`.**
- **N+1 avoidance:** the work queues fetch a page in one query and map to DTOs; list endpoints don't lazily walk associations per row. Where a queue needs a related name, the UI resolves it from an already-fetched list rather than the backend fanning out. (For heavier joins I'd use fetch joins or projections — I'd name that.)
- **Connection pool:** HikariCP (Boot default); its metrics are exported to Prometheus, so pool saturation is observable — relevant because the pessimistic locks on hot rows are where a pool would back up under contention.

## Interview Q&A

**Q (basic): Walk me through what happens when a request hits your backend.**
> "First the filters run — a correlation-id filter sets a per-request id for logging, then Spring Security authenticates the session and checks CSRF on writes, then a user-context filter turns the authenticated email into a user-org-roles context for the request. Then a thin controller hands off to a service, which does the actual work — reads the tenant from the context, runs the access guard, does the business logic in a transaction — and calls a repository that loads rows scoped by organization. The service returns a DTO, never an entity, and Jackson serializes it. Any error comes back in one consistent shape with that correlation id."

**Q (intermediate): Why return DTOs instead of your JPA entities?**
> "Three reasons here specifically. First, field masking — I build the DTO in the service, so a masked field like date of birth is nulled before anything leaves; if I serialized the entity, the value would escape. Second, it decouples the API contract from the database schema, so I can change a table without breaking clients. Third, it avoids lazy-loading surprises where serializing an entity accidentally triggers extra queries. Write responses use an unmasked DTO because the caller supplied the data."

**Q (intermediate): How do you keep controllers from becoming a mess?**
> "Controllers are deliberately thin — they just receive the request and delegate to a service. All the real logic — authorization, business rules, state transitions, the claim math, audit and event creation — lives in services and pure policy classes. Repositories only expose org-scoped finders, so tenancy is baked into the data layer. The result is that the controller has almost nothing to test, and everything worth testing is in a service I can hit with an integration test or a policy class I can unit test."

**Q (advanced): How do you handle a client retrying a request?**
> "It depends on the operation. For state changes, the client sends the version it expects, and if the row already moved on, it gets a 409 — so a retried transition with a stale version fails safely instead of double-applying. For creates that are genuinely retriable — submitting a claim, starting adjudication — the design reserves an Idempotency-Key so a retry doesn't create a duplicate; I'm honest that the fully-realized concurrency controls today are the optimistic version check plus pessimistic locks on the hot rows like the accumulator and audit head. And for uniqueness, I pre-check for a clean 409 but keep a database unique constraint as the real backstop against a race."

**Q (advanced): Where would N+1 queries bite you, and how do you avoid it?**
> "The risk is the work queues — if I lazily walked associations per row, a page of 20 claims could fire dozens of extra queries. I avoid it by fetching a page in one query and mapping straight to DTOs, and where a list needs a related name, the frontend resolves it from a list it already has rather than the backend fanning out per row. If a queue genuinely needed joined data, I'd use a fetch join or a projection query. And because Hikari pool metrics go to Prometheus, I'd actually *see* a query storm as pool pressure rather than guessing."

### Remember these points
- Thin **controller → service → repository → entity** + DTOs + pure policy classes; repos are org-scoped by design.
- Request order: **CorrelationIdFilter → Security → UserContextFilter → controller → service → repo**; one `ApiError` contract for filter- and controller-level errors.
- **DTOs not entities** — masking happens in the DTO; contract decoupled from schema.
- Idempotency: **`expectedVersion` optimistic lock** gives double-apply safety; **Idempotency-Key reserved** for retriable creates.
- Flyway owns schema, Hibernate `validate`-only; HikariCP metrics make pool pressure observable.

---

# 18. Database deep dive

> **P1 chapter.** Locking, isolation, races, immutable history. The concurrency questions here overlap with Ch. 10 and Ch. 24 — this is where you show you understand *why* the locks are where they are.

## The two kinds of locking (and where each is used)

**Optimistic locking (`@Version`):** the default for mutable rows. Every update checks that the version hasn't changed since you read it; if it has, you get a conflict (409). It assumes conflicts are rare — no lock is held, you just detect a collision at write time. Used for requests, claims, consent, assignments — anywhere two users *might* edit but usually don't. The client passes `expectedVersion`, which also gives idempotent double-apply safety.

**Pessimistic locking (`SELECT … FOR UPDATE`):** used for the two genuine hot spots where I *expect* contention and can't tolerate a lost update:
- **The benefit accumulator** — insert-if-absent (`ON CONFLICT DO NOTHING`) then `@Lock(PESSIMISTIC_WRITE)` lock-by-key, so concurrent adjudications for the same patient/plan/year serialize and can't double-spend the deductible.
- **The audit chain head** — same pattern, so concurrent audit writes for one org can't interleave and corrupt the sequence/hash chain.

The principle (from §31): **optimistic for user-editable rows, pessimistic row locks for financial accumulators and other hot serialized state.** Being able to say *why* each is where it is — "optimistic where conflicts are rare, pessimistic where they're expected and correctness is non-negotiable" — is the senior answer.

## Why insert-if-absent *before* the lock

You can't lock a row that doesn't exist yet. So the pattern is: `INSERT … ON CONFLICT DO NOTHING` to guarantee the row is there (idempotent — if it exists, nothing happens), *then* `SELECT … FOR UPDATE` to lock it. This closes the race where two requests both find "no accumulator yet" and both try to create one — the unique key + `ON CONFLICT` makes that safe, and then they serialize on the lock.

## Isolation, races, deadlocks

- **Isolation level:** the default (Postgres READ COMMITTED). The pessimistic locks provide the stronger guarantee exactly where it's needed, rather than raising the isolation level globally (which would add contention everywhere for a problem that only exists on two hot rows).
- **The races I explicitly handle:** double-spend of a deductible (accumulator lock), audit-chain interleave (head lock), duplicate creation (unique constraints + pre-check), concurrent state edits (optimistic version), duplicate event processing (unique event id).
- **Deadlock risk:** low, because each transaction locks at most one hot row and in a consistent order (accumulator keyed by patient/plan/year; head keyed by org). I don't take multiple pessimistic locks in an order that could invert. If I extended this, I'd keep a consistent lock-acquisition order to stay deadlock-free.

## Immutable history & versioned decisions

A recurring modeling choice: **don't mutate, append.**
- State machines write append-only `*_status_history` rows.
- Adjudications are **immutable versions** — re-adjudication appends a new version rather than editing the old one, so the decision "as it was made" is preserved.
- Consent uses the **supersede** pattern — a change inserts a new version and marks the old superseded.
- Audit events are immutable and never deleted.

The through-line: anything that's a *decision* or a *record* is immutable, so history is reconstructable and (for audit) tamper-evident. Mutable rows are only the "current working state" ones, and those carry `@Version`.

## Migrations (Flyway)

43 versioned `V*.sql` migrations own the schema; Hibernate only validates. Migrations are **forward-only and additive** in spirit (enum values are never renumbered, columns are added). This is what lets `ddl-auto: validate` work — the restored/migrated DB always matches the entities. A migration that succeeds while the *deploy* fails is a real concern (Ch. 24): because migrations run on app startup, a bad migration fails the boot; the mitigation is that migrations are additive so a rollback of the app is still schema-compatible.

## Retention, deletion, backup, restore

- **Retention** purges only *operational* data (long-expired break-glass grants); audit is never purged (Ch. 14).
- **Backup/restore** (Ch. 22): a `pg_dump -Fc` backup and — importantly — an automated **restore drill** that restores into a scratch DB and verifies every table's row count matches, because "a backup you've never restored isn't a backup." The dump includes `flyway_schema_history`, so a restored DB passes `validate`.

## Interview Q&A

**Q (basic): Optimistic vs pessimistic locking — what's the difference and where do you use each?**
> "Optimistic locking assumes conflicts are rare — you don't hold a lock, you just check at write time that the row's version hasn't changed since you read it, and if it has, you get a conflict. I use that for user-editable rows like requests and claims, with the client passing the version it expects. Pessimistic locking actually holds a lock — a SELECT FOR UPDATE — so other writers wait. I use that in exactly two places where contention is expected and a lost update would be a real bug: the benefit accumulator, so two claims can't double-spend a deductible, and the audit chain head, so concurrent audit writes can't corrupt the hash chain."

**Q (intermediate): Why not just raise the isolation level to serializable everywhere?**
> "Because that would add contention across the entire app to solve a problem that only exists on two hot rows. Serializable isolation makes the database detect and abort conflicting transactions globally, which means retries and reduced throughput everywhere. Instead I keep the default read-committed isolation and put a targeted pessimistic lock on exactly the two rows that need strict serialization. It's the minimal, surgical fix — strong guarantees where I need them, no global tax where I don't."

**Q (intermediate): Why insert-if-absent before locking the accumulator?**
> "You can't take a row lock on a row that doesn't exist yet. The first time a patient is adjudicated for a plan-year, there's no accumulator row. If I just did SELECT FOR UPDATE, two concurrent first-adjudications would both find nothing and both try to insert, and one would fail. So I do an insert-with-on-conflict-do-nothing first, which is idempotent — it guarantees the row exists without erroring if it already does — and then SELECT FOR UPDATE, at which point both requests serialize cleanly on the same row."

**Q (advanced): Are you worried about deadlocks?**
> "Not much, and here's why: each adjudication transaction takes at most one pessimistic lock — the accumulator, keyed by patient, plan, and year — and each audit write takes one, the chain head keyed by org. Since a transaction doesn't grab two hot locks in an order that could invert with another transaction, there's no classic lock-ordering deadlock. If I extended the system to need multiple pessimistic locks in one transaction, I'd enforce a consistent acquisition order to keep it deadlock-free. The bigger practical risk under load isn't deadlock, it's contention — writers queuing on a hot row — which I'd see in the latency and connection-pool metrics."

**Q (advanced): Why is so much of your data immutable?**
> "Because decisions and records need to be reconstructable, and in the audit case, tamper-evident. So anything that's a decision or a historical fact is append-only: state changes write history rows, re-adjudication appends a new immutable version instead of editing the old one, consent changes supersede rather than mutate, and audit events are never edited or deleted. The only mutable rows are the current-working-state ones, and those carry a version column for optimistic locking. The benefit is I can always answer 'what did this look like at the time,' which matters for both explainable adjudication and the audit trail."

### Remember these points
- **Optimistic (`@Version`)** for user-editable rows; **pessimistic (`SELECT … FOR UPDATE`)** for the two hot rows: accumulator + audit head.
- **Insert-if-absent (`ON CONFLICT DO NOTHING`) then lock** — you can't lock a nonexistent row; closes the create race.
- Default READ COMMITTED + targeted locks, not global serializable (surgical, not a blanket tax).
- **Append, don't mutate:** history rows, immutable adjudication versions, consent supersede, permanent audit — history is reconstructable.
- Flyway owns schema (43 migrations, additive), Hibernate validates; **restore drill** verifies backups.

---

# 19. Cloud & infrastructure (AWS + Terraform)

> **P2 chapter, but high-impact.** The credibility rule: **never equate "Terraform configured" with "verified deployment."** Say which is which. Also be ready to talk cost trade-offs — that reads as real ownership.

## Two distinct deployments (don't conflate them)

HealthCloud has **two** independent AWS footprints, each its own self-contained Terraform config sharing only the S3 state bucket:

1. **The on-demand production-shape stack** (`infrastructure/terraform/`): ECS Fargate + ALB + RDS + S3/CloudFront + Cognito. This is the *showcase* of production architecture. It's expensive (~$72/mo run-rate) so it's **on-demand**: stand it up, capture evidence, tear it down. **It has been destroyed** (2026-09-27) to stop the meter; it's fully re-creatable from the committed config.
2. **The always-on demo** (`infrastructure/ec2-demo/`): the *live link* for a resume — the whole app on **one `t3.small` EC2 box** via Docker Compose (Postgres + backend + frontend nginx + **Caddy** for auto Let's Encrypt HTTPS), pulling the GHCR images CI publishes, at `https://nikhil.healthcloud-demo.com`. ~$15/mo, covered by credits.

The framing that lands in an interview: *"The production-shape architecture is real and in Terraform and I demonstrated it, but keeping it always-on costs ~$70/month, so for the permanent live link I run the same app cheaply on one EC2 box. AWS credibility comes from the built code, the IaC, and the evidence — not from where the live link happens to point."*

## The production-shape stack, service by service

- **VPC & networking** (`network.tf`): a VPC across 2 AZs, public subnets (ALB + Fargate) and private subnets (RDS). **Deliberately no NAT Gateway** — the biggest cost save (~$32/mo); Fargate reaches the internet via a public subnet, and RDS needs no egress. Being able to explain *why no NAT* is a strong cost-awareness signal.
- **ECS Fargate** (`ecs.tf`): **one task holds both containers** (backend + frontend nginx) talking over localhost — cheapest shape (one task = one compute charge), images unchanged. Because awsvpc containers share a network namespace and nginx is fixed to 8080, the backend runs on 8081. **ARM64 runtime** (the images were built arm64 on Apple Silicon). The **RDS password and Cognito client secret are injected from Secrets Manager** by the ECS agent — never in the task def or state; an execution role has `GetSecretValue` scoped to those ARNs.
- **ALB** (`alb.tf`): HTTP :80, but its security group ingress is **locked to CloudFront's managed prefix list** — so the only path in is through CloudFront (which forces HTTPS); a request straight to the `*.elb.amazonaws.com` name is dropped.
- **RDS** (`rds.tf`): managed Postgres 17, `db.t4g.micro`, encrypted at rest, in private subnets, not publicly accessible, master password managed in Secrets Manager. Demo-tuned for clean teardown (single-AZ, no backups, `skip_final_snapshot`).
- **ECR** (`ecr.tf`): two image repos, scan-on-push, keep-last-5 lifecycle.
- **CloudFront** (`cloudfront.tf`): a distribution over the ALB origin — gives a free trusted HTTPS endpoint (ACM can't cert the ALB's AWS-owned name, and Cognito requires HTTPS callbacks). Uses managed `CachingDisabled` + `AllViewer` policies so cookies/headers/query forward (the app is a dynamic BFF; the session/CSRF cookies and OAuth code must pass through).
- **Cognito** (`cognito.tf`): the OIDC user pool, a confidential app client (BFF holds the secret), a hosted UI. Auth-hardened: the client's auth flows are trimmed to `ALLOW_REFRESH_TOKEN_AUTH`, the deploy runs `demo,cognito` (no dev-login).

## The always-on EC2 demo (the interesting cost-engineering)

The `ec2-demo/` config is a compact, honest piece of "how do I keep a live link up cheaply." The deploy gotchas — which are great "I actually did this" details — are baked into the config so I don't rediscover them:
- **Must be x86_64, not Graviton**, because the GHCR images CI publishes are `linux/amd64` only — the box must match. (Multi-arch images → a cheaper `t4g` is a future optimization.)
- **`t3.micro` (1 GB) OOMs** running Postgres + JVM + nginx + Caddy → **`t3.small` (2 GB)** + a 2 GB swapfile + a `-Xmx768m` heap cap.
- **A default subnet in `us-east-1e` can't host `t3.*`** → a Terraform data source filters for a supported AZ.
- **GHCR packages must be made public** at the package level or the pull is denied.
- **Caddy issues certs only once DNS points at the box** (ACM tls-alpn-01) — if it boots before DNS, restart Caddy to retrigger.
- The OIDC `redirect_uri` is **pinned** to the HTTPS domain via env (Caddy→nginx→backend is an internal HTTP hop — the same lesson as CloudFront→ALB).
- **No SSH** — access is via SSM Session Manager; secrets are delivered via SSM Parameter Store (SecureString), read once at boot; IMDSv2 required.
- The Cognito hosted-UI **branding is codified in Terraform** here (`aws_cognito_user_pool_ui_customization`, CSS+logo committed) — so an apply/rebuild restores it, unlike the ECS pool where branding is AWS-only drift.

## Terraform conventions & state

- `required_version` and the AWS provider are pinned; `.terraform.lock.hcl` is committed; `default_tags` stamp every resource; a `name_prefix` local names resources consistently.
- **State is in an S3 remote backend** (bucket `healthcloud-tfstate-…`, versioned + encrypted + private) with **S3-native locking** (`use_lockfile`, no DynamoDB on TF ≥1.10). State files are git-ignored — never committed.
- The bucket was created once by a small local-state `bootstrap/` config (chicken-and-egg: it makes the very bucket the main config stores state in), then left alone.
- **Environment separation:** the two stacks have separate state keys, so a `destroy` of one can never touch the other.

## Cost & the AWS boundary rule

- **Credits:** a $100 sign-up grant, and I earned another $100 via the 5 console activities. At ~$15/mo the EC2 demo stretches $100 for months.
- **The AWS boundary rule** (a real operating discipline): I never run `terraform apply`/`destroy` or any AWS mutation without an explicit per-action go-ahead, and I flag cost first. Read-only `fmt`/`validate`/`plan` are fine. This is worth mentioning as a professional habit — I treat cloud spend as something to control deliberately.

## Docker & local vs cloud

- **Local:** Docker Compose brings up Postgres + Kafka + (optionally) the app; the everyday `up -d postgres kafka` is unchanged, and heavier profiles (`full`, `observability`) are opt-in.
- **Images:** multi-stage Dockerfiles — backend builds the jar on JDK 25 and runs on a slim JRE as a non-root user with a health check; frontend builds the SPA and serves it from non-root nginx that proxies to the backend.
- **A real war story worth telling:** pushing the large backend image to ECR failed repeatedly with `docker push` (HTTP timeout — Docker parallelizes layer uploads and the biggest layer never finished on a home uplink, and Docker Desktop then wedged on a VM lock needing a Mac restart). The fix was **`crane push`** from a `docker save` tarball, which streams/retries — up in ~2 minutes. Lesson: on a slow uplink, push large images with `crane` (or from CI), not `docker push`.

## Interview Q&A

**Q (basic): How is HealthCloud deployed?**
> "Two ways. There's a production-shape stack in Terraform — ECS Fargate, an ALB, RDS Postgres, S3/CloudFront, and Cognito — that I stand up on-demand, capture evidence from, and tear down because it's around seventy dollars a month. And there's a permanent always-on demo that runs the same app cheaply on a single EC2 box with Docker Compose and Caddy for HTTPS, which is the live link on my resume. The real AWS credibility is the production architecture in code plus the evidence, not where the live link points."

**Q (intermediate): Why no NAT Gateway in your VPC?**
> "Cost and necessity. A NAT Gateway is about thirty-plus dollars a month, and I didn't need it. My Fargate tasks run in public subnets, so they reach the internet — for pulling images and hitting Secrets Manager — directly through the internet gateway, and RDS lives in private subnets that don't need any outbound access at all. So I put the ALB and Fargate in public subnets, the database in private ones with no egress, and skipped the NAT entirely. It's a deliberate, explainable cost decision."

**Q (intermediate): How do you handle secrets in the cloud?**
> "They're never in the Terraform code or the container definitions. The RDS master password is managed by Secrets Manager — Terraform sets manage-master-user-password, so the password is generated and stored by AWS and I never see it. The Cognito client secret is in Secrets Manager too. The ECS execution role has GetSecretValue scoped to exactly those two ARNs, and the ECS agent injects them into the container as environment variables at launch. On the EC2 demo, secrets go through SSM Parameter Store as SecureStrings, read once at boot by the instance role — and there's no SSH; shell access is via SSM Session Manager."

**Q (advanced): You say the production stack is 'demonstrated' — what does that mean exactly?**
> "It means I actually stood it up on my real AWS account, verified the app end-to-end over HTTPS — health, login through Cognito, the authorized reads — captured screenshots and evidence, and then tore it down to stop the cost. It is *not* running right now. I'm careful about that distinction because 'I wrote Terraform for it' and 'I ran it and watched it work' are different claims, and conflating them would be dishonest. The config is committed and re-creatable, and the evidence pack has the proof from when it was live."

**Q (advanced): Walk me through a real infrastructure problem you hit.**
> "Pushing the container images to ECR. The backend image is a couple hundred megs compressed, and `docker push` kept timing out on my home upload — Docker splits the upload across layers in parallel, so the biggest layer never finished within the HTTP timeout, and at one point Docker Desktop wedged on a VM lock and I had to restart the Mac. I switched to `crane` — you do a `docker save` to a tarball and `crane push` streams and retries instead of parallelizing, and it was up in about two minutes, and `crane tag` adds a second tag with no re-upload. The takeaway I wrote down was: on a slow uplink, push big images with crane or from CI, not docker push. It's the kind of thing you only learn by actually shipping."

**Q (advanced): Why run the always-on demo on one EC2 box instead of keeping ECS up?**
> "Purely cost. The ECS-plus-ALB-plus-RDS-plus-CloudFront stack is about seventy dollars a month, which is a lot to burn on a portfolio link a recruiter visits occasionally. The same app on one t3.small with Docker Compose and Caddy is about fifteen, covered by credits. It's a single box, single AZ, no backups — which I'm upfront is not a production posture — but it's the right trade for an always-on demo. The production-shape design still lives in the repo and the evidence pack as the thing I'd actually run for real. I even had to size it carefully — a t3.micro OOMs running Postgres, the JVM, nginx, and Caddy together, so it's a t3.small with swap and a capped heap."

### Remember these points
- **Two footprints:** on-demand production-shape (ECS/ALB/RDS/CloudFront/Cognito, ~$72/mo, currently destroyed) + always-on EC2 demo (~$15/mo, the live link). Separate Terraform, separate state keys.
- **"Configured/demonstrated ≠ running"** — say which. Credibility = code + IaC + evidence.
- Cost engineering: **no NAT**, one Fargate task with both containers, ARM64, EC2 `t3.small`+swap over OOM-y micro.
- Secrets in **Secrets Manager / SSM**, injected at runtime, never in code/state; no SSH (SSM Session Manager).
- Terraform: pinned versions, committed lockfile, **S3 remote state + native locking**, bootstrap for the state bucket.
- War story: **`crane` over `docker push`** for large images on a slow uplink.
- The **AWS boundary rule** (explicit go-ahead + flag cost) as a professional habit.

---

# 20. CI/CD & delivery

> **P2 chapter.** Four CI jobs, the "test-gates-the-image" idea, and honest migration/rollback reasoning.

## The pipeline

`.github/workflows/ci.yml` runs on push and PR to `main` (with concurrency cancellation of superseded runs). Four jobs:
1. **`backend`** — Temurin JDK 25, `./mvnw -B verify` — compiles and runs the full backend test suite; the runner's Docker powers the Testcontainers tests (real Postgres, real Kafka).
2. **`frontend`** — Node 24, `npm ci` → `typecheck` → `test` (Vitest) → `build`.
3. **`backend-image`** (`needs: backend`) — builds the container image and **publishes to GHCR** (`ghcr.io/…/healthcloud-backend`, tags `sha-<short>` + `latest`), **only on push to `main`** (PRs build but don't push, which still proves the Dockerfile works). Auth is the automatic `GITHUB_TOKEN` — no secrets.
4. **`frontend-image`** (`needs: frontend`) — mirrors it for the frontend image.

## The key design ideas

- **Tests gate the image.** `backend-image` `needs: backend`, so an image only publishes if its tests passed — you can never ship an untested image.
- **PRs build but don't push.** A PR proves the Dockerfile still builds without polluting the registry; only `main` publishes.
- **Immutable + moving tags.** `sha-<short>` is immutable (a deploy pins to it for reproducibility); `latest` is the convenience pointer.
- **No secrets in CI** — the built-in `GITHUB_TOKEN` with `packages: write` publishes to GHCR.
- **`linux/amd64`** images (matching the EC2 demo box; multi-arch is a follow-up).

## Delivery, migrations, rollback

- **Delivery to the EC2 demo:** CI publishes new GHCR images on every `main` push; rolling the box forward is `docker compose pull && docker compose up -d` over SSM. (Or a `terraform apply` if user-data changed, which recreates the box and re-seeds.)
- **Migrations run on app startup** (Flyway). This is simple and keeps schema and code in lockstep, but it means **a bad migration fails the boot** — which is actually a safety property (the app won't start on a broken schema). Because migrations are **additive/forward-only**, rolling the *app* back to the previous image is still schema-compatible (the new columns just go unused), so an app rollback doesn't require a schema rollback.
- **Health checks:** the container HEALTHCHECK targets `/actuator/health/liveness`, and readiness (`/actuator/health/readiness`) includes the DB, so an orchestrator only routes traffic to a ready instance.

## Interview Q&A

**Q (basic): What's in your CI pipeline?**
> "Four jobs on every push and PR to main. A backend job that runs the full test suite on JDK 25 using the runner's Docker for the Testcontainers tests, a frontend job that type-checks, tests, and builds, and then two image jobs that build the backend and frontend containers and publish them to GitHub's container registry. The image jobs depend on the test jobs, so an image only ships if its tests passed."

**Q (intermediate): Why do PRs build the image but not push it?**
> "So a PR proves the Dockerfile still builds — catching a broken build before merge — without cluttering the registry with images from every proposed change. Only a push to main publishes. And I tag with the commit SHA as an immutable tag plus a moving `latest`, so a deployment can pin to an exact reproducible image while `latest` stays convenient. There are no secrets in the pipeline either — GitHub's built-in token handles publishing."

**Q (advanced): Your migrations run on startup — what happens if a migration is bad?**
> "The app fails to boot, which I actually treat as a feature — I'd rather the instance refuse to start than come up on a half-migrated schema. Because I keep migrations additive and forward-only, and Hibernate only validates the schema, a bad migration is caught at startup rather than corrupting anything. And since migrations are additive, rolling the application back to the previous image is still schema-compatible — the newly added columns just sit unused — so an app rollback doesn't force a schema rollback. The thing I can't do trivially is roll a migration *backward*; for that I'd write a compensating forward migration rather than a down-migration."

### Remember these points
- Four jobs; **image jobs `needs:` their test job** → untested images never ship.
- **PRs build (prove Dockerfile), `main` pushes**; `sha-<short>` immutable + `latest`; `GITHUB_TOKEN`, no secrets.
- Flyway migrations run **on startup** → bad migration fails the boot (a safety property); additive/forward-only → app rollback stays schema-compatible.
- Liveness vs readiness health checks gate traffic.

---

# 21. Testing strategy

> **P1 chapter.** The thesis: **the negative tests are the proof.** ~700 tests, real Postgres via Testcontainers, and honesty about what tests establish vs miss.

## The numbers (measured)

**Measured, full-suite run (2026-09-24):** backend **511 tests** (`mvnw clean verify`, Testcontainers → a real PostgreSQL per test) and frontend **183 tests** (Vitest, 40 files) + typecheck + build = **694 green** across ~103 backend test files. Always state these as *measured on that date*, not as a live guarantee.

## The testing pattern (real infra, not mocks, for data access)

- **Real PostgreSQL via Testcontainers** (`TestcontainersConfiguration` with `@ServiceConnection`), imported where needed. Repository and logic tests use `@SpringBootTest`; **full HTTP/session flows use a real embedded server** (`webEnvironment = RANDOM_PORT`) + the JDK `HttpClient` — *not* MockMvc, because MockMvc doesn't run the Spring Session filter, so it can't exercise real session cookies. **No mocks for data access** — the tests run against a real database.
- **State-changing tests do the real CSRF handshake:** log in, `GET /me` to obtain the readable `XSRF-TOKEN`, send it back as `X-XSRF-TOKEN`. So the tests exercise the actual security machinery.
- **Kafka tests** add a real broker via `KafkaTestcontainersConfiguration` (a `ConfluentKafkaContainer` with `@ServiceConnection`), imported *only* by the Kafka tests so the rest of the suite stays broker-free; the relay/consumers are disabled across the suite except where a test drives them directly.

## The test pyramid, mapped to real classes

- **Unit (pure policy):** `AdjudicationCalculatorTest`, the transition-policy tests, `AuditHashChainTest` — pure classes, no Spring, fast.
- **Repository/integration:** `AdjudicationRepositoryTest`, `BenefitAccumulatorRepositoryTest`, `TenantIsolationRepositoryTest` — against real Postgres.
- **Full HTTP/session integration:** `AdjudicationApiIntegrationTest`, `AuthenticationSessionIntegrationTest`, `TenantIsolationIntegrationTest` — real server + real cookies.
- **Security/negative (the proof):** `TenantIsolationIntegrationTest` (cross-tenant → secure 404), `DeployProfileNoDevLoginTest` (the dev-login bypass is absent under `demo`), `CognitoOidcUserServiceTest` (un-provisioned identity rejected), the consent-masking before/after tests.
- **Concurrency/financial:** `AdjudicationAccumulatorApiIntegrationTest` (the deductible carries correctly), plus the exclusion/fee-schedule/prior-auth/re-adjudication adjudication tests.
- **Event-driven:** `OutboxRelayKafkaIntegrationTest`, `ClaimAdjudicatedConsumerKafkaIntegrationTest`, `ClaimAdjudicatedDlqKafkaIntegrationTest` (the retry→DLT path), the dead-letter replay tests.
- **Frontend:** Vitest + RTL (mock the `api` object, keep real `ApiClientError`); router components wrapped in `MemoryRouter`; the axe-core accessibility gate.

## Negative tests are the proof (say this)

For a security system, the tests that matter most aren't "the happy path works" — they're "**the thing that should be denied *is* denied.**" The acceptance criteria are negative: a NorthCare user *cannot* read Green Valley data (secure 404); an unassigned provider *cannot* see a patient; a masked field *is* masked; the dev-login bypass *is* gone from the deploy profile; a poison message *goes* to the DLT. Those tests are the evidence the security model actually holds, and there's a rule that **every new tenant-owned resource gets a cross-tenant secure-404 test.**

## What tests establish vs what they miss (be honest)

- **They establish:** the logic is correct against a real database, tenancy/authz/consent hold on the paths I test, the money math is exact, the event pipeline retries and dead-letters correctly.
- **They miss:** they don't prove *absence* of a leak on an *untested* endpoint (which is why RLS would be a stronger guarantee than tests + discipline); axe under jsdom can't verify color contrast; there's no Playwright+axe E2E gate yet (a documented follow-up); the load numbers are single-node and not an SLA; security scanning (CodeQL/Dependabot/Trivy/ZAP) is in the frozen stack as documented follow-ups, not all wired.

## Interview Q&A

**Q (basic): How is the project tested?**
> "About 700 automated tests — 511 backend and 183 frontend on the last full run. The backend tests run against a real PostgreSQL through Testcontainers rather than mocks, and the full HTTP tests spin up a real server and use real session cookies, including doing the actual CSRF handshake. The frontend is Vitest and React Testing Library with an accessibility gate. CI runs all of it on every push."

**Q (intermediate): Why real Postgres via Testcontainers instead of mocking the database or using H2?**
> "Because the things I most need to trust are database behaviors — the tenant-scoped queries, the unique constraints that backstop races, the pessimistic row locks on the accumulator, the `ON CONFLICT` upsert. A mock or an in-memory database like H2 wouldn't exercise real Postgres semantics, so a test could pass while the real thing breaks. Testcontainers gives me a real Postgres per test run, so my repository and concurrency tests actually prove what they claim. The only cost is that Docker has to be running and the suite is a bit slower, which is a fine trade for correctness."

**Q (intermediate): Why not MockMvc for the HTTP tests?**
> "Because MockMvc doesn't run the Spring Session filter, so it can't exercise real session cookies — and session plus CSRF is exactly the machinery I need to test. So my full-flow tests start a real embedded server on a random port and drive it with a real HTTP client: log in, read the CSRF token from the cookie, send it back in the header, just like a browser. That way the test goes through the actual security filter chain, not a simulation of it."

**Q (advanced): Which tests give you the most confidence, and why?**
> "The negative ones. For a security system, 'the happy path works' is table stakes — what matters is that the thing that should be forbidden actually is. So the tests I lean on are the cross-tenant test that proves a NorthCare user gets a secure 404 for Green Valley data, the test that an unassigned provider can't see a patient, the before-and-after consent-masking test, the test that boots the deploy profile and asserts the dev-login bypass is gone, and the one that sends a poison message and asserts it lands in the dead-letter topic instead of blocking the partition. Those are the evidence the model holds. And I have a rule that every new tenant-owned resource gets its own cross-tenant secure-404 test, so that guarantee grows with the system."

**Q (advanced): What don't your tests prove?**
> "A few honest gaps. My tests prove the paths I test are safe, but they can't prove the *absence* of a leak on an endpoint I forgot — that's a limit of testing plus discipline, and it's the main reason I'd add database Row-Level Security for real data as a guarantee that doesn't depend on remembering. The accessibility gate can't check color contrast under jsdom, so that's a manual browser check. I don't have a Playwright end-to-end gate yet. And the load-test numbers are single-node and explicitly not an SLA. I'd rather name those than imply full coverage."

### Remember these points
- **694 measured** (511 backend / 183 frontend, 2026-09-24); ~103 backend test files; say "measured on that date."
- **Real Postgres via Testcontainers, no data-access mocks**; full flows = real server + real cookies + **real CSRF handshake** (MockMvc can't do sessions).
- **Negative tests are the proof**: cross-tenant 404, unassigned-provider 404, masking, `DeployProfileNoDevLoginTest`, DLT routing. New tenant resource ⇒ new cross-tenant test.
- Kafka tests use a real broker, isolated to those tests.
- Honest misses: absence-of-leak on untested endpoints (→ RLS), contrast, no E2E gate, load = single-node not SLA.

---

# 22. Observability & operations

> **P2 chapter.** Metrics, tracing, health probes, alerts, runbooks, and the restore drill. The mantra: **every panel shows a measured value — no fabricated numbers.**

## The three signals

- **Metrics (Micrometer → Prometheus):** `/actuator/prometheus` exposes auto-instrumented JVM/HTTP/HikariCP metrics plus a common `application=healthcloud` tag and HTTP p95 histograms. Domain metrics are added on the transaction's **afterCommit** so a rolled-back change is never counted — the exemplar is `healthcloud.adjudications` (tagged `outcome`, `type`) and a gauge `healthcloud.outbox.pending`. `/actuator/prometheus` is unauthenticated **only under `local`**; the deploy keeps it authenticated.
- **Dashboards (Grafana):** an auto-provisioned "HealthCloud Overview" dashboard (18 panels: a headline stat row + Traffic/latency, Domain, and Runtime sections). Every panel shows measured values; an as-yet-unemitted counter uses `... or vector(0)` so it reads 0 rather than "No data."
- **Tracing (Micrometer Tracing + OpenTelemetry → Jaeger):** spans exported over OTLP; sampling 1.0 locally; `traceId`/`spanId` in the log pattern beside `correlationId`. A custom `@Observed` `adjudicate-claim` span nests under the HTTP span, and Kafka observation propagates the trace context across the event boundary.

## Health & readiness probes (the deliberate split)

Kubernetes-style probes:
- **Liveness** (`/actuator/health/liveness`) = "is the process alive?" — process-only, so a database blip never restarts the app.
- **Readiness** (`/actuator/health/readiness`) = "can I serve?" — includes `db`, so an instance leaves the load balancer when Postgres is unreachable.
- **Root `/actuator/health`** = the full aggregate (db + a custom `OutboxHealthIndicator` that surfaces the relay backlog) — can report degraded without killing or de-pooling anything.
- A custom indicator maps a domain problem to `OUT_OF_SERVICE` (degraded), **not** `DOWN`, and stays out of the readiness group unless the app genuinely can't serve — a relay backlog can still serve requests, so it's root-health-only.
- Health detail is `when-authorized` (an anonymous caller sees only `{"status":"UP"}`, never the `db` component), overridden to `always` under `local`.

## Alerting

Prometheus alert rules (`alert-rules.yml`) — `BackendTargetDown`, `OutboxBacklogHigh`, `HighHttp5xxRate`, `HighRequestLatencyP95`, `JvmHeapHigh` — **every expression over a metric the app actually exports** (thresholds are demo *targets*, not measured SLOs, and I say so). No Alertmanager wired locally — routing to a real destination needs external services + secrets, so it's a documented follow-up. The outbox alert is backed by that `healthcloud.outbox.pending` gauge — the pattern for making a domain signal alertable.

## Backup & restore (the honest bit)

"A backup you've never restored isn't a backup," so I ship a **restore drill**, not just a dump: `db-backup.sh` writes a `pg_dump -Fc` archive; `db-restore-drill.sh` restores into a *scratch* DB, verifies every table's row count matches source vs restored, drops the scratch, and reports PASS/FAIL — all without touching the live DB. The dump includes `flyway_schema_history` so a restored DB passes `validate`. The production RDS equivalent (automated backups + PITR + snapshot restore) is an on-demand follow-up (RDS retention is 0 for cheap teardown).

## Runbooks & RPO/RTO

Operational playbooks in `docs/runbooks/`: an index with the metric → alert → `correlationId`/`traceId` → trace triage workflow, and an `alert-response.md` with a section per alert (each alert rule's `runbook` annotation links to it). On **RPO/RTO** (recovery point/time objectives): I can reason about them — the local drill demonstrates the *mechanism*; the demo box is single-AZ with no backups (RPO/RTO effectively "re-seed from scratch," acceptable for synthetic data), and a real deployment would use RDS automated backups + PITR to hit a real RPO. I'm careful not to quote an RPO/RTO number I haven't measured.

## Interview Q&A

**Q (basic): How would you know if the app is unhealthy in production?**
> "Three signals. Metrics — the app exposes Prometheus metrics for JVM, HTTP, the connection pool, plus domain counters, and there's a Grafana dashboard over them. Traces — it exports spans to Jaeger so I can see where time goes in a request, including a custom span around adjudication. And health probes — a liveness probe for 'is the process alive' and a readiness probe that includes the database so an instance drops out of the load balancer if Postgres is unreachable. On top of that there are Prometheus alert rules for things like the backend being down or latency spiking."

**Q (intermediate): Why split liveness and readiness?**
> "Because they answer different questions and should trigger different actions. Liveness is 'is the process alive' — if it fails, the orchestrator restarts the container, so I keep it process-only; I do *not* want a brief database hiccup to trigger a restart loop. Readiness is 'can I actually serve traffic right now' — it includes the database, so if Postgres is unreachable the instance is pulled out of the load balancer but not killed, and it rejoins when the database is back. And I keep a degraded signal like an outbox backlog on the root health endpoint only, mapped to out-of-service rather than down, because the app can still serve requests with a backlog — I don't want it de-pooled for that."

**Q (intermediate): How do you make sure your dashboards don't show fake data?**
> "It's a hard rule in this project — no unmeasured numbers. Every panel is backed by a metric the app actually exports, and a domain counter that hasn't fired yet uses an `or vector(0)` so it honestly reads zero instead of 'No data' or some made-up value. The alert thresholds are labeled as demo targets, not measured SLOs, because I haven't run the system long enough to have real service-level objectives. I'd rather a dashboard be honestly boring than impressively fake."

**Q (advanced): What's your backup and recovery story, and what's your RPO/RTO?**
> "The important design choice is that I ship a restore *drill*, not just a backup script, because a backup you've never restored isn't really a backup. The drill takes a dump, restores it into a scratch database, verifies every table's row count matches the source, and reports pass or fail — without touching the live database. On RPO and RTO, I'm careful: the drill proves the *mechanism* works, and for real numbers a production deployment would use RDS automated backups and point-in-time recovery to hit a defined RPO. My demo box is deliberately single-AZ with no backups — for synthetic data, 'recovery' is just re-seeding — so I won't quote an RPO or RTO I haven't actually measured."

**Q (advanced): How does a single request get traced across the system?**
> "A correlation-id filter stamps every request with an id — reusing a safe inbound header or generating a UUID — and that id goes into the logging context and is echoed back on the response, so a user can quote it in a bug report and I can grep for it. Separately, Micrometer Tracing plus OpenTelemetry create spans that go to Jaeger, and the trace and span ids are in the same log lines as the correlation id, so I can pivot from a log to the full trace. There's a custom span around adjudication nested under the HTTP span, and because Kafka observation is enabled, the trace context propagates through the event headers, so a claim adjudication and its downstream notification can be connected."

### Remember these points
- Three signals: **Micrometer/Prometheus metrics** (domain counters on **afterCommit**), **Grafana** (measured only, `or vector(0)`), **OTLP → Jaeger tracing** (traceId in logs).
- **Liveness = process-only** (no restart on DB blip); **readiness includes db** (de-pool, don't kill); degraded signals on root health as `OUT_OF_SERVICE`.
- Alerts over **real exported metrics**; thresholds are demo *targets*; no Alertmanager locally (follow-up).
- **Restore drill** (verify row counts in a scratch DB) > a bare backup; RPO/RTO reasoned, not fabricated.
- Correlation id (safe-validated, in MDC + response header) pivots logs → traces.

---

# 23. End-to-end cross-system walkthroughs

> **Synthesis chapter.** These traces tie every layer together. If you can narrate one of these smoothly — frontend → authz → backend → DB → events → audit — you've demonstrated whole-system understanding. Practice saying each aloud in ~60–90 seconds.

## 23.1 Login through an authorized API response

Browser hits the SPA → the SPA calls `GET /api/v1/auth/config` (public) to decide whether to show the Cognito button → user clicks "Sign in," a full-page redirect to `/oauth2/authorization/cognito` → the backend (BFF) redirects to Cognito's hosted login → the user authenticates → Cognito redirects back with a `code` → the backend exchanges it for tokens server-side → `CognitoOidcUserService` checks there's an ACTIVE `AppUser` for that email (else access-denied) → a server-side session is created, browser gets an HttpOnly `SESSION` cookie → the SPA calls `GET /api/v1/me`, which 200s → `UserContextFilter` resolved the email to user/org/roles → the SPA now shows role-appropriate nav. **Every subsequent read** re-derives the context and passes the five authz layers. No token ever touches the browser.

## 23.2 Consent grant, then a masked field flips live

A patient (or coordinator) opens the patient detail page and records a consent directive via `useConsent` → `POST .../consent-directives` (patient write routes through `PatientAccessGuard` → own-record only) → the service supersedes any current directive and inserts version+1 in one transaction → on success the mutation **invalidates the patient query** → TanStack Query refetches → `PatientService.toFieldSafeDto` now asks `ConsentPolicyService.decideForActor` and gets GRANT for the date-of-birth category → the field comes back populated and drops out of `maskedFields` → the UI flips "Restricted" to the real value with no page reload. Revoke is the mirror: flips to REVOKED, next read masks it again.

## 23.3 Cross-tenant denial (the secure 404)

A NorthCare user, authenticated, requests `GET /api/v1/patients/{greenValleyPatientId}` → `UserContextFilter` has their org = NorthCare → the service calls `patients.findByIdAndOrganizationId(id, northCareOrgId)` → no row (it belongs to Green Valley) → `NotFoundException` → **404, identical to a nonexistent id.** The user cannot tell whether the patient exists. `TenantIsolationIntegrationTest` asserts exactly this.

## 23.4 Request creation, assignment, transition

A coordinator creates a service request for a patient (request is patient-gated) → `null → DRAFT` history row written in the same transaction → it's submitted (`DRAFT → SUBMITTED`, the `RequestTransitions` policy validates the move, role and version checked) → triaged → **assignment** via `PUT .../assignment` (the *only* path to `ASSIGNED` — records the assignee *and* advances status atomically; a bare PATCH to ASSIGNED is refused) → each move appends a history row. A provider who isn't assigned to the request's patient gets a secure 404 on the request itself.

## 23.5 Document upload, scan, download

A coordinator uploads a file via multipart `FormData` (CSRF header injected, no explicit content-type so the browser sets the boundary) → `PatientAccessGuard` authorizes → size + content-type validated → bytes stored via `DocumentStorage` (local dir now, S3 in the shape), metadata row written with `scan_status` → the `DocumentScanner` runs (flags EICAR) and sets CLEAN/QUARANTINED → later a download `GET .../documents/{id}/content` re-authorizes through the guard and **only serves a CLEAN file** (else 409 `DOCUMENT_NOT_AVAILABLE`), streaming as an attachment. Bytes never entered a DTO, log, or event.

## 23.6 Multi-line adjudication with partial approval

A reviewer adjudicates an ACCEPTED claim → the engine finds coverage on the service date (`findCovering`) → locks the benefit accumulator (insert-if-absent then `FOR UPDATE`) → classifies each line by precedence (exclusion > OON > auth-required > covered) → the covered lines go to the pure `AdjudicationCalculator` (allowed → copay → deductible → coinsurance → OOP cap), the non-covered lines become denied lines (member owes full charge, no cost-share) → so a claim can be **partially approved**: some lines paid, some `NOT_COVERED`/`AUTH_REQUIRED`/`OUT_OF_NETWORK` → the accumulator is updated, the immutable adjudication + lines written, the claim advanced ACCEPTED → ADJUDICATED with a history row, an audit event and an outbox event, all in one transaction → an afterCommit metric increment.

## 23.7 Appeal and reprocessing with financial adjustment

A member appeals an adjudicated claim → `POST /api/v1/appeals` (validates the claim is appealable, no open appeal exists, denormalizes the patient from the claim) → a reviewer **overturns** it → in the *same transaction* as recording the overturn, `AdjudicationService.adjudicate` re-runs → it **backs out the prior version's accumulator contribution** (reads the prior version's line snapshot, subtracts under the accumulator lock) → recomputes under current config → appends a **new immutable adjudication version** → both the overturn and the re-adjudication commit together. Separately, a plan-config fix can trigger a **reprocessing batch** (`@Transactional(NOT_SUPPORTED)`) that re-adjudicates every affected claim, each in its own transaction, recording per-claim success/failure.

## 23.8 A business event through outbox → Kafka → notification

Adjudication commits, having written a `claim.adjudicated` **outbox row** in the same transaction (PHI-free payload: claim number, version, outcome, money totals) → the `OutboxRelay` poller picks up the committed row, publishes to Kafka (key = claim id, org id in a header), stamps `published_at` → `ClaimAdjudicatedConsumer` receives it, checks `existsByEventId` (idempotent), builds a notification purely from the event (never re-reads the claim) → if it had failed structurally, it'd have gone to `claim.adjudicated.DLT` → drained to `dead_letter_event` → an admin could inspect and replay. At-least-once delivery, effectively-once processing.

## 23.9 Break-glass access and review

A provider hits a patient they're not assigned to → secure 404 → the UI's break-glass panel appears (because the caller is a PROVIDER and got a 404) → they submit a reason → `POST /api/v1/break-glass` loads the patient *directly* by (org, id) — bypassing the relationship gate but not tenancy → writes a grant + `BREAK_GLASS_INVOKED` audit event in one transaction → the mutation invalidates the patient query → the page reloads *with* access, because `PatientAccessGuard` now honors the live grant (relationship layer only — consent/masking still apply). Later an admin sees it on the access-review page (`GET .../break-glass/all`) and can revoke early (`BREAK_GLASS_REVOKED` audit event); the guard filters on expiry AND revocation, so access ends at once.

## 23.10 Deployment, failed release, recovery

CI on `main` runs tests → builds and pushes GHCR images (only because tests passed) → on the EC2 box, `docker compose pull && docker compose up -d` → the new backend container starts, **Flyway runs migrations on boot** → if a migration is bad, **the container fails its health check and doesn't become ready** → because migrations are additive, rolling back to the previous image is schema-compatible (new columns unused) → traffic only ever went to a *ready* instance (readiness includes the DB), so a failed release doesn't serve broken responses. Recovery = repin to the last good `sha-<short>` image.

## Interview Q&A

**Q: Pick any flow and walk me through it end to end.** (Use 23.6 or 23.1 — they touch the most layers.)
> Narrate the adjudication trace (23.6): "A reviewer clicks Adjudicate — that's a POST the backend authorizes by role and patient access. The engine finds the coverage in effect on the service date, then locks the benefit accumulator so concurrent claims can't double-spend the deductible. It classifies each line by precedence — exclusions first, then out-of-network, then prior-auth, then covered — and runs the covered lines through the pure calculator: allowed, copay, deductible, coinsurance, out-of-pocket cap. Non-covered lines become denied lines where the member owes the full charge, so a claim can come out partially approved. Then it updates the accumulator, writes the immutable adjudication and its lines, advances the claim to adjudicated with a history row, and writes an audit event and an outbox event — all in one transaction. After it commits, a metric ticks up, and the outbox row gets published to Kafka and turned into a notification. So one click exercises authorization, the money engine, concurrency control, immutable history, audit, and the event pipeline."

### Remember these points
- Practice **23.1 (login)** and **23.6 (adjudication)** cold — they hit the most layers.
- Every trace touches the same spine: **authz layers → service in a transaction → DB → (audit + outbox in the same tx) → events after commit.**
- The "flips live" (23.2), "secure 404" (23.3), and "break-glass reloads with access" (23.9) moments are memorable — use them.

---

# 24. Hard engineering challenges

> **P0 chapter.** These are the questions that expose shallow understanding. For each: *current behavior first, then label any improvement as a proposal.* Don't bluff — a crisp "here's the honest limitation" beats a confident wrong answer.

**Q: Why does this project actually need Kafka?**
> "Honestly, at its current scale it doesn't strictly need it — an in-process event or a simple job table would work. I introduced Kafka to do two things well: demonstrate the event-driven pattern done correctly — transactional outbox, idempotent consumers, retry, dead-letter, replay — and model the seam where a real system fans out to independent consumers like notifications, analytics, or downstream services that shouldn't be coupled to the adjudication transaction. I'm upfront that it's demonstration-grade here — I even deliberately don't run managed Kafka in the cloud because it's too costly for a portfolio. So the right framing is: the design is production-shape and proven locally, not that the current load demands it."

**Q: Which parts could be simpler?**
> "Several, and being able to say so is the point. The six state machines could be one generic engine — I chose explicit policy classes for readability, but that's a defensible either-way call. Kafka could be an in-process event bus at this scale. The always-on demo doesn't need the full production stack. And the advanced-claims aggregates — anomaly signals, reprocessing — are there to show range, not because a minimal app would need them. What I would *not* simplify away is the five-layer authorization and the accumulator locking — those aren't complexity for its own sake, they're required by the domain's real access rules and real money-correctness needs."

**Q: What would break first under higher load, and how would you measure it?**
> "The database, and specifically two rows I serialize on purpose: the per-organization audit chain head and the per-patient benefit accumulator, both under a pessimistic lock. Under heavy concurrent adjudication — especially many claims for the same patient — writers would queue on those locks. How I'd measure it: I already export HTTP latency histograms and HikariCP connection-pool metrics to Prometheus, so I'd watch p95 on the adjudicate endpoint and pool saturation, and confirm with a Jaeger trace showing time spent waiting on the lock. The key discipline is measure before optimizing. If it were real, I'd relieve the audit-head contention by sharding the chain — say per-org-per-day — while keeping it verifiable, and I'd make sure the accumulator lock is only held for the minimal work."

**Q: Can revocation invalidate an already-issued download URL?**
> "Today, downloads stream through the backend and re-authorize on every request, so a revocation takes effect immediately — the next download attempt is denied. The harder version of the question is about S3 presigned URLs, which I'd use for large files in production: a presigned URL is a time-limited bearer capability, so once issued it works until it expires *regardless* of a later permission or consent change, and it can even be forwarded. So the honest answer is: with backend streaming, yes, revocation is immediate; with presigned URLs, no — not until expiry. The mitigation is short expiries, or keeping the most sensitive downloads proxied through the backend so authorization is checked on every byte."

**Q: What happens if permissions change between checking access and using the data (time-of-check to time-of-use)?**
> "Within a single request it's not an issue, because the access check and the data use are in the same transaction against a consistent snapshot. Across requests, access is re-derived fresh every time from the current session and current database state — I don't cache authorization on the server between requests — so a revoked consent or ended assignment is reflected on the very next request. The genuinely hard case is a long-running operation, like a reprocessing batch, where permissions could change mid-run; there, each claim's re-adjudication is its own transaction that re-checks, so it converges on the current state rather than acting on a stale snapshot for the whole batch."

**Q: Can two claims consume the same remaining deductible?**
> "No — that's exactly what the accumulator lock prevents. There's one accumulator row per patient, plan, and benefit year. Before computing, the engine ensures the row exists with an insert-if-absent, then takes a pessimistic write lock on it inside the adjudication transaction. So if two adjudications for the same patient race, the second blocks until the first commits and then reads the first's updated deductible-met. They serialize on that row, so the last hundred dollars of deductible can't be double-spent. I chose a pessimistic lock over optimistic specifically because it's a hot row where I *expect* contention, and an optimistic retry loop would just thrash."

**Q: The relay publishes to Kafka but the process crashes before it records success. What happens?**
> "The outbox row still has a null published-at, so it looks pending, and the next poll re-publishes it. The consumer then sees the event a second time and dedupes it — it checks whether it already recorded that event id, with a unique constraint as a backstop for the concurrent-duplicate case. So the visible outcome is at-least-once delivery, effectively-once processing. This is precisely why the design is at-least-once plus idempotent consumers rather than pretending to be exactly-once — a crash between publish and mark is a *when*, not an *if*, and the system is built to make it harmless."

**Q: Can duplicate notifications still happen?**
> "For my consumer, no visible duplicate, because its side effect is an idempotent database insert keyed on the event id — a second delivery is a no-op. The honest caveat is that idempotency lives in the *consumer's* side effect, not in Kafka. If the side effect were something non-idempotent like sending an email, then a redelivery *could* produce a duplicate email, because Kafka can't make an external send idempotent for me. So my current notification feed is safe by construction, and if I added email I'd need a dedupe store or an outbox on the send itself."

**Q: What does an HMAC audit chain fail to protect against?**
> "It's tamper-evident, not tamper-proof — it doesn't stop edits, it makes them detectable when someone runs verify, so undetected tampering is possible until verification runs. It doesn't help against an attacker who also has the master secret — they could recompute a valid chain, so the whole scheme depends on that key living outside the database, in config or KMS, out of reach of whoever can write the table. It can't reveal an action that was never logged in the first place — which is why I write the audit event inside the same transaction as the action. And it's single-party; for true non-repudiation I'd periodically anchor the head hash somewhere external and append-only. So it's a strong integrity control with clearly bounded guarantees."

**Q: Can a denial audit record disappear during a rollback?**
> "It can't get out of sync, because the audit write joins the same transaction as the action it records — `AuditService.record` isn't independently transactional, it enlists in the caller's transaction. So the audit event and the domain change commit together or roll back together. You never get a committed action with a missing audit event, or a committed audit event for an action that rolled back. If a transaction rolls back, both the action and its audit record vanish together — which is correct, because the action didn't happen."

**Q: How could tenant isolation fail in a worker or an export?**
> "Those are exactly the sneaky places, so I designed for them. In the event path, the Kafka events carry the organization id in a header and are deliberately PHI-free, so a consumer scopes to that org and even a misrouted event leaks nothing sensitive. In the export path, the CSV export calls the *same* tenant-scoped, consent-masked service read the JSON API uses — not a second query — so it can't become a back door around tenancy or masking; a masked date of birth exports as a blank cell. The honest general risk is that a *future* worker or export written carelessly could bypass the org scoping, and that's the strongest argument for adding database Row-Level Security — so the tenant filter is enforced by the database and can't be forgotten in a new code path."

**Q: What if a migration succeeds but the deployment fails afterward?**
> "Migrations run on app startup, so the sequence is: the new container starts, Flyway migrates, then the app finishes booting and passes its health check before traffic is routed to it. If the *app* fails after a successful migration, the instance never becomes ready, so the load balancer never sends it traffic — the old instances keep serving. Because I keep migrations additive and forward-only, the previous image is still schema-compatible with the migrated database — the new columns just go unused — so rolling the app back is safe without a schema rollback. The thing I can't do trivially is undo the migration itself; for that I'd write a compensating forward migration rather than a down-migration."

**Q: How would the system change for real sensitive data, many more tenants, or stricter availability?**
> "Different answers for each, and I'd label them as proposals. For real PHI: add Postgres Row-Level Security so tenant isolation is database-enforced not just discipline, move the audit master secret into KMS/HSM, enforce MFA, add real malware scanning and encryption-at-rest everywhere, sign a BAA, and do a proper risk assessment — the patterns are there, the compliance work isn't. For many more tenants: I'd revisit shared-DB tenancy — likely keep shared DB but add RLS and connection pooling per tenant, or move very large tenants to their own database, and I'd shard the hot rows like the audit head. For stricter availability: multi-AZ RDS with automated backups and PITR, autoscaling Fargate across AZs behind the ALB, a real managed Kafka cluster, and extracting the outbox relay and consumers into a separately deployed, horizontally scaled worker using `FOR UPDATE SKIP LOCKED`. Today's system demonstrates the shapes; those are the concrete steps to production-grade."

### Remember these points
- **Current behavior first, proposals labeled.** Honesty about limits reads as senior.
- Kafka = demonstration-grade + fan-out seam, not a scale necessity; simplifiable parts named freely; **don't** simplify away authz layering or accumulator locking.
- First bottleneck = **DB hot rows (audit head, accumulator)**; measure via latency histograms + Hikari metrics + traces before optimizing.
- Revocation: **immediate with backend streaming, not until expiry with presigned URLs**.
- Deductible double-spend: prevented by the **pessimistic accumulator lock**.
- Publish-crash: at-least-once + **idempotent consumer** → harmless; duplicates only if the side effect is non-idempotent (e.g. email).
- HMAC chain: tamper-**evident** not proof; useless if attacker has the secret; can't show un-logged actions.
- Audit + action **share a transaction** → never out of sync.
- Isolation risk lives in **workers/exports** → export reuses the masked read; **RLS** is the real fix.
- Migration-then-deploy-fail: readiness gate + additive migrations → safe app rollback.
- Real-data / many-tenants / HA answers: **RLS, KMS, MFA; per-tenant/sharded DB; multi-AZ + autoscale + real Kafka + extracted worker.**

---

# 25. Ownership & AI-assisted development

> **A make-or-break chapter.** Interviewers increasingly ask "how much of this did *you* do?" The winning posture is **calm, specific honesty**: you directed the design, you understand every piece, you reviewed and tested the output, and you can change it without the AI. Don't hide the AI, and don't let it diminish your ownership.

## The honest, confident framing

The truthful story — and the one that reads best — is: *"I built HealthCloud with Claude Code as a pair-programmer. I made the architectural decisions, I drove it one verified slice at a time, and I reviewed, ran, and tested everything before it counted as done. The AI accelerated the typing and the boilerplate; the judgment — what to build, how to structure it, where the security boundaries go, what to simplify — was mine. I can walk through any of this code and change it without the AI, and this handbook is partly proof I made sure I understand it."*

Notice what that does: it neither pretends the AI wasn't involved (which collapses under one probing question) nor treats "AI-assisted" as a confession (it's just modern tooling). It centers *your* judgment and *your* understanding.

## Answers to the specific ownership questions

**Q: What did you personally design and implement?**
> "I made the architecture calls — a modular monolith over microservices, shared-DB multi-tenancy with a secure-404, the five-layer authorization pipeline, the transactional outbox, the pessimistic-lock accumulator for money correctness, the HMAC audit chain. I decided the phase order and scope, what to keep synthetic, and where to stop — like not running managed Kafka in the cloud for cost. The implementation was AI-accelerated, but the shape of every subsystem and the decision of what each slice should do was mine."

**Q: How did Claude Code help?**
> "It was a fast pair-programmer. I'd decide what a slice should do and how it should fit the existing patterns, and it would draft the code, the migration, and the tests, and we'd iterate. It was especially useful for the repetitive parts — the eighth work queue follows the same pattern as the first — and for surfacing framework specifics on a bleeding-edge stack like Spring Boot 4 and Jackson 3. But it worked inside constraints I set, in a written rulebook the project carries, so it stayed consistent with the architecture across weeks."

**Q: How did you review and validate generated code?**
> "The loop was: plan a small slice, build it, *verify it* — run it and run the tests — then commit, one slice at a time, never multiple phases at once. Nothing counted as done until its acceptance criterion passed, especially the negative security tests. I also ran code and security reviews on the changes. So the AI didn't get to 'merge' anything unverified — I treated its output like a teammate's PR that I'm responsible for."

**Q: Which decisions did you make yourself?**
> "All the consequential ones. Monolith vs microservices. Secure-404 vs 403. Pessimistic vs optimistic locking on the accumulator. Outbox instead of a direct Kafka publish. HMAC-with-external-secret for the audit chain. Consent as deny-by-default with most-specific-tier-wins. Keeping the medical-code catalog global instead of tenant-scoped. No NAT gateway to save cost. Synthetic data and HIPAA-aligned-not-certified as a hard boundary. Those are judgment calls, and I can defend each one and its alternatives."

**Q: What mistakes did you catch?**
> "A few real ones. An audit-budget-style bug where a config update silently flipped a cost setting — I caught it by re-verifying the value rather than trusting the change went in. A `.gitignore` that swallowed a source folder because a bare directory name matches anywhere in the tree — the build worked locally but would've broken CI. A logo asset that got committed fully transparent because of a bad image edit. And the classic OTLP-endpoint rename in Spring Boot 4 where spans were created but silently never exported. Catching those is exactly the review discipline that matters when you work with an AI."

**Q: What can you explain or change independently? / Can you walk through this code without AI?**
> "Yes. Pick any file — the access guard, the adjudication calculator, the outbox relay, the audit chain — and I'll walk you through what it does, why it's structured that way, and how I'd change it. This handbook exists partly because I made sure I could do that. If you want, give me a small change — add a new field-masked field, add a new state to a workflow, add a new domain event — and I'll tell you exactly which files I'd touch and in what order."

**Q: What would you do differently?**
> "A handful. I'd add Postgres Row-Level Security from the start, so tenant isolation is database-enforced rather than repository discipline plus tests — it's my top hardening item. I'd wire the security scanners (CodeQL, Dependabot, Trivy) into CI earlier. I'd add a Playwright end-to-end accessibility gate. And I might have built one generic workflow engine instead of six state-machine policy classes, though I still think the explicit version is more readable. None of those are architectural regrets — they're refinements."

## Behavioral (STAR) stories — scaffolds you must personalize

Use STAR *for study*, but **speak the answer naturally without announcing the labels.** These scaffolds are grounded in real events from the project; the *feelings/motivation* parts need your own words (see "Needs My Confirmation").

**Story A — A debugging win (the outbox/OTLP-style silent failure).**
- **Situation:** I'd wired up distributed tracing, and spans were being created but never showing up in Jaeger.
- **Task:** figure out why traces silently vanished with no error.
- **Action:** I traced it methodically — confirmed spans existed, then checked the exporter config, and found that Spring Boot 4 had *renamed* the OTLP tracing endpoint property, so my Boot-3-style config was being silently ignored. I fixed the property name and verified a trace end to end.
- **Result:** tracing worked, and I wrote the gotcha into the project's rulebook so it couldn't bite again. The lesson: "no error" doesn't mean "correct config," especially on a new major version.

**Story B — A correctness decision under a trade-off (the accumulator lock).**
- **Situation:** the deductible and out-of-pocket max have to carry across a patient's claims, and two claims could be adjudicated concurrently.
- **Task:** guarantee two claims can't double-spend the same remaining deductible.
- **Action:** I chose a pessimistic row lock on a per-patient-per-plan-per-year accumulator, with an insert-if-absent first so the row always exists to lock, all inside the adjudication transaction — deliberately over optimistic locking, because it's a hot row where a retry loop would thrash.
- **Result:** concurrent adjudications serialize correctly; the accumulator tests prove the deductible carries. The lesson: pick the locking strategy from the *expected* contention, not a default.

**Story C — Scope discipline / keeping it honest.**
- **Situation:** it's tempting to claim big performance or availability numbers on a portfolio project.
- **Task:** keep every claim defensible.
- **Action:** I adopted a hard "no unmeasured claims" rule — I label things target vs measured, I say HIPAA-aligned not certified, and I tore down the expensive cloud stack rather than pretend it's always-on, keeping a cheap honest live demo instead.
- **Result:** everything in the project is defensible under scrutiny. The lesson: in a domain like healthcare, credibility comes from honesty about boundaries, not from inflated numbers.

**Story D — An AI-assisted-development reflection.**
- **Situation:** I built a large system with an AI pair-programmer.
- **Task:** get the acceleration without losing understanding or letting quality slip.
- **Action:** I worked in small verified slices, kept a written rulebook the AI read every session, verified and tested before committing, and ran review passes — treating AI output like a teammate's PR I'm accountable for.
- **Result:** a ~700-test system I can explain and modify line by line. The lesson: AI changes *how fast* you build, not *whether you're responsible* for what you ship.

## Common mistakes to avoid (ownership questions)

- **Don't over-claim** ("I wrote every line myself") — it's brittle and unnecessary.
- **Don't under-claim** ("the AI did it") — you made the decisions; say so.
- **Don't get defensive** — "AI-assisted" is just tooling; treat the question as neutral.
- **Do offer to prove it** — "give me a small change and I'll tell you which files I'd touch" is the strongest possible move.

### Remember these points
- Framing: **"I directed the design and understand every piece; the AI accelerated the typing; I reviewed and tested everything and can change it without the AI."**
- Have 2–3 concrete **decisions you made** and 2–3 **bugs you caught** ready — specificity is credibility.
- STAR stories A–D are real; **personalize the motivation** (Ch. 31).
- The killer move: **offer to make a small change live** and name the files.
- Neither over- nor under-claim; stay calm and specific.

---

# 26. Practical exercises

> Do these **before** reading the solutions in [Ch. 30](#30-exercise-solutions). They force you to trace real code, predict behavior, and design small changes — which is exactly what a good interviewer probes. Try to answer out loud or on paper first.

## Trace-the-code

**E1.** A `PROVIDER` who is *not* assigned to patient X calls `GET /api/v1/patients/{X}`. Trace every layer the request passes through and state the exact HTTP status and why. Then: the same provider invokes break-glass on X and retries — what changes and what stays the same?

**E2.** Trace `AdjudicationService.adjudicate` for a claim in `DRAFT` state. Where does it stop, and what error/status comes back?

**E3.** Two adjudications for the *same* patient/plan/year start at nearly the same instant. Describe the exact sequence of database operations (insert-if-absent, lock, read, compute, update, commit) for both, and prove the deductible can't be double-spent.

## Predict-the-behavior

**E4.** Plan: deductible $1000, coinsurance 20%, copay $30, no OOP max. Accumulator: deductible met $900. One covered line, charge $500, fee-schedule allowed $400. Compute allowed, copay, deductible-applied, coinsurance, member, plan-paid, and the new `deductibleMet`. (Show your work; scale 2, HALF_UP.)

**E5.** A patient has consent granting `CARE_TEAM` access to demographics but a `PROVIDER`-tier *deny* for one specific provider on the same category. That specific provider (who is on the care team) reads the patient. Is the date of birth masked? Why?

**E6.** The outbox relay publishes a `claim.adjudicated` event to Kafka, then the JVM is killed before `published_at` is stamped. Predict what happens on the next poll and what the consumer does. Is a duplicate notification created?

**E7.** An auditor edits one `detail` field directly in the `audit_event` table (via raw SQL) and leaves everything else. What does `GET /api/v1/audit-events/verify` report, and exactly why?

## Explain-the-test

**E8.** `TenantIsolationIntegrationTest` logs in as a NorthCare user and requests a Green Valley patient. What status does it assert, and why is asserting *404 specifically* (not 403) the whole point of the test?

**E9.** Why does a state-changing integration test have to call `GET /me` before its `POST`? What would happen if it didn't?

## Identify-the-failure-path

**E10.** A malformed `claim.adjudicated` message (bad JSON payload) arrives at the consumer. Trace where it ends up and why it does *not* block the partition. How would an operator recover it?

**E11.** Someone adds a new endpoint `GET /api/v1/patients/{id}/vitals` and loads the patient with a bare `patientRepository.findById(id)` (no org, no guard). Name two distinct things that could now go wrong, and the one change that would have prevented both.

## Design-a-small-change

**E12.** You need to add a new consent-controlled patient field, `phoneNumber`, that should be masked exactly like `dateOfBirth`. Which files do you touch, in what order, and what test do you add?

**E13.** Add a new claim line outcome, `EXPERIMENTAL_DENIED` (procedure flagged experimental by the plan → member owes full charge, like an exclusion). Where does the precedence go, what enum/DB changes are needed, and does the calculator change?

**E14.** Product wants providers to search claims by *patient name*, not just claim number. Explain why the current design deliberately doesn't allow this, and what you'd have to add to do it *safely* if it were truly required.

---

# 27. Mock interviews

> Four mocks matching real formats. **Questions first, then answers** — cover the answers and try each cold, then compare. These recombine material from across the handbook under time pressure.

## Mock A — Recruiter / phone screen (questions)

A1. Tell me about a project you're proud of.
A2. What was your role?
A3. What's the tech stack?
A4. What was the hardest part?
A5. Is it deployed anywhere I can see it?
A6. Did you use AI to build it?

## Mock A — Answers

> **A1:** "HealthCloud — a multi-tenant healthcare care-coordination and claims platform, built on synthetic data. The two things I'm proudest of are a five-layer consent-aware authorization model, where access depends on your relationship to a patient and their consent, not just your role, and a deterministic insurance-claims engine that can explain exactly how every dollar of a decision was computed."
>
> **A2:** "I designed and built it end to end, with Claude Code as a pair-programmer. I made the architecture decisions and drove it slice by slice, verifying and testing each piece; the AI accelerated the implementation."
>
> **A3:** "Spring Boot and Java on the backend, React and TypeScript on the front, PostgreSQL, Kafka for events, deployed on AWS with Terraform. Around 700 automated tests."
>
> **A4:** "Getting authorization right, because healthcare access is genuinely complex — two people with the same role can legitimately need different access. I built it as five independent backend checks including patient consent and per-field masking."
>
> **A5:** "Yes — there's a live demo I can send a link to, running the app on AWS. The full production-shape architecture is also in Terraform; I run the live link cheaply on a single box to keep it always-on."
>
> **A6:** "Yes, as a pair-programmer. I made the design calls, reviewed and tested everything, and I can walk through and change any part of it without the AI — that was a deliberate goal."

## Mock B — Technical deep-dive (questions)

B1. Walk me through the architecture.
B2. How does authorization work, concretely?
B3. Why 404 and not 403 for cross-tenant access?
B4. Explain the adjudication engine's calculation order.
B5. Two claims race on the same deductible — what stops a double-spend?
B6. Why an outbox instead of publishing to Kafka directly?
B7. Your audit chain — what does it *not* protect against?
B8. What breaks first under load, and how would you know?

## Mock B — Answers
Use, respectively: Ch. 3 Q1 · Ch. 6 Q "walk me through" · Ch. 4 Q "secure 404" · Ch. 10 Q "calculation order" · Ch. 10 Q "double-spend" · Ch. 15 Q "why outbox" · Ch. 14 Q "what does it NOT protect" · Ch. 3/24 Q "breaks first." Practice stringing B1→B8 as one escalating conversation — that's how a real deep-dive flows, each answer inviting the next follow-up.

## Mock C — System design (questions)

> Framed as "design a system like the one you built."
C1. Design a multi-tenant healthcare claims platform. Start with requirements.
C2. How do you isolate tenants?
C3. How do you model authorization when access depends on relationships and consent?
C4. How do you keep money math correct and explainable?
C5. How do you notify downstream systems when a claim is adjudicated, reliably?
C6. Now scale it to 100× the tenants and require 99.9% availability. What changes?

## Mock C — Answers (sketch — say these as a flowing design conversation)

> **C1:** "I'd clarify requirements first: multiple healthcare orgs sharing the system, strict data isolation, complex per-patient access rules including consent, claims adjudicated by explainable rules, and an audit trail. Reads and writes are synchronous; downstream reactions can be async. I'd pick a modular monolith to start — the domains are tightly coupled around the patient and money, and I want atomic transactions across them."
>
> **C2:** "Shared database with an organization-id tenant key, every query scoped by the org derived from the session, never the client. Cross-tenant access returns a secure 404 so existence doesn't leak. For real isolation guarantees I'd add Postgres Row-Level Security so the tenant filter is database-enforced."
>
> **C3:** "A layered pipeline where each layer only narrows: tenant, then role, then the object relationship — is this provider actually assigned to this patient — then consent-and-purpose, deny-by-default, then field-level masking. One shared guard class as the single choke point so no endpoint can skip it. Consent is versioned so I can reconstruct the state at any past date."
>
> **C4:** "A pure, deterministic calculator — allowed, copay, deductible, coinsurance, out-of-pocket cap — with all money in BigDecimal, and I store the full immutable breakdown per decision so it's explainable and re-adjudication appends a version. Deductibles carry across claims via a per-patient accumulator row that I update under a pessimistic lock so concurrent claims can't double-spend it."
>
> **C5:** "Transactional outbox: write the event to the same database in the same transaction as the adjudication, then a relay publishes committed rows to Kafka. At-least-once delivery with idempotent consumers, retries with backoff, a dead-letter topic for poison messages, and a replay path. Events are PHI-free with the org id in a header."
>
> **C6:** "At 100× and 99.9%: add RLS and consider per-tenant or sharded databases for the largest tenants; shard the hot serialized rows like the audit chain head; move to multi-AZ RDS with automated backups and point-in-time recovery; autoscale the app across AZs behind the load balancer; run a real managed Kafka cluster; and extract the outbox relay and consumers into a separately deployed, horizontally scaled worker using `FOR UPDATE SKIP LOCKED` so multiple relays don't double-publish. I'd drive all of that from the latency and pool metrics I already export."

## Mock D — Behavioral (questions)

D1. Tell me about a hard bug you solved.
D2. Tell me about a technical decision with a real trade-off.
D3. Tell me about a time you kept scope or quality honest under pressure.
D4. How do you make sure you understand code you didn't write from scratch?
D5. What would you do differently on this project?

## Mock D — Answers
Use the STAR stories from Ch. 25: D1 → Story A (OTLP silent failure), D2 → Story B (accumulator lock), D3 → Story C (no-unmeasured-claims), D4 → Story D (AI-assisted discipline), D5 → Ch. 25 "what would you do differently." Speak them naturally, no "situation/task" labels out loud, and end each with the one-line lesson.

### Remember these points
- Recruiter mock: lead with the two differentiators, keep it warm, land the AI question calmly.
- Deep-dive mock: **B1→B8 is one escalating conversation** — rehearse the chaining, not just isolated answers.
- System-design mock: **requirements first**, then isolation → authz → money → events → scale. Narrate, don't list.
- Behavioral mock: STAR for *study*, natural speech for *delivery*; always end on the lesson.

---

# 28. Quick-revision material

> The day-before pages. Skim these, not the whole handbook.

## Must-know cold (P0 fact sheet)

- **What it is:** multi-tenant healthcare care-coordination + claims platform, **synthetic data only**, HIPAA-*aligned* not certified.
- **Two differentiators:** (1) five-layer consent-aware authorization; (2) deterministic, explainable adjudication engine.
- **Five authz layers, in order:** tenant → role → relationship → consent+purpose → field masking; each only *narrows*; one `PatientAccessGuard` choke point.
- **Secure 404** for cross-tenant / unauthorized object access — never 403 (don't leak existence).
- **Multi-tenancy:** shared DB, `organization_id` on every tenant row, org derived from **session** not client.
- **Auth:** Cognito OIDC auth-code, backend is the **BFF**, server-side session (Spring Session JDBC), HttpOnly cookie, CSRF double-submit. Cognito = identity only; roles from our DB.
- **Adjudication order:** allowed → copay → deductible → coinsurance → OOP cap → plan pays the rest; **BigDecimal scale 2 HALF_UP**; pure calculator.
- **Accumulator:** per (patient, plan, year); insert-if-absent then **pessimistic `SELECT … FOR UPDATE`** → no deductible double-spend.
- **Events:** dual-write problem → **transactional outbox** → relay → Kafka → **idempotent** consumers → retry/backoff → **DLT** → replay. **At-least-once, effectively-once.**
- **Audit:** per-org **HMAC-SHA256 hash chain**, key derived from a secret **outside the DB**; tamper-**evident**; audit write **joins the caller's transaction**.
- **One transaction per change:** domain row + history + audit + outbox commit together.
- **Stack:** Java 25, Spring Boot 4.1, React 19/TS 6/Vite 8, PostgreSQL 17, Kafka, Terraform/AWS.
- **Scale:** 43 Flyway migrations, 30 backend packages, **694 tests (511 backend / 183 frontend, measured 2026-09-24)**.

## Decisions & trade-offs sheet (problem → choice → why → cost → when to revisit)

| Decision | Chose | Why | Cost / when I'd revisit |
|---|---|---|---|
| Service split | Modular monolith | Atomic cross-domain transactions; simple to run | No independent scaling → extract a module if one needs it |
| Tenancy | Shared DB + tenant key | Cheap, simple, shared reference data | Discipline+tests, not DB-enforced → add **RLS** / DB-per-tenant for real data |
| Object denial | Secure 404 | Don't leak existence | Slightly less "helpful" errors — correct trade |
| Auth tokens | Server-side session (BFF) | XSS-safe, revocable | Stateful → needs shared session store (have it, in Postgres) |
| Accumulator | Pessimistic lock | Hot row, expected contention, no double-spend | Reduced concurrency on that row → shard if it's the bottleneck |
| Other mutable rows | Optimistic `@Version` | Conflicts rare | Retry on 409 conflict |
| Events | Transactional outbox | Solves dual-write | Single-instance relay → `FOR UPDATE SKIP LOCKED` to scale out |
| Delivery | At-least-once + idempotent | Exactly-once is a myth across a side effect | Non-idempotent side effects need their own dedupe |
| Audit integrity | HMAC chain, external key | Forge-resistant, tamper-evident | Not tamper-proof; external anchoring for non-repudiation |
| Consent default | Deny-by-default | Fail closed on privacy | Needs seeded directives for the happy path |
| Adjudication rules | Hand-written pure calculator | Deterministic + explainable + testable | Rules engine/table if benefit rules explode |
| Medical codes | Global, not tenant-scoped | Public national standards | — (correct as-is) |
| Cloud always-on | 1 EC2 box, not ECS | ~$15 vs ~$70/mo | Single-AZ, no backups → the ECS shape for real HA |
| Cloud egress | No NAT gateway | Save ~$32/mo | Public-subnet Fargate; fine here |
| Kafka in cloud | None (local only) | MSK too costly | Real managed Kafka at scale |

## Glossary (with a HealthCloud example each)

- **Tenant** — an org; NorthCare. **Secure 404** — cross-tenant read returns "not found," not "forbidden."
- **BFF** — the Spring backend holds the session so the browser holds no token.
- **Deny-by-default consent** — DOB is masked unless a directive grants it.
- **Purpose of use** — read purpose is fixed to CARE_COORDINATION on the backend.
- **Supersede pattern** — changing consent inserts a new version, marks the old superseded.
- **Optimistic lock** — a claim edit with a stale `expectedVersion` → 409.
- **Pessimistic lock** — `SELECT … FOR UPDATE` on the accumulator during adjudication.
- **Accumulator** — the per-patient row tracking deductible-met / OOP-met across claims.
- **Allowed amount** — `min(fee-schedule, charge)`; the split is computed off this.
- **Coinsurance** — member's % share after deductible.
- **OOP max** — once met, the plan pays 100%.
- **Transactional outbox** — event row written in the same DB transaction as the change.
- **Idempotent consumer** — dedupes on `event_id` so a redelivered event is a no-op.
- **DLT** — dead-letter topic where poison messages go instead of blocking the partition.
- **HMAC hash chain** — each audit row's fingerprint covers the previous one; edits cascade.
- **Break-glass** — a provider's time-boxed emergency access, reason-recorded and audited.
- **§60 proof** — claim carries codes, no narrative; the narrative is consent-masked.

## Verified numbers (only quote these)

- **694 tests** total (**511 backend**, **183 frontend across 40 files**), measured on a full-suite run **2026-09-24**.
- **43** Flyway migrations. **30** backend domain packages. ~103 backend test files.
- **Load test (from evidence, single-node, local — NOT an SLA):** the captured k6 run — roughly **~107 req/s, p95 ~38 ms, 0% errors @ 50 VUs** on the authenticated read path. Always frame as local/single-node.
- **Cost:** EC2 demo ~**$15/mo**; on-demand ECS stack ~**$72/mo** (destroyed). $100 sign-up credits + $100 earned.
- Everything else: if you didn't measure it, say "I didn't measure that; here's how I would."

## Last-day review guide (in order)

1. Re-read this chapter (28) — the fact sheet and trade-off table.
2. Say the **30/90-second pitch** out loud twice (Ch. 1).
3. Whiteboard the **adjudication 2-line example** (Ch. 10) once from memory.
4. Say the **five authz layers** and the **secure-404 reason** out loud (Ch. 6).
5. Say the **outbox → at-least-once → idempotent** chain (Ch. 15).
6. Say what the **HMAC chain does NOT protect against** (Ch. 14/24).
7. Rehearse the **AI-ownership framing** (Ch. 25).
8. Skim the **hard-challenges** answers (Ch. 24) — just the "Remember these points."
9. Sleep. You know this.

---

# 29. Self-assessment rubric

Rate yourself 1–5 on each before an interview. Anything ≤3 → re-study the linked chapter.

| Dimension | 1 (weak) | 3 (okay) | 5 (strong) | Chapter |
|---|---|---|---|---|
| **Accuracy** | I state things I'm unsure of | Mostly right, some hand-waving | Every claim is precise; I say "didn't measure" when true | all |
| **Clarity** | Rambling, jargon-first | Understandable with effort | Direct answer → mechanism → example → trade-off, naturally | 1, 27 |
| **Depth** | Surface features only | Can explain the how | Can explain the *why*, alternatives, and limits | 6, 10, 14, 15, 24 |
| **Evidence** | "It just works" | Vague references | I cite the class/file and can open it | all "code refs" |
| **Follow-up handling** | One question deep | Two deep | I welcome adversarial follow-ups and stay honest about gaps | 24 |
| **Ownership** | Over- or under-claims AI | Defensive | Calm, specific; offers to make a change live | 25 |
| **Trade-off fluency** | "I used X" | Knows one alternative | Problem→choice→alternatives→cost→when-to-revisit | 28 |

**Green-light check:** you can (a) pitch it in 90 seconds, (b) whiteboard the adjudication example, (c) name the five layers and why secure-404, (d) explain the outbox and idempotency, (e) state the HMAC chain's limits, and (f) answer the AI question without flinching. If all six are yes, you're ready.

---

# 30. Exercise solutions

> Compare against your own attempts from [Ch. 26](#26-practical-exercises). If you got the *reasoning* right, minor wording differences don't matter.

**E1 (trace: unassigned provider reads a patient).** Filters run: correlation-id → Spring Security (session authenticated) → `UserContextFilter` sets org+roles. The service calls `PatientAccessGuard.requireAccessibleInTenant(X)`: it loads the patient by `(org, X)` (tenant layer — passes, same org), then because the caller is provider-gated and *not* actively assigned and has *no* live break-glass grant, it throws `NotFoundException` → **404** (secure 404, identical to a nonexistent patient). After break-glass: the provider `POST /api/v1/break-glass` with a reason → grant + `BREAK_GLASS_INVOKED` audit written in one tx → on retry, the guard's `hasActiveBreakGlass` is now true, so the relationship layer passes and the read proceeds. **What stays the same:** tenant isolation and consent/field-masking still apply — break-glass overrides *only* the relationship layer, so a consent-masked DOB is still masked.

**E2 (adjudicate a DRAFT claim).** `AdjudicationService.adjudicate` loads the claim (patient-gated), then checks its status: adjudication is only legal from `ACCEPTED` (first) or `ADJUDICATED` (re-adjudication). `DRAFT` is neither → `InvalidStateTransitionException` → **409 `INVALID_STATE_TRANSITION`**. Nothing is written.

**E3 (two concurrent adjudications, same patient/plan/year).** Both call `accumulators.insertIfAbsent(...)` — the first inserts the row, the second's `ON CONFLICT DO NOTHING` is a no-op; either way the row now exists. Both then attempt `lockByKey` (`SELECT … FOR UPDATE`). One acquires the lock; the other **blocks**. The winner reads `deductibleMet`, computes, `add()`s its contribution, saves, and commits — releasing the lock. Only *then* does the loser acquire the lock and read the **updated** `deductibleMet`, so its deductible step sees the reduced remaining amount. They serialize; the same dollars can't be applied twice. (Both are inside the adjudication transaction, so the lock is held until commit.)

**E4 (compute).** remainingDeductible = 1000 − 900 = 100.
- allowed = min(400, 500) = **400**
- copay = min(30, 400) = **30**; afterCopay = 370
- deductibleApplied = min(100, 370) = **100** → remaining 0; afterDeductible = 270
- coinsurance = 270 × 0.20 = **54.00**
- member = 30 + 100 + 54 = **184.00** (no OOP cap)
- planPaid = 400 − 184 = **216.00**
- new deductibleMet = 900 + 100 = **1000 (met)**
(Note the write-off: charge 500 − allowed 400 = $100 nobody pays.)

**E5 (consent tier conflict).** **Masked.** Most-specific-tier-wins: the `PROVIDER`-tier directive is more specific than the `CARE_TEAM`-tier grant, and it's a *deny*, so it decides → DENY. Even though the provider is on the care team, the more specific per-provider deny governs, so the date of birth is masked.

**E6 (relay crash before stamping).** The outbox row's `published_at` is still null, so the next poll re-fetches and **re-publishes** it. The consumer receives the event again, `existsByEventId` returns true (it recorded it the first time), so it **skips** — and the `UNIQUE(event_id)` constraint is the backstop if two deliveries raced. **No duplicate notification** — at-least-once delivery, effectively-once processing.

**E7 (raw edit of one `detail` field).** `verify` walks the chain recomputing each `entryHash` from the row's canonical fields (which include `detail`). For the tampered row, the recomputed HMAC no longer equals the **stored** `entryHash` → it reports **broken at that sequence** with an entry-hash-mismatch reason. The attacker can't fix the stored hash to match, because the per-org HMAC key is derived from a secret held outside the database. (Subsequent rows' `prevHash` links still line up with the *stored* hashes, so the break is pinpointed at the edited row, not cascaded falsely.)

**E8 (`TenantIsolationIntegrationTest`).** It asserts **404**. Asserting 404 *specifically* is the whole point: a 403 would confirm the Green Valley patient exists, which is itself a disclosure. Proving it's a 404 — indistinguishable from a nonexistent id — proves the isolation doesn't leak existence, which is the actual security property.

**E9 (why `GET /me` before a `POST`).** To do the CSRF handshake: `GET /me` returns the readable `XSRF-TOKEN` cookie, which the test then echoes as the `X-XSRF-TOKEN` header on the `POST`. Without it, the state-changing request has no CSRF token and Spring Security rejects it with a **403** — the test would fail at the security layer before reaching the controller.

**E10 (malformed payload).** A bad JSON payload throws a `JacksonException`, which `KafkaConsumerErrorConfig` registers as **non-retryable**, so the `DefaultErrorHandler` sends it **straight to `claim.adjudicated.DLT`** with no retries. It doesn't block the partition because the record is routed off and the offset advances. Recovery: `DeadLetterDrainer` has already drained it into the `dead_letter_event` table; an operator lists it via `GET /api/v1/dead-letter-events`, fixes the underlying bug, and calls `POST .../{id}/replay` to re-drive it onto the source topic (safe because the consumer is idempotent).

**E11 (bare `findById`, no org, no guard).** Two things go wrong: (1) **tenant isolation breaks** — a user could read another org's patient vitals, because the load isn't scoped by org; (2) **the relationship/consent gate is bypassed** — an unassigned provider (or any authenticated user) reads vitals they shouldn't. The one change that prevents both: route the load through **`PatientAccessGuard.requireAccessibleInTenant(id)`**, which loads by `(org, id)` *and* applies the relationship layer — restoring both the secure-404 tenancy check and the assignment gate in one call. (Field masking would still be handled in the DTO, but the guard closes the two big holes.)

**E12 (add a masked `phoneNumber`).** Order: (1) if the column doesn't exist, a Flyway migration to add it; (2) add `PHONE_NUMBER("phoneNumber", <ConsentDataCategory>, <DataClassification>)` to `PatientFieldPolicy` — since `toFieldSafeDto` loops over `PatientFieldPolicy.consentControlled()`, the new field is automatically consent-checked; (3) ensure `PatientDto.masked(...)` blanks `phoneNumber` when it's in `maskedFields`; (4) frontend: render "Restricted" when the field is masked; (5) add a consent before/after test asserting the field masks/unmasks, and confirm the CSV export blanks it (it reuses the masked read, so it should for free). The elegance: because the masking loop is data-driven off the policy enum, adding a field is mostly one enum entry plus the DTO blanking.

**E13 (new `EXPERIMENTAL_DENIED` line outcome).** (1) Add `EXPERIMENTAL_DENIED` to the `LineOutcome` enum (**append, never renumber**) and a Flyway migration updating the DB CHECK constraint to allow the new value. (2) Add a plan-config source for "experimental" procedures (a `plan_experimental_procedure` table mirroring `plan_exclusion`, or a flag). (3) In `AdjudicationService`'s line classification, insert it into the **precedence** chain — it behaves like an exclusion (member owes full charge, no cost-share), so place it near exclusion, e.g. `exclusion > experimental > out-of-network > auth-required > covered`, and build a `deniedLine(...)` for it. (4) **The calculator does *not* change** — non-covered lines never reach it; the service constructs the denied line with copay/deductible/coinsurance/OOP all zero and member = charge. (5) Add an adjudication integration test with an experimental line.

**E14 (search claims by patient name).** The current design deliberately searches only PHI-free business numbers because (a) patient names are PHI and must not land in query strings or logs (rule 5), and (b) free name search enables *fishing* for people. To do it *safely* if truly required: run the search entirely on the **backend**, **restricted to the caller's accessible patient set** (so a provider only matches patients they're assigned to — reuse `accessiblePatientIdsIfGated`), send the term in a **POST body, never a query string or the URL**, keep it **out of logs**, respect consent/masking on the results, and get product/compliance sign-off because it's a privacy-sensitive capability. In short: narrow the search domain to already-authorized patients and keep the sensitive term off the wire's loggable surfaces.

---

# 31. Needs my confirmation

> These are the things this handbook **can't** know about you — mostly personal motivation, effort, and a few facts worth re-verifying before you quote them. Fill them in yourself; don't let the handbook put words in your mouth. Everywhere the earlier chapters used first-person "I chose / I built," it was describing decisions evident in the code — but the *why-it-mattered-to-you* is yours to supply.

## Personal / motivation (for behavioral answers)
1. **Why did you build HealthCloud?** What drew you to healthcare + claims specifically? (A genuine reason — "I wanted to prove I could handle real authorization complexity, not CRUD" — is far better than a generic one.)
2. **How long did it take, over what calendar period?** ("Built over ~N weeks/months, evenings/weekends" — have a real range; don't guess a number you can't stand behind.)
3. **What was genuinely hard *for you*** (vs hard in the abstract)? The moment you were stuck and how you felt/what you did — that's the authentic core of a STAR story.
4. **What are you most proud of, personally?** (Distinct from "the most impressive feature.")
5. **What frustrated you or what would you tell your past self?**

## AI-collaboration specifics (for the ownership questions)
6. **How would you describe the split** in your own words? (The handbook's framing is "I directed design + reviewed/tested; AI accelerated implementation" — confirm that's accurate and make it yours.)
7. **A concrete example of a time you overrode or corrected the AI** — pick one you actually remember, so it's real under follow-up.
8. **What did you learn about *working with* AI** that you'd bring to a team? (This is increasingly a real interview question.)

## Facts worth re-verifying before you quote them
9. **Test counts / migration count** — this handbook uses **694 (511 backend / 183 frontend), 43 migrations, 30 packages**, measured 2026-09-24. Re-run `mvnw verify` / `npm test` and re-count if it's been a while; quote the latest measured numbers, dated.
10. **The k6 load numbers** (~107 req/s, p95 ~38 ms, 0% errors @ 50 VUs) come from `docs/evidence/load-test.md` — confirm the exact figures there and always frame them as single-node/local, not an SLA.
11. **The live demo URL** — confirm `https://nikhil.healthcloud-demo.com` is up before an interview (it's a single box; check it that morning).
12. **Whether the ECS production stack was actually observed running** — the evidence pack (`docs/evidence/aws.md`) has the capture; confirm you can speak to what you personally saw when it was live, since it's since been torn down.
13. **Your target companies / role level** — the handbook is pitched at strong SWE interviews generally; tailor the depth (e.g. system-design emphasis for senior loops) to the specific role.

## Story scaffolds to personalize (from Ch. 25)
14. Story A (OTLP/tracing debug), B (accumulator lock decision), C (no-unmeasured-claims discipline), D (AI-assisted discipline) are grounded in real project events — but add **your own** felt experience and the specific moment, so they don't sound generic.

*(When you've filled these in, you can delete this chapter or keep it as your personal answer key.)*

---

# 32. Coverage appendix

> A map proving every phase and every required topic area is covered, and where. Use it to find a topic fast or to spot-check your prep.

## Implementation phases → chapters

| Phase | Topic | Primary chapter(s) |
|---|---|---|
| 0 | Design/scaffold, ADRs, monorepo | 3, 19, 20 |
| 1 | Foundation & multi-tenant identity | 4, 5 |
| 2 | Care-coordination workflow | 8 |
| 3 | Consent / authorization / privacy / documents | 6, 7, 12 |
| 4 | Clinical context & claims intake | 9 |
| 5 | Basic adjudication engine (MVP) | 10 |
| 6 | Advanced claims (prior-auth, referrals, appeals, anomaly, review, reprocessing) | 11 |
| 7 | Advanced security/governance (audit, break-glass, retention) | 14 |
| 8 | Event-driven (outbox, Kafka, DLQ, replay) | 15 |
| 9 | Search / reporting / accessibility | 13 |
| 10 | Cloud deployment & CI/CD | 19, 20 |
| 11 | Observability & recovery | 22 |
| 12 | Final validation & portfolio | 21, 25, 28 |

## Required topic areas (A–K from the assignment) → chapters

| Area | Description | Chapters |
|---|---|---|
| A | Product purpose & overview | 1, 2 |
| B | Architecture & system design | 3, 17, 24 |
| C | Frontend engineering | 16, 13 |
| D | Backend & APIs | 17, 8, 9 |
| E | Database & multi-tenancy | 4, 18 |
| F | Auth, authorization, consent, security | 5, 6, 7, 14 |
| G | Care coordination & claims | 8, 9, 10, 11 |
| H | Documents, reporting, communication | 12, 13, 15 |
| I | Events & distributed systems | 15, 24 |
| J | AWS, infrastructure, delivery | 19, 20 |
| K | Testing, performance, observability, ops | 21, 22 |
| — | End-to-end walkthroughs | 23 |
| — | Hard challenges | 24 |
| — | Ownership & AI | 25 |
| — | Practice & revision | 26, 27, 28, 29, 30 |

## Key source-of-truth references (for going deeper on your own)

- **Design spec:** `docs/source-of-truth/HealthCloud_Final_Source_of_Truth.pdf` (the frozen *what-to-build*).
- **ADRs:** `docs/adr/ADR-001…018` (the *why* of each big decision — read 001 monolith, 002 shared-DB tenancy, 004 Cognito+BFF, 018 dev-login).
- **Architecture & data:** `docs/architecture/architecture.md`, `docs/er-diagram/er-diagram.md`.
- **Security:** `docs/threat-model/threat-model.md`, `docs/evidence/security-proofs.md`.
- **Evidence pack:** `docs/evidence/` (test-results, aws, observability, load-test, ui, resume-bullets).
- **Runbooks:** `docs/runbooks/`.
- **The rulebook & diary:** `CLAUDE.md` (conventions) and `docs/PROGRESS.md` (the build log).

## Key code landmarks (open these to make an answer yours)

- Authorization: `backend/.../patient/PatientAccessGuard.java`, `.../auth/SecurityConfig.java`, `.../context/UserContextFilter.java`.
- Consent/masking: `.../consent/ConsentPolicy.java`, `.../patient/PatientFieldPolicy.java`, `PatientService.toFieldSafeDto`.
- Adjudication: `.../adjudication/AdjudicationCalculator.java`, `AdjudicationService.java`, `.../coverage/BenefitAccumulator.java`.
- Events: `.../outbox/OutboxService.java` + `OutboxRelay.java`, `.../notification/ClaimAdjudicatedConsumer.java`, `.../deadletter/DeadLetterReplayService.java`.
- Audit: `.../audit/AuditHashChain.java`, `AuditService.java`, `AuditSigningKeys.java`.
- Errors/context: `.../error/GlobalExceptionHandler.java`, `.../error/CorrelationIdFilter.java`.

---

*End of the HealthCloud Interview Mastery Handbook. Study it in the recommended order, do the exercises before the solutions, fill in Chapter 31 in your own words, and rehearse the pitches and the adjudication example out loud. You built this — this handbook just helps you prove it.*

