# Security Policy

> **Project:** CLite — xastudio.clite
> **Author:** XA Studio (eXtended Attention Studio)
> **Repository:** [github.com/xastudio360/clite](https://github.com/xastudio360/clite)

---

## Table of Contents

- [Supported Versions](#supported-versions)
- [Scope](#scope)
- [Out of Scope](#out-of-scope)
- [Reporting a Vulnerability](#reporting-a-vulnerability)
- [Response Process](#response-process)
- [Severity Classification](#severity-classification)
- [Disclosure Policy](#disclosure-policy)
- [Planned Security Releases](#planned-security-releases)
- [Security Design Principles](#security-design-principles)

---

## Supported Versions

Security fixes are backported according to the following support matrix:

| Version line | Status               | Security fixes until    |
|--------------|----------------------|-------------------------|
| `1.x` (latest) | ✅ Actively supported | Current stable + 1 year after `2.0.0` |
| `0.x`        | ⚠️ Pre-release only  | Not supported. Upgrade to `1.0.0`.    |

Once `2.0.0` is released, `1.x` enters **maintenance mode**: security fixes only,
no new features. `0.x` pre-release versions receive no security support.

---

## Scope

The following are in scope for security reports:

| Category                    | Examples                                                     |
|-----------------------------|--------------------------------------------------------------|
| Memory safety               | Buffer overflows, out-of-bounds reads/writes, use-after-free |
| Integer safety              | Integer overflows leading to incorrect allocation sizes       |
| Format string vulnerabilities | Unsanitized format strings in `clite_fmt` or `clite_log`   |
| Input validation            | Malformed UTF-8, untrusted string data causing unsafe behavior|
| API contract violations     | Functions exhibiting undefined behavior on valid inputs       |
| Denial of service           | Inputs that cause excessive memory allocation or infinite loops|
| FFI boundary safety         | Memory corruption or type confusion across the FFI layer      |

---

## Out of Scope

The following are **not** in scope for security reports:

| Category                             | Reason                                                    |
|--------------------------------------|-----------------------------------------------------------|
| Bugs that require `CLITE_RELEASE` to be disabled | Debug-only assertions are not a security boundary |
| Issues in third-party dependencies   | Report to the respective upstream project                 |
| Theoretical vulnerabilities with no practical exploit path | Requires demonstrated impact |
| Cryptographic functionality          | CLite does not implement cryptography                     |
| Issues in code marked `@experimental`| Not covered by stability or security guarantees           |
| Social engineering or phishing       | Outside the scope of a code library                       |
| Vulnerabilities in the developer's own application code that uses CLite | CLite cannot protect against misuse at the application level |

If you are unsure whether an issue is in scope, report it privately and we will
assess it together.

---

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.** Public
disclosure before a fix is available puts all users of CLite at risk.

### Preferred method — GitHub Security Advisory (private)

Use GitHub's private vulnerability reporting:

1. Go to [github.com/xastudio360/clite/security/advisories/new](https://github.com/xastudio360/clite/security/advisories/new)
2. Fill in the advisory form with as much detail as possible (see below).
3. Submit. The report is visible only to you and the maintainers.

### What to include in your report

A high-quality report accelerates the response significantly. Please include:

- **Description** — a clear explanation of the vulnerability and its potential impact.
- **Affected versions** — which version(s) you observed the issue in.
- **Affected module(s)** — which CLite module(s) are involved (e.g., `clite_strbuf`, `clite_utf8`).
- **Reproduction steps** — a minimal, self-contained C program that demonstrates
  the issue. Attach it as a file if the code is long.
- **Expected behavior** — what should happen.
- **Actual behavior** — what actually happens (crash, wrong output, memory error, etc.).
- **Sanitizer output** — if ASan, UBSan, or Valgrind output is available, include it.
- **Suggested severity** — your assessment using the classification in the next section.
- **Suggested fix** — optional, but welcome if you have one.
- **CVE request** — indicate if you have already requested or been assigned a CVE.

The more detail you provide, the faster we can validate, fix, and credit your report.

---

## Response Process

Upon receiving a vulnerability report, XA Studio follows this process:

```
Day 0     Report received
  │
  ▼
Day 1–2   Acknowledgement sent to reporter
  │
  ▼
Day 3–7   Initial triage: severity assessed, affected versions identified
  │
  ▼
  ├── Critical → fix development begins immediately
  ├── Moderate → fix development begins within the week
  └── Minor    → scheduled for next patch cycle
  │
  ▼
  Fix developed on a private branch, validated with sanitizers and tests
  │
  ▼
  Reporter notified of fix availability and asked to validate (if willing)
  │
  ▼
  Coordinated disclosure date agreed (default: fix release date)
  │
  ▼
  Security release published (see response SLA below)
  │
  ▼
  GitHub Security Advisory published
  CVE published (if applicable)
  CHANGELOG.md updated with ### Security entry
```

### Response SLA

Response timelines are measured from the date the report is received:

| Severity   | Acknowledgement | Fix release     |
|------------|-----------------|-----------------|
| 🔴 Critical | ≤ 24 hours      | < 1 week        |
| 🟡 Moderate | ≤ 48 hours      | 1–2 weeks       |
| 🟢 Minor    | ≤ 72 hours      | 2–4 weeks       |

These are commitments, not targets. If a fix requires more time due to complexity,
the reporter will be notified and a status update will be provided.

---

## Severity Classification

CLite uses the following four-level severity model, aligned with common industry
practice:

### 🔴 Critical

Vulnerabilities that can be exploited remotely or with minimal user interaction
to cause memory corruption, code execution, or significant data loss.

**Examples:**
- Heap buffer overflow triggered by untrusted input to `clite_strbuf`
- Integer overflow in allocation size calculation leading to underallocation
- Out-of-bounds write in `clite_utf8` when processing attacker-controlled data

**SLA:** Fix released in < 1 week. Out-of-band release issued immediately.

---

### 🟡 Moderate

Vulnerabilities that require specific conditions or user interaction to exploit,
or that have limited impact (e.g., information disclosure without code execution,
denial of service requiring local access).

**Examples:**
- Out-of-bounds read (information disclosure) in `clite_str_slice`
- Infinite loop triggered by a specifically crafted UTF-8 sequence
- OOM condition not properly propagated, causing silent data truncation

**SLA:** Fix released in 1–2 weeks, in the next scheduled patch release.

---

### 🟢 Minor

Low-impact vulnerabilities with no realistic exploit path, or issues where the
impact is limited to degraded behavior with no security consequence.

**Examples:**
- Assertion not triggered on invalid input in release mode (no memory corruption)
- Log message including more information than intended (no sensitive data)
- Incorrect return value on a rare error path with no downstream effect

**SLA:** Fix released in 2–4 weeks, in the next scheduled patch release.

---

### ℹ️ Informational

Design observations, hardening suggestions, or potential future risks that are
not currently exploitable. These are tracked but do not trigger the security
release process. They are addressed in regular feature releases.

---

## Disclosure Policy

XA Studio follows **coordinated disclosure** (also known as responsible disclosure):

1. The reporter notifies XA Studio privately.
2. XA Studio acknowledges receipt and begins working on a fix.
3. A disclosure date is agreed upon — typically the date the fix is released,
   but no later than **90 days** from the initial report.
4. The fix is released and the advisory is published simultaneously.
5. The reporter is credited in the advisory unless they request anonymity.

If XA Studio fails to respond within the SLA defined above, or if the 90-day
deadline approaches without a resolution, the reporter is free to disclose
publicly with reasonable notice (minimum 7 days).

We ask that reporters:
- Not exploit the vulnerability beyond what is necessary to demonstrate it.
- Not disclose the vulnerability publicly until the coordinated disclosure date.
- Not access, modify, or destroy data belonging to other users.

---

## Planned Security Releases

In addition to on-demand security fixes, CLite publishes **quarterly security
maintenance releases** on the following schedule:

| Quarter | Target month |
|---------|-------------|
| Q1      | March       |
| Q2      | June        |
| Q3      | September   |
| Q4      | December    |

These releases include accumulated minor security fixes and hardening improvements
that do not warrant an immediate out-of-band release. The release notes will
clearly identify all security-related changes in the `### Security` section of
`CHANGELOG.md`.

---

## Security Design Principles

Understanding how CLite approaches security by design helps contributors write
safe code and helps users assess their exposure:

**No silent failures.** Every CLite API that can fail returns an explicit result.
There is no `errno`, no unchecked `-1`, no silent `NULL`. An application that
checks all `CliteResult` values will never silently ignore an error condition.

**Bounds checking by default.** All slice and collection access is bounds-checked
in debug builds. `CLITE_RELEASE` disables these checks for performance — it is
the application developer's responsibility to ensure inputs are validated before
enabling release mode.

**Explicit ownership.** Every allocation has a documented owner. CLite does not
use implicit shared ownership or garbage collection. The ownership model
(Owned / Borrowed / Shared via `clite_rc`) is documented for every public
function that returns a pointer.

**No format string vulnerabilities by design.** `clite_strbuf_append_fmt` is
built on bounded formatting primitives. CLite never passes a user-controlled
string directly as a format argument.

**Sanitizer-clean from day one.** All modules are developed and tested under
ASan, UBSan, TSan, and Valgrind as a mandatory CI requirement, not an optional
extra. A sanitizer failure is treated as a build failure.

**`CLITE_NO_STDLIB` does not reduce security.** The embedded build mode disables
standard library dependencies but does not relax any safety invariant. Bounds
checking, assertion handling, and error propagation behave identically.

---

## Attribution

XA Studio thanks all security researchers and contributors who responsibly
disclose vulnerabilities. Reporters are credited by name (or handle) in the
GitHub Security Advisory for each issue, unless anonymity is requested.

---

*© XA Studio (eXtended Attention Studio). All rights reserved under Apache License 2.0.*
