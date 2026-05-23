# CLite — Concept & Project Structure
### A Forgiving, Safe & Modern C Programming Library

> **Package:** `xastudio.clite`
> **Repository:** `xastudio360/clite`
> **Author:** XA Studio (eXtended Attention Studio)
> **License:** Apache License 2.0
> **Initial Version:** `1.0.0-1`
> **Standard:** C11 (minimum), C17 (recommended)

---

## 1. Philosophy

C is powerful, but unforgiving. A single unchecked pointer, an off-by-one error,
or a forgotten `free()` can corrupt memory, crash a process, or open a security
vulnerability. CLite does not try to replace C — it embraces it, and makes it
**safer, more expressive, and harder to misuse** without sacrificing performance
or portability.

**Three core principles:**

| Principle       | Meaning                                                                 |
|-----------------|-------------------------------------------------------------------------|
| **Forgiving**   | Common mistakes are caught at compile-time or produce defined behavior  |
| **Zero-cost**   | Every abstraction compiles down to what a careful C programmer would write by hand |
| **Composable**  | Modules are independent; use only what you need, link only what you use |

CLite is **not** a runtime framework. It is a header-first library with optional
thin translation-unit implementations. The developer remains in full control.

---

## 2. Target Audience

- Systems programmers who want safer C without switching to C++/Rust
- Embedded developers on constrained targets (MCU, RTOS, bare metal)
- C codebases that need gradual safety hardening
- Students learning C who want guardrails without training wheels

---

## 3. Platform & Compiler Support

### 3.1 Platforms (Tier 1 — fully tested in CI)

| Platform        | Architecture       |
|-----------------|--------------------|
| Linux           | x86-64, ARM64, ARMv7, RISC-V 64 |
| macOS           | x86-64, ARM64 (Apple Silicon)   |
| Windows         | x86-64 (MSVC, MinGW, Clang-cl)  |
| Bare metal      | ARMv7-M, ARMv8-M (Cortex-M)     |

### 3.2 Platforms (Tier 2 — best-effort)

| Platform        | Notes                              |
|-----------------|------------------------------------|
| FreeBSD / OpenBSD | Should work, not in primary CI   |
| WebAssembly (WASI) | via Clang/wasi-sdk              |
| Android NDK     | ARM64, x86-64                      |

### 3.3 Compiler Support

| Compiler        | Minimum Version | Notes                          |
|-----------------|-----------------|--------------------------------|
| GCC             | 8.0             | Full support                   |
| Clang           | 7.0             | Full support                   |
| MSVC            | 19.20 (VS 2019) | Full support                   |
| IAR             | 8.x             | Embedded Tier 1                |
| Keil ARM CC     | 6.x             | Embedded Tier 1                |

### 3.4 C Standard

- **Minimum required:** C11
- **Recommended:** C17
- All features that require C11+ are guarded with `#if __STDC_VERSION__ >= 201112L`
- No C++ dependency; fully compatible with `extern "C"` inclusion

---

## 4. Module Map

CLite is organized into **independent modules**. Each module lives in its own
header (and optional `.c` file). There are no forced interdependencies between
modules except where explicitly documented.

```
xastudio.clite
│
├── [FOUNDATION]
│   ├── clite_defs          — primitive typedefs, compiler macros, platform detection
│   ├── clite_assert        — safe assertions with custom handlers, no abort() surprises
│   └── clite_compiler      — portability macros (__likely, __noinline, __packed, etc.)
│
├── [MEMORY]
│   ├── clite_mem           — safe malloc/free wrappers, zero-on-alloc, OOM handler hook
│   ├── clite_arena         — arena / bump allocator (zero fragmentation, fast free-all)
│   ├── clite_pool          — fixed-size object pool allocator
│   └── clite_rc            — intrusive reference counting (no GC, explicit ownership)
│
├── [STRINGS]
│   ├── clite_str           — length-aware string type (not null-terminated by default)
│   ├── clite_strbuf        — growable string buffer (safe append, no sprintf overflows)
│   └── clite_utf8          — UTF-8 validation, iteration, and basic manipulation
│
├── [COLLECTIONS]
│   ├── clite_slice         — fat pointer (ptr + len) with bounds-checked access
│   ├── clite_vec           — type-safe growable array (macro-generated, no void*)
│   ├── clite_map           — open-addressing hash map (type-safe via macros)
│   └── clite_list          — intrusive doubly-linked list
│
├── [ERROR HANDLING]
│   ├── clite_result        — Result<T, E> pattern: success/error without setjmp
│   ├── clite_option        — Option<T> pattern: nullable values without raw NULL
│   └── clite_panic         — controlled panic with stack context, no undefined behavior
│
├── [I/O]
│   ├── clite_io            — safe read/write wrappers, EOF/error distinction
│   ├── clite_path          — portable path manipulation (no OS-specific APIs)
│   └── clite_fmt           — safe formatting (bounded snprintf, typed format helpers)
│
├── [CONCURRENCY]
│   ├── clite_atomic        — portable atomics (C11 _Atomic + MSVC fallback)
│   ├── clite_mutex         — thin cross-platform mutex/rwlock wrapper
│   └── clite_thread        — portable thread creation (pthreads + Win32)
│
├── [DIAGNOSTICS]
│   ├── clite_log           — structured logging with levels, sinks, and zero alloc
│   └── clite_trace         — lightweight execution tracing / breadcrumbs
│
└── [FFI LAYER]
    ├── clite_ffi           — C ABI stable exports for cross-language bindings
    └── clite_ffi_wasm      — WASM/WASI specific exports and memory helpers
```

**Module dependency rule:** `clite_defs` ← everything. All other modules are
peer-level; no module in `[MEMORY]` may depend on `[COLLECTIONS]` and vice versa,
unless explicitly layered (e.g. `clite_vec` may use `clite_mem` for allocation).

---

## 5. API Design Principles

### 5.1 No Silent Failures
Every function that can fail returns either a `CliteResult` or an error code.
Returning `-1` and setting `errno` is forbidden in CLite APIs.

```c
// ❌ Old C style
int  n = read(fd, buf, len);   // -1 means error, check errno

// ✅ CLite style
CliteResult(isize) r = clite_io_read(fd, buf, len);
if (clite_is_err(r)) { /* handle clite_err(r) */ }
```

### 5.2 Explicit Ownership
Every allocation has a documented owner. CLite uses a three-ownership model:
- **Owned** — caller must free
- **Borrowed** — caller must not free, lifetime tied to source
- **Shared** — managed by `clite_rc` reference count

### 5.3 Bounds-Checked by Default
All slice/array access goes through checked accessors in debug builds.
Release builds (`CLITE_RELEASE`) fall back to direct pointer arithmetic.

### 5.4 Type-Safe Collections via X-Macros / `_Generic`
No `void*` collections. Type safety is enforced at compile time using macro
instantiation patterns:

```c
CLITE_VEC_DEFINE(IntVec, int)        // generates a fully typed int vector
CLITE_MAP_DEFINE(StrIntMap, CliteStr, int)
```

### 5.5 Configurable, Not Opinionated
Behavior is configured via compile-time defines, not global state:

| Define                    | Effect                                      |
|---------------------------|---------------------------------------------|
| `CLITE_RELEASE`           | Disable bounds checks, assertions           |
| `CLITE_NO_STDLIB`         | Strip all `<stdlib.h>` dependencies (embedded) |
| `CLITE_CUSTOM_ALLOCATOR`  | Plug in a custom `malloc`/`free`            |
| `CLITE_LOG_LEVEL`         | Set minimum log level at compile time       |
| `CLITE_ASSERT_HANDLER`    | Override assertion failure callback         |

---

## 6. Project Repository Structure

```
xastudio360/clite/
│
├── include/
│   └── xastudio/
│       └── clite/
│           ├── clite.h                 # Single-include umbrella header
│           ├── defs.h
│           ├── assert.h
│           ├── compiler.h
│           ├── mem.h
│           ├── arena.h
│           ├── pool.h
│           ├── rc.h
│           ├── str.h
│           ├── strbuf.h
│           ├── utf8.h
│           ├── slice.h
│           ├── vec.h
│           ├── map.h
│           ├── list.h
│           ├── result.h
│           ├── option.h
│           ├── panic.h
│           ├── io.h
│           ├── path.h
│           ├── fmt.h
│           ├── atomic.h
│           ├── mutex.h
│           ├── thread.h
│           ├── log.h
│           ├── trace.h
│           ├── ffi.h
│           └── ffi_wasm.h
│
├── src/                                # Non-header implementations
│   ├── mem.c
│   ├── arena.c
│   ├── pool.c
│   ├── str.c
│   ├── strbuf.c
│   ├── utf8.c
│   ├── vec.c
│   ├── map.c
│   ├── io.c
│   ├── path.c
│   ├── fmt.c
│   ├── mutex.c
│   ├── thread.c
│   ├── log.c
│   ├── trace.c
│   └── ffi.c
│
├── tests/
│   ├── unit/
│   │   ├── test_mem.c
│   │   ├── test_arena.c
│   │   ├── test_str.c
│   │   ├── test_vec.c
│   │   ├── test_map.c
│   │   ├── test_result.c
│   │   └── ...
│   ├── integration/
│   │   ├── test_full_pipeline.c
│   │   └── test_embedded_sim.c
│   └── fuzz/
│       ├── fuzz_str.c
│       ├── fuzz_utf8.c
│       └── fuzz_map.c
│
├── samples/
│   ├── 01_hello_result.c
│   ├── 02_arena_allocator.c
│   ├── 03_safe_strings.c
│   ├── 04_typed_vec.c
│   ├── 05_logging.c
│   └── 06_embedded_no_stdlib.c
│
├── docs/
│   ├── getting-started.md
│   ├── modules/
│   │   ├── memory.md
│   │   ├── strings.md
│   │   ├── collections.md
│   │   ├── error-handling.md
│   │   ├── concurrency.md
│   │   └── ffi.md
│   ├── design-decisions.md
│   └── porting-guide.md             # How to port to a new platform
│
├── cmake/
│   ├── CliteConfig.cmake.in
│   ├── CliteVersion.cmake
│   └── modules/
│       └── FindClite.cmake
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                   # Build + test on all Tier 1 platforms
│   │   ├── fuzz.yml                 # Weekly fuzzing run
│   │   └── security.yml             # Quarterly security audit
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       └── feature_request.md
│
├── CMakeLists.txt                   # Primary build system
├── meson.build                      # Alternative: Meson support
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CONTRIBUTORS.md
├── LICENSE                          # Apache 2.0
├── README.md
└── ROADMAP.md
```

---

## 7. Build System

**Primary:** CMake 3.16+
**Secondary:** Meson (for projects already using it)
**Embedded:** Raw `Makefile` template provided in `docs/porting-guide.md`

CMake targets:

```cmake
find_package(Clite REQUIRED)

# Link only the modules you need
target_link_libraries(my_app PRIVATE
    xastudio::clite::mem
    xastudio::clite::str
    xastudio::clite::log
)

# Or link the full library
target_link_libraries(my_app PRIVATE xastudio::clite)
```

---

## 8. Testing Strategy

| Layer             | Tool                      | Requirement                        |
|-------------------|---------------------------|------------------------------------|
| Unit tests        | Unity (lightweight C)     | ≥ 80% line coverage per module     |
| Integration tests | Custom harness            | All public API paths covered       |
| Fuzz testing      | libFuzzer / AFL++         | `str`, `utf8`, `map`, `fmt`, `io`  |
| Static analysis   | `clang-tidy` + `cppcheck` | Zero warnings on CI                |
| Sanitizers        | ASan, UBSan, TSan         | All tests pass under all sanitizers|
| Memory check      | Valgrind (Linux)          | Zero leaks in all samples          |

---

## 9. Roadmap

### v1.0.0 — Foundation *(Target: Month 0–4)*
- [ ] `clite_defs`, `clite_compiler`, `clite_assert`
- [ ] `clite_mem`, `clite_arena`, `clite_pool`
- [ ] `clite_str`, `clite_strbuf`
- [ ] `clite_slice`, `clite_vec`
- [ ] `clite_result`, `clite_option`, `clite_panic`
- [ ] `clite_log` (basic sinks: stderr, file)
- [ ] CMake + Meson build system
- [ ] CI: Linux x86-64, macOS ARM64, Windows x86-64
- [ ] Full unit tests + sanitizer pass
- [ ] Getting Started documentation

### v1.1.0 — Collections & I/O *(Target: Month 4–7)*
- [ ] `clite_map`, `clite_list`
- [ ] `clite_io`, `clite_fmt`
- [ ] `clite_utf8`
- [ ] Fuzz testing infrastructure
- [ ] Embedded (no-stdlib) build mode
- [ ] CI: ARM64 Linux, ARMv7 bare metal sim

### v1.2.0 — Concurrency & Tracing *(Target: Month 7–10)*
- [ ] `clite_atomic`, `clite_mutex`, `clite_thread`
- [ ] `clite_trace`
- [ ] `clite_path`
- [ ] TSan integration in CI
- [ ] Windows IOCP async I/O exploration

### v1.3.0 — Security Hardening *(Target: Month 10–13)*
- [ ] First quarterly security audit
- [ ] Hardened `clite_fmt` (format string attack surface reduction)
- [ ] Canary / stack protection helpers
- [ ] `CLITE_RELEASE` performance benchmarks vs raw C

### v2.0.0 — FFI Layer *(Target: Month 13–18)*
- [ ] `clite_ffi` — stable C ABI exports
- [ ] `clite_ffi_wasm` — WASM/WASI target
- [ ] Python bindings (`xastudio-clite-py`)
- [ ] Rust bindings (`xastudio-clite-rs`)
- [ ] TypeScript/WASM bindings (`xastudio-clite-ts`)
- [ ] ABI stability guarantee from v2.0.0 onwards

### v2.1.0+ — Ecosystem Integration
- [ ] Integration with other XA Studio ecosystem packages
- [ ] `clite_rc` (reference counting)
- [ ] Advanced arena strategies (virtual memory, huge pages)
- [ ] WASI async I/O
- [ ] Package manager support: vcpkg, Conan, pkg-config

---

## 10. Security Policy

- Security vulnerabilities are reported privately to `xa.studio.360@gmail.com` (or GitHub
  private advisory).
- Severity classification follows §4.3 of the XA Studio Open Source Ecosystem document.
- Quarterly security releases on the schedule defined in §4.4.
- All cryptographic functionality is explicitly **out of scope** for CLite;
  developers must use a dedicated cryptographic library.

---

## 11. What CLite Is NOT

To keep the library focused and auditable, the following are explicitly out of scope:

| Out of Scope              | Rationale                                           |
|---------------------------|-----------------------------------------------------|
| Cryptography              | Requires specialist review; use libsodium / mbedTLS |
| Networking                | Scope creep; will be a separate XA Studio package   |
| File system watcher       | Too OS-specific for v1.x                           |
| Regular expressions       | Separate concern; consider re2c or PCRE2            |
| GUI / rendering           | Entirely out of domain                              |
| Garbage collection        | Contradicts the zero-cost principle                 |

---

*© XA Studio (eXtended Attention Studio). All rights reserved under Apache License 2.0.*
