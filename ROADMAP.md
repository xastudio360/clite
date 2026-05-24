# CLite — Roadmap: MVP → 1.0.0
### From First Commit to Production-Ready Release

> **Package:** `xastudio.clite`
> **Author:** XA Studio (eXtended Attention Studio)
> **License:** Apache License 2.0
> **Document Version:** 1.0.0
> **Roadmap Scope:** `0.1.0-1` → `1.0.0-1`

---

## Overview

```
Phase 0   Phase 1   Phase 2   Phase 3   Phase 4   Phase 5   Phase 6
  │         │         │         │         │         │         │
  ▼         ▼         ▼         ▼         ▼         ▼         ▼
[Scaffold] [Core]  [Memory] [Strings] [Collect] [Error]  [1.0.0]
0.1.0      0.2.0   0.3.0    0.4.0     0.5.0     0.6.0    1.0.0
Week 0     Week 2  Week 5   Week 9    Week 13   Week 17   Week 22
```

**Total estimated duration:** ~22 weeks (≈ 5.5 months)
**Development model:** Iterative. Each phase produces a tagged, tested, usable version.
Every phase ends with a passing CI, full documentation update, and a CHANGELOG entry.

---

## Versioning in This Roadmap

Following XA Studio versioning (`BIG.Base.little[.bugfix]-build`):

| Version  | Phase       | Nature                              |
|----------|-------------|-------------------------------------|
| `0.1.0`  | Scaffold    | Pre-release. Infrastructure only.   |
| `0.2.0`  | Core        | Pre-release. Foundation modules.    |
| `0.3.0`  | Memory      | Pre-release. Memory subsystem.      |
| `0.4.0`  | Strings     | Pre-release. String subsystem.      |
| `0.5.0`  | Collections | Pre-release. Collections subsystem. |
| `0.6.0`  | Error & Log | Pre-release. Error handling & log.  |
| `1.0.0`  | Release     | Stable. Public API frozen.          |

All `0.x.0` releases carry the label **pre-release** and make **no ABI/API stability
guarantees**. Breaking changes between pre-release phases are allowed and expected.

From `1.0.0` onward, the public API is **frozen** within the `1.x` line.

---

## Phase 0 — Scaffold `0.1.0`
**Duration:** Week 0 → Week 2
**Goal:** Empty skeleton that compiles, passes CI, and establishes every convention
used for the remainder of the project. Zero library functionality is expected.

### Infrastructure
- [x] Repository created at `github.com/xastudio360/clite`
- [x] `LICENSE` — Apache 2.0
- [x] `README.md` — project description, build instructions, badge placeholders
- [ ] `CHANGELOG.md` — initialized with `[Unreleased]` section
- [ ] `CONTRIBUTING.md` — branch strategy, commit convention, PR checklist
- [ ] `SECURITY.md` — vulnerability reporting process
- [x] `ROADMAP.md` — this document
- [ ] `.github/ISSUE_TEMPLATE/bug_report.md`
- [ ] `.github/ISSUE_TEMPLATE/feature_request.md`
- [ ] `.gitignore`, `.editorconfig`, `.clang-format`

### Build System
- [ ] `CMakeLists.txt` — root, sets C11 standard, defines `xastudio::clite` target
- [ ] `cmake/CliteVersion.cmake` — version variables wired to CMake project()
- [ ] `cmake/CliteConfig.cmake.in` — for `find_package(Clite)` consumer support
- [ ] `meson.build` — alternative build system, mirrors CMake structure
- [ ] Per-module CMake targets established (even if headers are empty)
- [ ] Build tested on: Linux x86-64 (GCC + Clang), macOS ARM64 (Clang), Windows x86-64 (MSVC)

### CI / CD
- [ ] `.github/workflows/ci.yml`
  - Matrix: {Linux GCC 8/12/14, Linux Clang 7/16/18, macOS Clang, Windows MSVC 2019/2022}
  - Steps: configure → build → test → install → consumer build test
- [ ] `.github/workflows/fuzz.yml` — placeholder, runs nothing yet, will be wired in Phase 4
- [ ] `.github/workflows/security.yml` — placeholder, quarterly trigger
- [ ] CI badge added to README

### Directory Skeleton
- [ ] `include/xastudio/clite/` — all module headers created as empty stubs
- [ ] `src/` — all `.c` files created as empty stubs
- [ ] `tests/unit/` — test runner wired (Unity framework vendored or fetched via CMake)
- [ ] `tests/integration/` — placeholder
- [ ] `tests/fuzz/` — placeholder
- [ ] `samples/` — placeholder
- [ ] `docs/` — placeholder structure

### Coding Standards
- [ ] `.clang-format` — project formatting rules locked in
- [ ] `.clang-tidy` — baseline rule set (no warnings policy enforced in CI)
- [ ] `cppcheck` — integrated into CI, baseline suppressions documented
- [ ] Standard file header template documented in `CONTRIBUTING.md`

### Definition of Done — Phase 0
> CI is green on all Tier 1 platforms. Repository is publicly visible.
> A developer can `git clone`, run `cmake`, `make`, and `ctest` and get zero failures
> (zero tests = zero failures at this stage). Every future commit will keep CI green.

---

## Phase 1 — Core Foundation `0.2.0`
**Duration:** Week 2 → Week 5
**Goal:** The non-optional foundation that every other module depends on.
After this phase, the conventions of the entire library are settled.

### Module: `clite_defs` (`include/xastudio/clite/defs.h`)
- [ ] Exact-width integer types: `i8`, `i16`, `i32`, `i64`, `u8`, `u16`, `u32`, `u64`
- [ ] `isize` / `usize` — pointer-sized signed/unsigned integers
- [ ] `f32` / `f64` — float aliases with static size assertions
- [ ] `byte` — `uint8_t` alias for raw memory operations
- [ ] `bool` — C11 `_Bool` alias with `true`/`false` (no `<stdbool.h>` dependency)
- [ ] `NULL` guard — defined safely if not already defined
- [ ] `CLITE_VERSION_MAJOR`, `CLITE_VERSION_MINOR`, `CLITE_VERSION_PATCH` — numeric macros
- [ ] `CLITE_VERSION_STRING` — `"0.2.0"`
- [ ] Platform detection macros:
  - `CLITE_OS_LINUX`, `CLITE_OS_MACOS`, `CLITE_OS_WINDOWS`, `CLITE_OS_WASM`
  - `CLITE_ARCH_X64`, `CLITE_ARCH_ARM64`, `CLITE_ARCH_ARM32`, `CLITE_ARCH_RISCV64`
- [ ] Endianness detection: `CLITE_BIG_ENDIAN`, `CLITE_LITTLE_ENDIAN`
- [ ] `CLITE_RELEASE` / `CLITE_DEBUG` mode detection (defaults to debug if not set)
- [ ] `CLITE_NO_STDLIB` — compile-time opt-out of all standard library dependencies

### Module: `clite_compiler` (`include/xastudio/clite/compiler.h`)
- [ ] `CLITE_LIKELY(x)` / `CLITE_UNLIKELY(x)` — branch prediction hints
- [ ] `CLITE_INLINE` / `CLITE_NOINLINE` — portable force-inline / noinline
- [ ] `CLITE_NORETURN` — `[[noreturn]]` / `__attribute__((noreturn))` / `__declspec(noreturn)`
- [ ] `CLITE_UNUSED(x)` — suppress unused variable warnings
- [ ] `CLITE_PACKED` — struct packing attribute
- [ ] `CLITE_ALIGNED(n)` — alignment attribute
- [ ] `CLITE_DEPRECATED(msg)` — deprecation attribute with message
- [ ] `CLITE_STATIC_ASSERT(cond, msg)` — C11 `_Static_assert` with fallback
- [ ] `CLITE_ARRAY_LEN(arr)` — compile-time array length (safe, no pointer decay)
- [ ] `CLITE_STRINGIFY(x)` / `CLITE_CONCAT(a, b)` — preprocessor utilities
- [ ] `CLITE_PRAGMA(x)` — portable `_Pragma`
- [ ] Compiler identification: `CLITE_COMPILER_GCC`, `CLITE_COMPILER_CLANG`, `CLITE_COMPILER_MSVC`

### Module: `clite_assert` (`include/xastudio/clite/assert.h`)
- [ ] `CLITE_ASSERT(cond)` — in debug: calls assert handler; in release: `((void)0)`
- [ ] `CLITE_ASSERT_MSG(cond, msg)` — assertion with human-readable message
- [ ] `CLITE_ASSERT_NOT_NULL(ptr)` — specialized null pointer assertion
- [ ] `CLITE_ASSERT_IN_RANGE(val, lo, hi)` — bounds assertion
- [ ] `CliteAssertHandler` — function pointer type: `void (*)(const char* file, int line, const char* msg)`
- [ ] `clite_assert_set_handler(CliteAssertHandler)` — register custom handler
- [ ] `clite_assert_get_handler(void)` — retrieve current handler
- [ ] Default handler: prints to `stderr`, calls `abort()` (overridable)
- [ ] `CLITE_NO_STDLIB` path: default handler calls a user-defined `clite_platform_abort()`

### `clite.h` — Umbrella Header
- [ ] Single `#include <xastudio/clite/clite.h>` pulls in all stable modules
- [ ] Module-level opt-out: `#define CLITE_NO_CONCURRENCY` before include, etc.

### Tests — Phase 1
- [ ] `tests/unit/test_defs.c` — type sizes, platform macros, version macros
- [ ] `tests/unit/test_compiler.c` — each macro compiles and behaves correctly
- [ ] `tests/unit/test_assert.c` — handler registration, custom handler invocation,
  assert-in-release is no-op
- [ ] All tests pass under ASan + UBSan on Linux

### Documentation — Phase 1
- [ ] `docs/getting-started.md` — build from source, link with CMake, first program
- [ ] `docs/modules/foundation.md` — full API reference for `defs`, `compiler`, `assert`
- [ ] All public symbols have doxygen-compatible doc comments

### Definition of Done — Phase 1
> All foundation headers are feature-complete and documented. A developer can write
> a C11 program that includes `clite.h`, uses `CLITE_ASSERT`, and compiles cleanly
> with `-Wall -Wextra -Werror` on all Tier 1 platforms.

---

## Phase 2 — Memory Subsystem `0.3.0`
**Duration:** Week 5 → Week 9
**Goal:** Safe, composable memory management. This is the highest-risk module in terms
of correctness — it gets the most test coverage and sanitizer attention.

### Module: `clite_mem` (`include/xastudio/clite/mem.h` + `src/mem.c`)
- [ ] `CliteAllocator` — vtable struct: `{alloc, realloc, free, userdata}`
- [ ] `clite_mem_alloc(allocator, size)` → `void*` (never returns NULL; calls OOM handler)
- [ ] `clite_mem_alloc_zeroed(allocator, size)` → `void*` — zero-initialized allocation
- [ ] `clite_mem_realloc(allocator, ptr, old_size, new_size)` → `void*`
- [ ] `clite_mem_free(allocator, ptr, size)` — size-aware free (helps allocators track usage)
- [ ] `clite_mem_copy(dst, src, size)` — safe memcpy (no overlap assumed, asserts in debug)
- [ ] `clite_mem_move(dst, src, size)` — safe memmove
- [ ] `clite_mem_set(dst, byte, size)` — safe memset
- [ ] `clite_mem_zero(dst, size)` — explicit zero (not optimized away by compiler)
- [ ] `clite_mem_equal(a, b, size)` → `bool` — constant-time comparison
- [ ] `CLITE_MEM_DEFAULT` — global default allocator (wraps system malloc/free)
- [ ] `CliteOomHandler` — `void (*)(usize requested_size)`
- [ ] `clite_mem_set_oom_handler(CliteOomHandler)` — register OOM callback
- [ ] `CLITE_NO_STDLIB` path: `CLITE_MEM_DEFAULT` must be replaced by user; compile error if not

### Module: `clite_arena` (`include/xastudio/clite/arena.h` + `src/arena.c`)
- [ ] `CliteArena` — opaque struct (or transparent with documented layout)
- [ ] `clite_arena_init(arena, backing_allocator, capacity)` → `bool`
- [ ] `clite_arena_init_static(arena, buffer, size)` — no-alloc init from static buffer
- [ ] `clite_arena_alloc(arena, size)` → `void*`
- [ ] `clite_arena_alloc_aligned(arena, size, alignment)` → `void*`
- [ ] `clite_arena_reset(arena)` — reset cursor to zero, keep backing memory
- [ ] `clite_arena_destroy(arena)` — free backing memory
- [ ] `clite_arena_used(arena)` → `usize` — bytes currently allocated
- [ ] `clite_arena_remaining(arena)` → `usize`
- [ ] `CliteArenaCheckpoint` — savepoint type
- [ ] `clite_arena_checkpoint(arena)` → `CliteArenaCheckpoint`
- [ ] `clite_arena_restore(arena, checkpoint)` — roll back to checkpoint
- [ ] `CliteAllocator clite_arena_allocator(arena)` — adapt arena as a `CliteAllocator`

### Module: `clite_pool` (`include/xastudio/clite/pool.h` + `src/pool.c`)
- [ ] `ClitePool` — fixed-size object pool
- [ ] `clite_pool_init(pool, backing_allocator, object_size, capacity)` → `bool`
- [ ] `clite_pool_init_static(pool, buffer, buffer_size, object_size)`
- [ ] `clite_pool_acquire(pool)` → `void*` (NULL if exhausted, never OOM-panics)
- [ ] `clite_pool_release(pool, ptr)` — return object to pool
- [ ] `clite_pool_destroy(pool)`
- [ ] `clite_pool_available(pool)` → `usize`
- [ ] `clite_pool_capacity(pool)` → `usize`
- [ ] `CliteAllocator clite_pool_allocator(pool)` — adapt pool as a `CliteAllocator`
- [ ] Double-free detection in debug builds (poison freed slots)

### Tests — Phase 2
- [ ] `tests/unit/test_mem.c` — alloc/free, zero, copy, move, OOM handler
- [ ] `tests/unit/test_arena.c` — init variants, alloc, reset, checkpoint/restore, overflow
- [ ] `tests/unit/test_pool.c` — acquire/release, exhaustion, double-free detection
- [ ] All tests pass under ASan + UBSan + Valgrind
- [ ] Benchmark: arena vs pool vs malloc for 1M small allocations (results in `docs/`)

### Documentation — Phase 2
- [ ] `docs/modules/memory.md` — full API reference + ownership model explanation
- [ ] `samples/02_arena_allocator.c` — arena usage end-to-end example
- [ ] `docs/design-decisions.md` — why `CliteAllocator` vtable, why size-aware free

### Definition of Done — Phase 2
> All memory modules pass unit tests with zero errors under ASan, UBSan, and Valgrind.
> A developer can use `CliteArena` as a drop-in allocator for any CLite module.

---

## Phase 3 — String Subsystem `0.4.0`
**Duration:** Week 9 → Week 13
**Goal:** Safe, non-null-terminated strings that interop cleanly with C string literals
and standard APIs, plus growable buffers that eliminate `sprintf` overflow.

### Module: `clite_str` (`include/xastudio/clite/str.h` + `src/str.c`)
- [ ] `CliteStr` — `{ const byte* ptr; usize len; }` — immutable string view
- [ ] `CLITE_STR(literal)` — macro: `{ (const byte*)(literal), sizeof(literal) - 1 }`
- [ ] `clite_str_from_cstr(cstr)` → `CliteStr` — wrap null-terminated string (strlen)
- [ ] `clite_str_to_cstr(str, buf, buf_len)` → `bool` — safe copy to null-terminated buffer
- [ ] `clite_str_equal(a, b)` → `bool`
- [ ] `clite_str_equal_ci(a, b)` → `bool` — case-insensitive
- [ ] `clite_str_starts_with(str, prefix)` → `bool`
- [ ] `clite_str_ends_with(str, suffix)` → `bool`
- [ ] `clite_str_contains(str, needle)` → `bool`
- [ ] `clite_str_find(str, needle)` → `isize` — index or -1
- [ ] `clite_str_slice(str, start, end)` → `CliteStr` — bounds-checked sub-view
- [ ] `clite_str_trim(str)` → `CliteStr` — trim whitespace (view, no allocation)
- [ ] `clite_str_trim_start(str)` → `CliteStr`
- [ ] `clite_str_trim_end(str)` → `CliteStr`
- [ ] `clite_str_split_once(str, delim, left, right)` → `bool`
- [ ] `clite_str_is_empty(str)` → `bool`
- [ ] `clite_str_hash(str)` → `u64` — deterministic (wyhash or similar)

### Module: `clite_strbuf` (`include/xastudio/clite/strbuf.h` + `src/strbuf.c`)
- [ ] `CliteStrBuf` — `{ byte* ptr; usize len; usize cap; CliteAllocator alloc; }`
- [ ] `clite_strbuf_init(buf, allocator)` — empty buffer
- [ ] `clite_strbuf_init_cap(buf, allocator, initial_capacity)` — pre-allocated
- [ ] `clite_strbuf_destroy(buf)`
- [ ] `clite_strbuf_append_str(buf, str)` → `bool`
- [ ] `clite_strbuf_append_cstr(buf, cstr)` → `bool`
- [ ] `clite_strbuf_append_char(buf, c)` → `bool`
- [ ] `clite_strbuf_append_byte(buf, b)` → `bool`
- [ ] `clite_strbuf_append_fmt(buf, fmt, ...)` → `bool` — safe bounded formatting
- [ ] `clite_strbuf_prepend_str(buf, str)` → `bool`
- [ ] `clite_strbuf_insert_str(buf, index, str)` → `bool`
- [ ] `clite_strbuf_remove(buf, start, len)` → `bool`
- [ ] `clite_strbuf_clear(buf)` — reset length to 0, keep allocation
- [ ] `clite_strbuf_as_str(buf)` → `CliteStr` — borrow as immutable view
- [ ] `clite_strbuf_to_cstr(buf)` → `const char*` — null-terminate in place, borrow pointer
- [ ] `clite_strbuf_reserve(buf, additional)` → `bool` — explicit growth hint

### Module: `clite_utf8` (`include/xastudio/clite/utf8.h` + `src/utf8.c`)
- [ ] `CliteUtf8Error` — enum: `{VALID, INVALID_BYTE, TRUNCATED, OVERLONG, SURROGATE}`
- [ ] `clite_utf8_validate(str)` → `CliteUtf8Error` — validate entire string
- [ ] `clite_utf8_validate_lossy(str)` → `bool` — true if any invalid sequences
- [ ] `CliteCodepoint` — `u32` typedef
- [ ] `CliteUtf8Iter` — iterator struct
- [ ] `clite_utf8_iter_init(iter, str)` — initialize iterator
- [ ] `clite_utf8_iter_next(iter, codepoint)` → `bool` — advance, fill codepoint
- [ ] `clite_utf8_encode(codepoint, buf, buf_len)` → `u8` — bytes written (0 on error)
- [ ] `clite_utf8_codepoint_len(first_byte)` → `u8` — sequence length from first byte
- [ ] `clite_utf8_char_count(str)` → `usize` — number of codepoints (not bytes)
- [ ] `clite_utf8_byte_index(str, char_index)` → `isize` — char → byte offset
- [ ] Fuzz target: `tests/fuzz/fuzz_utf8.c`

### Tests — Phase 3
- [ ] `tests/unit/test_str.c` — all CliteStr operations, edge cases (empty, single byte)
- [ ] `tests/unit/test_strbuf.c` — growth, append variants, fmt, remove, reserve
- [ ] `tests/unit/test_utf8.c` — valid sequences, all error categories, iterator, encode
- [ ] Fuzz: `fuzz_utf8.c` wired to CI (short runs), long runs in `fuzz.yml`
- [ ] Tests pass under ASan + UBSan

### Documentation — Phase 3
- [ ] `docs/modules/strings.md` — CliteStr vs CliteStrBuf, UTF-8 guide
- [ ] `samples/03_safe_strings.c` — build a JSON key from parts without a single sprintf

### Definition of Done — Phase 3
> `CliteStr` and `CliteStrBuf` cover all common string operations. UTF-8 validation
> passes the full Unicode test suite (valid + invalid sequences). Zero sanitizer errors.

---

## Phase 4 — Collections `0.5.0`
**Duration:** Week 13 → Week 17
**Goal:** Type-safe, allocator-aware collections. No `void*` in public APIs.

### Module: `clite_slice` (`include/xastudio/clite/slice.h`)
- [ ] `CliteSlice(T)` — macro-defined fat pointer: `{ T* ptr; usize len; }`
- [ ] `CLITE_SLICE_FROM_ARRAY(arr)` — derive slice from C array (safe, no decay)
- [ ] `clite_slice_get(slice, index)` → `T*` — bounds-checked in debug
- [ ] `clite_slice_get_unchecked(slice, index)` → `T*` — explicit unsafe access
- [ ] `clite_slice_sub(slice, start, end)` → `CliteSlice(T)`
- [ ] `clite_slice_is_empty(slice)` → `bool`
- [ ] `clite_slice_first(slice)` → `T*` (NULL if empty)
- [ ] `clite_slice_last(slice)` → `T*` (NULL if empty)
- [ ] `clite_slice_iter_*` — for-each iteration pattern

### Module: `clite_vec` (`include/xastudio/clite/vec.h` + `src/vec.c`)
- [ ] `CLITE_VEC_DEFINE(Name, T)` — instantiates a fully typed vector type
- [ ] Generated API per instantiation:
  - `Name_init(vec, allocator)`
  - `Name_init_cap(vec, allocator, capacity)`
  - `Name_destroy(vec)`
  - `Name_push(vec, value)` → `bool`
  - `Name_pop(vec)` → `bool` (writes to out param)
  - `Name_get(vec, index)` → `T*`
  - `Name_set(vec, index, value)` → `bool`
  - `Name_insert(vec, index, value)` → `bool`
  - `Name_remove(vec, index)` → `bool`
  - `Name_clear(vec)`
  - `Name_reserve(vec, additional)` → `bool`
  - `Name_len(vec)` → `usize`
  - `Name_cap(vec)` → `usize`
  - `Name_is_empty(vec)` → `bool`
  - `Name_as_slice(vec)` → `CliteSlice(T)`
- [ ] Growth strategy: 2x up to 1 MB, 1.5x above (configurable per-instance)
- [ ] Fuzz target: `tests/fuzz/fuzz_vec.c`

### Module: `clite_map` (`include/xastudio/clite/map.h` + `src/map.c`)
- [ ] `CLITE_MAP_DEFINE(Name, K, V)` — instantiates a typed open-addressing hash map
- [ ] Generated API per instantiation:
  - `Name_init(map, allocator)`
  - `Name_destroy(map)`
  - `Name_insert(map, key, value)` → `bool`
  - `Name_get(map, key)` → `V*` (NULL if not found)
  - `Name_remove(map, key)` → `bool`
  - `Name_contains(map, key)` → `bool`
  - `Name_len(map)` → `usize`
  - `Name_clear(map)`
  - `Name_iter_init(iter, map)`
  - `Name_iter_next(iter, key_out, val_out)` → `bool`
- [ ] Default hash function: wyhash (embedded, no external dep)
- [ ] Custom hash/compare: `CLITE_MAP_DEFINE_EX(Name, K, V, hash_fn, cmp_fn)`
- [ ] Load factor: 0.75 (configurable via compile-time define)
- [ ] Fuzz target: `tests/fuzz/fuzz_map.c`

### Module: `clite_list` (`include/xastudio/clite/list.h`)
- [ ] Intrusive doubly-linked list (node embedded in user struct — zero extra allocation)
- [ ] `CliteListNode` — `{ CliteListNode* prev; CliteListNode* next; }`
- [ ] `CliteList` — `{ CliteListNode head; usize len; }`
- [ ] `clite_list_init(list)`
- [ ] `clite_list_push_front(list, node)`
- [ ] `clite_list_push_back(list, node)`
- [ ] `clite_list_pop_front(list)` → `CliteListNode*`
- [ ] `clite_list_pop_back(list)` → `CliteListNode*`
- [ ] `clite_list_remove(list, node)`
- [ ] `clite_list_insert_before(list, anchor, node)`
- [ ] `clite_list_insert_after(list, anchor, node)`
- [ ] `clite_list_is_empty(list)` → `bool`
- [ ] `clite_list_len(list)` → `usize`
- [ ] `CLITE_LIST_ENTRY(ptr, type, member)` — recover containing struct from node pointer
- [ ] `CLITE_LIST_FOREACH(list, node_var)` — safe iteration macro

### Tests — Phase 4
- [ ] `tests/unit/test_slice.c`
- [ ] `tests/unit/test_vec.c` — push/pop, bounds, growth, insert/remove, reserve
- [ ] `tests/unit/test_map.c` — insert/get/remove, collision handling, iteration, resize
- [ ] `tests/unit/test_list.c` — all operations, ENTRY macro, FOREACH
- [ ] Fuzz: `fuzz_vec.c`, `fuzz_map.c` wired to `fuzz.yml`
- [ ] Tests pass under ASan + UBSan + TSan

### Documentation — Phase 4
- [ ] `docs/modules/collections.md`
- [ ] `samples/04_typed_vec.c` — typed vector end-to-end

### Definition of Done — Phase 4
> All collection types are type-safe, allocator-aware, and fuzz-tested. `CLITE_VEC_DEFINE`
> and `CLITE_MAP_DEFINE` generate clean code with zero clang-tidy warnings.

---

## Phase 5 — Error Handling & Logging `0.6.0`
**Duration:** Week 17 → Week 20
**Goal:** Propagate errors explicitly. Log structured events without allocation.

### Module: `clite_result` (`include/xastudio/clite/result.h`)
- [ ] `CLITE_RESULT_DEFINE(Name, T, E)` — instantiates a typed result type
- [ ] Generated API:
  - `Name_ok(value)` → `Name` — construct success
  - `Name_err(error)` → `Name` — construct error
  - `Name_is_ok(result)` → `bool`
  - `Name_is_err(result)` → `bool`
  - `Name_unwrap(result)` → `T` — panics on error (debug only)
  - `Name_unwrap_or(result, default_val)` → `T`
  - `Name_unwrap_err(result)` → `E`
- [ ] `CLITE_TRY(result, label)` — propagate error to goto label (C idiom)
- [ ] `CliteStatus` — general-purpose error enum for use across modules:
  `{CLITE_OK, CLITE_ERR_NULL, CLITE_ERR_OOM, CLITE_ERR_BOUNDS,
   CLITE_ERR_IO, CLITE_ERR_INVALID, CLITE_ERR_NOT_FOUND, CLITE_ERR_OVERFLOW, ...}`
- [ ] `clite_status_str(status)` → `CliteStr` — human-readable description

### Module: `clite_option` (`include/xastudio/clite/option.h`)
- [ ] `CLITE_OPTION_DEFINE(Name, T)` — typed optional value
- [ ] Generated API:
  - `Name_some(value)` → `Name`
  - `Name_none()` → `Name`
  - `Name_is_some(opt)` → `bool`
  - `Name_is_none(opt)` → `bool`
  - `Name_unwrap(opt)` → `T` — panics if none
  - `Name_unwrap_or(opt, default_val)` → `T`
  - `Name_ptr(opt)` → `T*` — NULL if none

### Module: `clite_panic` (`include/xastudio/clite/panic.h`)
- [ ] `CLITE_PANIC(msg)` — controlled panic: log context, call panic handler
- [ ] `CLITE_PANIC_FMT(fmt, ...)` — formatted panic message
- [ ] `ClitePanicInfo` — `{ const char* file; int line; const char* func; CliteStr msg; }`
- [ ] `ClitePanicHandler` — `void (*)(const ClitePanicInfo*)`
- [ ] `clite_panic_set_handler(ClitePanicHandler)`
- [ ] Default handler: print to stderr, `abort()`
- [ ] `CLITE_NO_STDLIB` path: user must define `clite_platform_panic()`

### Module: `clite_log` (`include/xastudio/clite/log.h` + `src/log.c`)
- [ ] Log levels: `CLITE_LOG_TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`
- [ ] `CLITE_LOG_LEVEL` — compile-time minimum level (strips lower levels at compile time)
- [ ] `CliteLogRecord` — `{ level, timestamp, file, line, func, message }`
- [ ] `CliteLogSink` — `void (*)(const CliteLogRecord*)` function pointer
- [ ] `clite_log_set_sink(sink)` — register output sink
- [ ] `clite_log_set_level(level)` — runtime minimum level
- [ ] Built-in sinks:
  - `clite_log_sink_stderr` — plain text to stderr
  - `clite_log_sink_json` — newline-delimited JSON (no malloc, fixed stack buffer)
- [ ] Log macros: `CLITE_LOG_INFO(msg)`, `CLITE_LOG_WARN(fmt, ...)`, etc.
- [ ] Zero allocation in hot path (format into stack buffer, max 512 bytes)
- [ ] Thread-safe sink dispatch (atomic pointer swap, no mutex in log path)
- [ ] `samples/05_logging.c` — structured logging with custom sink

### Tests — Phase 5
- [ ] `tests/unit/test_result.c` — ok/err construction, CLITE_TRY, unwrap variants
- [ ] `tests/unit/test_option.c`
- [ ] `tests/unit/test_panic.c` — custom handler, PANIC_FMT
- [ ] `tests/unit/test_log.c` — level filtering, custom sink, JSON format validation
- [ ] Tests pass under ASan + UBSan

### Documentation — Phase 5
- [ ] `docs/modules/error-handling.md` — Result vs Option vs panic, CLITE_TRY pattern
- [ ] `samples/01_hello_result.c` — file-open → read → parse with full error propagation

### Definition of Done — Phase 5
> A complete program can be written using only CLite that opens a file, reads and
> parses it, and propagates every error explicitly — with zero raw NULL checks and
> zero unchecked return values.

---

## Phase 6 — Release Hardening `1.0.0`
**Duration:** Week 20 → Week 22
**Goal:** Freeze the public API. Harden quality. Ship.

### API Audit
- [ ] Full review of every public symbol name for consistency
- [ ] Every deprecated symbol (if any) marked with `CLITE_DEPRECATED`
- [ ] No `TODO` or `FIXME` comments in public headers
- [ ] All `0.x` API breakages resolved; no known breaking changes planned
- [ ] `CLITE_VERSION_STRING` updated to `"1.0.0"` in `clite_defs.h`

### Documentation Completion
- [ ] `README.md` — polished, with examples, badges, installation instructions
- [ ] `docs/getting-started.md` — end-to-end tutorial (build → link → use all modules)
- [ ] All module docs complete: foundation, memory, strings, collections, error-handling
- [ ] `docs/design-decisions.md` — rationale for every non-obvious API choice
- [ ] `docs/porting-guide.md` — how to add a new platform / `CLITE_NO_STDLIB` usage
- [ ] API reference generated via Doxygen and published (GitHub Pages)
- [ ] `CHANGELOG.md` — complete history from `0.1.0` to `1.0.0`

### Samples Complete
- [ ] `samples/01_hello_result.c`
- [ ] `samples/02_arena_allocator.c`
- [ ] `samples/03_safe_strings.c`
- [ ] `samples/04_typed_vec.c`
- [ ] `samples/05_logging.c`
- [ ] `samples/06_embedded_no_stdlib.c` — all modules in `CLITE_NO_STDLIB` mode

### Quality Gates (all must pass before tag)
- [ ] Zero warnings: `-Wall -Wextra -Wpedantic -Werror` on GCC 8, GCC 14, Clang 7, Clang 18, MSVC 2022
- [ ] Zero errors: ASan, UBSan on all unit + integration tests
- [ ] Zero leaks: Valgrind memcheck on all samples
- [ ] Coverage: ≥ 80% line coverage across all modules
- [ ] Static analysis: zero `cppcheck` errors, zero `clang-tidy` warnings
- [ ] Fuzz: minimum 1 hour of fuzzing on `str`, `utf8`, `map`, `fmt` with no crashes
- [ ] All samples build and run correctly on Tier 1 platforms
- [ ] `find_package(Clite)` works correctly in a clean consumer CMake project

### Release Process
- [ ] Final `CHANGELOG.md` entry for `1.0.0`
- [ ] Git tag: `v1.0.0`
- [ ] GitHub Release created with release notes (generated from CHANGELOG)
- [ ] Doxygen API reference deployed to GitHub Pages
- [ ] vcpkg port submitted (PR to vcpkg registry)
- [ ] Conan recipe published to ConanCenter

### Definition of Done — Phase 6 (= Release)
> `v1.0.0` is tagged. CI is green. All quality gates pass. Documentation is live.
> A developer who has never seen CLite can follow `docs/getting-started.md` from
> zero to a working program in under 15 minutes.

---

## Milestone Summary

| Milestone | Version | Week | Deliverable                                         |
|-----------|---------|------|-----------------------------------------------------|
| Scaffold  | `0.1.0` |  2   | Repository, CI, build system, empty stubs           |
| Core      | `0.2.0` |  5   | `defs`, `compiler`, `assert` — foundation complete  |
| Memory    | `0.3.0` |  9   | `mem`, `arena`, `pool` — safe allocators            |
| Strings   | `0.4.0` | 13   | `str`, `strbuf`, `utf8` — safe string handling      |
| Collections| `0.5.0`| 17   | `slice`, `vec`, `map`, `list` — type-safe containers|
| Error/Log | `0.6.0` | 20   | `result`, `option`, `panic`, `log`                  |
| **Release** | **`1.0.0`** | **22** | **Public API frozen. Production ready.**    |

---

## Post-1.0.0 (Preview)

The following are explicitly **out of scope** for `1.0.0` but planned for `1.1.0`+:

- `clite_io` — safe file I/O wrappers
- `clite_fmt` — safe formatted output
- `clite_path` — portable path manipulation
- `clite_atomic`, `clite_mutex`, `clite_thread` — concurrency primitives
- `clite_trace` — execution tracing
- `clite_ffi` — stable C ABI layer for cross-language bindings
- Embedded CI on real hardware (Cortex-M target)

---

*© XA Studio (eXtended Attention Studio). All rights reserved under Apache License 2.0.*
