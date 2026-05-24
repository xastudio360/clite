# Contributing to CLite

> **Author:** XA Studio (eXtended Attention Studio)
> **Repository:** [github.com/xastudio360/clite](https://github.com/xastudio360/clite)

Thank you for your interest in contributing to CLite. This document describes
everything you need to know to submit a high-quality contribution — from setting
up your environment to getting your pull request merged.

Please read this document in full before opening a PR. Contributions that do not
follow these guidelines will be asked to revise before review begins.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Ways to Contribute](#ways-to-contribute)
- [Before You Start](#before-you-start)
- [Development Environment](#development-environment)
- [Branch Strategy](#branch-strategy)
- [Commit Convention](#commit-convention)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [File Header](#file-header)
- [Testing Requirements](#testing-requirements)
- [Documentation Requirements](#documentation-requirements)
- [Changelog Requirements](#changelog-requirements)
- [Deprecation Process](#deprecation-process)
- [Review Expectations](#review-expectations)

---

## Code of Conduct

CLite is a professional open-source project. All contributors are expected to
engage respectfully and constructively. Harassment, personal attacks, or
deliberately hostile communication will not be tolerated and may result in
permanent exclusion from the project.

---

## Ways to Contribute

| Type                     | How                                                              |
|--------------------------|------------------------------------------------------------------|
| Bug report               | Open an issue using the **Bug Report** template                  |
| Feature request          | Open an issue using the **Feature Request** template             |
| Bug fix                  | Fork → fix → PR targeting `develop`                             |
| New feature              | Discuss in an issue first, then fork → implement → PR           |
| Documentation            | Fork → edit `docs/` or doc comments → PR targeting `develop`    |
| Performance improvement  | Provide before/after benchmark results in the PR description     |
| Platform port            | Open an issue first; follow the porting guide in `docs/`        |

If you are unsure whether your contribution fits the project scope, open a
discussion issue before writing any code. This saves everyone time.

---

## Before You Start

1. **Search existing issues and PRs.** Your bug or idea may already be tracked.
2. **For non-trivial features**, open a feature request issue and wait for
   maintainer feedback before investing time in implementation.
3. **For bug fixes**, you may proceed directly, but linking to an existing issue
   is strongly encouraged.
4. **Check the roadmap** ([`ROADMAP.md`](ROADMAP.md)). If your idea is already
   planned for an upcoming phase, coordinate with the maintainers to avoid
   duplicate work.

---

## Development Environment

### Required tools

| Tool              | Minimum version | Purpose                          |
|-------------------|-----------------|----------------------------------|
| GCC or Clang      | GCC 8 / Clang 7 | Primary compiler                 |
| CMake             | 3.16            | Build system                     |
| clang-format      | 14.0            | Code formatting (enforced in CI) |
| clang-tidy        | 14.0            | Static analysis (enforced in CI) |
| cppcheck          | 2.9             | Additional static analysis       |
| Python 3          | 3.8             | CI helper scripts                |

### Recommended tools

| Tool              | Purpose                                     |
|-------------------|---------------------------------------------|
| Valgrind          | Memory leak detection (Linux)               |
| AddressSanitizer  | Memory error detection (GCC/Clang)          |
| UndefinedBehaviorSanitizer | UB detection (GCC/Clang)          |
| Doxygen           | Local API reference generation              |
| Meson             | Alternative build system verification       |

### Setup

```sh
# Clone your fork
git clone https://github.com/<your-username>/clite.git
cd clite

# Add the upstream remote
git remote add upstream https://github.com/xastudio360/clite.git

# Configure a debug build with sanitizers
cmake -B build \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCLITE_BUILD_TESTS=ON \
  -DCLITE_BUILD_SAMPLES=ON \
  -DCLITE_SANITIZERS=ON

cmake --build build --parallel

# Run the full test suite
ctest --test-dir build --output-on-failure
```

---

## Branch Strategy

CLite uses a structured branching model. **Never target `main` directly.**

```
main                  ← stable, tagged releases only
│
└── develop           ← integration branch; all PRs target here
    │
    ├── feature/<name>    ← new features and non-trivial improvements
    ├── fix/<name>        ← bug fixes
    ├── docs/<name>       ← documentation-only changes
    ├── perf/<name>       ← performance improvements
    ├── refactor/<name>   ← internal refactoring, no API change
    └── hotfix/<name>     ← critical fixes (branched from main, merged to both)
```

### Rules

- Branch names are lowercase, hyphen-separated: `feature/arena-checkpoint`, `fix/strbuf-overflow`.
- `main` is protected. Only maintainers merge into `main`, and only from a
  `release/*` or `hotfix/*` branch after full CI passes.
- `develop` is semi-protected. PRs require at least one maintainer approval.
- Hotfix branches are branched from `main` and merged into **both** `main` and
  `develop` to keep them in sync.
- Delete your branch after it is merged.

---

## Commit Convention

CLite follows [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).
Every commit message must conform to this format:

```
<type>(<scope>): <short description>

[optional body]

[optional footer(s)]
```

### Types

| Type       | When to use                                              |
|------------|----------------------------------------------------------|
| `feat`     | A new feature or public API addition                     |
| `fix`      | A bug fix                                                |
| `perf`     | A performance improvement with no API change             |
| `refactor` | Internal restructuring with no behavior or API change    |
| `docs`     | Documentation only                                       |
| `test`     | Adding or fixing tests only                              |
| `build`    | Build system, CI, toolchain changes                      |
| `chore`    | Maintenance tasks (dependency bumps, file renames, etc.) |
| `security` | Security fix (coordinate with maintainers before commit) |

### Scope

The scope is the module name in lowercase: `mem`, `arena`, `str`, `vec`, `result`,
`log`, `ci`, `cmake`, `docs`, etc.

### Examples

```
feat(vec): add Name_reserve() to pre-allocate capacity

fix(strbuf): prevent integer overflow in capacity growth calculation

perf(map): replace linear probe with quadratic probe for better cache behavior

docs(arena): document checkpoint/restore lifetime requirements

build(ci): add ARM64 Linux runner to matrix

security(fmt): add format string length validation
```

### Rules

- The short description is **imperative mood**, lowercase, no trailing period:
  `add`, `fix`, `remove`, `update` — not `added`, `fixes`, `removed`.
- Maximum 72 characters for the first line.
- Body lines wrap at 80 characters.
- Reference issues in the footer: `Fixes #42`, `Closes #17`, `Refs #99`.
- Breaking changes must include `BREAKING CHANGE:` in the footer:

```
feat(result): rename CliteResult_unwrap to CliteResult_value

BREAKING CHANGE: CliteResult_unwrap has been renamed to CliteResult_value
to avoid confusion with panicking behavior. Update all call sites.

Refs #88
```

---

## Pull Request Process

### Before opening a PR

- [ ] Your branch is up to date with `upstream/develop`
- [ ] `cmake --build build` succeeds with zero warnings under `-Wall -Wextra -Werror`
- [ ] `ctest --test-dir build` passes with zero failures
- [ ] `clang-format` has been applied to all changed files
- [ ] `clang-tidy` reports zero warnings on all changed files
- [ ] New public symbols have doc comments
- [ ] `CHANGELOG.md` has been updated (see [Changelog Requirements](#changelog-requirements))
- [ ] Tests have been added or updated for the change (see [Testing Requirements](#testing-requirements))

### PR description

A PR description must include:

1. **What** — a concise description of the change.
2. **Why** — motivation and context. Link to the relevant issue.
3. **How** — a brief explanation of the implementation approach for non-trivial changes.
4. **Testing** — what was tested and how.
5. **Breaking changes** — list any API or behavior changes that affect existing users.

Use the PR template provided in `.github/`.

### Review and merge

- A minimum of **one maintainer approval** is required before merging.
- The CI pipeline must be fully green (all platforms, all sanitizers).
- Maintainers may request changes. Address all comments before re-requesting review.
- Squash merging is used for feature branches. Merge commits are used for
  `release/*` and `hotfix/*` branches to preserve history.
- The PR author is responsible for keeping the branch up to date with `develop`
  during review. Use `git rebase`, not merge commits.

---

## Coding Standards

### Language and standard

All production code is written in **C11** (minimum). C17 features may be used
where beneficial, guarded with `#if __STDC_VERSION__ >= 201710L`. C++ is not
permitted in production code. Headers must be compatible with `extern "C"`.

### Formatting

Formatting is enforced automatically by `clang-format`. Run it before every commit:

```sh
clang-format -i include/xastudio/clite/*.h src/*.c tests/**/*.c samples/*.c
```

The `.clang-format` file at the repository root is the authoritative configuration.
Do not modify it without a maintainer discussion.

### Naming conventions

| Entity                  | Convention               | Example                        |
|-------------------------|--------------------------|--------------------------------|
| Types (structs, enums)  | `PascalCase` with prefix | `CliteArena`, `CliteStatus`    |
| Functions               | `clite_module_verb_noun` | `clite_arena_alloc_aligned`    |
| Macros                  | `CLITE_UPPER_SNAKE`      | `CLITE_ASSERT`, `CLITE_LIKELY` |
| Constants / enum values | `CLITE_UPPER_SNAKE`      | `CLITE_ERR_OOM`, `CLITE_OK`   |
| Private functions       | `static` + same naming   | `static void arena_grow(...)`  |
| Parameters & locals     | `lower_snake_case`       | `initial_capacity`, `node_ptr` |

### Error handling

- Public functions that can fail **must** return `CliteResult`, `CliteStatus`,
  or `bool`. Returning `-1` and setting `errno` is forbidden.
- `NULL` return values are only permitted for functions explicitly documented
  as returning an optional pointer (i.e., they parallel `CliteOption`).
- Internal-only functions (marked `static`) may use simplified error signaling
  provided the caller always checks the result.

### Memory

- All allocations must go through a `CliteAllocator`. Direct calls to `malloc`,
  `calloc`, `realloc`, or `free` are forbidden in production code except inside
  `src/mem.c`.
- Every allocation must have a documented owner and a clear free path.
- Module init functions that allocate memory must have a corresponding destroy
  function that frees all resources, even on partial initialization.

### Portability

- Do not use compiler extensions without a portability macro defined in
  `clite_compiler`. If you need a new extension, add the macro there first.
- Do not use platform-specific APIs directly. Abstract them behind the
  appropriate module (e.g., threading goes through `clite_thread`).
- All code must compile cleanly on GCC, Clang, and MSVC at their supported
  minimum versions.
- Do not use Variable-Length Arrays (VLAs). They are not supported in C++,
  are optional in C11, and are forbidden in `CLITE_NO_STDLIB` mode.

### Assertions and undefined behavior

- Use `CLITE_ASSERT` / `CLITE_ASSERT_MSG` for invariant checks, never raw `assert()`.
- Do not rely on undefined behavior, even if the current compiler produces the
  expected output. UBSan must report zero errors on all tests.
- Signed integer overflow, null pointer dereference, and out-of-bounds access
  are never acceptable, even in internal code paths.

---

## File Header

Every source file (`.h` and `.c`) must begin with the standard XA Studio header:

```c
// Copyright (c) XA Studio (eXtended Attention Studio).
// Licensed under the Apache License, Version 2.0.
// See LICENSE in the project root for license information.
//
// Project : xastudio.clite
// Author  : XA Studio <github.com/xastudio360>
// Created : YYYY-MM-DD
```

Replace `YYYY-MM-DD` with the date the file was first created. Do not update
this date on subsequent edits.

---

## Testing Requirements

Every code change must be accompanied by tests. The following rules apply:

### Coverage

- New public functions must have unit tests covering:
  - The happy path (correct input, expected output)
  - All documented error conditions
  - Edge cases: empty input, maximum values, zero-length buffers
- Bug fixes must include a regression test that fails before the fix and
  passes after.
- Coverage target is **≥ 80% line coverage** per module, measured in CI.

### Sanitizers

All tests must pass under the following sanitizers with zero errors:

```sh
cmake -B build-san \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCLITE_SANITIZERS=ON
cmake --build build-san
ctest --test-dir build-san --output-on-failure
```

### Test framework

CLite uses [Unity](https://github.com/ThrowTheSwitch/Unity) for unit tests.
Place unit tests in `tests/unit/test_<module>.c`. Integration tests go in
`tests/integration/`. Fuzz targets go in `tests/fuzz/fuzz_<module>.c`.

### Test naming

```c
// Function under test: clite_arena_alloc
// Test name: test_arena_alloc_<scenario>

void test_arena_alloc_returns_aligned_pointer(void) { ... }
void test_arena_alloc_fails_when_capacity_exceeded(void) { ... }
void test_arena_alloc_zero_size_returns_valid_pointer(void) { ... }
```

---

## Documentation Requirements

### Doc comments

Every public symbol (function, type, macro, enum value) must have a
Doxygen-compatible doc comment in its header file:

```c
/**
 * @brief Allocates @p size bytes from the arena.
 *
 * The returned pointer is aligned to @p CLITE_DEFAULT_ALIGNMENT bytes.
 * Returns NULL if the arena has insufficient remaining capacity.
 * Does NOT call the OOM handler — arena exhaustion is a recoverable condition.
 *
 * @param arena  Initialized arena. Must not be NULL.
 * @param size   Number of bytes to allocate. Must be > 0.
 * @return       Pointer to allocated memory, or NULL on exhaustion.
 *
 * @see clite_arena_alloc_aligned
 * @see clite_arena_reset
 */
void* clite_arena_alloc(CliteArena* arena, usize size);
```

### Ownership documentation

Functions that transfer, borrow, or share ownership must document it explicitly:

```c
/**
 * @brief Returns an immutable view of the buffer contents.
 *
 * @note **Borrowed.** The returned CliteStr is valid only for the lifetime
 *       of @p buf. Do not store it beyond the next mutation of @p buf.
 */
CliteStr clite_strbuf_as_str(const CliteStrBuf* buf);
```

### Prose documentation

For significant new modules, update or create the relevant file in `docs/modules/`.
The document must include: purpose, API summary, usage example, and ownership notes.

---

## Changelog Requirements

Every PR that changes behavior, adds features, fixes bugs, or modifies the public
API **must** include a `CHANGELOG.md` entry under the `[Unreleased]` section.

CLite follows the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format:

```markdown
## [Unreleased]

### Added
- `clite_arena_checkpoint()` and `clite_arena_restore()` for savepoint-based
  rollback of arena allocations. (#42)

### Changed
- `clite_mem_alloc()` now always zero-initializes memory in debug builds. (#51)

### Fixed
- Fixed integer overflow in `clite_strbuf` capacity growth when buffer exceeds
  2 GiB on 32-bit platforms. (#67)

### Deprecated
- `clite_str_find_cstr()` is deprecated. Use `clite_str_find()` with
  `CLITE_STR()` instead. Will be removed in v1.3.0.

### Removed
- Removed `clite_mem_alloc_unsafe()` deprecated since v0.3.0.

### Security
- Fixed potential out-of-bounds read in `clite_utf8_iter_next()` on
  malformed input. (#73)
```

Changelog entries are written in **past tense** and reference the issue or PR
number where relevant.

---

## Deprecation Process

When deprecating a public API:

1. Mark the symbol with `CLITE_DEPRECATED("Use X instead.")` in the header.
2. Add a `### Deprecated` entry to `CHANGELOG.md`.
3. Document the replacement and the version when the symbol will be removed.
4. The symbol must be retained for the minimum window defined in the
   XA Studio Ecosystem Governance document (`XA_STUDIO_ECOSYSTEM.md`).
5. Removal requires a separate PR and a `### Removed` entry in `CHANGELOG.md`.

Never silently remove a symbol without going through the deprecation process,
regardless of how internal it seems. If it is in a public header, it is public.

---

## Review Expectations

### For contributors

- Respond to review comments within a reasonable time (ideally within a week).
- If you disagree with a requested change, explain your reasoning clearly and
  professionally. Maintainers will consider the argument on its merits.
- If a PR becomes stale (no activity for 30 days), it may be closed. You are
  welcome to reopen it when you are ready to continue.

### For maintainers

- Provide actionable, specific feedback. "This looks wrong" is not a review
  comment; "This will overflow on 32-bit platforms because `int` is 32 bits,
  use `isize` instead" is.
- Approve PRs that meet all requirements, even if you would have made different
  implementation choices. Perfection is the enemy of progress.
- Respond to PRs within 7 days of submission.

---

*© XA Studio (eXtended Attention Studio). All rights reserved under Apache License 2.0.*
