# HealthCloud — Interview Questions & Answers

A practice-focused Q&A guide for talking about HealthCloud in interviews. Each question is tagged by difficulty and written so you can read the answer and say it out loud naturally. Answers use real examples from the project; anything hypothetical or unmeasured is labelled as such.

**How to use this:** pick a topic from the table of contents, read the question, cover the answer, try to say it yourself, then check. Start with the "Master these first" list in [§32](#32-final-revision) if you're short on time.

**Honesty note:** HealthCloud is a portfolio project on **synthetic data only**. It is healthcare-*inspired* and HIPAA-*aligned*, **not certified**, and has **no real users or production traffic**. Test counts and the few measured numbers are labelled where they appear; everything else is described as designed/implemented behavior.

---

## Table of contents

1. [Project overview & requirements](#1-project-overview--requirements)
2. [System design & architecture](#2-system-design--architecture)
3. [Frontend (React / TypeScript)](#3-frontend-react--typescript)
4. [Backend (Java / Spring Boot)](#4-backend-java--spring-boot)
5. [Database (PostgreSQL)](#5-database-postgresql)
6. [API design](#6-api-design)
7. [Authentication](#7-authentication)
8. [Authorization & privacy](#8-authorization--privacy)
9. [Multi-tenancy](#9-multi-tenancy)
10. [Consent management](#10-consent-management)
11. [Healthcare workflows](#11-healthcare-workflows)
12. [Claims processing & adjudication](#12-claims-processing--adjudication)
13. [Document management](#13-document-management)
14. [Event-driven architecture](#14-event-driven-architecture)
15. [Notifications](#15-notifications)
16. [Testing](#16-testing)
17. [Cloud & infrastructure](#17-cloud--infrastructure)
18. [CI/CD](#18-cicd)
19. [Observability](#19-observability)
20. [Backup & recovery](#20-backup--recovery)
21. [Audit & governance](#21-audit--governance)
22. [Security & threat modeling](#22-security--threat-modeling)
23. [Search & reporting](#23-search--reporting)
24. [UI/UX & accessibility](#24-uiux--accessibility)
25. [Reliability & performance](#25-reliability--performance)
26. [Cost management](#26-cost-management)
27. [Documentation & demonstration](#27-documentation--demonstration)
28. [Ownership & AI assistance](#28-ownership--ai-assistance)
29. [Limitations & future work](#29-limitations--future-work)
30. [End-to-end flows](#30-end-to-end-flows)
31. [Behavioral & STAR questions](#31-behavioral--star-questions)
32. [Final revision](#32-final-revision)

---

## 1. Project overview & requirements

**Q1.1. In one or two sentences, what is HealthCloud? — Very basic**

Answer:
HealthCloud is a multi-tenant healthcare platform where care teams coordinate patient care and process insurance claims, and every time someone reads a patient's data the system checks not just *who* they are but *whether the patient consented* to that specific use. It's a portfolio project built on synthetic data, but it's built in a production shape — real authorization, a real claims-adjudication engine, event-driven messaging, and a cloud deployment.

Follow-up: Why do you call it "consent-aware"?
Most systems stop at roles — a nurse role can see patient records, full stop. HealthCloud adds a layer on top: even if your role allows it, a specific field can still be hidden because the patient's consent directive says a provider outside their care team can't see, say, the clinical narrative. So access is a function of role *and* the patient's own decisions.

Remember: "Coordinate care + process claims, with consent enforced on every read."

---

**Q1.2. What real-world problem is it modeling? — Very basic**

Answer:
Two problems that actually live together in healthcare. First, care coordination — patients, providers, and coordinators need to share requests, referrals, and clinical context across an organization without everyone seeing everything. Second, claims — turning a bill for a medical service into an explainable payment decision (what the plan covers, what the patient owes). The interesting part is that both of those touch sensitive data, so the whole thing is wrapped in privacy rules: multi-tenancy so organizations are isolated, and consent so patients control their own information.

Follow-up: Why put coordination and claims in the same app instead of two apps?
They share the same core entities — patients, providers, organizations, and the same authorization model. Building them together let me prove one consistent security model across two very different workflows: a clinical workflow (requests, referrals) and a financial workflow (claims, adjudication). That's a stronger portfolio story than two isolated CRUD apps.

---

**Q1.3. Who are the users, and what are the roles? — Basic**

Answer:
There are seven roles, and they map to how a real clinic and its billing side work. A **patient** sees only their own record. A **provider** (a doctor) sees only patients they're actively assigned to. A **care coordinator** manages assignments and workflow across patients. A **claims reviewer** works the claims queue — accepting, rejecting, adjudicating. An **org admin** configures plans and runs administrative actions. An **auditor** reads the tamper-evident audit trail but can't change anything. There's also a second provider per org used to demonstrate out-of-network scenarios. Each role exists in two separate organizations — NorthCare and Green Valley — so I can demonstrate tenant isolation.

Follow-up: How does a provider only see "their" patients?
Through a relationship layer. A provider is linked to patients via an active `provider_patient_assignment`. When they try to read a patient, a guard checks that assignment; if there's none, they get a 404 as if the patient doesn't exist — not a 403, because a 403 would confirm the patient exists in that org. Coordinators and admins skip that relationship check because their job is org-wide.

Remember: "7 roles × 2 orgs. Patient=self, provider=assigned-only, coordinator/admin=broad, reviewer=claims, auditor=read-only."

---

**Q1.4. What's the one thing that makes this project stand out? — Basic**

Answer:
The layered authorization — specifically that two users with the *same role* can get *different results* from the same endpoint because the relationship, consent, and purpose differ. That's the flagship. A lot of projects show role-based access; very few show consent-based field masking where a date of birth comes back as `null` with a "this field was masked" marker because the patient's consent directive denies it for that caller's purpose. Second to that is the claims-adjudication engine, which is a deterministic, explainable calculator — for any decision it can show which plan applied and how every dollar was computed.

Follow-up: Is the consent check done on the frontend or backend?
Always the backend. The frontend never receives a value it isn't allowed to see — the backend nulls it out before serializing. The frontend just renders "Restricted." That's a hard rule in the project: the frontend can hide or disable UI for convenience, but it is never the security boundary.

---

**Q1.5. What were the main functional requirements? — Medium**

Answer:
At a high level: multi-tenant identity and login; care coordination with patients, providers, assignments, and service requests that move through a state machine; consent directives that patients and staff can record and revoke; secure document upload with malware scanning; a claims pipeline from intake through adjudication, including advanced pieces like prior authorization, referrals, appeals, and reprocessing; a tamper-evident audit trail with break-glass emergency access; and event-driven processing so a claim decision fans out to downstream consumers reliably. On the non-functional side: strict tenant isolation, consent enforcement, no sensitive data in logs or events, and everything explainable and testable.

Follow-up: How did you capture acceptance criteria?
The design came from a frozen source-of-truth document, and each phase had a concrete "proof of done." For example, Phase 1's proof was "a NorthCare user cannot access Green Valley data, and a browser can't pick a different tenant." Phase 3's was "two users with the same role get different results because relationship/consent/purpose differ." Those negative outcomes became tests — the cross-tenant denial test, the consent-masking test — so acceptance criteria and the test suite are the same thing.

Remember: "Acceptance criteria are negative tests: cross-tenant denial, consent denial, invalid transitions."

---

**Q1.6. How did you decide what went into the MVP versus later? — Medium**

Answer:
The build was phased 0 through 12, and the MVP was phases 0–5: foundation and identity, care coordination, consent and documents, clinical context and claims intake, and the basic adjudication engine. The rule was dependency order — you can't build claims adjudication before you have claims, and you can't have claims before you have patients and plans. Everything past phase 5 — advanced claims, break-glass, event-driven messaging, search, cloud deploy, observability — is genuinely optional hardening that builds on a working core. So if I'd had to stop early, phase 5 was a coherent, demonstrable product on its own.

Follow-up: What would you cut if you had half the time?
I'd keep the authorization layering, consent, and the adjudication engine, because those are the differentiators. I'd drop or defer the event-driven Kafka layer and the advanced claims variants (appeals, reprocessing) — they're impressive but they demonstrate breadth, not the core idea. The core idea is "access is consent-aware and every claim decision is explainable."

---

**Q1.7. How do you keep this honest given it's a portfolio project? — Medium**

Answer:
A few hard rules I stuck to. Synthetic data only — no real patient information ever. No unmeasured claims — if I say a number, like 511 backend tests, it's because I measured it; I explicitly write "target" versus "measured" for anything performance-related. And it's described as HIPAA-*aligned*, never HIPAA-*certified*, because certification is a legal process this hasn't been through. Even the demo passwords on the login page are intentionally published because they're throwaway accounts reaching only synthetic data. Being precise about what's real is part of the engineering maturity I want the project to show.

Follow-up: Give an example where that honesty changed how you'd answer.
Load testing. I ran a local k6 test and got roughly 107 requests/second at p95 38 ms with zero errors at 50 virtual users — but that's a single-node local number, so I'd never present it as a production SLA. In an interview I'd say "here's a local measurement under these exact conditions," not "the system handles X."

---

**Q1.8. What did you deliberately leave out of scope, and why? — Hard**

Answer:
Several things, on purpose. No microservices — it's a modular monolith, because the complexity of distributed services wasn't justified for the problem and would have buried the interesting domain logic in infrastructure. No real payment rails — adjudication computes what's owed but doesn't move money. MFA exists in the identity pool but isn't enforced, to keep the demo frictionless. And the messaging layer uses local Kafka rather than a managed cloud broker, because a managed broker is expensive and the event-driven design is fully provable locally. Each of those is a documented decision with a trade-off, not an accident — which matters, because interviewers probe whether you know *why* something isn't there.

Follow-up: When would the modular monolith stop being the right call?
When teams and deploy cadence force it. The moment you have several teams that need to deploy independently, or one module — say adjudication — has wildly different scaling needs from the rest, the monolith's single deploy unit becomes the bottleneck. The design keeps that door open: the modules have clean boundaries and communicate through well-defined services and events, so a module could be extracted later without rewriting the domain logic.

Remember: "Monolith, no real payments, MFA available-not-enforced, local Kafka — all deliberate, all documented."

---

**Q1.9. If a PM asked you to add a brand-new feature tomorrow, how would the design hold up? — Very hard**

Answer:
It depends on the feature, but the architecture is set up to absorb new patient-scoped resources cheaply. Say the ask is "let patients message their care team." I'd add a new module with its own table carrying an `organization_id`, route every read and write through the same `PatientAccessGuard` so tenant isolation and the relationship gate come for free, decide which fields are consent-controlled and add them to a field policy, and if the message triggers a notification I'd emit it through the transactional outbox so it's reliable. The point is the cross-cutting concerns — tenancy, authorization, consent, auditing, events — are all centralized, so a new feature plugs into them rather than reinventing them. Where it would strain is anything that breaks the patient-scoped assumption, like a cross-organization feature; that would need real design work because tenant isolation is deliberately absolute right now.

Follow-up: What's the risk of centralizing all those concerns in shared components?
The shared guard and policy classes become critical code — a bug there is a security bug everywhere. I mitigate that by keeping them pure and heavily tested, and by making the guard the *only* path to patient data so there's no second implementation to drift. The alternative — each module implementing its own checks — spreads the risk out but massively increases the chance one module gets it wrong. Centralizing concentrates the risk somewhere I can actually guard it.

---

## 2. System design & architecture

**Q2.1. Describe the overall architecture in a minute. — Basic**

Answer:
It's a modular monolith with a backend-for-frontend pattern. The backend is one Spring Boot application split into around thirty domain modules — patient, consent, claim, adjudication, audit, and so on — each with thin controllers and the real logic in services. The frontend is a React single-page app that talks only to this backend over a same-origin API, so the browser never holds tokens; it just has a session cookie. Underneath is one PostgreSQL database shared by all tenants, with an `organization_id` column keeping tenants isolated. For asynchronous work there's a transactional outbox that publishes to Kafka. And it's deployed as containers — the production-shape version on AWS ECS, and an always-on demo on a single EC2 box.

Follow-up: What does "backend-for-frontend" buy you here?
The backend holds the OAuth session and talks to Cognito, so the SPA never deals with access tokens or refresh tokens — it just sends a cookie. That removes a whole class of frontend token-storage vulnerabilities, and it means CSRF protection plus HttpOnly cookies are the security model, which is well-understood. The BFF is the confidential OAuth client; the browser is never trusted with secrets.

Remember: "Modular monolith + BFF + shared-DB multi-tenancy + outbox→Kafka + containers."

---

**Q2.2. Why a modular monolith instead of microservices? — Medium**

Answer:
Because the hard part of this project is the domain — consent, authorization, adjudication — not the infrastructure. Microservices would have added network calls, distributed transactions, and deployment complexity that contribute nothing to demonstrating those ideas, and would actually make things like "one atomic transaction that writes the domain change, the status history, the audit event, and the outbox event together" much harder. A monolith lets me keep those in a single database transaction, which is exactly the guarantee I want. The modules still have clean boundaries, so it's a monolith by deployment, not by discipline.

Follow-up: How do you stop a monolith from becoming a big ball of mud?
Module boundaries and a few firm conventions. Controllers are thin — no business logic. Cross-module access goes through services and repositories, not by reaching into another module's tables. Decision logic lives in pure, dependency-free policy classes. And repositories are tenant-safe by construction — they only expose org-scoped finders, so you *can't* accidentally write a query that crosses tenants. Those conventions are written down in the project's rulebook and enforced by a custom code-review agent.

---

**Q2.3. What are the main layers of a request, from HTTP to database? — Medium**

Answer:
A request comes in and first hits a chain of filters — one sets a correlation ID for tracing, one resolves the caller's identity, organization, and roles into a request-scoped context from the session, and Spring Security handles authentication and CSRF. Then it reaches a thin controller, which just validates the request shape and delegates to a service. The service is where everything happens: it reads the tenant and actor from the context (never from the client), runs the authorization layers, applies business rules, and for a state change it writes the domain row plus a history row plus an audit event plus an outbox event in one transaction. Repositories underneath only ever query scoped to the organization. Responses go back through a global exception handler that renders one consistent error shape.

Follow-up: Why resolve identity in a filter instead of in each controller?
So it's impossible to forget. If every controller had to fetch the user, one of them eventually wouldn't, and that's a security hole. Doing it once in a filter means the request-scoped context is always populated the same way, derived on the backend from the authenticated session, and services just read it. It also means no controller can be tricked into trusting a client-supplied tenant ID, because the tenant only ever comes from that context.

Remember: "Filters (correlation, identity, security) → thin controller → service (authz + rules + one-tx) → tenant-scoped repo → global error handler."

---

**Q2.4. What design patterns show up repeatedly, and why? — Medium**

Answer:
A handful, used consistently. **Pure policy classes** for all decision logic — the state machines, the consent evaluator, the adjudication calculator, the audit hash function are all plain classes with no Spring or database dependencies, so they're trivial to unit-test exhaustively. The **aggregate-plus-history** pattern — an important state change always writes the domain change and an append-only history row together. The **transactional outbox** for reliable events. **Optimistic locking** via version columns for most updates, and **pessimistic row locks** for financial accumulators where lost updates would corrupt money. And a **single choke point** for patient access so the relationship check can't be bypassed. The theme is: centralize the thing that must never be gotten wrong, and keep the decision logic pure so you can test it to death.

Follow-up: Why pure policy classes instead of putting logic in the service?
Two reasons. Testability — I can feed the adjudication calculator hundreds of input combinations in microseconds with no database. And clarity — the rules of the domain live in one readable place instead of being tangled with transaction management and data loading. The service's job becomes "load the facts, call the policy, persist the result," which is easy to reason about.

---

**Q2.5. How do modules communicate without becoming tightly coupled? — Hard**

Answer:
Two ways, depending on whether the caller needs an answer now. For synchronous needs, a module calls another module's service directly — for example, the adjudication service asks the coverage module whether a plan excludes a procedure. That's a compile-time dependency, but it's against a service interface, not another module's tables, and I watch for cycles. For things that should happen *after* a change commits — like notifying downstream systems that a claim was adjudicated — I use the outbox and Kafka, which fully decouples the producer from the consumers. The producer just records an event in its own transaction and moves on; it doesn't know or care who consumes it.

Follow-up: How did you avoid a circular dependency between, say, appeals and adjudication?
Appeals depends on adjudication, not the other way around — overturning an appeal re-runs the adjudication engine, so the appeal service calls the adjudication service. Adjudication has no idea appeals exist. Keeping the dependency one-directional is the discipline; when I found a case where two services wanted each other, I moved the shared piece down into a lower-level component (like the access guard, which depends only on repositories) so both could use it without a cycle.

Remember: "Sync = call the other service (one-directional, no cycles). Async/after-commit = outbox→Kafka (fully decoupled)."

---

**Q2.6. If this had to serve real hospital traffic, what's the first thing that breaks? — Very hard**

Answer:
Honestly, the single-instance assumptions. The outbox relay is a scheduled poller that assumes one running instance — if I scaled the app horizontally, two relays would both try to publish the same pending events. The fix is a `SELECT ... FOR UPDATE SKIP LOCKED` so multiple relays can safely divide the work, which I've noted as the path but not implemented. The second thing is the shared database becoming the bottleneck — at real scale you'd add read replicas for the heavy read paths like search, and you'd think hard about the financial row locks becoming contention points under high concurrency for the same patient. None of these are design flaws for a synthetic-data portfolio, but they're exactly the honest "what would you change for production" answer.

Follow-up: Why not build it multi-instance-ready from the start?
Because it would have been speculative complexity. `SKIP LOCKED` polling, distributed scheduling, and replica routing are real work that I couldn't have verified without real scale, and the project's rule is no unmeasured claims. I preferred a correct single-instance implementation with the scaling path clearly documented over a more complex implementation I couldn't actually prove worked. Knowing where the seams are and what you'd change is the senior signal, not pre-building for load you don't have.

---

## 3. Frontend (React / TypeScript)

**Q3.1. What's the frontend built with? — Very basic**

Answer:
It's a React 19 single-page app in TypeScript, built with Vite. Routing is React Router, server data is handled by TanStack Query, the component library is Material UI, and forms use React Hook Form with Zod for validation. The app talks to the backend through one typed fetch client, and it never stores tokens — authentication is just a session cookie the browser sends automatically.

Follow-up: Why TanStack Query instead of putting server data in something like Redux?
Because most of the app's state *is* server state — lists of claims, a patient's details, queues — and that has needs Redux doesn't handle well on its own: caching, background refetching, staleness, loading and error states. TanStack Query gives me all of that declaratively. I only reach for local component state for genuinely local things like which tab is open or a form's in-progress values. There's no global client-state store because the app doesn't really need one.

Remember: "React 19 + TS + Vite + React Router + TanStack Query + MUI + RHF/Zod. Session cookie, no tokens."

---

**Q3.2. How does the frontend know if the user is logged in? — Basic**

Answer:
It asks the backend. There's a `useCurrentUser` hook that calls `GET /api/v1/me`. If that returns 200 with the user's identity and roles, they're logged in; if it returns 401, they're not. A `ProtectedRoute` component wraps the app — while the `/me` call is loading it shows a spinner, on a 401 it redirects to the login page, and on any other error it shows an error screen. So login state is derived from a real backend call, not from anything stored in the browser, which means the frontend and backend can never disagree about who you are.

Follow-up: What happens when the session expires mid-session?
The next API call returns 401. The query client is configured not to retry on 401, so instead of hammering the server it surfaces the error, and the protected route sends the user back to login. There's no token to refresh on the client because the backend holds the OAuth session — session lifetime is a server concern.

---

**Q3.3. How does the typed API client work, and why one central client? — Medium**

Answer:
There's a single module with a private `request` helper that wraps `fetch`. Every call goes through it, so cross-cutting concerns are handled in exactly one place: it sends the session cookie with `credentials: 'same-origin'`, and for any non-GET request it reads the readable `XSRF-TOKEN` cookie and echoes it back as an `X-XSRF-TOKEN` header for CSRF protection. On a non-2xx response it parses the backend's standard error body and throws a typed `ApiClientError` that carries the status, the error code, and the correlation ID. Above that helper is a big `api` object of typed methods like `listClaims` or `adjudicateClaim`. Centralizing it means CSRF, error handling, and credentials are impossible to forget on a new endpoint.

Follow-up: Why surface the correlation ID to the client?
So that when something goes wrong, the error the user sees can include the same correlation ID that's in the backend logs and traces. If I'm demoing and hit an error, I can copy that ID and find the exact request server-side. It ties the frontend error directly to the backend diagnostics.

Code reference: `frontend/src/api/client.ts` (the `request` wrapper and CSRF injection), `frontend/src/api/types.ts`.

---

**Q3.4. How do forms and validation work? — Medium**

Answer:
React Hook Form manages form state, and Zod defines a schema for each form that mirrors the backend's validation rules. The Zod schema catches obvious problems instantly in the browser — a missing field, a date in the future — for good UX. But the backend re-validates everything, because the frontend is never the security or correctness boundary. When the backend rejects something, the typed error comes back and I show the message plus the correlation ID. For a dynamic form like creating a claim with multiple line items, I use React Hook Form's field-array support so you can add and remove lines.

Follow-up: Isn't validating in two places duplicative?
It's intentional duplication with different jobs. The client validation is for fast feedback so the user isn't waiting on a round trip to learn a field is empty. The server validation is for correctness and security, because a client can be bypassed entirely. If they ever drift, the backend wins and it's just a UX bug on the frontend, never a hole. I keep the Zod schema close to the backend's Jakarta validation so drift is unlikely.

Remember: "Zod mirrors backend validation for UX; backend re-validates for real. Backend always wins."

---

**Q3.5. How is role-aware UI handled without it becoming a security risk? — Hard**

Answer:
The UI hides or disables actions a user's role can't perform — a patient doesn't see the "adjudicate" button, for example — based on the roles from `useCurrentUser`. But that's purely convenience, and I'm explicit about it: the backend enforces every one of those rules independently. If someone crafted the request by hand, the backend would still reject it. A good example is the work queues that mirror a state machine's transition table on the frontend to decide which action buttons to show; the backend re-validates every transition, so if the frontend's copy ever drifts, it's a cosmetic bug, not a bypass.

Follow-up: Then why bother gating UI at all?
Because showing users buttons that will just fail is bad UX, and it leaks intent — a claims reviewer doesn't need to see admin-only plan configuration. Hiding it is cleaner and more honest about what each role does. It's defense in depth for usability, layered on top of the real defense, which is server-side.

---

**Q3.6. How does the frontend handle a paginated, searchable work queue? — Hard**

Answer:
Each queue page keeps page number, page size, sort, and any filters in local state, and passes them to a query hook. The hook calls the API, which returns a stable page envelope — content plus total counts and first/last flags — and the page renders the content in a table with Material UI's pagination and sortable column headers. Two details matter. First, I use `keepPreviousData` so when you change page the old rows stay visible until the new ones arrive, instead of flashing a spinner. Second, the free-text search box is debounced — it waits about 300 milliseconds after you stop typing before querying, so it fires once instead of on every keystroke. Sort fields and filter values match the backend's allowlist exactly, so an invalid sort is impossible from the UI.

Follow-up: Why does the backend return its own page envelope instead of the framework's default?
Because I wanted to own the JSON contract. Spring Data's default page serialization isn't guaranteed stable across versions, and I didn't want the frontend coupled to a framework's internal shape. So the backend maps every paged result into a small `PageResponse` record with exactly the fields the frontend needs. It's a small amount of code that decouples the two sides cleanly.

Remember: "Local state → hook → PageResponse envelope. keepPreviousData (no flash) + 300ms debounced search. Sort/filter values match backend allowlist."

---

**Q3.7. How would you handle a slow or failing backend call gracefully in the UI? — Very hard**

Answer:
TanStack Query gives me the states to do it well. Every query exposes loading, error, and success, so a page shows a spinner or skeleton while loading, the real content on success, and a clear error with the correlation ID on failure — never a blank screen or a silent failure. For mutations like adjudicating a claim, the button shows a pending state so you can't double-click, and on success I invalidate the relevant queries so the list and detail refresh to the true server state rather than me guessing what changed. For genuinely slow calls, `keepPreviousData` keeps the last good data on screen. The one thing I deliberately don't do everywhere is optimistic updates, because in a domain where a server-side rule might reject the action, showing a fake success and then rolling it back would be more confusing than a brief pending state.

Follow-up: When would you add optimistic updates despite that?
For actions that almost never fail and where latency really hurts UX — something like toggling a personal preference. There the risk of a rollback is tiny and the responsiveness win is real. For anything that runs server-side business rules — a state transition, an adjudication — I'd keep it pessimistic, because the honest answer is "I don't know the result until the server computes it."

---

## 4. Backend (Java / Spring Boot)

**Q4.1. What's the backend stack? — Very basic**

Answer:
Java with Spring Boot. It uses Spring Security for authentication and authorization, Spring Data JPA for database access, Spring Session backed by the database so sessions survive restarts, and Spring for Kafka on the messaging side. The database is PostgreSQL with Flyway managing the schema. It's one application, organized into around thirty domain modules.

Follow-up: Why store sessions in the database with Spring Session JDBC?
So sessions aren't tied to one server's memory. If the app restarts, or if it ran as more than one instance, the session lives in Postgres and any instance can serve the request. It also means logout genuinely invalidates the session server-side by deleting the row, rather than hoping a client throws away a token.

Remember: "Java + Spring Boot: Security, Data JPA, Session JDBC, Kafka. Postgres + Flyway. One app, ~30 modules."

---

**Q4.2. What does a typical service method do, step by step? — Basic**

Answer:
Take adjudicating a claim. The service first reads the caller's organization and roles from the request-scoped context — never from anything the client sent. It checks the role is allowed. It routes the claim's patient through the access guard, so tenant isolation and the relationship check happen. Then it loads the facts it needs — the claim, the covering plan, the benefit accumulator — applies the pure calculator to compute the decision, and writes the result. And that write is one transaction: the adjudication record, the claim's status change, its history row, the audit event, and the outbox event all commit together or not at all. Thin controller, everything in the service, one atomic write.

Follow-up: Why keep controllers thin?
So business logic lives in one testable place and can't accidentally differ between endpoints. Controllers just handle HTTP — parse the request, check the shape, call the service, return the response. If logic crept into controllers, I'd have rules duplicated across the web layer and no single source of truth. It also makes the services reusable — the appeal service can call the adjudication service directly because the logic isn't trapped in a controller.

---

**Q4.3. What does "one transaction for a state change" mean and why does it matter? — Medium**

Answer:
When something important happens — a claim gets adjudicated — several things must all be true afterward: the domain row is updated, there's a history row recording the transition, there's an audit event, and there's an outbox event for downstream systems. If those weren't atomic, you could get a claim marked adjudicated with no audit trail, or an event published for a change that got rolled back. So they all happen inside a single database transaction. Either everything commits or nothing does. The audit and outbox writes are deliberately designed to join the caller's transaction rather than open their own, which is what makes this guarantee hold.

Follow-up: How do the audit and outbox services join the caller's transaction instead of starting a new one?
They're plain service methods that are *not* annotated to start a new transaction — they just do their database work, so they run inside whatever transaction the calling service already opened. If I'd marked them as requiring a new transaction, the audit row could commit even if the domain change rolled back, which would be a lie in the audit trail. It's a subtle but deliberate choice: the whole point of the audit event is that it's true, so it must share the fate of the thing it describes.

Remember: "Domain change + history + audit + outbox = one atomic transaction. Audit/outbox join the caller's tx, never their own."

---

**Q4.4. How does background and scheduled work run? — Medium**

Answer:
The main piece is the outbox relay — a scheduled job that polls the outbox table for events that were committed but not yet published, sends them to Kafka, and marks them published. There are also Kafka consumers that react to those events, and a dead-letter drainer that captures messages that failed processing. Batch reprocessing of claims runs on request rather than on a schedule. The design keeps scheduled work simple and idempotent, so re-running it is safe.

Follow-up: What happens if the relay publishes an event but crashes before marking it published?
On the next poll it publishes that event again — the relay is at-least-once by design. That's fine because the consumers are idempotent: they dedupe on the event's ID, so processing the same event twice has no extra effect. I chose at-least-once plus idempotent consumers over trying to achieve exactly-once, because true exactly-once across a database and a broker is extremely hard, and this combination gives the same practical result.

---

**Q4.5. How is configuration and environment handled across local, CI, and deploy? — Hard**

Answer:
Spring profiles. Locally I run the `local` profile, which seeds synthetic demo data and enables a dev-login shortcut so I don't need real Cognito to click around. CI runs the tests against real Postgres and Kafka in containers, with tracing turned off to avoid noise. The deployed app runs `demo,cognito` — it seeds demo data so logins map to real users, but it does *not* include the `local` profile, so the dev-login bypass simply doesn't exist in production and Cognito is the only way in. Secrets — the database password, the Cognito client secret, the audit signing secret — never live in the code or the container; they come from AWS Secrets Manager or SSM Parameter Store at runtime.

Follow-up: Why is separating "seed data" from "dev-login" into different profiles important?
Because I wanted a seeded, demoable deployment without the security hole. Early on, seeding and dev-login were both under the `local` profile, which meant deploying with seed data would have dragged the unauthenticated dev-login endpoint along with it. Splitting them — seeding under `local` or `demo`, dev-login only under `local` — let the deploy be `demo,cognito`: full of demo data, but with Cognito as the only login path. There's even a test that boots the deploy profile and asserts the dev-login endpoint is absent.

Remember: "Profiles: local (seed + dev-login), demo (seed only), cognito (real OIDC). Deploy = demo,cognito — no dev-login. Secrets from Secrets Manager/SSM."

---

**Q4.6. Java has checked exceptions and Spring has its own exception model — how do you keep error handling consistent? — Very hard**

Answer:
There's one error contract for the whole API: a JSON body with a code, a message, a correlation ID, and optional details. Services throw domain exceptions — a not-found, an invalid-state-transition, a conflict — and a single global exception handler translates every one of those, plus framework exceptions like validation failures and optimistic-lock conflicts, into that contract with the right HTTP status. Crucially, filter-chain failures — a 401 from an unauthenticated request, a 403 from access denied — are rendered by custom security handlers using the *same* contract, so a client sees one consistent error shape whether the failure happened in a controller or in a filter before the controller ran. And the handler never leaks internals — a database constraint violation becomes a generic 409, never the raw SQL.

Follow-up: Why is it important that a constraint violation doesn't echo the SQL?
Two reasons. Security — database error text can reveal table and column names, which helps an attacker map your schema. And correctness of the contract — the client should get a clean, stable "conflict" it can handle, not an implementation detail that might change. So the handler catches those, logs the real cause server-side with the correlation ID for me to debug, and returns a safe generic message to the caller.

Code reference: `backend/.../error/GlobalExceptionHandler.java`, `ApiError.java`, `ErrorCode.java`, plus `RestAuthenticationEntryPoint` / `RestAccessDeniedHandler`.

---

## 5. Database (PostgreSQL)

**Q5.1. Why PostgreSQL? — Very basic**

Answer:
Because the data is highly relational and correctness matters more than raw scale here. Patients, providers, claims, plans, consent directives — these have real relationships and real invariants, and I want the database to enforce them with foreign keys, unique constraints, and transactions. Postgres also gives me strong transactional guarantees, which I lean on heavily for the atomic writes, and features like partial unique indexes and row-level locking that I use for specific correctness problems. It's a mature, free, well-understood relational database that fits the domain.

Follow-up: Would a NoSQL database have worked?
Not well for this. The whole app depends on multi-row atomic transactions — updating a claim and writing its history and audit and outbox rows together — and on relational integrity across tenants. A document store would push all of that consistency work into application code, where it's easy to get wrong, and I'd lose the foreign keys that make tenant isolation structural. NoSQL shines for scale and flexible schemas; this domain wants integrity and transactions.

Remember: "Relational data + hard invariants + atomic multi-row writes = Postgres. FKs, unique constraints, transactions, row locks."

---

**Q5.2. How is the schema managed? — Basic**

Answer:
With Flyway migrations. Every schema change is a numbered SQL migration file checked into the repo — there are 43 of them. Hibernate is set to `validate`, meaning it never generates or alters schema itself; it only checks that the entities match what Flyway created. So the database schema has a single source of truth — the migration files — and it evolves in a controlled, versioned, repeatable way across every environment.

Follow-up: Why `validate` instead of letting Hibernate auto-create the schema?
Because auto-generated schema is unpredictable and unversioned — you can't review it, you can't roll it forward carefully, and two environments can drift. With Flyway plus `validate`, the schema is explicit SQL I wrote and reviewed, applied in the same order everywhere, and Hibernate acts as a safety check that the code and schema agree. In anything resembling production, controlled migrations are non-negotiable.

Remember: "43 Flyway migrations = source of truth. Hibernate validate-only, never generates DDL."

---

**Q5.3. How does the schema enforce tenant isolation? — Medium**

Answer:
Every tenant-owned table carries an `organization_id` column, and child tables don't just reference their parent by ID — they reference the parent by the composite of ID and organization. To make that possible, tenant-owned tables have a unique constraint on the pair of ID and organization ID, so a child's foreign key can point at "this row *in this tenant*." That means it's structurally impossible for a child row in one organization to reference a parent in another — the database rejects it. Combined with repositories that only ever query scoped to the organization, isolation is enforced at the data layer, not just in application logic.

Follow-up: Why enforce it with foreign keys instead of just filtering in queries?
Because query filters can be forgotten, but a foreign key can't be bypassed. Defense in depth: the application always filters by organization, but even if a bug wrote a query that didn't, the composite foreign keys would stop cross-tenant data from linking up in the first place. I want tenant isolation to survive a mistake in one query, so I push it down into the schema.

Remember: "org_id on every tenant table + UNIQUE(id, org_id) so children FK-with-org. Isolation is structural, not just filtered."

---

**Q5.4. How do you handle concurrent updates to the same row? — Medium**

Answer:
Two mechanisms, chosen per situation. For most updates — claims, requests, consent, assignments — I use optimistic locking with a version column. The client sends the version it read; if someone else changed the row in the meantime, the versions don't match and the update is rejected with a conflict, so no one silently overwrites another person's change. For financial accumulators — where two adjudications for the same patient could otherwise both read the same deductible and both apply it, losing money — I use a pessimistic row lock: the transaction locks the accumulator row so concurrent adjudications serialize.

Follow-up: Why pessimistic locking for the accumulator but optimistic everywhere else?
Because the failure modes differ. For a claim, a conflict is rare and the right response is "reload and try again" — optimistic locking makes that a clean, cheap check. For the accumulator, contention is expected — several claims for one patient in the same year — and a lost update means the deductible is applied twice or not enough, which is real money being wrong. There, I'd rather have the transactions wait for each other than retry-storm on conflicts. So: optimistic where conflicts are rare and retry is fine; pessimistic where correctness of a running total is critical.

Remember: "Optimistic (version column) for most rows; pessimistic row lock for money accumulators. Match the lock to the failure cost."

---

**Q5.5. Walk through the "insert-if-absent then lock" pattern on the benefit accumulator. — Hard**

Answer:
The benefit accumulator tracks how much of a patient's deductible and out-of-pocket max has been met this year, and adjudication needs to read it, use it, and update it atomically. The problem is the row might not exist yet the first time. If I just did "select, and insert if missing," two concurrent adjudications could both find it missing and both insert, and one would fail or, worse, they'd race. So the pattern is: first an `INSERT ... ON CONFLICT DO NOTHING`, which guarantees the row exists without failing if another transaction just created it; then a `SELECT ... FOR UPDATE` that takes a pessimistic lock on that guaranteed-present row. After that lock, this transaction is the only one touching that accumulator, so it can safely read the running total, apply the claim, and write it back.

Follow-up: What exactly goes wrong without the insert-if-absent step?
You get a race on creation. Two transactions both see no row, both try to insert, and depending on timing one hits a unique-constraint violation and fails, or you add complex retry logic. The `ON CONFLICT DO NOTHING` turns "create it if needed" into a safe, idempotent step that never fails on a race — whoever gets there first creates it, everyone else no-ops — and *then* everyone can lock the now-guaranteed row. It cleanly separates "make sure it exists" from "get exclusive access to it."

Code reference: `AdjudicationService.lockAccumulator(...)` → `BenefitAccumulatorRepository.insertIfAbsent(...)` (native `ON CONFLICT DO NOTHING`) then `lockByKey(...)` (`@Lock(PESSIMISTIC_WRITE)`).

---

**Q5.6. How do you keep queries fast, and where would indexing matter most? — Hard**

Answer:
The heaviest reads are the work queues — paginated, filtered, sorted lists of claims or requests scoped to an organization. Those benefit from indexes on the organization ID plus whatever they filter and sort by, so the database isn't scanning the whole table per tenant. The outbox relay's poll for unpublished events uses a partial index on the "not yet published" condition, so it finds pending work without scanning published rows. And the uniqueness guarantees — a claim number unique per tenant, one active consent per natural key — are backed by unique indexes, which also serve as lookup indexes. At synthetic-data scale none of this is stressed, so I'm honest that these are correctness-and-shape decisions rather than measured performance wins.

Follow-up: How would you find the slow query if a queue got sluggish at scale?
I'd reproduce it and run `EXPLAIN ANALYZE` to see the actual plan — whether it's doing a sequential scan where an index should apply, how the filter and sort are executed, and where the time goes. Then I'd add or adjust an index to match the query's shape and confirm the plan changed. I'd also check the pagination approach — deep offset pagination gets slow on large tables, and I'd switch to keyset pagination if that turned out to be the bottleneck. But I'd measure before changing, not guess.

Remember: "Index org_id + filter/sort columns for queues; partial index for outbox 'pending'; unique indexes for per-tenant uniqueness. Measure with EXPLAIN ANALYZE before tuning."

---

## 6. API design

**Q6.1. What style is the API, and what does a typical endpoint look like? — Basic**

Answer:
It's a REST-style JSON API under a versioned path like `/api/v1`. Resources are nouns — patients, claims, consent directives — and HTTP methods carry the meaning: GET to read, POST to create, PATCH to change status. For example, `GET /api/v1/claims` lists claims, `POST /api/v1/claims` creates one, `GET /api/v1/claims/{id}` reads one, and `POST /api/v1/claims/{id}/adjudicate` runs the engine on it. State transitions that are more than a simple field update get their own action-style endpoints rather than a generic update, because they do real work.

Follow-up: Why version the API path from day one?
Because it's nearly free to add up front and painful to retrofit. If I ever needed a breaking change to a contract, `/v2` lets old and new coexist during a migration instead of breaking every client at once. For a portfolio project it also signals that I think about API contracts as things clients depend on, not just internal plumbing.

---

**Q6.2. What HTTP status codes do you use, and what does each mean here? — Basic**

Answer:
The usual ones, used precisely. 200 for a successful read or action, 201-style creation for new resources. 400 for a validation failure, with per-field details. 401 when you're not authenticated, 403 when you're authenticated but your role isn't allowed. 404 for something that doesn't exist — and importantly, also for something that exists but you're not allowed to reach, which I'll come back to. 409 for a conflict — either an optimistic-lock version mismatch or an illegal state transition, which are distinct codes in the body even though both are 409. And 500 for an unexpected error, with a safe generic message.

Follow-up: Why return 404 instead of 403 for a patient a provider isn't assigned to?
Because a 403 confirms the patient exists. If a provider probes patient IDs and gets 403 on some and 404 on others, they've learned which patients exist in that organization, which is itself a privacy leak. Returning 404 for both "doesn't exist" and "exists but you can't see it" means an unauthorized caller can't tell the difference. It's called a secure 404, and it's used consistently for object-level access denials.

Remember: "Secure 404 = 'not found' and 'not allowed' look identical, so you can't probe for existence. 409 splits into version-conflict vs invalid-transition in the body."

---

**Q6.3. How does validation work on the API? — Medium**

Answer:
Request bodies are validated declaratively with Jakarta Bean Validation annotations — required fields, sizes, dates that must be in the past, and so on. When validation fails, the global handler returns a 400 with a code of "validation failed" and a details map naming each bad field, so the client can show field-level errors. Beyond shape validation, the services do semantic validation — a claim must have at least one line and a positive total to be submitted, a plan referenced must exist in your tenant — and those return clear, specific errors too. The frontend mirrors the shape rules in Zod for fast feedback, but the backend is the authority.

Follow-up: Where's the line between a 400 and a 409?
A 400 means the request itself is malformed or invalid in isolation — a missing field, a bad date, an unknown code. A 409 means the request is well-formed but conflicts with the current state of the world — you're trying a state transition that isn't legal from the current status, or the version you're updating is stale. So 400 is "this input is wrong," 409 is "this input is fine but it can't be applied right now." Keeping them distinct helps clients respond correctly — fix the form versus reload and retry.

---

**Q6.4. How is pagination designed, and why? — Medium**

Answer:
Every list endpoint is paginated server-side and returns a stable envelope — the page of content plus the total element count, total pages, and first/last flags. The client sends page, size, sort, and any filters. Two safety details: page size is clamped to a maximum so a client can't ask for a million rows, and the sort field is checked against an allowlist so you can only sort by columns I've approved. An unknown sort field returns a clean 400, not a 500 — without the allowlist, passing a bad field would blow up deep in the data layer, and it would also let someone probe internal column names.

Follow-up: Why an allowlist for sort fields specifically?
Because sort fields get passed straight into the query's ordering, and if you let the client name any property, two bad things happen. A typo or a non-existent field throws a framework exception that surfaces as a 500 — ugly and leaky. And a curious client could enumerate which internal field names exist by watching which sorts succeed. The allowlist turns sorting into a closed set of known-safe options, so it's both robust and non-probeable.

Remember: "PageResponse envelope + clamp size (max 100) + sort allowlist (unknown field → clean 400, not 500). Own the contract, don't leak internals."

---

**Q6.5. How does the API stay idempotent for retriable operations? — Hard**

Answer:
This is a place where I'll correct a common assumption about my own project. There is *no* HTTP `Idempotency-Key` header in the API — the idempotency lives on the event-consumer side, not on the synchronous write endpoints. When a claim is adjudicated, the outbox publishes an event at-least-once, and the consumers dedupe on the event's unique ID: if a consumer has already processed an event with that ID, it skips it, with a unique constraint as a backstop for the race. For the synchronous operations, safety comes from other mechanisms — optimistic locking means re-submitting a stale update just fails cleanly rather than double-applying, and re-adjudicating a claim intentionally creates a new version rather than being a no-op. So idempotency is real, but it's precise about where it lives.

Follow-up: If you were to add HTTP-level idempotency keys, where and why?
On the genuinely create-type commands where a network retry could produce a duplicate — creating a claim, submitting one. There, the client would send a unique key, the server would record it with the created resource, and a retry with the same key would return the original result instead of creating a second claim. I'd store the key with a uniqueness constraint so concurrent retries can't both win. I didn't build it because at this scale the risk is low and I'd rather not claim a mechanism I hadn't actually exercised — but I know exactly where it would go.

Remember: "No Idempotency-Key header. Idempotency = consumer-side event-ID dedup (at-least-once + idempotent consumers). Optimistic locking makes stale re-submits fail cleanly."

---

**Q6.6. How do you prevent sensitive data from ever leaking through the API — in URLs, errors, or exports? — Very hard**

Answer:
Several habits, applied consistently. Sensitive identifiers and any patient data never go in URL query strings, because URLs end up in logs and browser history — searches match on synthetic business identifiers like a claim number, never on patient names. Error responses carry a generic message and a correlation ID, never the underlying exception text or SQL. Masked fields don't just disappear from the JSON — the backend actually nulls them before serialization and lists them as masked, so there's no code path where a value the caller shouldn't see gets serialized and then hidden client-side. And exports go through the same masked read the JSON API uses, so a CSV can never dump a raw column the API itself would have hidden. The principle is that the masking and scoping happen once, deep in the read, and everything — JSON, CSV, logs, events — inherits it.

Follow-up: How do you guarantee a CSV export can't bypass masking?
By making the export call the exact same service method the JSON list uses, rather than writing a second query. The masked field is already `null` in the DTO that method returns, so it serializes as a blank cell in the CSV automatically. If the export had its own query that read raw columns, it could leak — so the rule is that an export formats already-masked DTOs, it never re-reads the database. That way there's one place masking is applied and every output format is downstream of it.

Remember: "One masked read, many outputs. No PHI in URLs/logs/errors. Export reuses the masked service call, never a raw query."

---

## 7. Authentication

**Q7.1. How does login work? — Basic**

Answer:
The real login path uses Amazon Cognito with OpenID Connect. When you click "Sign in," the browser goes to the backend, which redirects you to Cognito's hosted login page. You authenticate there, Cognito sends an authorization code back to the backend, and the backend exchanges that code for your identity and establishes a session. From then on, the browser just carries a session cookie. The backend is the OAuth client that holds the session — that's the backend-for-frontend pattern — so the browser never touches tokens.

Follow-up: What's the local dev login then?
Locally there's a shortcut endpoint that logs you in by email with no password, purely so I can click around as different roles without standing up Cognito. It's gated to the `local` profile only, and the deployed app doesn't run that profile, so the shortcut simply doesn't exist in the deployment. There's even a test that boots the deploy profile and confirms that endpoint is gone.

Remember: "Cognito OIDC auth-code via a Spring BFF. Session cookie, no tokens in the browser. Dev-login is local-profile only."

---

**Q7.2. Why keep the session on the backend instead of using tokens in the browser? — Medium**

Answer:
Because browser token storage is a well-known source of trouble. If the frontend held access and refresh tokens, they'd live in JavaScript-reachable storage and become a target for cross-site scripting, and I'd have to manage refresh logic and token expiry on the client. With the backend-for-frontend pattern, the backend is a confidential OAuth client that holds the tokens server-side, and the browser only has an HttpOnly session cookie it can't even read. That shrinks the attack surface a lot: the security model becomes "protect a session cookie with HttpOnly and CSRF defenses," which is mature and well-understood, instead of "safely store and rotate tokens in a browser."

Follow-up: What's the downside of the BFF approach?
It ties the frontend to its backend — the SPA can't just call some third-party API directly with a token, because it doesn't have one. Everything routes through the backend. For this app that's exactly what I want, since the backend is the security boundary anyway, but if I needed the frontend to talk to many independent APIs, a token model might fit better. It also means the backend has to be up for the frontend to do anything, but that's already true here.

---

**Q7.3. How is CSRF handled, given you use cookies? — Medium**

Answer:
Cookie-based auth is vulnerable to cross-site request forgery, so there's an explicit defense. The backend issues a CSRF token in a readable cookie. For any state-changing request — anything that isn't a GET — the frontend reads that cookie and echoes the value back in a request header. The backend checks that the header matches. A malicious site can cause your browser to send the cookie, but it can't read the cookie's value to put it in the header, because of the same-origin policy — so it can't forge the header, and the request is rejected. GETs don't need it because they don't change state.

Follow-up: Why is this "double submit" pattern safe?
Because it relies on the same-origin policy protecting the *reading* of the cookie. The session cookie rides along automatically on any request the browser makes, including a forged one — that's the vulnerability. But the CSRF token has to be copied from the cookie into a custom header by JavaScript, and a cross-origin attacker's script can't read your cookies for my domain. So only genuine same-origin code can produce the matching header. The attacker can trigger a request but can't complete the handshake.

Remember: "CSRF: readable token cookie echoed in X-XSRF-TOKEN header on writes. Attacker can send the cookie but can't read it to forge the header."

---

**Q7.4. How does the app know your roles and organization after login? — Medium**

Answer:
Cognito only proves *who* you are — it establishes identity by email. It does not assign roles. After the session is established, a filter looks up that email in the application's own database and loads the user's organization, memberships, and roles from there into a request-scoped context. So identity comes from Cognito, but authority comes from the app's database. That separation is deliberate and follows the rule that the backend is the only place roles are decided — Cognito could never be tricked into granting someone an admin role, because Cognito doesn't know about roles at all.

Follow-up: Why not put roles in the Cognito token as claims?
Because then the identity provider becomes part of my authorization model, and keeping roles in sync between Cognito and the app would be a source of bugs and drift. Worse, if roles lived in a token, I'd be trusting a token's claims for authorization decisions, and I want those decisions grounded in the database I control, inside the same transaction as everything else. Keeping Cognito to "who are you" and the database to "what may you do" is cleaner and safer.

Remember: "Cognito = identity (who). App database = authority (roles/org). Never trust the IdP for authorization."

---

**Q7.5. How does logout work, and why did it need extra care? — Hard**

Answer:
Logout has two halves. First, the backend invalidates the session — it clears the server-side session and deletes the session cookie, so the app no longer knows you. But that alone isn't enough with a hosted identity provider, because Cognito keeps its own single-sign-on cookie. If I only cleared the app session, the next time you clicked "Sign in," Cognito would silently log you straight back in as the same user without asking — which is confusing and wrong for a shared demo. So the second half is a redirect to Cognito's logout URL, which clears Cognito's cookie too. Only after both is the user truly signed out and able to log in as someone else.

Follow-up: Why couldn't you use the standard OIDC logout mechanism?
Because Cognito doesn't advertise the standard end-session endpoint that Spring's built-in logout handler expects, so I couldn't just wire that up. Cognito has its own non-standard logout URL with a specific query-string shape. So the backend builds that URL from configuration and exposes it, and the frontend does a full-page redirect to it after clearing the local session. It's a small example of an integration not matching the spec and having to adapt to the actual provider rather than the ideal.

Remember: "Logout = clear app session AND redirect to Cognito's (non-standard) logout URL, or SSO silently re-logs you in."

---

**Q7.6. Is MFA supported, and how would you enforce it? — Hard**

Answer:
The Cognito user pool has MFA available — time-based one-time passwords are configured as optional — but it isn't enforced, deliberately, so the demo stays frictionless for recruiters clicking through. Enforcing it would be a configuration change on the pool to make MFA required, plus handling the enrollment flow the first time a user logs in. Because authentication is delegated to Cognito, this is genuinely a policy setting rather than application code I'd have to write — which is one of the benefits of not building auth myself.

Follow-up: What's the trade-off of enforcing MFA on a demo versus a real system?
For a real healthcare system, enforcing MFA is basically mandatory — the data is too sensitive to protect with a password alone. For a synthetic-data demo, enforcing it would just add friction for someone evaluating the project, with no real data to protect, so leaving it optional is the right call *for this context*. The honest framing in an interview is: "it's available and I know how to enforce it; I chose not to for the demo, and I can articulate exactly when that choice would flip."

---

## 8. Authorization & privacy

**Q8.1. What's the difference between authentication and authorization here? — Very basic**

Answer:
Authentication is proving who you are — that's Cognito and the session. Authorization is deciding what you're allowed to do once you're known — and that's where most of the interesting work in this project lives. HealthCloud has a layered authorization model, so being logged in gets you almost nothing on its own; each thing you try to access is checked against several independent rules.

Remember: "Authentication = who you are (Cognito). Authorization = what you may do (layered, backend-only)."

---

**Q8.2. Describe the layers of authorization. — Basic**

Answer:
There are five layers, applied in order, and each one can only narrow access, never widen it. First, **tenant** — you can only touch data in your own organization. Second, **role** — your role has to permit the kind of action at all. Third, **relationship** — for patient data, a provider must be actively assigned to that patient; a patient can only reach their own record. Fourth, **consent and purpose** — the patient's consent directives have to allow this kind of access for this purpose. Fifth, **field-level masking** — even on a record you can read, individual sensitive fields can be hidden based on consent. So two people with the same role can get different results because the later layers depend on relationship and consent, not just role.

Follow-up: Why in that specific order?
It goes from cheapest and broadest to most specific. Tenant and role are quick checks that eliminate most unauthorized access immediately. Relationship narrows to the right patients. Consent and masking are the finest-grained and most expensive, so they run last, on data that's already passed the coarser gates. It's both a logical narrowing and an efficiency ordering.

Remember: "Tenant → role → relationship → consent+purpose → field masking. Each only narrows. Same role ≠ same result."

---

**Q8.3. What is the "secure 404" and why does it matter? — Medium**

Answer:
When you try to access a patient — or anything tied to a patient — that you're not allowed to reach, the response is a 404 Not Found, exactly as if the record didn't exist, rather than a 403 Forbidden. This matters because a 403 leaks information: it confirms the record exists, just that you can't see it. If a provider could probe patient IDs and distinguish "doesn't exist" from "exists but forbidden," they could enumerate which patients are in an organization. The secure 404 makes those two cases indistinguishable, so an unauthorized caller learns nothing. It's applied consistently through the access guard.

Follow-up: Is there ever a case where you *do* return 403 instead of 404?
Yes — for role-level denials that aren't existence-sensitive. If a claims reviewer tries to hit an admin-only configuration endpoint, that's a flat 403, because there's no secret being protected — everyone knows the admin endpoint exists, you just can't use it. The secure 404 is specifically for object-level access where the *existence* of the object is itself sensitive, like a specific patient. So the rule is: 403 when the action is forbidden and that's not a secret; 404 when even knowing the object exists would leak something.

Remember: "Secure 404 for object-level/existence-sensitive denials (patients). Flat 403 for role-level denials (admin endpoints)."

---

**Q8.4. How is the relationship layer implemented so it can't be bypassed? — Medium**

Answer:
There's a single component — the patient access guard — that is the *only* path to patient data. Every read and write that touches a patient, or anything scoped to a patient like their requests, consent, documents, or claims, routes through it. It has two entry points: one that checks "may this caller reach this specific patient" and throws a secure 404 if not, and one that returns the set of patient IDs a caller may see, used to scope list queries. Because there's exactly one implementation and everything goes through it, there's no second copy of the logic to drift, and a new feature that touches patients can't accidentally skip the check — it has to call the guard to get the data at all.

Follow-up: Doesn't a single guard become a single point of failure?
It's a single point of *enforcement*, which is the goal — I'd much rather have one heavily-tested choke point than the same check reimplemented in twenty places where one of them is subtly wrong. The risk is that a bug in the guard is a bug everywhere, so I mitigate that by keeping it focused and testing it hard, including the negative cases: cross-tenant returns 404, an unassigned provider returns 404, a patient reaching another patient returns 404. The guard also depends only on repositories, not on the services it protects, so any service can use it without creating a dependency cycle.

Code reference: `patient/PatientAccessGuard.java` — `requireAccessibleInTenant(patientId)` and `accessiblePatientIdsIfGated(caller, org)`.

---

**Q8.5. Explain field-level masking with a concrete example. — Hard**

Answer:
Say a provider reads a patient. They pass the tenant, role, and relationship checks, so they get the patient record. But the date of birth is a consent-controlled field. Before serializing, the backend asks the consent policy: for this actor, for the purpose of this read, is the birth-date category allowed? If the patient's directives don't grant it, the backend sets the date of birth to `null` in the response and adds "dateOfBirth" to a list of masked fields. The provider sees the patient but with the birth date shown as "Restricted." The key point is the masking happens on the backend, in the read — the frontend never receives the real value, so there's nothing to leak. And the same read is used everywhere, so an export or a different view can't accidentally expose it.

Follow-up: Why return the field as null-plus-a-marker instead of just omitting it?
So the frontend can tell the difference between "this field is genuinely empty" and "this field is hidden from you," and show an honest "Restricted" placeholder rather than a blank that looks like missing data. The `maskedFields` list makes the masking explicit and self-describing — the client doesn't have to guess. It's display-only information, though; it's not a security control, because the actual protection already happened by nulling the value server-side.

Remember: "Mask = null the value server-side + list it in maskedFields. Purpose is backend-fixed per read. Frontend just renders 'Restricted'."

---

**Q8.6. Two users, same role, one gets data and one gets a 404. Walk me through why. — Very hard**

Answer:
Picture two providers in the same organization, both with the provider role, both trying to read the same patient. Provider A is actively assigned to that patient through a care relationship; Provider B is not. Both pass the tenant check — same org. Both pass the role check — both are providers. Then the relationship layer runs: the access guard checks the assignment. Provider A has one, so they proceed to consent and masking and get the record, possibly with some fields masked. Provider B has no assignment and no break-glass grant, so the guard throws a secure 404 — to Provider B, that patient simply doesn't appear to exist. Same endpoint, same role, opposite outcomes, entirely because of the relationship layer. That's the concrete proof of why role-based access alone isn't enough for this domain.

Follow-up: Now add consent — how could Provider A, who's assigned, still be denied a specific field?
Even assigned, Provider A hits the consent-and-purpose layer for each controlled field. Suppose the patient granted their care team access to clinical narratives but denied it to individual providers outside a tighter scope, and the consent policy resolves that Provider A's tier doesn't get the narrative for this purpose. Then Provider A reads the patient and most fields, but the clinical narrative comes back masked. So the record is visible, but a field inside it isn't — that's the fifth layer doing its job independently of the relationship layer. Access isn't one yes/no; it's a cascade of narrowing decisions down to individual fields.

---

## 9. Multi-tenancy

**Q9.1. What does multi-tenancy mean in this app? — Very basic**

Answer:
Multiple separate organizations — tenants — use the same running application and the same database, but each one can only ever see its own data. In HealthCloud there are two demo tenants, NorthCare and Green Valley, each with their own patients, providers, claims, and everything else. A NorthCare user cannot see or touch anything belonging to Green Valley, even though both are served by the same backend and stored in the same tables.

Remember: "One app, one database, many isolated organizations. Shared infrastructure, strictly separated data."

---

**Q9.2. Which multi-tenancy model did you choose and why? — Basic**

Answer:
The shared-database, shared-schema model — every tenant's rows live in the same tables, distinguished by an `organization_id` column. The alternatives are a database per tenant or a schema per tenant. Shared schema is the simplest to operate and the cheapest — one database to migrate, back up, and monitor — which suits a portfolio project and honestly suits many real SaaS products. The trade-off is that isolation becomes the application's and schema's responsibility rather than the infrastructure's, so I have to be rigorous about it, which is where the `organization_id` scoping and composite foreign keys come in.

Follow-up: When would database-per-tenant be worth the extra cost?
When tenants demand hard physical isolation — for compliance or contractual reasons — or when one tenant is so large it needs its own resources, or when you need to restore or migrate a single tenant independently. Those are real drivers in enterprise healthcare. For this project none of them applied, and a database per tenant would multiply operational overhead for no benefit on synthetic data. But I can name the tipping points, which is what matters.

Remember: "Shared DB + org_id column. Cheapest to operate; isolation is my job. DB-per-tenant only for hard isolation / huge tenants / per-tenant restore."

---

**Q9.3. How is the tenant determined for a request? — Medium**

Answer:
Entirely on the backend, from the authenticated session — never from anything the client sends. A filter resolves the logged-in user, looks up their organization membership in the database, and puts the organization ID into a request-scoped context. Services read the tenant only from that context. If a client tried to pass an organization ID in a query parameter or a header to act as another tenant, it's simply ignored — there's a test that spoofs exactly that and confirms the response still only contains the caller's real organization's data.

Follow-up: Why is "never trust the client for tenant" such a strict rule?
Because tenant ID is the master key to isolation — if a client could influence it, the entire multi-tenancy model collapses in one request. It's the single most dangerous input you could accept from a client. So the tenant is derived from the authenticated identity, which the client can't forge, and it's read from the backend context everywhere. Accepting it from the client even once, even "just for an admin tool," would be the kind of hole that leaks every tenant's data.

Remember: "Tenant comes from the authenticated session → backend context. Client-supplied org IDs are ignored. Proven by a spoofing test."

---

**Q9.4. How do you stop a query from accidentally crossing tenants? — Medium**

Answer:
Two layers. First, repositories are tenant-safe by construction — they only expose finders scoped to the organization, like "find by ID and organization ID," and business code doesn't use bare "find by ID." So the normal way to query already includes the tenant filter, and forgetting it means the method doesn't exist. Second, the schema backs it up: because child rows reference their parents by the composite of ID and organization, even a query that somehow returned a cross-tenant row couldn't have linked that data together in the first place. And there's a dedicated family of tenant-isolation tests that I extend every time I add a tenant-owned resource.

Follow-up: How do you make sure the tests actually catch a regression?
The isolation tests are written as attacks. They seed both organizations, log in as one, and assert that the other's data is invisible through every access path — direct reads, list endpoints, and spoofed tenant parameters. Because they assert absence — "Green Valley's patient must not appear" — a regression that leaked cross-tenant data would make a test fail loudly. The rule in the project is that a new tenant-owned resource isn't done until it has a cross-tenant test proving another tenant's ID returns a secure 404.

Code reference: `auth/TenantIsolationIntegrationTest.java` (spoofed `?organizationId=` and `X-Organization-Id` ignored), `identity/TenantIsolationRepositoryTest.java`.

---

**Q9.5. How does tenant isolation apply to background jobs and events, which have no logged-in user? — Hard**

Answer:
This is the subtle part, because the request-scoped context that carries the tenant doesn't exist outside a web request. The design handles it by carrying the tenant *in the data*. The outbox event records the organization ID as part of the event when it's created inside the request transaction, and the Kafka message carries it as a header. So when a consumer processes the event, it knows which tenant it belongs to from the message itself, not from a session. The consumer then does its work scoped to that organization. The tenant travels with the work rather than being ambient, which is exactly what you need once you leave the synchronous request path.

Follow-up: What could go wrong if a consumer ignored the tenant on the event?
It could write a downstream record — a notification, say — against the wrong organization, or aggregate data across tenants, which would be a cross-tenant leak through the back door. That's why the tenant is a required field on the events the consumers rely on, and the consumer scopes its writes to it. It's the same principle as the synchronous side — the tenant is never assumed or guessed — just applied to asynchronous work by making the tenant part of the message contract. One honest limitation: a dead-lettered message with a missing organization ID can't be replayed by a tenant admin, which is a known edge I've documented rather than papered over.

Remember: "No session in async work → tenant rides in the event payload/headers. Consumers scope to it. Tenant is part of the message contract."

---

## 10. Consent management

**Q10.1. What is a consent directive? — Very basic**

Answer:
A consent directive is a record of a patient's decision about who can use their information and for what. It says something like "grant my care team access to my clinical narrative for care coordination" or "deny providers outside my care team access to this category." Directives are what the authorization system consults in the consent layer — they turn the patient's wishes into rules the backend actually enforces on every read.

Remember: "A consent directive = the patient's rule about who may use which data, for which purpose."

---

**Q10.2. What are the pieces of a consent decision? — Basic**

Answer:
A directive is scoped along a few dimensions: the data category it's about — like clinical context or demographics; the purpose — like care coordination; the scope or tier it applies to — the whole organization, the care team, or a specific provider; whether it's a grant or a deny; and an effective date window. When the system needs to decide whether an actor can see a controlled field, it gathers the applicable directives and resolves them into a single grant-or-deny for that actor, purpose, and category, at that moment in time.

Follow-up: What's a "purpose" and why include it?
Purpose is *why* the data is being accessed — care coordination, claims support, and so on. Including it means consent isn't just "who," it's "who, for what reason." A patient might allow their data to be used for treatment but not for some other purpose. In this app the purpose for a given read is fixed on the backend per action — the caller doesn't get to choose it — so you can't sidestep consent by claiming a more permissive purpose.

Remember: "Directive = category + purpose + scope/tier + grant/deny + date window. Purpose is backend-fixed per action, never client-chosen."

---

**Q10.3. What happens by default if there's no matching directive? — Medium**

Answer:
Deny. The consent engine is deny-by-default — if no applicable grant exists for that actor, purpose, and category, access is denied and the field is masked. This is the safe default for sensitive data: silence means no, not yes. You have to have an affirmative grant to see a controlled field. It's the opposite of a system that shows everything unless someone explicitly locks it down, which is how data leaks.

Follow-up: Isn't deny-by-default going to frustrate legitimate users with over-masking?
It could, if the grants weren't set up sensibly, so the demo seeds realistic directives. But I'd rather err toward masking and have someone request access than err toward exposure and leak. In a real deployment you'd pair deny-by-default with good defaults for common care scenarios and a clear way to request or record consent, so the friction is minimized without giving up the safe posture. The principle stays: the system never *assumes* consent.

Remember: "No matching grant = deny + mask. Silence means no. Affirmative grant required to see a controlled field."

---

**Q10.4. How are conflicting directives resolved? — Hard**

Answer:
Two rules working together. First, most-specific-tier-wins: directives are evaluated from most specific to least — a directive about a specific provider beats one about the care team, which beats one about the whole organization. The engine walks the tiers in that order and uses the first tier that has an applicable directive. Second, within that winning tier, deny wins over grant — if there's any applicable deny, access is denied. And underneath both, if nothing applies at all, it's deny-by-default. So specificity picks which directives are authoritative, and within them the safer answer wins.

Follow-up: Why most-specific-wins rather than, say, most-recent-wins?
Because specificity matches how people actually think about permissions. If a patient grants their whole care team access but specifically denies one provider, the specific deny should obviously win — that's the more precise expression of their intent. Most-recent-wins would make the outcome depend on the order directives happened to be recorded, which is fragile and surprising. Specificity gives a stable, intuitive result: the narrower, more deliberate statement governs. Deny-wins-within-a-tier then makes the tie-breaker always the safe direction.

Code reference: `consent/ConsentPolicy.java` — specificity order provider → care-team → organization, deny-wins within the matched tier, then deny-by-default.

---

**Q10.5. How is revocation and history handled — can a patient change their mind? — Hard**

Answer:
Yes, and it's handled without ever destroying history. Directives are versioned using a supersede pattern: you don't mutate a directive in place. Recording a change supersedes the current one and inserts a new version, and revoking flips the current directive to a revoked status. So at any time there's a clear "current" state — enforced so there's at most one active directive per natural key — but every past version is retained, which matters for an audit trail: you can show what the consent was at the time a given access happened. And because the consent engine re-checks the effective date window at decision time, a directive that's expired or not yet in force doesn't grant anything even if it's technically "active."

Follow-up: Does a revocation take effect immediately for in-flight access?
It takes effect on the next decision. Consent is evaluated at read time, on every controlled field, so the moment a revocation is committed, the next read consults the new state and masks accordingly — there's no cached "you're allowed" that lingers. In the UI, revoking a directive invalidates the relevant queries so a masked field can flip to "Restricted" live without a reload. What it can't do is retroactively un-see data someone already legitimately read — no system can — which is exactly why there's an audit trail recording who accessed what and when.

Remember: "Supersede, never mutate. One active per key, all versions kept. Consent evaluated at read time, so revocation applies to the next read. Date window re-checked live."

---

**Q10.6. A patient revokes consent while a claim that used their data is mid-adjudication. What happens? — Very hard**

Answer:
It depends on what the adjudication actually touches. Claims data — procedure codes, amounts, plan parameters — is claims-domain information, not the consent-controlled clinical narrative, so adjudication generally operates on data that isn't gated by the clinical consent directives; that's a deliberate design point, so a reviewer can process a claim without unrestricted medical context. So a revocation of clinical-narrative consent wouldn't stop the adjudication math. But for the parts of the system that *do* read consent-controlled fields, the revocation takes effect at the next read because consent is evaluated per-read, not cached — and everything is inside transactions, so you never get a half-applied state. The consistent story is: consent is checked at the moment of access on the fields it governs, adjudication runs on claim-relevant data by design, and the audit trail records what happened either way.

Follow-up: Isn't it a problem that adjudication can proceed on data after consent changes?
Only if adjudication were reading consent-controlled clinical data, and it deliberately isn't — a claim carries coded, claim-relevant data, not clinical narratives, which is one of the privacy design proofs in the project: the reviewer role can do its job without unrestricted access to medical context. Consent governs the sensitive clinical fields, which live elsewhere and are masked there. So there's a clean separation: consent protects the clinical context, and the claims pipeline runs on the minimum necessary financial and coded data. That separation is what lets both statements be true at once — consent is strictly enforced, and claims processing isn't blocked by it.

Remember: "Adjudication runs on coded claim data, not consent-controlled clinical narrative (minimum-necessary). Consent is enforced per-read on the fields it governs. Clean separation, both true at once."

---

## 11. Healthcare workflows

**Q11.1. What is a service request and how does it move through the system? — Basic**

Answer:
A service request is a unit of care-coordination work — a request about a patient that a team acts on. It moves through a state machine: it starts as a draft, gets submitted, triaged, assigned to someone, reviewed, possibly sent back for more information, and finally approved, rejected, cancelled, or closed. Each move is a controlled transition — you can't jump from draft straight to approved — and every transition is recorded in a history table so there's a full timeline of who did what and when.

Follow-up: Why model it as an explicit state machine instead of just a status field?
Because a plain status field lets anyone set any value, which allows nonsensical or unsafe transitions. Modeling it as a state machine means the legal moves are defined in one place, and the backend rejects an illegal one with a specific "invalid transition" error. It also makes the workflow self-documenting and gives you the history for free, since every valid move writes a history row. The status field becomes a controlled thing rather than a free-for-all.

Remember: "Service request = care-coordination work item on a controlled state machine, with a full transition history."

---

**Q11.2. How are the state transitions actually enforced? — Medium**

Answer:
The legal transitions live in a pure policy class — a plain table of "from this status, these moves are allowed." When a transition is requested, the service checks things in a fixed order: does the record exist, is the move legal from the current status, does the caller's role permit it, is a reason supplied if one's required, and does the version match for optimistic locking. Only if all pass does it update the status and write the history row, in one transaction. Keeping the transition table in a pure class means I can unit-test every allowed and disallowed move exhaustively without touching the database.

Follow-up: Some statuses can't be reached by a plain status change — why?
Because some transitions require extra work that must happen atomically with the status change, so they get a dedicated command instead of a bare status update. Assigning a request is the example: reaching the "assigned" status also has to record *who* it's assigned to, so it goes through an assignment endpoint that records the assignee and advances the status together, and a plain status-change to "assigned" is refused. Same idea in claims — reaching "adjudicated" runs the engine, so you can't just set that status by hand. The rule is: if reaching a status requires a side record, make it a command, not a settable value.

Remember: "Transition order: exists → legal move → role → reason → version → update + history, one tx. Some statuses are command-only (assign, adjudicate)."

---

**Q11.3. How are providers connected to patients? — Medium**

Answer:
Through care relationships — assignments. A provider is linked to a patient by an active provider-patient assignment, and coordinators are linked by a parallel coordinator assignment. These are effective-dated and versioned: at most one is current per patient-provider pair, and "changing" an assignment supersedes the old one and creates a new one rather than editing in place, so history is preserved. Together, the provider and coordinator assignments define a patient's care team, which is exactly what the consent engine's care-team tier refers to. So the relationship data does double duty — it gates provider access to patients and it defines who counts as the care team for consent.

Follow-up: Why effective-dated and versioned instead of a simple link?
Because care relationships change over time and you need to know what was true historically — who was on the care team when a given access or decision happened. A simple link that you edit or delete loses that. The supersede pattern keeps every version with its date range, so the current state is clear but the past is reconstructable. It also enforces the "at most one current" invariant with a partial unique index, so you can't accidentally end up with two active assignments for the same pair.

---

**Q11.4. How does concurrency show up in the workflow, and how is it handled? — Hard**

Answer:
The classic case is two coordinators acting on the same request at nearly the same time — both load it, both try to transition it. Without protection, the second write could silently overwrite the first, and you'd lose a transition. That's handled by optimistic locking: each transition includes the version the caller read, and if the record changed in between, the versions don't match and the second one gets a conflict instead of clobbering the first. The frontend then reloads and shows the current state. So concurrent edits are safe — one wins cleanly and the other is told to refresh, rather than a last-write-wins data loss.

Follow-up: Why is a 409 conflict the right response rather than merging?
Because these are discrete state transitions, not text you can merge. If one coordinator assigned the request and another tried to reject it from the old state, there's no sensible automatic merge — the second action was decided against stale information. The honest thing is to reject it and make the person look at the current state and decide again. Merging would risk applying an action the user wouldn't have chosen had they seen the truth. For state machines, "reload and re-decide" is safer than any automatic reconciliation.

Remember: "Concurrent transitions → optimistic lock → the stale one gets a 409, reloads, re-decides. No silent overwrite, no risky auto-merge."

---

**Q11.5. How would you extend the workflow with a new state or a new participant role without breaking existing behavior? — Very hard**

Answer:
Because the transitions live in a pure policy table and the enforcement order is uniform, adding a state is mostly a matter of extending that table with the new legal moves and adding the handling for the new status, plus a migration if it needs new columns. The uniform check order — exists, legal move, role, reason, version — means the new state automatically inherits the safety machinery. For a new participant role, I'd add it to the role model and specify which transitions it's allowed to make in the policy. The thing I'd be careful about is history and existing records: a new state has to make sense for records already in flight, and I'd want tests covering the new transitions, including the illegal ones, before trusting it. The design deliberately makes this kind of extension additive rather than a rewrite.

Follow-up: What's the risk when you add a state to a machine that already has live data?
Existing records are in old states, and you have to make sure every old state has a sensible path forward under the new rules — you don't want to strand records in a status that can no longer transition anywhere. So I'd map out reachability from every existing status, add migrations if any records need to move, and write tests that start from each old state. The pure transition table helps here because I can reason about and test the whole graph in isolation before any of it touches real records.

---

## 12. Claims processing & adjudication

**Q12.1. What is a claim in this system? — Basic**

Answer:
A claim is a bill for medical services submitted for payment. It has a header with patient, dates, and totals, and one or more lines, each billing a specific procedure code with a charge amount. The total is computed on the backend from the lines, not trusted from the client. A claim moves through its own state machine — draft, submitted, accepted or rejected, and adjudicated — and adjudication is the step that turns an accepted claim into an explainable payment decision.

Follow-up: Why compute the total on the backend instead of taking it from the request?
Because the total is money, and the client is never trusted with correctness. If the client sent the total, a bug or a malicious request could claim a total that doesn't match the lines. Computing it from the lines on the backend means the number is always internally consistent with what's actually being billed. It's the same principle as never trusting the client for tenant or roles — anything that matters is derived server-side.

Remember: "Claim = header + procedure-code lines. Total computed backend-side. Own state machine → adjudication produces the payment decision."

---

**Q12.2. What does the adjudication engine do, in plain terms? — Basic**

Answer:
It takes an accepted claim and figures out, for each line and overall, how much the insurance plan pays and how much the patient owes, and it records exactly how it got there. It finds the coverage in effect on the service date, then applies the plan's rules in a set order — the allowed amount, the copay, the deductible, the coinsurance, and the out-of-pocket maximum — to split each line into plan-paid versus member-responsibility. The result is immutable and fully itemized, so for any decision you can show which plan applied and how every dollar was computed. That explainability is the whole point.

Follow-up: What makes it "deterministic and explainable"?
Deterministic means the same claim and plan always produce the same result — the calculation is pure, with no randomness or hidden state. Explainable means it doesn't just output a number; it records the breakdown per line: allowed, copay, deductible applied, coinsurance, out-of-pocket adjustment, plan paid, member owes. So a reviewer or a patient can see not just *what* was decided but *why*, line by line. In a domain where people dispute bills, "here's exactly how we computed this" is essential.

Remember: "Adjudicate = find coverage on service date → apply allowed→copay→deductible→coinsurance→OOP cap → record plan-paid vs member-owes per line. Deterministic + itemized."

---

**Q12.3. Walk through the order of the calculation with a worked example. — Medium**

Answer:
The order per line is: allowed amount, then copay, then deductible, then coinsurance, then the out-of-pocket cap. Let me use a checked example. Say a line has a charge of $200, the plan's allowed amount for that procedure is $150, there's a $20 copay, the patient has $50 of deductible still remaining this year, and coinsurance is 20%. First, allowed is the lesser of charge and the plan's allowed, so $150 — the plan never pays on more than it allows. Take the $20 copay off, leaving $130. Apply the remaining deductible, $50, leaving $80 — the patient pays that $50. Coinsurance is 20% of the remaining $80, so $16 to the patient. So the member owes $20 + $50 + $16 = $86, and the plan pays $150 − $86 = $64. That's before the out-of-pocket cap, which would cap the member's share if they'd already hit their yearly max. This is a synthetic example to illustrate the mechanics.

Follow-up: How is the money handled precisely — no floating-point errors?
All money uses `BigDecimal` with a scale of two decimal places and half-up rounding, applied consistently through a single money-normalizing helper. Floating-point types like `double` can't represent many decimal fractions exactly, so using them for currency leads to rounding drift — the classic $0.01 discrepancies. `BigDecimal` gives exact decimal arithmetic, and fixing the scale and rounding mode in one place means every amount is rounded the same way, so the line amounts always reconcile to the totals.

Code reference: `adjudication/AdjudicationCalculator.java` — pure, `money()` sets scale 2 HALF_UP; order allowed → copay → deductible → coinsurance → OOP.

---

**Q12.4. What are the possible outcomes for a claim line, and how do they interact? — Medium**

Answer:
A line can be covered, not-covered, auth-required, or out-of-network. Covered means it goes through the full cost-sharing math I described. The other three mean the plan pays nothing and the member owes the charge, and importantly they skip the cost-sharing math entirely — so they don't consume the deductible or out-of-pocket. Not-covered happens when the plan excludes that procedure. Auth-required happens when the plan requires prior authorization for that procedure and there's no approved authorization covering the service date. Out-of-network happens when the plan defines a network and the claim's rendering provider isn't in it. When more than one could apply, there's a precedence: exclusion beats out-of-network beats auth-required.

Follow-up: Why does precedence matter, and why that order?
Because a line might trip more than one rule, and you need one deterministic outcome, not an ambiguous mix. The order reflects how absolute each reason is. An exclusion is the plan flatly not covering that procedure — that's final, so it wins. Out-of-network is the next most fundamental — even a covered, authorized service isn't paid if it's out of network. Auth-required is the most "fixable" — approve the authorization and re-adjudicate and it becomes covered. So the ordering runs from most-absolute to most-recoverable, which gives a sensible, explainable single outcome.

Remember: "COVERED / NOT_COVERED / AUTH_REQUIRED / OUT_OF_NETWORK. Non-covered ones skip cost-sharing (no deductible/OOP use). Precedence: exclusion > out-of-network > auth-required."

---

**Q12.5. How does the deductible carry across multiple claims for the same patient? — Hard**

Answer:
Through a benefit accumulator — a row per patient, plan, and benefit year that tracks how much deductible and out-of-pocket has been met so far. When a claim is adjudicated, the engine reads that accumulator to find the *remaining* deductible, uses it in the calculation, and updates it — all inside the adjudication transaction, under a pessimistic row lock so concurrent adjudications for the same patient can't both consume the same deductible. So the first claim of the year might exhaust the deductible, and the next claim sees zero remaining and jumps straight to coinsurance. Once the out-of-pocket max is met, the accumulator reflects that and the plan pays 100%. The running totals are the memory that makes claims interact correctly across a year.

Follow-up: What happens under concurrency — two claims for the same patient adjudicated at once?
That's exactly what the pessimistic lock protects. Each adjudication does an insert-if-absent to guarantee the accumulator row exists, then a `SELECT ... FOR UPDATE` to lock it. The second adjudication blocks until the first commits, then reads the *updated* remaining deductible. So they serialize on that row — the deductible is applied once, correctly, across both, instead of both reading the same starting value and double-applying it. That's the one place I chose pessimistic locking over optimistic, precisely because the cost of a lost update here is wrong money.

Remember: "Benefit accumulator (patient, plan, year) tracks deductible/OOP met. Read-and-update under a row lock inside the adjudication tx → concurrent claims serialize, no double-spend."

---

**Q12.6. How does re-adjudication work without corrupting the running totals? — Very hard**

Answer:
Re-adjudication re-runs the engine on an already-adjudicated claim — for example after a plan config fix or an overturned appeal — and it writes a new immutable version rather than editing the old one, so the full history is retained. The danger is the accumulator: the original adjudication already consumed some deductible and out-of-pocket, so a naive re-run would double-count. So before recomputing, the engine backs out the prior version's contribution — it reads what that version applied to the accumulator and subtracts it — and then recomputes under current coverage and config. The old version stays on record; the latest version is what's current. That way the accumulator ends up as if only the new decision had ever been applied, even though both are kept for audit.

Follow-up: What's an honest limitation of this re-adjudication?
It reverses and recomputes *this claim only*, not the other claims in the same benefit year. In reality, if a mid-year plan change affected a patient's deductible, every subsequent claim's math could shift, and truly correct behavior would re-cascade through all of them in order. I chose to keep re-adjudication scoped to a single claim because a full year-wide re-cascade is significantly more complex and I could reason about and verify the single-claim version confidently. The batch reprocessing feature re-runs a plan's claims, but each is still handled independently. It's a deliberate, documented simplification, and I can explain exactly what a fuller version would require.

Remember: "Re-adjudicate = back out the prior version's accumulator contribution, then recompute as a new immutable version. Limitation: this claim only, not a year-wide cascade."

---

**Q12.7. What advanced claims features exist beyond basic adjudication? — Hard**

Answer:
A set of them, each a small aggregate with its own state machine following the same patterns. Prior authorization — pre-approving a planned procedure, which adjudication then honors. Referrals — a coordinator routing a patient to a specialty. Appeals — disputing a claim's decision, where an overturn re-runs adjudication in the same transaction as the overturn. Anomaly signals — an advisory detector that flags things like a possible duplicate claim or an unusually high charge, purely additive so it never changes the claim's status or math. Manual review cases that a reviewer opens and resolves. And batch reprocessing — re-running a plan's claims after a config change. They demonstrate breadth, but they all reuse the same building blocks: pure transition policies, one-transaction writes with history, patient-gated access, and immutable records.

Follow-up: The anomaly detector — is it a real fraud model?
No, and I'm careful to say so. It's a deterministic, explainable heuristic — for example, "another claim for this patient shares this service date and a procedure code" flags a possible duplicate, and a total above a configurable threshold flags a high charge. It's a demo detector, not a trained or measured fraud model, and it's advisory only: it emits signals for a human reviewer, it doesn't block or change anything automatically. Claiming it was a real fraud model would violate the no-unmeasured-claims rule.

---

## 13. Document management

**Q13.1. How does document upload and download work? — Basic**

Answer:
A user uploads a file for a patient — say a PDF — as a multipart request. The file's metadata goes into the database: the file name, content type, size, an opaque storage key, a scan status, and who uploaded it. The bytes themselves go behind a storage abstraction — a local filesystem stand-in in development, and private S3 in the cloud shape. To download, the request re-checks authorization, confirms the file passed its malware scan, and streams it back as an attachment. The bytes never pass through a JSON response, a log, or an event — they're kept entirely separate from the metadata.

Follow-up: Why separate the bytes from the metadata behind an abstraction?
So the rest of the system never needs to know where or how the bytes are stored. The metadata is queryable and access-controlled in the database; the bytes live in a blob store optimized for that. The storage abstraction means I can swap a local filesystem for S3 without touching any of the access logic — the code just asks the abstraction for the bytes by key. It also keeps large binary data out of the database, which isn't the right place for it.

Remember: "Metadata in Postgres (name, type, size, storage key, scan status, uploader); bytes behind a storage abstraction (local → S3). Bytes never enter JSON/logs/events."

---

**Q13.2. How is access to documents controlled? — Medium**

Answer:
Documents inherit the same patient access model as everything else. Every document read and write routes through the patient access guard, so an assigned provider or the patient themselves can reach a patient's documents, while an unassigned provider or another tenant gets a secure 404 — the document appears not to exist. Uploads are further restricted to specific roles — the patient on their own record, coordinators, and admins — so a provider can read but not upload, for instance. Because it goes through the same guard as patient data, I didn't have to build a separate document-permission system; it composes with the existing layers.

Follow-up: What stops someone from guessing a storage key and grabbing a file directly?
The storage key is opaque and never the thing that authorizes access — download goes through the application endpoint, which re-runs the full authorization before it ever asks storage for the bytes. And in the cloud shape the bucket is private, so there's no public URL to hit directly. So even if someone knew a key, they couldn't retrieve the file without passing the app's access checks, and they can't reach the bucket directly. Authorization is on the request, not on knowledge of the key.

Remember: "Documents route through the same PatientAccessGuard (secure 404). Upload role-restricted. Download re-authorizes before fetching bytes; private bucket, no direct URL."

---

**Q13.3. How does malware scanning and quarantine work? — Medium**

Answer:
On upload, the file is scanned and its metadata gets a scan status — pending, clean, or quarantined. Download only serves files that are clean; a quarantined or still-pending file is refused with a specific "not available" error rather than a secure 404, because the caller already sees the file in the listing with its status — hiding it would be confusing, whereas a clear "not available yet / blocked" is honest. In development the scanner is a stand-in that recognizes the standard antivirus test signature so I can demonstrate the quarantine path without real malware.

Follow-up: Why a specific "not available" error instead of the secure 404 you use elsewhere?
Because the two situations protect different things. The secure 404 exists so an unauthorized caller can't learn a record exists. But for a quarantined document, the caller is *authorized* — they can see it listed with its status — so there's no existence to hide; the honest response is "you can see this exists, it's just blocked or not scanned yet." Using a 404 there would wrongly imply the file vanished. Matching the error to what the caller legitimately knows is the theme — 404 when existence is secret, a clear status error when it isn't.

Remember: "Scan status pending/clean/quarantined. Only clean downloads. Quarantined/pending → clear 'not available' (caller already sees it listed), not a secure 404."

---

**Q13.4. Scanning is synchronous now — how would you make it asynchronous and what changes? — Very hard**

Answer:
Today the scan happens inline on upload, which is simple but means the upload request waits for the scan and doesn't scale to large files or slow scanners. The asynchronous version would accept the upload, store the bytes, mark the document pending, and emit an event through the outbox saying "scan this document." A worker consumes that event, runs the scan, and flips the status to clean or quarantined. The download rule doesn't change — it still only serves clean files — so during the window between upload and scan completion, the file is simply pending and not downloadable, which is the safe default. The pieces to add are the event, the worker, and idempotent handling so a redelivered scan event doesn't cause problems.

Follow-up: What new failure modes does going async introduce?
A few. A scan event could be lost or the worker could crash mid-scan — handled by the same at-least-once outbox plus idempotent consumer approach, with a dead-letter path for scans that keep failing. A file could sit pending indefinitely if the worker is down, so you'd want monitoring on scan backlog and pending age. And you have to make sure a pending file is never servable, which is already the rule. The trade-off is real: async scales and decouples, but it turns a simple synchronous guarantee into a distributed one that needs retries, dead-lettering, and monitoring — which is exactly the machinery the event-driven layer already provides, so it would reuse it rather than invent new infrastructure.

Remember: "Async scan = upload → pending → outbox 'scan' event → worker → clean/quarantined. Download rule unchanged. New concerns: lost/failed scans (DLT), pending backlog monitoring."

---

## 14. Event-driven architecture

**Q14.1. Why is there an event-driven layer at all? — Basic**

Answer:
Because some work should happen *as a consequence* of a change but shouldn't hold up the change itself or be tightly coupled to it. When a claim is adjudicated, downstream things might need to know — a notification feed, and in a real system things like reporting or external integrations. Doing all that synchronously inside the adjudication request would make it slow and fragile, and would couple adjudication to every consumer. So adjudication just records that it happened, commits, and returns; the event fans out asynchronously to whoever cares. Producers don't know their consumers.

Follow-up: What technology backs it?
A transactional outbox in PostgreSQL plus Apache Kafka. The outbox is how the event gets recorded reliably as part of the database transaction, and Kafka is how it's delivered to consumers. Locally Kafka runs in a container; in the cloud shape I proved the design without a managed broker because a managed one is expensive and the pattern is fully demonstrable locally.

Remember: "Event-driven so after-effects don't block or couple to the change. Transactional outbox (Postgres) + Kafka. Producers don't know consumers."

---

**Q14.2. What problem does the transactional outbox solve? — Medium**

Answer:
The dual-write problem. If adjudication committed its database change and *then* separately published to Kafka, those two writes aren't atomic — the database commit could succeed and the Kafka publish fail, or vice versa, leaving the system inconsistent: a claim marked adjudicated with no event, or an event for a change that rolled back. The outbox fixes this by making the event just another row written in the *same* database transaction as the domain change. So either both the change and the event row commit, or neither does. A separate relay process then reads committed event rows and publishes them to Kafka after the fact. The database transaction is the single source of atomicity.

Follow-up: So how does the event actually get to Kafka after it's in the outbox table?
A scheduled relay polls the outbox table for rows that were committed but not yet published, sends each to Kafka — using the event type as the topic and the aggregate ID as the key — and then stamps the row as published. A partial index makes finding unpublished rows cheap. If the relay crashes after publishing but before stamping, the row looks unpublished next time and gets republished — that's the at-least-once behavior, which is safe because consumers are idempotent.

Remember: "Outbox solves dual-write: event row committed in the same tx as the change (atomic). A relay publishes committed rows to Kafka after commit, then stamps them published."

---

**Q14.3. How do you avoid processing the same event twice? — Medium**

Answer:
Idempotent consumers. Because the relay is at-least-once, a consumer can receive the same event more than once, so each consumer dedupes on the event's unique ID: if it has already recorded that event ID, it skips it. There's a unique constraint on the event ID as a backstop, so even a race where two deliveries arrive nearly simultaneously can't create duplicates — the second insert fails the constraint and is treated as already-processed. The combination — at-least-once delivery plus idempotent consumers — gives the practical effect of exactly-once without the enormous difficulty of true exactly-once across a database and a broker.

Follow-up: Why not just aim for exactly-once delivery?
Because exactly-once across independent systems — a database and a message broker — is famously hard and often not truly achievable end to end; what people usually call exactly-once is really at-least-once plus idempotency somewhere. So rather than chase a fragile guarantee at the delivery layer, I made delivery reliably at-least-once and made the consumers idempotent, which is simpler to reason about and robust. The dedup key is the thing that makes duplicate deliveries harmless, and that's a small, testable piece of logic.

Remember: "At-least-once delivery + consumers dedup on event ID (unique constraint backstop) = effectively-once. Chasing true exactly-once isn't worth it."

---

**Q14.4. What happens when a consumer keeps failing to process a message? — Hard**

Answer:
There's a retry-then-dead-letter strategy. A failing message is retried a bounded number of times with a backoff. If it still fails, it's sent to a dead-letter topic instead of blocking the partition forever. A drainer then captures dead-lettered messages into a database table so "what's stuck" becomes an ordinary, queryable thing rather than something buried in Kafka. An admin can inspect those and trigger a replay, which re-publishes the message onto its source topic to be processed again. Some failures are treated as non-retryable — a structurally malformed message or a bad header will never succeed on retry, so those go straight to the dead-letter path rather than wasting retries.

Follow-up: Why distinguish retryable from non-retryable failures?
Because retrying a transient failure — a brief database hiccup — is exactly right, but retrying a permanent one — a message whose payload can't be parsed — is pointless and harmful. Retrying the unparseable message just burns attempts and delays everything behind it, and it'll fail identically every time. So structural failures are marked non-retryable and dead-lettered immediately, while transient ones get their backoff-and-retry budget. It's about not letting a poison message block the queue, and not wasting effort on failures that can't improve.

Remember: "Retry with backoff → dead-letter topic → drain to a DB table → admin inspect/replay. Structural failures skip retries (poison message won't improve)."

---

**Q14.5. Explain how replay stays safe given it re-publishes a message. — Very hard**

Answer:
Replay re-publishes a stored dead-letter message onto its source topic so a consumer can try again. The tricky part is doing that reliably alongside marking the record replayed, without the Kafka send being trapped inside a database transaction. So the replay service runs without an ambient transaction, publishes to Kafka first, and *then* delegates to a separate transactional method that stamps the record as replayed and writes an audit event atomically. The order matters: publish first, then mark. If it crashes after publishing but before marking, a retry just re-publishes — and that's harmless, because the consumer is idempotent and will dedupe the redelivery on its event ID. An already-replayed record is refused to prevent an obvious double, and cross-tenant access is a secure 404.

Follow-up: Why publish-first-then-mark rather than mark-then-publish?
Because the failure modes are asymmetric. If I marked it replayed first and then the publish failed, the record would claim it was replayed when the message never actually went out — a silent loss, the worst case. Publishing first means the only failure window leaves a record that *looks* un-replayed, so a retry re-publishes — a duplicate, which the idempotent consumer safely absorbs. Given a choice between "might silently lose the message" and "might harmlessly send it twice," you always pick the harmless duplicate. Idempotency is what makes that safe to choose.

Remember: "Replay: no ambient tx, publish to Kafka FIRST, then mark-replayed + audit in a tx. Crash → re-publish → consumer dedups. Never mark-then-publish (silent loss)."

---

## 15. Notifications

**Q15.1. How do notifications work? — Basic**

Answer:
Notifications are driven by events, not by the code that made the change. When a claim is adjudicated, the outbox publishes an event, and a consumer builds a notification record from that event — an in-app notification feed of adjudication outcomes. The consumer builds the notification purely from the event's contents; it doesn't go re-read the claim. That keeps notifications loosely coupled — the adjudication code has no idea notifications exist, it just records what happened, and the notification side reacts.

Follow-up: Why build the notification from the event rather than re-reading the claim?
Loose coupling and resilience. If the consumer re-read the claim, it would be tightly bound to the claim module and could see a *later* state than the event describes, or fail if the claim changed. Building purely from the event means the notification reflects exactly the fact that occurred, the consumer doesn't depend on the producer's tables, and it can run entirely independently. The event is a self-contained, PHI-free description of what happened, which is all the notification needs.

Remember: "Notifications are event-driven: consumer builds them from the event alone, never re-reading the source. Loose coupling."

---

**Q15.2. How do you keep sensitive data out of notifications and events? — Medium**

Answer:
By making events carry the minimum necessary, PHI-free information — a claim adjudicated event has the claim ID and number, the version, the outcome, and the money split, but no patient identifiers and no clinical narrative. That's a hard project rule: no sensitive data in logs, errors, or event payloads. So notifications built from those events are inherently free of protected data too. If a notification needs to be shown to a specific user, the display layer resolves what that user is allowed to see at render time through the normal authorization — the event itself never carries the sensitive bits.

Follow-up: Why is it important that events specifically are PHI-free?
Because events flow through Kafka and get stored in outbox tables, consumer tables, and potentially dead-letter tables — they spread and persist across the system, sometimes outside the tight access controls around the primary data. If an event carried protected health information, every one of those places would become a place PHI could leak. Keeping events to non-sensitive identifiers and coded outcomes means the messaging layer never becomes a privacy hole, no matter how far a message travels or how long it sits in a dead-letter table.

Remember: "Events carry minimum-necessary, PHI-free data (IDs, outcome, amounts). Messaging spreads and persists, so it must never carry sensitive data."

---

**Q15.3. What are the current limitations of notifications, honestly? — Hard**

Answer:
It's an in-app feed built from adjudication events — it's a proof of the event-driven pattern more than a full notification product. There's no email or push delivery wired up, no user preferences for what to be notified about, and no digesting or grouping. Those would be real features to add: an email channel would itself go through the reliable event path with its own retries and dead-lettering, and delivery to an external email provider would need idempotency so a retry doesn't send the same email twice. I'd rather describe what's actually there — a reliable, idempotent, PHI-free in-app feed — than overstate it as a complete notification system.

Follow-up: If you added email, how would you stop duplicate sends on a retry?
The same event-ID idempotency idea, extended to the side effect. Before sending, the email worker would check whether it had already sent for that event ID, and record the send atomically. Since the outbox is at-least-once, without that check a redelivered event would send a second email. External providers often also accept an idempotency key on their send API, which I'd use as a second layer. The principle carries straight over from the consumers: at-least-once delivery is fine as long as the *effect* is idempotent.

---

## 16. Testing

**Q16.1. What kinds of tests does the project have? — Basic**

Answer:
A layered set. On the backend there are unit tests for the pure policy classes — the state machines, the consent evaluator, the adjudication calculator — which are fast and exhaustive because they have no dependencies. Then integration tests that run against a real PostgreSQL, and full HTTP tests that spin up the app on a real port and exercise real sessions and CSRF. On the frontend there are component and hook tests with Vitest and React Testing Library, plus an automated accessibility check. Altogether it's a measured 694 tests — 511 backend and 183 frontend — as of the last full run.

Follow-up: Why test against a real database instead of mocking it?
Because a lot of the correctness lives *in* the database interaction — the tenant-scoped queries, the composite foreign keys, the row locks, the constraint-backed uniqueness. Mocking the database would test my mock, not the actual behavior, and would completely miss things like a constraint violation or a query that isn't really tenant-scoped. Using a real Postgres in a container means the tests exercise the same database behavior as production, so they catch the bugs that matter here.

Remember: "Unit (pure policies) + integration (real Postgres) + full HTTP (real port, real session/CSRF) + frontend Vitest + axe. Measured 694 (511 backend, 183 frontend)."

---

**Q16.2. How do the integration tests use real infrastructure? — Medium**

Answer:
With Testcontainers, which starts a real PostgreSQL — and where needed a real Kafka — in a Docker container for the tests, and wires the app to it automatically. So the tests run against genuine Postgres 17, not an in-memory substitute that behaves differently. For the full HTTP tests, the app boots on a random real port and the test acts like a real client using a plain HTTP client — it logs in, does the CSRF handshake, and makes real requests with real cookies. That proves the whole stack works together: the security filters, the session, CSRF, the controllers, the services, and the database.

Follow-up: Why the full random-port HTTP tests instead of the lighter mock-MVC approach?
Because the lighter approach doesn't run the full session and security filter chain the same way, and session plus CSRF behavior is central to this app's correctness. By booting a real server and using a real HTTP client, the test exercises exactly what a browser would — the session cookie, the CSRF token handshake, the 401 when the session is invalidated. That's the only way to truly verify the authentication and CSRF flow end to end rather than a simulation of it.

Code reference: `TestcontainersConfiguration.java` (`@ServiceConnection` Postgres 17), `auth/AuthenticationSessionIntegrationTest.java` (RANDOM_PORT + JDK HttpClient + CSRF handshake).

---

**Q16.3. Why do you emphasize negative and security tests? — Medium**

Answer:
Because in a security-and-privacy system, the proof isn't that the happy path works — it's that the wrong thing is *prevented*. So the most important tests assert absence and denial: a NorthCare user cannot see Green Valley's data; an unassigned provider gets a secure 404; a consent denial masks a field; an illegal state transition is rejected; a spoofed tenant ID is ignored. These negative tests *are* the acceptance criteria — the project's definition of done for each phase was a negative outcome, and the test encodes it. A regression that opened a hole would make one of these fail loudly.

Follow-up: Give an example of a negative test catching something a positive test would miss.
A positive test confirms an assigned provider can read their patient — but it says nothing about isolation. The negative test that an *un*assigned provider gets a 404 is what actually proves the relationship gate works. If someone refactored the guard and accidentally let any provider through, the positive test would still pass — the assigned provider still reads their patient — while the negative test would fail. The denial is the real assertion; the success is almost incidental.

Remember: "Negative tests = the real proof. Cross-tenant denial, secure 404, consent masking, invalid transition, tenant spoofing. They ARE the acceptance criteria."

---

**Q16.4. What's not tested, and how do you talk about that honestly? — Hard**

Answer:
Two notable gaps I'm upfront about. There's no end-to-end browser test suite — Playwright is in the intended stack and I have an automated accessibility check at the component level, but a full Playwright end-to-end gate is a documented follow-up, not something I built. And the accessibility testing has a real limitation: the automated axe check runs in a JavaScript DOM that can't actually render, so it can't check color contrast — that I verified manually in a browser. So I describe the accessibility work as "AA-aligned," meaning automated checks plus manual verification on core screens, not certified. Being precise about the boundary of what's tested is part of the honesty rule.

Follow-up: If you added Playwright end-to-end tests, what would you cover first?
The critical flows that cross the whole stack and are hardest to verify with unit tests — logging in through Cognito and landing authorized, the cross-tenant denial actually behaving as a 404 in the browser, and a full claim lifecycle from creation through adjudication with the breakdown rendering correctly. Those are the flows where a subtle integration bug between frontend, session, and backend could hide, and where a real-browser test adds the most confidence beyond what the component and HTTP tests already give.

Remember: "Honest gaps: no Playwright E2E (follow-up); axe can't check contrast in jsdom (verified manually) → 'AA-aligned', not certified."

---

**Q16.5. How do you make tests deterministic and independent, especially with shared infrastructure? — Very hard**

Answer:
A few disciplines. The pure policy tests are inherently deterministic — no clock, no I/O, no shared state. The integration tests get a real database per run via Testcontainers and seed the data they need, so they don't depend on each other's leftovers. Kafka tests are isolated — the relay and consumers are disabled by default across the suite so they don't fire unexpectedly, and the specific Kafka tests either drive the relay directly or re-enable consumers explicitly, so timing is controlled rather than racy. And where the code has a real ordering concern — like the outbox relay or the accumulator lock — the tests assert the invariant directly, for example checking the history row was written, rather than relying on wall-clock timing.

Follow-up: Asynchronous tests are notoriously flaky — how do you avoid that?
By not testing async through arbitrary sleeps. Instead of "wait two seconds and hope the consumer ran," the tests drive the mechanism deterministically — publish directly and then assert the consumer's effect, or invoke the relay's publish step explicitly — so there's no race to lose. Disabling the background schedulers by default is key: it means nothing fires on its own timing during a test, and each test triggers exactly the step it's verifying. Flakiness usually comes from tests depending on timing they don't control, so the fix is to take control of the timing.

Remember: "Determinism: pure tests are triv, fresh Testcontainers DB + own seed per run, schedulers off by default, drive async explicitly (no sleeps), assert invariants not timing."

---

## 17. Cloud & infrastructure

**Q17.1. Where and how is the app deployed? — Basic**

Answer:
Two ways, on purpose. There's a production-shape deployment on AWS using ECS Fargate for the containers, RDS for PostgreSQL, CloudFront in front for HTTPS, and Cognito for auth — all defined in Terraform. That's the "here's how I'd really run it" showcase, but it's expensive to leave running, so it's stood up on demand, evidence captured, then torn down. Separately, there's an always-on demo on a single small EC2 box running everything with Docker Compose behind Caddy for automatic HTTPS — that's the live link recruiters can click any time, at about a fifth of the cost. Same application and data in both; only the hosting differs.

Follow-up: Why maintain two deployments instead of one?
Because they serve different goals that conflict. The ECS stack demonstrates production-grade cloud architecture — managed database, load balancing, container orchestration, infrastructure as code — which is the engineering credibility. But it costs roughly $70 a month to leave on, which isn't worth it for a link nobody might visit for days. The single EC2 box is always up for about $15 a month, so the portfolio link is reliably live. Keeping both lets me have the impressive architecture *and* an always-on demo without paying for the expensive one around the clock. The credibility comes from the code, the infrastructure-as-code, and the evidence pack, not from where the live link happens to point.

Remember: "Two deploys: ECS/Fargate/RDS/CloudFront (Terraform, production-shape, on-demand) + always-on single EC2 + Docker Compose + Caddy (live link, ~$15/mo). Same app."

---

**Q17.2. What AWS services are actually used, and what does each do? — Medium**

Answer:
In the production-shape stack: ECS Fargate runs the containers without me managing servers; RDS runs a managed PostgreSQL in private subnets; an Application Load Balancer and CloudFront provide the entry point and HTTPS; ECR stores the container images; Cognito is the identity provider; Secrets Manager holds the database and Cognito secrets; and it all sits in a VPC with public and private subnets. Terraform defines every bit of it. On the always-on side: one EC2 instance, an Elastic IP, SSM Parameter Store for secrets, and SSM Session Manager for shell access instead of SSH. Both keep all data synthetic.

Follow-up: Why no NAT gateway in the network design?
Cost, deliberately. A NAT gateway runs around thirty dollars a month just to let private resources reach the internet. In this design the containers run in public subnets with their own public IPs, so they can pull images and reach AWS services directly without a NAT, and the database sits in private subnets with no internet access at all — which it doesn't need. So I saved the NAT cost by giving the compute direct egress and keeping only the database private. It's a documented trade-off: slightly less conventional than compute-in-private-subnets, but appropriate and much cheaper for this scale.

Remember: "ECS Fargate, RDS (private), ALB+CloudFront, ECR, Cognito, Secrets Manager, VPC — all Terraform. EC2+EIP+SSM for the always-on box. No NAT gateway (compute in public subnets) saves ~$32/mo."

---

**Q17.3. How are secrets handled in the cloud? — Medium**

Answer:
Never in the code, never in the container image, never in Terraform state as plaintext. The database password is managed by AWS — RDS generates it and stores it in Secrets Manager, and the app reads it at runtime through an IAM permission. The Cognito client secret is stored the same way. On the always-on EC2 box, secrets are generated by Terraform and delivered through SSM Parameter Store as encrypted values, which the instance reads once at boot using its instance role — so they're never baked into the machine's startup script. The principle is that secrets live in a dedicated secret store and are fetched at runtime by an identity with permission, rather than traveling with the code.

Follow-up: Why does it matter that the DB password isn't even in Terraform state?
Because Terraform state is a file that records everything Terraform manages, and if the password were set by Terraform it would sit in that state in readable form — and state files get stored, backed up, and sometimes shared. By having RDS manage the password and only referencing the secret's ARN, the actual password never enters state at all; Terraform only knows *where* the secret is, not what it is. That closes off state files as a place credentials could leak, which is a real and commonly-overlooked exposure.

Remember: "Secrets in Secrets Manager / SSM, fetched at runtime via IAM. RDS manages its own password → never in code, image, or Terraform state."

---

**Q17.4. Tell me about a real infrastructure problem you hit and how you solved it. — Hard**

Answer:
Two good ones. First, image architecture: I built the container images on an Apple Silicon Mac, so they came out ARM-based, and the cloud compute had to match — the ECS tasks run on ARM, and the always-on EC2 box specifically had to be an Intel-family instance because the images the CI pipeline publishes are Intel-only, so a cheaper ARM box wouldn't run them. Getting that mismatch wrong means the container just won't start, so it's a real gotcha. Second, pushing images: on a home internet connection, the standard Docker push kept timing out on the large backend image because it splits bandwidth across layers and the biggest layer never finished in time. I switched to a tool called crane that streams and retries the upload, which pushed it reliably in a couple of minutes. Both are the kind of practical, "it doesn't work and here's why" lessons that only come from actually deploying.

Follow-up: Why did the small EC2 box need special care beyond the architecture?
Memory. The first attempt on a one-gigabyte instance ran out of memory trying to run PostgreSQL, the JVM backend, nginx, and Caddy all at once — the machine would go unresponsive while its status still showed healthy, which was confusing to diagnose. The fix was a two-gigabyte instance plus a swap file plus capping the JVM's heap so everything fit. It's a good reminder that "just run it all on one box" has real resource limits, and that the JVM in particular needs its heap bounded when it shares a small machine.

Remember: "Real lessons: image arch must match compute (ARM/Intel) or it won't start; push big images with crane, not docker push (timeout); 1GB box OOMs → 2GB + swap + capped JVM heap."

---

**Q17.5. How do you keep the infrastructure reproducible and safe to change? — Very hard**

Answer:
Everything is Terraform — the infrastructure is code, versioned in the repo, so a deployment is reproducible rather than a pile of manual console clicks. The Terraform state lives in a remote backend in S3 with locking, so it's shared and can't be corrupted by two applies at once, and it's encrypted and private. There's a strict rule that I never apply changes that create or destroy real cloud resources without an explicit go-ahead, because those cost money and can be destructive — read-only planning is always fine, but applying is gated. And the two stacks are deliberately independent, with separate state, so tearing down the expensive on-demand stack can't accidentally break the always-on demo. There's also a budget alarm as a backstop against surprise spend.

Follow-up: What's the risk of infrastructure-as-code, and how do you manage it?
The main risk is that a small change to the code can have a large, sometimes destructive real-world effect — a tweak that Terraform decides requires replacing a database, for instance. I manage that by always running a plan first and reading exactly what it intends to add, change, or destroy before applying, and by being especially wary of changes that force replacement of stateful resources. The other risk is state itself — if the state file is lost or corrupted, Terraform loses track of reality — which is why it's in a locked, versioned, encrypted remote backend rather than on my laptop. Infrastructure-as-code is far safer than manual changes, but only if you actually read the plan and protect the state.

Remember: "All Terraform + remote locked encrypted S3 state. Apply is approval-gated (costs money / can be destructive). Two independent stacks. Budget alarm as backstop. Always read the plan."

---

## 18. CI/CD

**Q18.1. What does the CI pipeline do? — Basic**

Answer:
On every push and pull request to the main branch, GitHub Actions runs four jobs. A backend job builds and runs the full backend test suite against a real PostgreSQL. A frontend job installs dependencies, type-checks, runs the frontend tests, and builds the app. Then two image jobs build the backend and frontend container images. The rule is all four must stay green — a red pipeline doesn't get merged. It's the automated gate that keeps the main branch always in a working, tested state.

Follow-up: How do the tests get a real database in CI?
The CI runner has Docker available, and the backend tests use Testcontainers, which starts a real PostgreSQL container inside the CI job automatically. So the same integration tests that run locally against real Postgres run identically in CI — there's no separate, weaker test configuration for CI. That's important: it means CI is testing the real behavior, not a mocked stand-in, so a passing pipeline actually means something.

Remember: "GitHub Actions on push/PR to main: backend (verify vs real Postgres), frontend (typecheck/test/build), backend-image, frontend-image. All four green or no merge."

---

**Q18.2. When do container images get published, and why only then? — Medium**

Answer:
The image jobs build on every change so I know the image *can* build, but they only *publish* to the container registry on a push to the main branch — not on pull requests. And each image job depends on its test job, so only a tested build gets published. The reason is that a pull request is proposed, unreviewed code — you want to know it builds, but you don't want to publish an image from it as if it were releasable. Publishing only from main means every published image corresponds to code that's been merged and passed tests. Authentication to the registry uses the pipeline's built-in token, so there are no long-lived registry credentials to manage.

Follow-up: What's the deployment step — is it automatic?
No, and that's deliberate. CI publishes images, but deploying them is a manual, on-demand step, because the production-shape stack costs money to run and I stand it up intentionally. The always-on demo pulls the published images when I roll it forward. So it's continuous integration and continuous *delivery* — the images are always ready to deploy — but not continuous *deployment* to production on every merge, which wouldn't make sense for an on-demand, cost-controlled setup.

Remember: "Images build on every change, publish only on main, and only after tests pass. Deploy is manual/on-demand (cost). CI + delivery, not auto-deploy."

---

**Q18.3. The frozen stack lists CodeQL, Dependabot, Trivy, and ZAP — are those wired up? — Hard**

Answer:
No, and I want to be accurate about that. Those security scanners — static analysis, dependency scanning, image scanning, and dynamic testing — are named in the project's intended tooling, but they are documented *follow-ups*, not something currently running in the pipeline. The only workflow that exists is the build-and-test one with its four jobs. So if I were asked "what security automation runs in CI," the honest answer is "the tests and the isolation and authorization tests that encode the security requirements — the dedicated scanners are planned but not yet wired in." I'd rather say that than imply a security posture I haven't actually implemented.

Follow-up: If you added them, what would each catch and where would it run?
Static analysis and dependency scanning would run on every pull request — the first flags risky code patterns, the second flags known-vulnerable libraries, both cheap and non-disruptive. Image scanning would run in the image jobs to catch vulnerable OS packages in the container before publishing. Dynamic testing, which probes a *running* app, needs a deployed instance to point at, so it would run against the on-demand stack rather than on every pull request. Sequencing them that way — fast checks on every PR, the heavier running-app scan against a real deployment — keeps the pipeline fast while still covering the different classes of issue.

Remember: "CodeQL/Dependabot/Trivy/ZAP are documented follow-ups, NOT wired. Only build+test runs. Be precise: the security *tests* run; the *scanners* don't yet."

---

## 19. Observability

**Q19.1. How do you know what the app is doing in production? — Basic**

Answer:
Three signals: metrics, logs, and traces. The app exposes metrics through Spring Actuator in a format Prometheus scrapes — things like request rates, latencies, JVM health, and a few domain counters like number of adjudications. Logs carry a correlation ID and trace ID on every line. And distributed tracing follows a request across boundaries so you can see where time went. Locally there's a full stack — Prometheus, Grafana dashboards, and Jaeger for traces — that you bring up with a compose profile.

Follow-up: What's a correlation ID and why is it on every log line?
It's a unique ID assigned to each incoming request by a filter, and it's attached to every log line produced while handling that request, echoed back in a response header, and included in error responses. So if a user reports an error and gives me that ID, I can find every log line for that exact request instantly, instead of guessing among thousands. It's the thread that ties a single request's whole story together across the logs.

Remember: "Metrics (Prometheus/Actuator) + logs (with correlation ID) + traces (Jaeger). Correlation ID ties one request's logs/errors/trace together."

---

**Q19.2. How are health checks designed, and why more than one? — Medium**

Answer:
There are separate liveness and readiness probes, which mean different things. Liveness answers "is the process alive?" and depends only on the process itself — so a temporary database blip does *not* fail liveness, because you don't want to kill and restart a perfectly healthy app just because a dependency hiccuped. Readiness answers "can I serve traffic right now?" and includes the database — so if Postgres is unreachable, readiness fails and the load balancer stops sending that instance traffic until it recovers, without restarting it. There's also a fuller health aggregate for monitoring that can show degradation without affecting either probe. Splitting them prevents the classic mistake of a dependency outage triggering a restart storm.

Follow-up: Why not just have one health check that includes everything?
Because one combined check conflates two different decisions — "restart me" and "stop routing to me" — that should be made differently. If a single check included the database and the database blipped, the orchestrator would restart the app, which does nothing to fix the database and just adds churn. By separating them, a database problem pulls the instance out of rotation temporarily but leaves the process running to recover, while only a genuine process failure triggers a restart. Different failures deserve different responses, and one check can't express that.

Remember: "Liveness = process only (don't restart on a dependency blip). Readiness = includes DB (leave the LB when DB is down, don't restart). One check conflates 'restart' and 'stop routing'."

---

**Q19.3. How would you diagnose a slow or failing request with these tools? — Hard**

Answer:
I'd start from a symptom and follow the thread. If a dashboard shows latency or error rate climbing, I'd look at the metrics to see which endpoint and whether it correlates with something like database connections or JVM heap. Then I'd grab a correlation ID from an example failing request — from the user's error or the logs — and pull every log line for it, which shows where in the flow it failed. If it's a latency problem, the distributed trace for that request shows the breakdown across spans — how much time was in the database versus the application — so I can see exactly where it's slow rather than guessing. The three signals work together: metrics tell you *something's* wrong and roughly where, logs and traces tell you *why* for a specific request.

Follow-up: What custom domain metrics did you add, and why those?
The main one is an adjudications counter, tagged with the outcome, incremented only after the transaction commits so a rolled-back adjudication is never counted. I added it because generic HTTP and JVM metrics tell you the app is healthy but nothing about whether the *business* is flowing — this lets you see adjudication volume and outcomes over time, which is the kind of thing you'd actually alert on or investigate. The "increment only after commit" detail matters: a metric that counted attempts including rolled-back ones would lie about what actually happened.

Remember: "Metrics → which endpoint/resource. Correlation ID → that request's logs. Trace → where the time went (DB vs app). Domain counters incremented after-commit only."

---

**Q19.4. What alerting exists, and what's honestly missing? — Hard**

Answer:
There are Prometheus alert rules defined over real exported metrics — the backend being down, the outbox backlog growing too large, a high rate of server errors, high request latency, and high JVM heap. Each is expressed as a condition over a metric the app actually emits, and each links to a runbook describing how to respond. What's honestly missing is the routing layer — there's no Alertmanager wired to actually deliver those alerts to email or a pager, because that needs external services and credentials, so it's a documented follow-up. And the observability stack isn't wired into the cloud deployment yet — it runs locally. So the alert *rules* and *runbooks* are real and grounded; the *delivery* and the *cloud wiring* are the acknowledged gaps.

Follow-up: Why bother writing alert rules if they're not delivered anywhere?
Because the hard, valuable part is deciding *what* to alert on and *how to respond* — the rules encode which conditions actually matter and the thresholds, and the runbooks capture the response, and both are grounded in metrics the app really exports. Wiring those to a delivery channel is comparatively mechanical configuration that needs live credentials. So the rules and runbooks demonstrate the thinking and are ready to connect, while I avoid claiming a paging setup I haven't actually stood up. It's the same honesty principle — build and show the substantive part, don't fake the last mile.

Remember: "Alert rules over real metrics + runbooks per alert (backend down, outbox backlog, 5xx rate, latency, heap). Missing: Alertmanager delivery + cloud wiring (documented follow-ups)."

---

## 20. Backup & recovery

**Q20.1. How are backups handled? — Basic**

Answer:
There's a backup script that dumps the PostgreSQL database into a compressed archive, run inside the database container so it doesn't need database tools installed on the host. But the more interesting part is that I don't just take backups — there's a restore drill. The philosophy is "a backup you've never restored isn't really a backup," so there's a script that actually rehearses recovery: it backs up, restores into a scratch database, verifies the data matches, and reports pass or fail — all without touching the live database.

Follow-up: Why is the restore drill more valuable than the backup itself?
Because a backup you can't restore is worthless, and plenty of teams discover their backups are corrupt or incomplete only when they desperately need them. Taking a backup is easy; proving you can *recover* from it is the thing that actually matters. The drill closes that gap — it demonstrates, automatically and repeatably, that the backup is genuinely restorable and complete. That's the difference between hoping you're safe and knowing you are.

Remember: "Backup script (pg_dump in-container) + a restore DRILL that restores to a scratch DB and verifies. 'A backup you've never restored isn't a backup.'"

---

**Q20.2. How does the restore drill verify the restore actually worked? — Medium**

Answer:
It restores the backup into a separate scratch database, then compares the row count of every table between the source and the restored copy. If they all match, it passes; if any differ, it fails with a non-zero exit code so it could gate automation. Then it drops the scratch database to clean up. It's careful to run against a quiescent database and to exclude volatile things like session tables that legitimately change moment to moment, so the comparison is meaningful rather than flapping on data that's supposed to differ. The whole thing is non-destructive — the live database is only read, never touched.

Follow-up: Row counts aren't a full integrity check — what would a stronger verification add?
Right, matching row counts proves nothing was lost in bulk but doesn't prove every field restored correctly. A stronger check would compare checksums of the data, or restore and then run the application's own validation and a smoke test against the restored copy — actually log in and read a few records to confirm the app works on it. For a portfolio drill, row-count-per-table is a solid, fast, honest signal that the backup is complete and loadable; I'd describe deeper verification as the next step rather than claim the drill proves perfect fidelity.

Remember: "Drill: restore to scratch DB → compare per-table row counts → pass/fail (nonzero exit) → drop scratch. Excludes volatile tables. Stronger: checksums + smoke test."

---

**Q20.3. What are RPO and RTO, and what are they for this project honestly? — Hard**

Answer:
Recovery point objective is how much data you can afford to lose — how far back your last usable backup is. Recovery time objective is how long you can afford to be down while recovering. For this project, honestly, they're not formally defined because it's a synthetic-data portfolio, not a system with a real business continuity requirement. What exists is the mechanism — backups and a proven restore path — rather than a committed objective. In the production-shape cloud stack, RDS supports automated backups and point-in-time recovery, which is what you'd lean on to hit a tight recovery point, but I run that stack on demand with backups turned off for cheap teardown, so I don't claim a specific RPO or RTO number I haven't measured.

Follow-up: If this were real, how would you set and meet an RPO of, say, five minutes?
I'd enable continuous backup — point-in-time recovery on the managed database — which lets you restore to any moment, so the recovery point is essentially the last few seconds rather than the last nightly dump. To meet it reliably I'd combine that with automated snapshots, and critically I'd rehearse the restore regularly — the same drill philosophy — and measure how long a real restore actually takes, because RTO is only real if you've timed it. Setting the objective is a business decision; meeting it is continuous backup plus tested, timed recovery. I wouldn't quote a number I hadn't actually measured under a realistic restore.

Remember: "RPO = data you can lose; RTO = time to recover. Here: mechanism exists (backups + proven restore), no formal objective (synthetic). Real 5-min RPO = PITR + tested, timed restores."

---

## 21. Audit & governance

**Q21.1. What is the audit trail? — Basic**

Answer:
It's an append-only log of security-and-privacy-relevant actions — things like a claim being adjudicated, consent being revoked, break-glass emergency access being used. Each audit event records what happened, on what resource, the outcome, the correlation ID, and a short non-sensitive detail, scoped to the organization. It's readable only by auditor and admin roles, and it's immutable — there's no update or delete path. Its job is accountability: being able to answer "who did what, when" after the fact.

Follow-up: How is it kept free of sensitive data?
By recording only coded metadata — an action type, a resource type and ID, an outcome — never a clinical narrative or patient identifiers in the detail. That's the same rule as everywhere else: no sensitive data in logs, and the audit trail is a log. So it captures that an action happened and enough to trace it, without becoming a second copy of the protected data it's meant to oversee. An audit trail that leaked the data it audits would defeat its own purpose.

Remember: "Append-only, immutable log of security actions (adjudication, consent revoke, break-glass). Coded metadata only, no PHI. Read by auditor/admin."

---

**Q21.2. What makes the audit trail tamper-evident? — Medium**

Answer:
It's a hash chain. Each audit event includes a sequence number, the previous event's hash, and its own hash, which is computed from the event's contents plus that previous hash using a keyed hash function. Because each entry's hash depends on the one before it, the events form a chain — if someone modifies, deletes, reorders, or inserts a row, that entry's hash no longer matches and the break cascades to every entry after it. There's a verification endpoint that walks the whole chain and confirms every link, and it also checks the chain's head to catch someone truncating the end. So you can't quietly alter history without it being detectable.

Follow-up: Why "tamper-evident" rather than "tamper-proof"?
Because nothing stored in a database you control is truly tamper-*proof* — someone with enough access can change bytes. What the hash chain guarantees is that any such change is *detectable*: you can't alter the log and have it still verify. That's the achievable and honest goal — you make tampering impossible to hide, so the trail is trustworthy as evidence. Claiming tamper-proof would overstate it; tamper-evident is precise and is exactly what a hash chain provides.

Remember: "Hash chain: each entry hashes its contents + the prior hash. Any edit/delete/reorder/insert breaks the chain and cascades. Verify endpoint walks it + checks the head. Tamper-EVIDENT, not proof."

---

**Q21.3. Where's the signing key, and why does that placement matter? — Hard**

Answer:
The hash is keyed — computed with a secret — and each organization has its own key, derived from a master secret using a keyed hash of the organization's ID. The crucial part is *where* the master secret lives: outside the database it protects, in configuration or a secret store, never in the database itself. That's what makes the chain meaningful. If the key lived in the same database as the audit events, an attacker who could tamper with the events could also read the key and recompute valid hashes for their forged entries — the tamper-evidence would be worthless. By keeping the key out of the database, someone who compromises the audit table alone can't forge a valid chain, because they don't have the key to compute correct hashes.

Follow-up: Why per-organization keys instead of one global key?
Blast radius and isolation. Deriving a separate key per organization means the tenants' audit chains are cryptographically independent — a problem or exposure affecting one org's key doesn't let you forge another org's chain. It fits the multi-tenant model: everything else is tenant-isolated, so the audit integrity should be too. And deriving them from one master secret via a keyed hash means I don't have to store and manage many independent secrets — there's one secret to protect, and the per-org keys come from it deterministically.

Code reference: `audit/AuditSigningKeys.java` (`orgKey = HMAC(masterSecret, orgId)`), `audit/AuditHashChain.java` (canonical serialization + HMAC-SHA256), master secret from config, not the DB.

---

**Q21.4. What is break-glass access and how is it controlled? — Hard**

Answer:
Break-glass is the emergency-access pattern from healthcare: in a genuine emergency, a provider might need to reach a patient they're not assigned to. Rather than making that impossible or making it trivial, the system lets a provider self-grant time-boxed access to an unassigned patient, recording a required reason. The access guard honors a live grant, so it temporarily overrides *only* the relationship layer — never tenant isolation, never consent masking. Using break-glass writes an audit event immediately, and admins and auditors can review all live grants and revoke one early. So it's emergency access that's possible but never silent — every use is recorded and reviewable.

Follow-up: Isn't self-granted emergency access a huge hole?
It's a deliberate, controlled trade-off that mirrors real clinical systems. The alternative — requiring approval in a life-or-death emergency — could cost time you don't have, so the access is allowed immediately. What makes it safe is that it's *accountable*: it's time-boxed so it expires, it requires a stated reason, every invocation is audited permanently, and it's subject to after-the-fact access review where an admin can revoke it. It only overrides the relationship gate, so tenant isolation and consent-controlled fields are untouched. The security model shifts from prevention to detection-and-accountability, which is the appropriate model for emergencies.

Remember: "Break-glass = provider self-grants time-boxed access to an unassigned patient, reason required, audited immediately, reviewable/revocable. Overrides ONLY the relationship layer."

---

**Q21.5. How do retention and the permanent audit trail coexist? — Very hard**

Answer:
There's a tension: privacy says don't keep sensitive operational data longer than needed, but accountability says the audit trail must be permanent. The project resolves it by drawing a clear line. Operational data can be purged on a retention policy — for example, long-expired break-glass grants, which hold a sensitive free-text reason, get purged after a configurable window, and that purge is itself audited. But the audit trail is *never* purged — partly because it's the accountability record, and partly because deleting an audit row would break the hash chain and destroy the integrity of everything after it. So retention applies to operational data, and the audit log is deliberately exempt. The two policies target different things: forget the operational detail, keep the immutable record that the action happened.

Follow-up: The break-glass grant is purged but its audit event stays — isn't that contradictory?
No, and that's exactly the intended split. The grant *row* carries the sensitive detail — the free-text emergency reason — so once it's long expired, purging it removes sensitive data that no longer needs to exist, which serves privacy. But the audit *event* proving break-glass happened carries only coded, non-sensitive metadata — that an emergency access occurred, when, on what — so keeping it forever serves accountability without holding onto anything sensitive. So you end up able to prove the emergency access happened, without retaining the sensitive reason indefinitely. Purge the sensitive operational detail; keep the non-sensitive permanent proof.

Remember: "Retention purges operational data (e.g. expired break-glass grants + their sensitive reason); audit trail is NEVER purged (accountability + deleting a row breaks the hash chain). Purge is itself audited."

---

## 22. Security & threat modeling

**Q22.1. What's the core security principle of the app? — Basic**

Answer:
The backend is the only security boundary. The frontend can hide buttons and disable fields for good UX, but every protected operation is authorized on the backend, and the backend never trusts anything security-relevant from the client — not the tenant, not the roles, not totals. So even if someone bypassed the UI entirely and crafted raw requests, they'd hit the same authorization layers, the same tenant scoping, and the same validation. Security lives on the server, and the client is treated as untrusted.

Remember: "Backend is the ONLY security boundary. Frontend = UX convenience. Never trust the client for tenant, roles, or money."

---

**Q22.2. What are the main trust boundaries and attack surfaces? — Medium**

Answer:
The main trust boundary is between the client — the browser, or anyone crafting requests — and the backend. Everything crossing that boundary is untrusted input: request bodies, query parameters, headers, cookies, uploaded files. So the defenses cluster there: authentication on the session, CSRF on state-changing requests, validation on inputs, the authorization layers on every access, and the secure-404 so denials don't leak. There's a second boundary at the identity provider — Cognito — which we trust for identity but not for authority. And there's the messaging layer, where events flow — kept PHI-free so that surface can't leak sensitive data. A formal threat model in the docs walks the data-flow diagram and enumerates threats per category with the mitigation for each, grounded in real code.

Follow-up: How did you approach the threat model methodically?
I used the STRIDE framework — spoofing, tampering, repudiation, information disclosure, denial of service, elevation of privilege — as a checklist against a data-flow diagram of the system. For each element and each category, I asked "what's the threat here and what mitigates it," and tied every mitigation to actual code rather than aspiration. For example, spoofing is countered by Cognito plus backend-derived identity; tampering by the audit hash chain and validation; information disclosure by the secure-404, field masking, and PHI-free events; elevation of privilege by the layered authorization. Using a framework means the coverage is systematic instead of me just listing the threats I happened to think of.

Remember: "Trust boundary = client↔backend (all input untrusted). Also IdP (trust identity, not authority) and messaging (kept PHI-free). Threat model via STRIDE against a DFD, mitigations tied to real code."

---

**Q22.3. How does the app defend against injection attacks? — Medium**

Answer:
For SQL injection, all database access goes through JPA and parameterized queries — user input is always bound as a parameter, never concatenated into query text. Even the free-text search, which builds a "contains" pattern, binds the term as a parameter and escapes the special wildcard characters, so a user typing a percent sign searches for a literal percent sign rather than affecting the query. The sort-field allowlist prevents injecting arbitrary column names through the sort parameter. For the CSV export, there's specific defense against spreadsheet formula injection — a cell starting with an equals sign or similar gets neutralized so opening the export in a spreadsheet can't execute it. And because the frontend is React, it escapes rendered values by default, so cross-site scripting through the UI is largely handled by the framework.

Follow-up: What's CSV formula injection and why defend against it?
It's an attack where a value in an exported CSV starts with something like an equals sign, and when someone opens the file in a spreadsheet, the spreadsheet interprets it as a formula and can execute it — potentially running commands or exfiltrating data. Even though the data is synthetic here, it's a real class of vulnerability in any app that exports user-influenced data to CSV. The defense is to detect a leading formula trigger character and prefix the cell so the spreadsheet treats it as text. It's a good example of a threat that lives outside your app — in the tool that opens your output — that you're still responsible for.

Remember: "Parameterized JPA queries (never concatenate); search escapes LIKE wildcards + binds params; sort allowlist; CSV formula-injection defusing; React auto-escapes output."

---

**Q22.4. What's the most likely real vulnerability class for an app like this, and how is it addressed? — Hard**

Answer:
Broken access control — it's consistently the top real-world web vulnerability, and it's exactly the risk for a multi-tenant, role-and-consent system. The danger is a specific endpoint that forgets a check: a list that isn't tenant-scoped, a read that skips the relationship gate, an export that reads raw columns. The whole architecture is built to make that hard: the tenant comes only from the backend context, repositories only expose org-scoped finders, all patient access funnels through one guard, and exports reuse the masked read. And critically, the negative tests assert denial on these paths, so a regression that opened one would fail a test. The defense is centralization plus tests that specifically prove the denials, because access control bugs are bugs of omission and omissions don't announce themselves.

Follow-up: How would you catch an access-control regression before it shipped?
Layered. The negative tests are the automated net — cross-tenant, unassigned-provider, consent-denial, tenant-spoofing tests fail if a path opens up. The convention that there's *one* access guard means there's one place to review rather than many. And I built a project-specific code-review helper that checks changes against exactly these invariants — tenant scoping, the authorization layering, secure-404 — so a review flags a new endpoint that doesn't route through the guard. The combination — one choke point, invariant-focused review, and negative tests — is aimed squarely at the omission problem, because you can't rely on noticing the absence of a check by eye.

Remember: "Top risk = broken access control (bugs of omission). Defense: one guard + org-scoped repos + backend-only tenant + export reuses masked read + negative tests that assert denial + invariant-focused review."

---

**Q22.5. What residual security risks remain, honestly? — Very hard**

Answer:
A few I'd name without prompting. The dedicated security scanners — static analysis, dependency scanning, image and dynamic scanning — aren't wired into CI yet, so I'm relying on careful design and tests rather than automated vulnerability detection; that's a real gap. MFA is available but not enforced. The dead-letter replay and some ops surfaces are powerful admin actions that are audited but depend on the admin role being sound. The published demo passwords are an intentional exposure for a synthetic demo, but they'd obviously be unacceptable with real data. And there are the scaling caveats — single-instance assumptions in the relay — which are availability rather than confidentiality risks. None of these are hidden; they're documented follow-ups, and being able to enumerate them is itself part of a mature security posture.

Follow-up: If you had one week to harden this before real data, what's first?
Wire in the automated scanners and enforce MFA — those close the biggest gaps cheaply. Then I'd add a secret origin-verification header between the CDN and the load balancer so the backend can only be reached through the front door, tighten the ops endpoints so metrics and admin surfaces are strictly role-gated, and rotate off the published demo credentials entirely. After that I'd formalize the observability wiring in the cloud so I could actually detect an incident. I'd sequence it by risk-reduction-per-effort: the scanners and MFA first because they're high-value and low-effort, then the network and endpoint hardening, then the operational detection. And nothing touches real data until the negative-test suite is expanded to cover every new surface.

Remember: "Residual risks named openly: no CI scanners yet, MFA not enforced, powerful audited admin actions, intentional demo passwords, single-instance relay. Harden order: scanners+MFA → network/endpoint → detection."

---

## 23. Search & reporting

**Q23.1. How does search work across the work queues? — Basic**

Answer:
Every work queue — claims, prior authorizations, referrals, and so on — has a debounced free-text search box, and the search runs server-side in SQL as a case-insensitive "contains" match. Importantly, it searches on a synthetic business identifier — a claim number, an authorization number — not on patient names. That's deliberate: it keeps sensitive data out of search queries and URLs while still letting someone find the record they're looking for by its reference number.

Follow-up: Why search business numbers instead of patient names?
Two reasons, both about privacy. Search terms end up in query strings and logs, and you never want patient names there. And searching by name would be a way to enumerate patients across what someone can see. The business numbers — claim number, referral number — are synthetic, non-sensitive identifiers that uniquely find a record without exposing who it's about in the query. So you keep the usability of "find this specific claim" without the privacy cost of name search.

Remember: "Server-side, case-insensitive 'contains' search on synthetic business numbers (claim/auth/referral #), never patient names. Debounced. Keeps PHI out of queries/logs."

---

**Q23.2. How is search implemented safely in SQL? — Medium**

Answer:
The search term goes through a small helper that returns nothing for a blank box — meaning "no filter" — and otherwise builds a pattern for a SQL "contains" match. It binds the term as a parameter, never concatenating it into the query, and it escapes the SQL wildcard characters so a user typing a percent or underscore searches for that literal character instead of it acting as a wildcard. The query uses an explicit escape clause to match. So search is injection-safe by construction and behaves predictably even with special characters in the input.

Follow-up: What happens if a user pastes a special character or a huge string?
A special character like a percent sign is escaped, so it matches literally rather than turning the search into "match everything" — which both is correct behavior and avoids an accidental full scan. A very long string just won't match anything and returns an empty page; it can't break the query because it's a bound parameter, not part of the SQL text. The combination of parameter binding and wildcard escaping means arbitrary user input is handled safely and sensibly, which is exactly what you want from a search box exposed to untrusted input.

Remember: "Search helper: blank → no filter; else bound param + escaped LIKE wildcards + explicit escape clause. Special chars match literally; injection impossible."

---

**Q23.3. How does CSV export uphold the privacy rules? — Hard**

Answer:
The export reuses the exact same service read the JSON API uses, rather than having its own query. That's the whole trick: because the JSON read already applies tenant scoping, the relationship gate, and consent masking, the data the export formats is already scoped and already masked — a masked date of birth is already null in the DTO, so it exports as a blank cell. There's no path where the export reads a raw column the API would have withheld. On top of that, the CSV formatter does RFC-compliant quoting and defuses formula-injection. So the export inherits every access control automatically and adds safe formatting — "field masking meets data export," done by composition rather than duplication.

Follow-up: What would break this guarantee, and how do you prevent it?
It would break the moment someone wrote the export as a separate, "more efficient" query that read the database directly instead of going through the masked service read — that query could easily return raw columns and leak masked fields. The prevention is the convention, stated explicitly in the project rules: an export must call the same service method the JSON read uses and only *format* the already-masked DTOs; it must never re-read the database. So the guarantee holds as long as that discipline holds, and the reference implementation shows the right way so a new export is copied from a safe pattern.

Remember: "Export reuses the masked JSON service read → inherits tenant scope + relationship gate + consent masking automatically. Formatter only formats. Never a separate raw query."

---

**Q23.4. How would reporting scale if the data got large, and where does the current approach fall short? — Very hard**

Answer:
The current export builds the whole result set in one response — it doesn't stream — which is completely fine at synthetic scale but wouldn't hold up for a very large export, because it would hold everything in memory and produce one big response. The honest description is "correct and simple, not built for large-scale reporting." To scale it, I'd stream the export so rows flow out as they're read rather than being buffered, and for genuinely heavy reporting I'd move it off the request path entirely — generate the report asynchronously through the event/worker machinery, store it, and hand the user a link when it's ready. At real analytical scale you'd also separate reporting from the transactional database — a read replica or a separate reporting store — so big report queries don't compete with live traffic.

Follow-up: Why not build streaming and async reporting now?
Because it would be speculative complexity for data volumes this project never sees, and the project's rule is not to build for unmeasured load. The synchronous, in-memory export is correct and demonstrates the important property — that it inherits masking — without the added machinery. I'd rather ship the simple correct version and clearly document the scaling path than build streaming I couldn't actually exercise. Knowing exactly what I'd change — streaming, then async generation, then separating reporting storage — and why, in that order, is the useful answer, not pre-building it.

Remember: "Export builds the whole set in memory (fine at synthetic scale). Scale path: stream rows → async generation via workers → separate reporting store/replica. Don't pre-build for unmeasured load."

---

## 24. UI/UX & accessibility

**Q24.1. What does the UI look like and how is it organized? — Basic**

Answer:
It's a clean, professional single-page app built on Material UI with a custom theme — a teal-and-indigo design system I call "Care Constellation," with light and dark modes. The shell is a role-gated sidebar grouped into Care, Claims & coverage, and Governance, so you only see the sections your role uses. Pages follow consistent patterns — work queues as searchable, paginated lists; detail pages with a header, status, and cards; forms with labels above fields. There's a bespoke dark landing page with a credentials popup so a recruiter can pick a role and sign in.

Follow-up: Why build a real design system instead of default components?
Because polish signals care, and a consistent visual language makes the app feel like a product rather than a demo. Centralizing it in a theme — colors, typography, component defaults, the status chips — means every screen restyles from one place and stays consistent, rather than each page inventing its own look. It also made the light/dark mode work manageable, since the theme defines both schemes and components adapt automatically. The design system is what makes twenty-odd pages feel like one coherent app.

Remember: "MUI + custom 'Care Constellation' theme (teal/indigo, light+dark). Role-gated grouped sidebar. Consistent queue/detail/form patterns. Theme is the single styling source."

---

**Q24.2. What accessibility work is there? — Medium**

Answer:
The app targets WCAG 2.2 AA. Concretely: the shell has a skip-to-content link, proper landmark regions, and each page has exactly one top-level heading with correct heading order via a shared heading component. Icon-only buttons have accessible labels, tables have labels, and forms associate labels with their inputs. There's an automated accessibility check using axe-core in the component tests that runs the WCAG rules over rendered markup, so accessibility regressions get caught in the test suite. And I verified keyboard navigation, landmarks, and contrast manually in the browser on the core screens.

Follow-up: You said AA-*aligned*, not AA-*certified* — what's the distinction?
The automated axe check has a real limitation: it runs in a simulated DOM that doesn't actually render pixels, so it can't evaluate color contrast — one of the AA criteria. I check contrast manually in a real browser instead. So the coverage is automated checks for the structural criteria — landmarks, labels, heading order, roles — plus manual verification for contrast on core screens, plus a theme designed to meet AA. That's genuine, meaningful accessibility work, but it's not a full page-by-page audit against every criterion, so I call it "aligned," which is honest, rather than "certified," which would overstate it.

Remember: "WCAG 2.2 AA-aligned: skip link, landmarks, single h1 + order, labeled controls/tables, axe-core in tests. axe can't check contrast in jsdom → verified manually. Aligned, not certified."

---

**Q24.3. How does the UI handle loading, empty, and error states so it feels solid? — Hard**

Answer:
Deliberately, because those states are where apps feel broken. Every data-driven page has a real loading state — a spinner or skeleton — rather than a flash of empty content, and paginated lists keep the previous data visible while the next page loads so there's no jarring blank. Empty states use a consistent, friendly component — an icon and a message — instead of a bare empty table, so "no results" looks intentional rather than like a failure. And errors show a clear message with the correlation ID rather than a blank screen or a stack trace. The theme and shared components make these consistent across every page, so the app behaves predictably whatever the data situation.

Follow-up: Why do empty and error states matter as much as the happy path?
Because users hit them constantly — a new user has empty queues, a filter returns nothing, a network call fails — and an app that only looks good when full of data feels fragile the moment reality intrudes. A blank table leaves the user wondering if it's broken or loading; a clear empty state tells them there's simply nothing yet. An unhandled error showing a white screen destroys trust; a clear message with a traceable ID keeps it. Handling these well is a big part of what separates something that feels like a real product from something that feels like a prototype.

Remember: "Loading (skeleton, no flash; keepPreviousData), empty (consistent friendly component), error (clear message + correlation ID). These states are where apps feel broken — handle them like the happy path."

---

## 25. Reliability & performance

**Q25.1. How does the system stay correct under concurrent access? — Basic**

Answer:
Two locking strategies matched to the situation. Most updates use optimistic locking — a version number that catches a conflicting change and rejects it cleanly instead of silently overwriting. The financial accumulator, where two adjudications could corrupt a running total, uses a pessimistic row lock so those operations serialize. So concurrent users either get a clean conflict to retry, or they safely queue behind a lock where correctness demands it. Nobody's change silently disappears, and money is never double-counted.

Remember: "Optimistic locking (version) for most rows; pessimistic row lock for money accumulators. Clean conflict or safe serialization — never silent overwrite."

---

**Q25.2. What's the performance story, honestly? — Medium**

Answer:
There's one real measurement: a local load test against the authenticated read path that showed roughly 107 requests per second at a 95th-percentile latency of about 38 milliseconds with zero errors at 50 virtual users. But I'm careful to frame that — it's a single-node local number under specific conditions, exercising the full authorization pipeline against real Postgres. It is *not* a production SLA, and I'd never present it as one. Beyond that, performance work is about shape rather than tuning — server-side pagination so lists don't load everything, indexes matching the query patterns, and keeping the hot paths simple. At synthetic scale nothing is stressed, so I don't make performance claims I haven't measured.

Follow-up: Why load test the read path specifically?
Because it's the most-hit path in a real system — people read far more than they write — and it exercises the full authorization stack: the session, the tenant scoping, the relationship gate, the queries. So it's the honest thing to measure for "how does the app behave under concurrent normal use," and it proves the authorization layers don't fall over under load. Writes are lower-volume and involve locks I'd test differently. The read path is where throughput matters most, so that's what I measured.

Remember: "One measured number: ~107 req/s, p95 ~38ms, 0 errors @ 50 VUs, LOCAL single-node read path. NOT a production SLA. Perf = shape (pagination, indexes), not unmeasured tuning claims."

---

**Q25.3. Where are the bottlenecks and single points of failure? — Hard**

Answer:
The honest ones. The outbox relay is a scheduled poller that assumes a single running instance — scale to multiple app instances and two relays would fight over the same pending events; the fix is a lock-and-skip query so they can divide the work, which I've documented but not built. The shared database is the central dependency — everything goes through it, so at real scale it becomes the thing to protect with read replicas for heavy reads and careful attention to the row locks becoming contention points for a very active patient. And the always-on demo is literally one box, one availability zone, no redundancy — appropriate for a demo, not for anything real. None of these are surprises; they're the expected seams of a modular monolith on a shared database, and I can point to each and say what production would need.

Follow-up: The pessimistic lock on the accumulator — could that become a bottleneck?
It could, under a narrow condition: many claims for the *same* patient and plan and year being adjudicated at exactly the same time would serialize on that one row. In practice that's rare — claims for one patient don't usually flood in simultaneously — so the contention is low and the correctness guarantee is worth it. If it ever did become hot, options include making the accumulator update faster to shorten the lock hold, or restructuring how the running total is maintained, but I wouldn't optimize it away without evidence it's actually contended, because the lock is protecting real money. It's a deliberate correctness-over-throughput choice at a point where throughput isn't the constraint.

Remember: "SPOFs/bottlenecks: single-instance relay (needs SKIP LOCKED), shared DB (needs replicas at scale), one-box demo (no redundancy), accumulator lock (only hot for same patient/plan/year — correctness worth it)."

---

**Q25.4. How would you handle a downstream dependency being slow or down — timeouts, retries, backpressure? — Very hard**

Answer:
It depends which dependency. For the database being unreachable, the readiness probe fails so the load balancer stops routing to that instance until it recovers, rather than piling requests onto a broken backend — that's backpressure at the routing level. For the asynchronous side, a failing consumer doesn't block forever: there's bounded retry with backoff, and then dead-lettering so a persistently failing message moves aside instead of jamming the partition, with replay once the problem's fixed. For a synchronous external call — if I added one, like an email provider — I'd wrap it with a timeout so a slow dependency can't hang requests indefinitely, and ideally a circuit breaker so repeated failures fail fast instead of every request waiting for the timeout. The general principle is: never let a slow or dead dependency turn into unbounded waiting or a blocked queue — fail fast, shed load, and isolate the failure.

Follow-up: Why is a timeout on an external call so important?
Because without one, a slow dependency becomes *your* outage. If every request makes a call that hangs for thirty seconds, your threads and connections fill up waiting, and soon the whole app is unresponsive even though the problem is elsewhere — the slowness propagates and amplifies. A timeout bounds the damage: the call fails after a set time, the request returns an error you can handle, and resources are freed. Adding a circuit breaker on top means after enough failures you stop trying for a while and fail instantly, which protects both you and the struggling dependency. It's the difference between one dependency degrading and your entire system going down with it.

Remember: "DB down → readiness fails → LB sheds it. Async → bounded retry+backoff → DLT → replay. Sync external calls → timeout + circuit breaker. Never allow unbounded waiting; isolate failure."

---

## 26. Cost management

**Q26.1. How do you keep cloud costs under control? — Basic**

Answer:
Mainly by not leaving the expensive stuff running. The production-shape AWS stack — load balancer, managed database, container orchestration, CDN — costs around $70 a month if left on, so I run it on demand: stand it up, capture the evidence I need, then tear it down back to nearly nothing. For the always-on portfolio link, I use a much cheaper single-box setup at about $15 a month. And there's a budget alarm that emails me if spend approaches a threshold, as a backstop against a surprise.

Remember: "Expensive stack runs on-demand (up → evidence → destroy). Always-on link on a cheap single box (~$15/mo vs ~$70/mo). Budget alarm as backstop."

---

**Q26.2. What specific architecture choices were driven by cost? — Medium**

Answer:
Several, explicitly. No NAT gateway — that alone saves about thirty dollars a month, achieved by putting compute in public subnets with direct egress and keeping the database private. No managed Kafka in the cloud — a managed broker is expensive, and I proved the event-driven design locally instead, since the pattern doesn't need the cloud to be demonstrable. Running both app containers in a single task in the on-demand stack — one compute charge instead of two. And the whole two-deployment split exists for cost: the impressive architecture on demand, the always-on link cheap. Each of these is a documented decision that trades a bit of production-conventionality for a real, quantified saving appropriate to a portfolio budget.

Follow-up: Doesn't skipping managed Kafka weaken the "I can do event-driven at scale" story?
I don't think so, because the hard, demonstrable part of event-driven design is the *patterns* — the transactional outbox solving dual-write, idempotent consumers, retry and dead-lettering and replay — and all of that is fully implemented and tested against a real Kafka locally. A managed cloud broker would add operational cost without teaching or proving anything new about the design. The honest framing is "the event-driven architecture is real and proven; I ran it on local Kafka rather than paying for a managed broker for a demo," which shows both the engineering and the cost judgment. Spending on a managed broker to make a synthetic demo more expensive would be poor judgment, not better engineering.

Remember: "Cost-driven: no NAT gateway (~$32/mo), no managed Kafka (proven locally), both containers in one task, two-deploy split. Each documented with the saving."

---

**Q26.3. How do you balance cost against demonstrating real cloud skills? — Hard**

Answer:
By separating what proves the skill from what proves I can pay a cloud bill. The skill is proven by the code, the infrastructure-as-code, and the evidence pack — the full production-shape stack is defined in Terraform and I stood it up, captured it working end to end over HTTPS with real auth, and tore it down. That evidence is permanent even though the running stack isn't. Leaving it running around the clock proves nothing additional about my ability; it just costs money for a link that might sit unvisited. So I optimized for "demonstrate the architecture thoroughly, keep a cheap always-on link for accessibility, and don't pay for idle capacity." The credibility comes from the artifacts, not from where the live link currently points — and being able to explain *that reasoning* is itself a signal of engineering and business judgment.

Follow-up: If an interviewer says "but real systems run 24/7, doesn't on-demand undercut the point?" — how do you respond?
I'd agree that real production runs continuously, and point out that the reason it does is because it serves real users with real availability requirements — which a synthetic portfolio demo doesn't have. The on-demand approach isn't me being unable to run it continuously; it's me applying the same cost-consciousness a real team applies, just with the knob turned to "portfolio budget." The Terraform, the architecture, and the captured evidence show I can build and operate the always-on version; the choice to run it on demand shows I weigh cost against benefit rather than spending reflexively. In a real job I'd run it 24/7 because the benefit would justify it — here it doesn't, and recognizing that is the point.

Remember: "Skill proven by code + IaC + evidence pack (permanent). Running 24/7 proves nothing extra, just costs money. On-demand = the same cost-consciousness a real team applies, at portfolio scale."

---

## 27. Documentation & demonstration

**Q27.1. What documentation exists for the project? — Basic**

Answer:
Quite a lot, because for a portfolio project the documentation *is* part of the deliverable. There's a README written as an engineering case study with the tech stack, architecture, and embedded evidence screenshots. There are architecture and database diagrams, a full set of architecture decision records explaining why each major choice was made, a STRIDE threat model, runbooks for operations, and an evidence pack with test results, security-boundary transcripts, observability screenshots, and UI captures. The idea is that someone could understand the system, and verify the claims, without me in the room.

Follow-up: Why write architecture decision records?
Because the *why* behind a decision is the thing that gets lost over time and the thing interviewers actually probe. An ADR captures the context, the decision, the alternatives considered, and the trade-offs, at the moment the decision was made. It means six months later — or in an interview — I can explain not just what I chose but why, and what I rejected. It also forces the discipline of actually considering alternatives rather than defaulting. For a project meant to demonstrate engineering judgment, the record of judgment is as valuable as the code.

Remember: "README case study + architecture/ER diagrams + ADRs + STRIDE threat model + runbooks + evidence pack. Docs are part of the deliverable. ADRs capture the *why* and the alternatives."

---

**Q27.2. How would you demo this project in an interview? — Medium**

Answer:
I'd anchor on the differentiator, not a feature tour. I'd log in as one role and read a patient, then log in as a different provider who isn't assigned and show that same patient returning a not-found — same role, different result, because of the relationship layer. Then I'd show a consent-controlled field masked, flip a consent directive, and watch it appear — the consent layer live. Then a claim through adjudication, showing the itemized breakdown of who pays what. That sequence tells the whole story: layered authorization, consent enforcement, and explainable claims, which are the three things that make the project distinctive. The live link is there for them to click themselves afterward.

Follow-up: What if you only had 60 seconds?
The two-providers-same-patient moment. I'd show one provider reading a patient and another provider — same role, same org — getting a secure 404 on that exact patient, and say "that's the whole idea: access isn't just your role, it's your relationship to the patient and their consent, enforced on the backend." That single contrast captures the differentiator faster than anything else, and it invites the natural follow-up questions about how the guard, consent, and secure-404 work — which lets me go as deep as they want from there.

Remember: "Demo the differentiator, not a feature tour: same role → different result (relationship), consent field masks/unmasks live, claim → itemized adjudication. 60-sec version: two providers, one patient, secure 404."

---

**Q27.3. How do you make sure the documentation's claims stay honest and current? — Hard**

Answer:
A few disciplines. Measured numbers — test counts, migration counts — are stated as measured and kept in sync when they change, and I don't write a performance or coverage number I haven't actually measured. The evidence pack contains real captures — actual HTTP transcripts of the security boundary behaving, real screenshots — rather than descriptions, so the claims are verifiable, not just asserted. And where documentation describes intended-but-not-built things — the security scanners, Playwright end-to-end tests, cloud observability wiring — those are explicitly labeled as follow-ups, so the docs never imply something exists that doesn't. The project rulebook itself encodes "no unmeasured claims" as a hard rule, so honesty is a convention I hold the docs to, not an afterthought.

Follow-up: You mentioned the docs and code can drift — how do you handle that?
By treating a divergence as something to state rather than hide. During this very preparation I found that one infrastructure README still described a stack as an empty skeleton when it had since grown real resources, and that an earlier note assumed an idempotency-key mechanism the code doesn't actually have. The right response isn't to pretend the docs were always perfect — it's to correct them and, in an interview, to be able to say "here's where a doc lagged the code and how I'd reconcile it." Drift is normal in any real project; what matters is noticing it and being straight about it rather than confidently repeating a stale claim.

Remember: "Honesty disciplines: measured-only numbers kept in sync, evidence pack has real captures, follow-ups labeled as such, 'no unmeasured claims' is a rule. Drift happens — correct it and be straight about it."

---

## 28. Ownership & AI assistance

**Q28.1. You built this with Claude Code — what was your role versus the AI's? — Medium**

Answer:
I directed it and I own it. The design came from a detailed source-of-truth I worked from, and I drove the build the way a lead drives work — deciding what to build next, one small slice at a time, reviewing each slice, verifying it actually worked, and course-correcting when it wasn't what I wanted. The AI accelerated the typing and helped me move fast across a big surface area, but the architecture decisions, the sequencing, the "is this correct and is this what I meant" judgment, and the verification were mine. I treated it like a very fast pair-programmer that I'm responsible for reviewing — the code shipped because I understood it and checked it, not because a tool produced it.

Follow-up: How do you know you actually understand code you didn't type character by character?
Because I can explain any part of it — why the access guard is the single choke point, why the accumulator uses a pessimistic lock while claims use optimistic, why events must be PHI-free, why re-adjudication backs out the prior contribution. Understanding isn't about who typed it; it's about whether you can reason about it, defend the decisions, and know what would break if you changed it. This whole preparation is me being able to do exactly that across the system. If I couldn't explain a piece, I'd go read it until I could — and there are parts I deliberately dug into precisely to make sure I could defend them.

Remember: "I directed and own it: design, sequencing, review, verification, course-correction were mine; AI accelerated typing. Ownership = I can explain and defend every decision, not who typed it."

---

**Q28.2. How did you validate what the AI produced rather than just trusting it? — Hard**

Answer:
Through the same loop every slice: build, then verify before moving on — run it, test it, click through it in the browser. "It compiles" was never "it works." The negative and security tests are a big part of that validation, because they assert the *denials* that matter — if the AI produced an endpoint that skipped the tenant check, a cross-tenant test would fail. I also used review passes, including project-specific review helpers tuned to the app's own invariants — tenant scoping, authorization layering, secure-404, no sensitive data in logs — to catch issues an eyeball might miss. And there were real bugs found and fixed this way, which is the proof the validation was real rather than rubber-stamping.

Follow-up: Can you give an example of catching or fixing something rather than just accepting it?
Yes — the clearest is the deployed dev-login hole. The app originally bundled seeding and the passwordless dev-login shortcut under the same profile, which meant deploying with demo data would have dragged an unauthenticated login endpoint into production. A security review of the deployment diff caught it, and the fix was to split seeding from dev-login into separate profiles so the deploy could be seeded but have no dev-login, backed by a test that boots the deploy profile and asserts the endpoint is gone. That's the loop working: a review found a real security issue in generated code, I understood why it was dangerous, fixed it properly, and locked it down with a test.

Remember: "Validate every slice: run/test/click, negative+security tests assert denials, invariant-focused review. Real example: caught the deployed dev-login hole → split profiles → test asserts it's gone."

---

**Q28.3. What did you actually learn by building this, if the AI wrote a lot of the code? — Hard**

Answer:
A lot, because directing and reviewing a system this size forces you to understand it deeply — arguably more than typing a smaller one would. I learned how layered authorization really composes, why the tenant must never come from the client, why exactly-once is a trap and at-least-once plus idempotency is the practical answer, why money needs decimal types and specific locking, how the transactional outbox solves dual-write, and a pile of concrete deployment lessons like image architecture mismatches and pushing large images. I also learned the discipline side — one verified slice at a time, negative tests as the real proof, no unmeasured claims. The AI made the surface area achievable, but understanding *why* each piece is built the way it is came from reviewing, questioning, and verifying it, which is genuine learning.

Follow-up: How would you respond to a skeptic who says "the AI did the hard part"?
I'd say the typing isn't the hard part — the judgment is. Deciding the architecture, sequencing twelve phases so dependencies come in order, recognizing that a seeded deploy was about to ship an auth bypass, knowing that re-adjudication has to reverse the prior accumulator contribution or it double-counts money — those are the hard parts, and they're mine. An AI will happily generate plausible code that's subtly wrong; catching that requires understanding. The proof is that I can sit here and explain any decision, defend the trade-offs, and tell you what I'd change and why. If the AI had "done the hard part," I couldn't do that — I'd just have code I couldn't account for.

Remember: "Learned: authz composition, backend-only tenant, at-least-once+idempotency, money types/locking, outbox/dual-write, deploy gotchas, plus the discipline. Hard part = judgment (mine), not typing."

---

## 29. Limitations & future work

**Q29.1. What are the deliberate simplifications in the project? — Basic**

Answer:
Several, all intentional. It's a modular monolith, not microservices. Adjudication doesn't move real money, just computes what's owed. MFA is available but not enforced. The event broker is local, not managed cloud. Notifications are an in-app feed without email. Some scanning is synchronous rather than async. And re-adjudication handles one claim at a time rather than cascading through a whole benefit year. Each was a conscious choice to keep the project focused and honest rather than an oversight — and I can explain the trade-off behind every one.

Remember: "Deliberate simplifications: monolith, no real money movement, MFA optional, local Kafka, in-app-only notifications, sync scan, single-claim re-adjudication. All conscious, all explainable."

---

**Q29.2. What's the technical debt you'd address first? — Medium**

Answer:
The single-instance assumption in the outbox relay, because it directly blocks horizontal scaling — the fix is a lock-and-skip query so multiple instances can share the work safely, and it's well understood. Alongside that I'd wire the security scanners into CI, since automated vulnerability detection is a real gap I'm currently covering with design and tests. Then the cloud observability wiring so the deployed app is actually monitored, not just the local stack. I'd sequence by risk and unblocking value — the scaling blocker and the security automation first, because they're the ones that would genuinely matter if this went further, and both are more about wiring than deep redesign.

Follow-up: How do you decide what's debt worth paying down versus a limitation you leave?
I ask whether it blocks something real or just isn't there yet. The single-instance relay is real debt because it actively prevents a legitimate next step — scaling out. Something like enforcing MFA isn't debt, it's a config choice appropriate to a demo that I'd flip for real data. And streaming exports isn't worth paying down now because nothing exercises the limitation at synthetic scale — building it would be speculative. So the test is: does leaving it cost me now or block a real next step? If yes, it's debt to address; if it's just "a fuller version would do more" with no current pain, it's a documented limitation I leave until there's a reason.

Remember: "First debt: single-instance relay (blocks scaling), then CI security scanners, then cloud observability wiring. Debt vs limitation test: does it block a real next step / cost now? Yes = debt; no = documented limitation."

---

**Q29.3. If this had to become a real product, what's the roadmap? — Hard**

Answer:
Roughly three horizons. First, harden for real data: enforce MFA, wire in the automated security scanners, add the network and endpoint hardening, rotate off demo credentials, and stand up real monitoring and alerting delivery in the cloud. Second, make it scale: the multi-instance-safe relay, read replicas for heavy reads, and load testing at realistic volumes to actually find the bottlenecks rather than guess. Third, deepen the domain: real payment integration, email and preference-based notifications, async document scanning, and the year-wide re-adjudication cascade. I'd do them in that order because you harden before you take real data, you scale before you take real load, and you deepen features once the foundation is genuinely production-grade. Each horizon builds on a solid version of the last.

Follow-up: What would you NOT do, even for a real product?
I wouldn't rush to break it into microservices. The modular monolith is the right architecture until there's a concrete forcing function — independent team deploys or a module with genuinely different scaling needs — and prematurely splitting it would add distributed-systems complexity, lose the single-transaction guarantees the domain relies on, and slow everything down for no benefit. I'd also resist adding speculative flexibility "in case we need it" — I'd let real requirements drive real complexity. The discipline of not building for imagined future needs is as important going forward as it was building it the first time.

Remember: "Roadmap: (1) harden for real data (MFA, scanners, monitoring), (2) scale (multi-instance relay, replicas, real load tests), (3) deepen (payments, email, async scan, year-wide re-adjudication). NOT: premature microservices or speculative flexibility."

---

**Q29.4. Looking back, what would you architect differently if you started over? — Very hard**

Answer:
Honestly, not the big structural choices — the modular monolith, shared-database multi-tenancy, the layered authorization, the outbox are all decisions I'd make again, and they held up. What I'd do differently is smaller and mostly about sequencing. I'd wire the security scanners and the deploy-profile separation in from the start rather than discovering the dev-login bundling later, because that was a real bug that earlier automation would have flagged. I'd build the relay multi-instance-safe from the beginning since the fix is cheap and known. And I'd keep the documentation and code in tighter sync as I went, because I found a couple of places where a doc lagged the code. So: same architecture, a few things done earlier and more carefully rather than retrofitted.

Follow-up: Isn't "I'd change almost nothing structural" a bit convenient?
It could sound that way, so let me be concrete about why. The structural decisions were driven from a frozen design and each has a clear rationale that survived the whole build — the monolith kept the transaction guarantees, shared-DB tenancy was proven isolatable with tests, the layered authorization delivered the exact differentiator I wanted. The things I *would* change are real and I've named them specifically — the dev-login profile bundling was an actual security bug, the single-instance relay is a real scaling blocker. If everything had gone perfectly I'd be suspicious of my own answer too, which is why I lead with the genuine mistakes rather than claiming a flawless build. The honest version is "the architecture was sound; the execution had specific, nameable things I'd sequence better."

Remember: "Keep the structural choices (monolith, shared-DB tenancy, layered authz, outbox — all held up). Change: scanners + deploy-profile split earlier, multi-instance relay from day one, tighter doc/code sync. Lead with real mistakes, not a flawless story."

---

## 30. End-to-end flows

These questions ask you to trace a whole flow across frontend, backend, database, security, events, and cloud. They're where interviewers see whether you understand the system as a connected whole, not as isolated features.

**Q30.1. Walk me through login all the way to an authorized API response. — Hard**

Answer:
You click "Sign in," which is a full-page navigation to the backend's Cognito authorization endpoint. The backend redirects you to Cognito's hosted login; you authenticate there and Cognito redirects back to the backend with an authorization code. The backend — acting as the confidential OAuth client — exchanges that code for your identity, confirms you correspond to an active user in its own database, and establishes a session, dropping an HttpOnly session cookie. The browser lands back in the app, which calls the current-user endpoint; a filter resolves your session into your identity, organization, and roles from the database, and returns them. Now you load, say, the claims queue: the request carries the session cookie, the same filter populates your tenant context, the controller delegates to the service, the service scopes the query to your organization and applies the role and relationship checks, and you get back only the claims you're allowed to see, paginated. At no point did the browser hold a token or supply its own tenant.

Follow-up: Where exactly do roles enter, and why not from Cognito?
Roles enter in that filter, looked up from the application's own database by your email, not from Cognito. Cognito only establishes *who* you are — identity by email. Authority is the app's decision, held in its database, so it can be reasoned about and enforced inside the same transactions as everything else. If roles came from a Cognito token, I'd be trusting an external token's claims for authorization and would have to keep them in sync; keeping Cognito to identity and the database to authority avoids both problems.

---

**Q30.2. Trace a cross-tenant access attempt and show why it fails. — Hard**

Answer:
Suppose a NorthCare user tries to read a Green Valley patient — either by guessing an ID or by trying to spoof the tenant. The request arrives with the NorthCare session cookie. The filter resolves the tenant strictly from that session — NorthCare — and ignores any organization ID the client tried to pass in a parameter or header. The service loads the patient scoped to NorthCare — "find by this ID *and* NorthCare's organization ID." The Green Valley patient isn't in NorthCare, so the lookup returns nothing, and the caller gets a secure 404 — the patient appears not to exist. Even if some layer were bypassed, the composite foreign keys mean Green Valley's data couldn't have linked into a NorthCare query anyway. And there's a test that does exactly this — spoofs the tenant parameter and header — and confirms only NorthCare data ever comes back.

Follow-up: Why is the result a 404 and not a 403?
Because a 403 would confirm the Green Valley patient exists, which is itself a leak — you could enumerate patients across tenants by watching for 403 versus 404. The secure 404 makes "doesn't exist" and "exists but you can't see it" indistinguishable, so the attempt yields zero information. That's the consistent rule for object-level, existence-sensitive access denials throughout the app.

---

**Q30.3. Trace a consent grant, then a revocation, and their effect on a read. — Hard**

Answer:
Start with a provider reading a patient where a sensitive field — the clinical narrative, say — is consent-controlled. With no applicable grant, the consent engine denies by default and the field comes back masked — null in the response, listed as masked, shown as "Restricted." Now the patient, or a coordinator, records a consent directive granting the care team access to that category for care coordination. That write supersedes any prior directive and inserts a new active version. The next time the provider reads the patient, the consent engine finds the applicable grant — most-specific tier, in force by date — and the field comes through unmasked. The UI, having invalidated its cached query on the change, shows it live. Later the patient revokes. That flips the directive to revoked, and because consent is evaluated at read time on every controlled field, the very next read masks the field again. Throughout, every version of the directive is retained, so you can reconstruct what consent was at any past moment.

Follow-up: If the provider had the patient open when consent was revoked, do they keep seeing the field?
Only until their next read. There's no cached "you're allowed" server-side — consent is re-evaluated on every read of a controlled field. So a stale screen might still show the old value, but any refresh or new fetch re-runs the consent check and masks it. What no system can do is un-see what was already legitimately displayed — which is exactly why there's a permanent audit trail recording who accessed what and when. Prevention going forward, accountability for what already happened.

---

**Q30.4. Trace a claim from submission through adjudication with a partial approval. — Hard**

Answer:
A provider or coordinator creates a claim — a header plus procedure-code lines — and the backend computes the total from the lines rather than trusting it. The claim starts in draft, gets submitted, which validates it has at least one line and a positive total, and a reviewer accepts it. Now adjudication runs as a dedicated command, not a status flip: the engine confirms coverage on the service date, then for each line applies allowed, copay, deductible, coinsurance, and the out-of-pocket cap, reading and updating the benefit accumulator under a row lock. A partial approval falls out naturally when lines differ — one line is covered and split into plan-paid and member-owed through the full math, while another is not-covered because the plan excludes that procedure, so its charge falls entirely on the member and it skips the cost-sharing. The claim ends adjudicated with an itemized, immutable record: per line, exactly what was allowed and who pays what, plus totals. All of that — the adjudication, the status change, the history row, the audit event, the outbox event — commits in one transaction.

Follow-up: What if there's no coverage in effect on the service date?
Then it's a recorded denial for no eligibility — the plan pays nothing and the member is responsible for the charge — but it's still a full, explainable adjudication, not an error. That matters: even "denied because you weren't covered that day" is a decision the system can show its reasoning for. And if the patient later turns out to have had retroactive coverage, re-adjudication can re-run it under the corrected eligibility and flip it, writing a new version while keeping the original denial on record.

---

**Q30.5. Trace an event from a database transaction through the outbox, Kafka, and a notification. — Very hard**

Answer:
When the claim is adjudicated, inside that single transaction the service writes the adjudication result and also writes an outbox event row — a PHI-free description of what happened, with the tenant ID. Both commit together, so the event can't exist without the change or vice versa. After commit, a scheduled relay polls the outbox for unpublished rows, finds this one, and publishes it to Kafka — the event type as the topic, the claim ID as the key — then stamps the row published. A consumer subscribed to that topic receives it and builds a notification purely from the event's contents, deduping on the event's unique ID so a redelivery is harmless. If the consumer failed repeatedly, the message would retry with backoff and then dead-letter into a queryable table, where an admin could inspect and replay it — publish-first, then mark-replayed, so a crash mid-replay just re-sends and the idempotent consumer absorbs the duplicate. So the chain is: atomic write including the event, reliable after-commit publish, idempotent consumption, with retry, dead-letter, and replay as the safety net.

Follow-up: Where could this go wrong, and what stops each failure from causing inconsistency?
Several points, each covered. The publish could fail after the DB commit — fine, the row stays unpublished and the next poll retries, at-least-once. The relay could publish then crash before stamping — fine, it republishes and the consumer dedupes. The consumer could process then crash before committing its own record — fine, the message is redelivered and dedup handles it. The consumer could hit a permanently bad message — it dead-letters instead of blocking the partition. And the tenant is carried in the event so a consumer never guesses it. The through-line is that every failure resolves to either a safe retry or a safe duplicate, never a lost event or a cross-tenant leak — which is the whole reason for at-least-once plus idempotency plus dead-lettering.

---

**Q30.6. Trace emergency break-glass access and its later review. — Very hard**

Answer:
A provider needs a patient they're not assigned to — an emergency. They hit the patient and get a secure 404 because the relationship gate denies them. In the UI that denied state offers an emergency-access panel: they enter a reason and break the glass. That writes a time-boxed grant with the reason, and immediately an audit event recording that break-glass was invoked — all in one transaction — with the audit detail kept PHI-free. Now the access guard honors that live grant, so the provider can reach the patient's whole record — because everything patient-scoped funnels through that one guard — but *only* the relationship layer is overridden; tenant isolation and consent-controlled fields are untouched. Later, an admin or auditor reviews all live grants in an access-review screen and can revoke one early, which cuts off access at once and writes a revocation audit event. Eventually the grant expires, and much later the retention job purges the expired grant with its sensitive reason — while the audit events proving it happened remain permanent.

Follow-up: Summarize why this is safe despite being self-granted.
Because safety here comes from accountability, not prevention — which is the right model for a genuine emergency where blocking access could cause harm. Every dimension is controlled: it's time-boxed so it self-expires, it requires a reason, it's audited the instant it's used, it's reviewable and revocable by admins, and it overrides only the relationship gate, never tenant or consent-field protections. So a provider *can* get emergency access without waiting for approval, but they can never do so *silently* — there's a permanent, tamper-evident record and an active review process. Prevention would be wrong for emergencies; detection and accountability are exactly right.

---

## 31. Behavioral & STAR questions

**How to use this section:** the spoken answer is written as one natural story — don't recite "Situation, Task, Action, Result" out loud. The STAR breakdown after each is just to help you see the structure. These stories are grounded in real things that happened while building HealthCloud. A few classic behavioral prompts (team conflict, stakeholder disagreement) don't have a truthful basis in a solo, AI-assisted portfolio project — those are flagged, with guidance to draw on your real background instead, and collected in [§32's "Personal details to confirm."](#personal-details-to-confirm)

**B1. Tell me about a difficult technical challenge you faced. — Behavioral**

Answer:
The hardest single thing was getting re-adjudication of claims correct without corrupting money. Adjudication tracks a running total — how much of a patient's deductible and out-of-pocket has been used this year — in an accumulator. Re-adjudicating a claim, say after a plan fix, meant re-running the calculation, but the original run had already consumed some of that deductible. My first mental model was just "recompute and overwrite," and I realized that would double-count — the patient would appear to have used their deductible twice. So I worked through it and landed on backing out the prior version's exact contribution to the accumulator first, then recomputing under current rules, and writing the result as a new immutable version while keeping the old one for audit. I verified it with tests that adjudicate, re-adjudicate, and assert the accumulator ends up as if only the new decision had ever applied. The lesson that stuck was that with money and running totals, you can't just recompute — you have to reverse before you re-apply.

STAR breakdown: **Situation** — re-adjudication had to re-run claims that had already affected a yearly accumulator. **Task** — recompute without double-counting the deductible/out-of-pocket. **Action** — reverse the prior version's contribution, recompute under current config, write a new immutable version, prove it with tests. **Result** — correct re-adjudication with full history retained and no double-counting.

Follow-up: What made you realize the naive approach was wrong before it shipped?
Thinking through a concrete scenario rather than trusting the abstraction. I traced a patient with a claim that used their whole deductible, then imagined re-adjudicating it, and saw the accumulator would show the deductible consumed twice. Walking a specific numeric example is what exposed it — the abstract "just recompute" sounded fine until I put real numbers through it. That's a habit I lean on for anything involving money or state: don't reason only in the abstract, run a concrete case by hand.

---

**B2. Tell me about an important technical decision and how you made it. — Behavioral**

Answer:
Choosing how to guarantee that a claim adjudication reliably produces a downstream event. The naive approach is: commit the database change, then publish to the message broker. But those two writes aren't atomic — if the publish fails after the commit, you've got a change with no event; if the commit fails after the publish, an event for something that didn't happen. I considered trying for exactly-once delivery and decided against it, because true exactly-once across a database and a broker is famously hard and often illusory. Instead I chose the transactional outbox: write the event as a row in the *same* transaction as the change, so they're atomic, and have a relay publish committed rows afterward — at-least-once — with consumers made idempotent by deduping on the event ID. That combination gives the practical effect of exactly-once with mechanisms I could actually reason about and test. I made the call by weighing correctness against complexity and picking the robust, understandable option over the theoretically-pure but fragile one.

STAR breakdown: **Situation** — adjudication needed to reliably emit a downstream event. **Task** — avoid the dual-write inconsistency. **Action** — evaluated exactly-once vs outbox + idempotency; chose the outbox with at-least-once delivery and idempotent consumers. **Result** — atomic, reliable event emission that's testable and can't lose or duplicate effects.

Follow-up: How do you make a call like that when both options "work"?
I ask which one I can actually reason about, test, and operate — not just which is theoretically nicest. Exactly-once sounds better on paper, but if I can't confidently explain how it holds under every failure, it's a liability. At-least-once plus idempotency I can trace through every crash point and prove harmless, and I can test the dedup directly. So my tie-breaker is understandability and testability under failure, because a guarantee you can't verify isn't really a guarantee.

---

**B3. Tell me about a tough debugging or troubleshooting experience. — Behavioral**

Answer:
Deploying to the cloud, I hit a wall pushing container images. The backend image kept failing to upload with a timeout, and it wasn't obvious why — the build was fine, the registry auth was fine, it just wouldn't finish. I dug in and worked out that the standard Docker push parallelizes the upload across image layers, splitting my home connection's bandwidth so the single largest layer never completed within the network timeout. Compounding it, one failed attempt left the local Docker environment wedged on a lock that only a machine restart cleared, which sent me briefly down the wrong path thinking the problem was local corruption. Once I understood it was a bandwidth-and-timeout issue, the fix was to push with a tool called crane, which streams and retries the upload instead of parallelizing it — the image went up in a couple of minutes. The takeaway was to diagnose the actual mechanism rather than keep retrying the thing that failed, and that "it times out" often means "look at how the transfer is actually structured."

STAR breakdown: **Situation** — container image pushes to the cloud registry kept timing out. **Task** — get the image published to deploy. **Action** — diagnosed that parallel-layer upload starved the biggest layer on a slow uplink; switched to a streaming, retrying push tool. **Result** — reliable image publish in minutes; documented the lesson so it wouldn't recur.

Follow-up: How did you keep from just retrying blindly?
After the second identical failure I stopped and treated "it times out" as a symptom to explain rather than bad luck to retry through. I reasoned about what a push actually does — multiple concurrent layer uploads — and connected that to my constraint, a limited home uplink, which made the biggest layer's failure make sense. Forming a mechanism-level hypothesis and then choosing a tool that changed that mechanism is what broke the loop. Blind retries would never have fixed a structural bandwidth problem.

---

**B4. Tell me about a mistake you made and what you learned. — Behavioral**

Answer:
The one I point to is a security mistake I caught before it reached real exposure but after it was in the deployment configuration. Early on, seeding demo data and the passwordless local dev-login shortcut were both under the same profile. When I set up the deployment to be seeded with demo data so recruiters could log in, that configuration would have dragged the unauthenticated dev-login endpoint along with it — meaning the deployed app could have had a login bypass. A security review of the deployment changes caught it. The fix was to separate the two concerns into different profiles, so the deploy could be seeded but have no dev-login at all, and I locked it down with a test that boots the deployment profile and asserts the bypass endpoint is genuinely absent. What I learned was that convenience features scoped too broadly become security holes when the scope shifts, and that the fix isn't just to remove the hole but to add a test that fails if it ever comes back.

STAR breakdown: **Situation** — seeding and the dev-login bypass shared one profile. **Task** — deploy a seeded demo without shipping an auth bypass. **Action** — a security review caught the risk; I split the profiles so the deploy seeds without dev-login and added a test asserting the endpoint is gone. **Result** — a Cognito-only deployment with an automated guard against regression.

Follow-up: Why add a test rather than just fixing the config?
Because a config fix protects against the mistake today, but a test protects against it forever. Security holes love to creep back in during a later refactor when someone doesn't remember the original reasoning. A test that boots the deploy profile and asserts the dev-login endpoint returns nothing means if anyone ever re-bundles them, the build fails loudly with a clear signal. Turning a fixed bug into a permanent invariant is the difference between fixing a symptom and closing the class of mistake.

---

**B5. Tell me about a time you took ownership beyond the minimum. — Behavioral**

Answer:
The honest example is the whole approach to honesty and evidence in the project. The minimum for a portfolio piece is working code and a README. I went further because I wanted it to be *defensible*, not just demoable. I held a strict "no unmeasured claims" rule — I only state numbers I actually measured, and I label targets versus measurements. I built an evidence pack with real HTTP transcripts showing the security boundary actually denying cross-tenant and consent-violating access, real observability screenshots, real test captures — so the claims are verifiable rather than asserted. And I wrote architecture decision records capturing *why* each major choice was made and what I rejected. None of that was strictly necessary to have a project to show, but it's the difference between "here's an app" and "here's an app I can stand behind under scrutiny," which is the whole point of a portfolio meant for serious interviews.

STAR breakdown: **Situation** — a portfolio project only strictly needs working code and a readme. **Task** — make it genuinely defensible under interview scrutiny. **Action** — enforced no-unmeasured-claims, built a verifiable evidence pack, wrote decision records. **Result** — a project whose every claim can be checked, not just asserted.

Follow-up: Why does verifiability matter so much to you here?
Because in an interview the claim is worth nothing if I can't back it, and worse than nothing if it turns out inflated. Anyone can say "it's secure and scalable"; being able to show the actual transcript of a cross-tenant request returning a secure 404, or the exact local load-test conditions behind a latency number, is what earns trust. It also keeps me honest with myself — the discipline of only claiming what I can show stopped me from ever hand-waving, which made the project genuinely better, not just better-presented.

---

**B6. Tell me about managing scope or prioritization under constraints. — Behavioral**

Answer:
The project was large — twelve phases — and the constant risk was trying to build everything at once and finishing nothing solid. I managed it by sequencing strictly by dependency and defining a clear MVP: phases zero through five, ending at a working basic adjudication engine, was a complete, demonstrable product on its own. Everything past that — advanced claims, the event-driven layer, cloud deploy, observability — was explicitly "after the core is solid." And I worked in small verified slices: build one thing, prove it works, commit, then the next. That rhythm meant I always had something working rather than a half-built everything, and if I'd had to stop at any point, the last committed slice was solid. Prioritization here was really about resisting the urge to go broad before the core was deep enough to stand on.

STAR breakdown: **Situation** — a twelve-phase system that couldn't be built all at once. **Task** — always have something solid and demonstrable. **Action** — sequenced by dependency, defined phases 0–5 as a shippable MVP, worked in small verified-then-committed slices. **Result** — a continuously-working system with a clear stopping point at every stage.

Follow-up: How did you decide the MVP line specifically at phase five?
Because phase five — basic adjudication — is where the project first tells its complete story: multi-tenant identity, care coordination, consent and privacy, claims intake, and an explainable payment decision. Everything before it is foundational; everything after is enhancement. So it's the earliest point where someone could look at the app and understand the full value proposition — consent-aware access and explainable claims — without a missing core piece. Drawing the MVP at the first *coherent whole* rather than at some feature count is the principle.

---

**B7. Tell me about a trade-off between competing priorities like security, reliability, and cost. — Behavioral**

Answer:
The clearest was the deployment cost trade-off. I'd built a full production-shape AWS stack — load balancer, managed database, container orchestration, CDN — which is the right way to demonstrate real cloud architecture. But leaving it running costs around seventy dollars a month, which is a lot for a portfolio link that might sit unvisited for days. The competing priority was that a portfolio link needs to be *always up* — a recruiter clicking a dead link is worse than no link. So I split it: the impressive stack runs on demand — stood up, evidence captured, torn down — while a much cheaper single-box setup, about fifteen dollars a month, hosts the always-on link. That way I got the architecture credibility *and* reliable availability without paying for idle capacity. The trade-off was accepting that the always-on box is less production-shaped, which I decided was fine because the credibility comes from the code and infrastructure-as-code, not from where the live link points.

STAR breakdown: **Situation** — a production-shape cloud stack was too costly to leave running, but the portfolio link needed 24/7 uptime. **Task** — demonstrate real architecture while keeping a reliable live link affordable. **Action** — ran the full stack on-demand for evidence, hosted the always-on link on a cheap single box, added a budget alarm. **Result** — architecture credibility plus a reliable ~$15/mo live link, with no idle spend.

Follow-up: How did you decide the cheaper box didn't undercut the credibility?
By separating what proves the skill from what hosts the link. The Terraform, the architecture, and captured evidence of the full stack running end-to-end over HTTPS with real auth prove I can build and operate production-grade infrastructure — and that evidence is permanent. The always-on box just needs to keep the link clickable. Nothing about running the expensive stack around the clock would prove anything additional; it would only cost money. So the cheaper box doesn't undercut the credibility because the credibility was never coming from the running stack — it comes from the artifacts and the demonstrated ability.

---

**B8. Tell me about working through uncertainty or learning something unfamiliar. — Behavioral**

Answer:
Going in, I was new to driving a build of this size with an AI coding tool, and the uncertainty wasn't the domain — that was well specified — it was *how* to actually execute something this big without getting lost across many sessions. I resolved it by imposing structure: a rulebook file the tool reads every session so conventions stay consistent, a roadmap file, and a running progress log, so any session could re-orient by reading three files. Then a strict working rhythm — one small slice, verify it, commit, update the log — so progress was always concrete and recoverable. The uncertainty was real at the start, and the way through it was building a system that made the work legible over time rather than relying on holding it all in my head. By the later phases the rhythm was second nature.

STAR breakdown: **Situation** — new to executing a large, multi-week build with an AI tool. **Task** — build a twelve-phase system without losing coherence across many sessions. **Action** — set up a rulebook, roadmap, and progress log; adopted a strict slice-verify-commit-log rhythm. **Result** — steady, recoverable progress across the whole project without losing the thread.

Follow-up: What would you tell someone starting a big project with this kind of uncertainty?
Externalize the memory and shrink the unit of work. You can't hold a large project in your head across weeks, so put the conventions, the plan, and the running status into files that survive between sessions — then any day you can re-orient in minutes. And make the unit of progress small and verifiable: one slice, proven to work, committed. That turns an intimidating "build this huge thing" into a repeatable "do the next small correct thing," which is both less overwhelming and far safer, because you're never more than one slice from a known-good state.

---

**B9. How did you ensure quality when using AI to write much of the code? — Behavioral**

Answer:
By never treating generated code as trusted until I'd verified it, and by building the verification into the process. Every slice ended in me actually running it, testing it, and often clicking through it — "it compiles" was never "it works." The negative and security tests were central, because they assert the *denials* that matter, so generated code that skipped a check would fail a test rather than slip through. I also used review passes tuned to the project's own invariants — tenant scoping, the authorization layering, the secure-404, no sensitive data in logs — to catch subtle issues. And it worked: that's how the deployed dev-login bypass got caught. So quality came from a disciplined loop and tests that encode the requirements, with me owning the judgment of whether each slice was correct and what I meant.

STAR breakdown: **Situation** — much of the code was AI-generated across a large system. **Task** — ensure it was correct, secure, and something I understood and owned. **Action** — verify-every-slice loop, negative/security tests as the proof, invariant-focused review passes. **Result** — real bugs caught (e.g. the dev-login bypass) and a system I can explain and defend end to end.

Follow-up: Where's the line between using AI as a tool and it "doing the project for you"?
The line is judgment and understanding. The tool accelerates producing code, but deciding the architecture, sequencing the work, recognizing a subtle security bug, knowing that re-adjudication must reverse before recomputing — that's the engineering, and that's mine. The test of whether it's really your project is simple: can you explain and defend every decision, and do you know what breaks if you change something? If yes, the AI was a tool; if no, it did the project for you. I can do that across this system, which is exactly why this whole preparation is possible.

---

**B10. What would you do differently if you built this again? — Behavioral**

Answer:
I'd keep the architecture — the modular monolith, shared-database multi-tenancy, layered authorization, the outbox all held up under the whole build. What I'd change is sequencing and a couple of early habits. I'd separate the deploy profiles from day one so the dev-login-and-seeding bundling never happened, since that was a real security bug earlier automation would have flagged. I'd build the outbox relay to be multi-instance-safe from the start, because the fix is cheap and known and it's the main scaling blocker. And I'd wire the security scanners into the pipeline early rather than leaving them as follow-ups. So: same structural decisions, but a few things done earlier and more carefully instead of discovered or deferred.

STAR breakdown: **Situation** — reflecting on the completed build. **Task** — identify genuine improvements without pretending the whole thing was flawed. **Action** — kept the sound structural decisions; named specific earlier/better choices (deploy-profile split, multi-instance relay, early scanners). **Result** — a concrete, honest list of what to sequence differently next time.

Follow-up: Team-based behavioral prompts (conflict, disagreeing with a manager, mentoring). — Needs your real experience
These don't have a truthful basis in HealthCloud, which is a solo, AI-assisted project — there were no teammates to disagree with or mentor. **Don't invent a HealthCloud story for these.** Draw on your real work, internship, academic-team, or open-source experience instead. There's a checklist in [§32's "Personal details to confirm"](#personal-details-to-confirm) of exactly which prompts need a real story from your background so you can prepare them separately with genuine specifics.

---

## 32. Final revision

### "Tell me about HealthCloud" — three lengths

**15-second version:**
HealthCloud is a multi-tenant healthcare platform for care coordination and insurance claims, where every read is consent-aware — access depends not just on your role but on your relationship to the patient and their consent, all enforced on the backend. It's a portfolio project on synthetic data, built production-shape with a real claims-adjudication engine, event-driven messaging, and a cloud deployment.

**60-second version:**
HealthCloud coordinates patient care and processes insurance claims for multiple healthcare organizations that share one system but are strictly isolated from each other. The differentiator is layered authorization: five independent checks — tenant, role, relationship, consent-and-purpose, and field-level masking — so two people with the same role can get different results, and a field like a date of birth can come back masked because the patient's consent denies it. The other centerpiece is a deterministic, explainable claims-adjudication engine that computes exactly who pays what and can show its reasoning line by line. Under the hood it's a modular monolith in Spring Boot with a React frontend, PostgreSQL, and a transactional outbox publishing to Kafka for reliable events. It's deployed two ways — a full production-shape AWS stack in Terraform that I run on demand, and an always-on single-box demo. Everything's synthetic data, and I hold a strict rule of only claiming numbers I've actually measured.

**Detailed version (2–3 minutes):**
Start with the 60-second version, then go deeper on whichever thread the interviewer leans toward. If it's security: the backend is the only trust boundary, the tenant always comes from the authenticated session and never the client, all patient access funnels through a single guard that returns a secure 404 so you can't even probe for existence, consent is deny-by-default with most-specific-tier-wins, and there's a tamper-evident audit trail using a per-organization hash chain whose key is held outside the database. If it's the domain: the adjudication engine applies allowed, copay, deductible, coinsurance, and out-of-pocket cap in order, uses exact decimal money, carries running totals across a year in an accumulator protected by a row lock, and supports versioned re-adjudication that reverses the prior contribution before recomputing. If it's distributed systems: the transactional outbox solves the dual-write problem by committing the event in the same transaction as the change, then a relay publishes at-least-once and idempotent consumers dedupe on event ID, with retry, dead-lettering, and replay as the safety net. Close on honesty: it's synthetic, HIPAA-aligned not certified, and the things that aren't built — the security scanners in CI, Playwright end-to-end tests, cloud observability wiring — are documented follow-ups, not hidden.

---

### Master these first (highest-value questions)

If you only prepare a dozen answers, prepare these — they're the ones that come up and the ones the whole project hangs on:

1. The five authorization layers and why same-role-different-result — [Q8.2](#8-authorization--privacy), [Q8.6](#8-authorization--privacy)
2. The secure 404 and why not 403 — [Q6.2](#6-api-design), [Q8.3](#8-authorization--privacy)
3. How the tenant is determined and why never from the client — [Q9.3](#9-multi-tenancy)
4. Consent resolution: deny-by-default, most-specific-tier-wins, deny-wins — [Q10.3](#10-consent-management), [Q10.4](#10-consent-management)
5. The adjudication calculation order + the worked example — [Q12.2](#12-claims-processing--adjudication), [Q12.3](#12-claims-processing--adjudication)
6. The benefit accumulator: insert-if-absent + row lock, and why pessimistic here — [Q5.5](#5-database-postgresql), [Q12.5](#12-claims-processing--adjudication)
7. The transactional outbox and the dual-write problem — [Q14.2](#14-event-driven-architecture)
8. At-least-once + idempotent consumers instead of exactly-once — [Q14.3](#14-event-driven-architecture)
9. One-transaction writes (change + history + audit + outbox) — [Q4.3](#4-backend-java--spring-boot)
10. The tamper-evident audit hash chain + key placement — [Q21.2](#21-audit--governance), [Q21.3](#21-audit--governance)
11. Why a modular monolith, and when it stops being right — [Q2.2](#2-system-design--architecture), [Q1.8](#1-project-overview--requirements)
12. Your honesty framing: synthetic, measured-only, AI-assisted-but-owned — [Q1.7](#1-project-overview--requirements), [Q28.1](#28-ownership--ai-assistance)

---

### Decision & trade-off recap

A fast cheat-sheet of the major choices and the trade-off behind each:

- **Modular monolith over microservices** — keeps single-transaction guarantees and puts the focus on domain logic; would revisit only under independent-deploy or divergent-scaling pressure.
- **Shared database + org_id over DB-per-tenant** — cheapest to operate; isolation becomes my job, backed by org-scoped repos + composite foreign keys + isolation tests.
- **Backend-for-frontend session over browser tokens** — no tokens in the browser, smaller attack surface; couples the SPA to its backend (fine here).
- **Secure 404 over 403** — denials don't leak existence; used for object-level/existence-sensitive access.
- **Optimistic locking generally, pessimistic on money** — cheap conflict-detection where conflicts are rare; serialized correctness where a lost update means wrong money.
- **Transactional outbox + at-least-once + idempotent consumers over exactly-once** — atomic and testable; avoids the fragile exactly-once trap.
- **BigDecimal money, scale 2, half-up** — exact decimal arithmetic; no floating-point drift.
- **Deny-by-default consent, most-specific-tier-wins** — safe default; intuitive, stable conflict resolution.
- **Two deployments (on-demand ECS + always-on cheap box)** — production-shape credibility plus an always-up link, without paying for idle capacity.
- **No NAT gateway / no managed cloud Kafka** — real cost savings; patterns proven locally, database kept private.
- **No unmeasured claims** — every number is measured or labelled a target; follow-ups labelled as not-built.

---

### Mock interview sequences

Practice these as chains — answer one, then follow the natural next question, using the linked answers.

**Mock A — Security deep-dive (senior/staff style):**
1. "How does authorization work?" → [Q8.2](#8-authorization--privacy)
2. "Two users same role, different results — show me why." → [Q8.6](#8-authorization--privacy)
3. "Why 404 not 403?" → [Q8.3](#8-authorization--privacy)
4. "How is the relationship check impossible to bypass?" → [Q8.4](#8-authorization--privacy)
5. "What's your biggest access-control risk and how do you catch a regression?" → [Q22.4](#22-security--threat-modeling)
6. "What security risks remain?" → [Q22.5](#22-security--threat-modeling)

**Mock B — Distributed systems / reliability:**
1. "Why an event-driven layer?" → [Q14.1](#14-event-driven-architecture)
2. "What's the dual-write problem and how do you solve it?" → [Q14.2](#14-event-driven-architecture)
3. "How do you avoid double-processing?" → [Q14.3](#14-event-driven-architecture)
4. "A consumer keeps failing — then what?" → [Q14.4](#14-event-driven-architecture)
5. "Trace a change from the DB transaction to a notification, and where it can break." → [Q30.5](#30-end-to-end-flows)
6. "What breaks first at real scale?" → [Q2.6](#2-system-design--architecture), [Q25.3](#25-reliability--performance)

**Mock C — Domain / claims correctness:**
1. "What does adjudication do?" → [Q12.2](#12-claims-processing--adjudication)
2. "Walk the math with numbers." → [Q12.3](#12-claims-processing--adjudication)
3. "How does the deductible carry across claims under concurrency?" → [Q12.5](#12-claims-processing--adjudication)
4. "Re-adjudicate a claim without corrupting totals." → [Q12.6](#12-claims-processing--adjudication)
5. "How do you keep money exact?" → [Q12.3](#12-claims-processing--adjudication) (BigDecimal follow-up)

**Mock D — Behavioral round:**
1. "Hardest technical challenge?" → [B1](#31-behavioral--star-questions)
2. "An important decision and how you made it?" → [B2](#31-behavioral--star-questions)
3. "A mistake and what you learned?" → [B4](#31-behavioral--star-questions)
4. "How did you ensure quality with AI writing code?" → [B9](#31-behavioral--star-questions)
5. "What would you do differently?" → [B10](#31-behavioral--star-questions)

**Mock E — Full-stack breadth (screening style):**
1. "Give me the overview." → [Q2.1](#2-system-design--architecture) + the 60-sec pitch
2. "How does login work end to end?" → [Q30.1](#30-end-to-end-flows)
3. "How does the frontend know you're logged in?" → [Q3.2](#3-frontend-react--typescript)
4. "How is the database schema managed and kept multi-tenant?" → [Q5.2](#5-database-postgresql), [Q5.3](#5-database-postgresql)
5. "How is it deployed and how do you control cost?" → [Q17.1](#17-cloud--infrastructure), [Q26.1](#26-cost-management)

---

### Personal details to confirm

These are the only places the guide needs input only you can give. Prepare these from your real experience — don't invent HealthCloud stories for them.

- **Team-based behavioral stories** (see [B10 follow-up](#31-behavioral--star-questions)): conflict with a teammate, disagreeing with a manager, mentoring or helping someone, influencing without authority, receiving hard feedback. HealthCloud is solo + AI-assisted, so these have no truthful basis here — prepare them from your real work, internship, academic-team, or open-source experience.
- **Your motivation story**: *why* you chose to build a healthcare consent-and-claims platform specifically. The guide deliberately doesn't invent a personal motivation — have a genuine one-liner ready ("I wanted a domain where authorization is genuinely hard," or your real reason).
- **Timeline / effort**: how long the project took and roughly how much time you put in — only you know this. Useful for "how long did this take?"
- **Your background framing**: how HealthCloud fits your broader story — student, career-switcher, strengthening backend/cloud skills — so "walk me through your background" connects naturally to it.
- **Any real production/scale experience elsewhere**: if you have work experience with real users or scale, keep it clearly separate from HealthCloud's synthetic-data reality so you never blur the two.

---

### Coverage checklist

What this guide covers, so you can track your revision:

- [ ] 1. Project overview & requirements
- [ ] 2. System design & architecture
- [ ] 3. Frontend (React/TS)
- [ ] 4. Backend (Java/Spring Boot)
- [ ] 5. Database (PostgreSQL)
- [ ] 6. API design
- [ ] 7. Authentication (Cognito/BFF/sessions/CSRF)
- [ ] 8. Authorization & privacy (five layers, masking, secure 404)
- [ ] 9. Multi-tenancy
- [ ] 10. Consent management
- [ ] 11. Healthcare workflows & state machines
- [ ] 12. Claims processing & adjudication
- [ ] 13. Document management
- [ ] 14. Event-driven architecture (outbox/Kafka)
- [ ] 15. Notifications
- [ ] 16. Testing
- [ ] 17. Cloud & infrastructure (AWS/Terraform)
- [ ] 18. CI/CD
- [ ] 19. Observability
- [ ] 20. Backup & recovery
- [ ] 21. Audit & governance (hash chain, break-glass, retention)
- [ ] 22. Security & threat modeling (STRIDE)
- [ ] 23. Search & reporting
- [ ] 24. UI/UX & accessibility
- [ ] 25. Reliability & performance
- [ ] 26. Cost management
- [ ] 27. Documentation & demonstration
- [ ] 28. Ownership & AI assistance
- [ ] 29. Limitations & future work
- [ ] 30. End-to-end flows
- [ ] 31. Behavioral & STAR
- [ ] Personal details to confirm (your input needed)

**A few honest reminders to carry into every interview:** it's synthetic data; it's HIPAA-*aligned*, not certified; the measured numbers (694 tests — 511 backend, 183 frontend; ~107 req/s local read-path load test) are exactly that — measured, local, not production SLAs; the unbuilt pieces (CI security scanners, Playwright E2E, cloud observability wiring, email notifications) are documented follow-ups; and you directed, reviewed, verified, and own the project — the AI accelerated the typing, not the judgment.










