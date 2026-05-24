# CLite

> A forgiving, safe, and modern programming library for C.

[![CI](https://github.com/xastudio360/clite/actions/workflows/ci.yml/badge.svg)](https://github.com/xastudio360/clite/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0--1-orange.svg)](CHANGELOG.md)
[![C Standard](https://img.shields.io/badge/C-C11%2FC17-lightgrey.svg)](#requirements)
[![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20macOS%20%7C%20Windows%20%7C%20Embedded-lightgrey.svg)](#platform-support)

---

C is powerful, but unforgiving. A single unchecked pointer, an off-by-one error,
or a forgotten `free()` can corrupt memory, crash a process, or open a security
vulnerability. CLite does not try to replace C — it embraces it, and makes it
**safer, more expressive, and harder to misuse** without sacrificing performance
or portability.

```c
// Without CLite
char* buf = malloc(size);
if (!buf) { /* easy to forget */ }
sprintf(buf, fmt, ...);              // potential overflow
strncpy(dst, src, n);               // off-by-one trap
free(buf);

// With CLite
CliteStrBuf buf;
clite_strbuf_init(&buf, CLITE_MEM_DEFAULT);
clite_strbuf_append_fmt(&buf, fmt, ...);   // bounded, checked
clite_strbuf_destroy(&buf);                // ownership is explicit
```

---

## Table of Contents

- [Philosophy](#philosophy)
- [Features](#features)
- [Modules](#modules)
- [Requirements](#requirements)
- [Platform Support](#platform-support)
- [Getting Started](#getting-started)
- [Building from Source](#building-from-source)
- [Usage with CMake](#usage-with-cmake)
- [Usage with Meson](#usage-with-meson)
- [Samples](#samples)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [Security](#security)
- [License](#license)

---

## Philosophy

CLite is built on three principles:

**Forgiving** — Common mistakes are caught at compile time or produce defined,
recoverable behavior. Silent failures are forbidden in CLite APIs. Every function
that can fail returns an explicit result.

**Zero-cost** — Every abstraction compiles down to what a careful C programmer
would write by hand. There is no runtime, no garbage collector, no hidden
allocation. In `CLITE_RELEASE` mode, bounds checks and assertions are stripped
entirely — the generated code is identical to raw C.

**Composable** — Modules are independent. There are no forced interdependencies.
Link only what you use. CLite works on hosted systems and on bare-metal targets
with no standard library (`CLITE_NO_STDLIB`).

---

## Features

- **Type-safe collections** — `CliteVec`, `CliteMap`, `CliteSlice` are
  macro-instantiated per type. No `void*`. No casting.
- **Explicit error handling** — `CliteResult(T, E)` and `CliteOption(T)` patterns
  eliminate silent `NULL` returns and unchecked error codes.
- **Safe memory management** — Pluggable `CliteAllocator` vtable.
  Arena, pool, and default (malloc) allocators included. OOM is never silent.
- **Length-aware strings** — `CliteStr` is a `(ptr, len)` view — not
  null-terminated by default. `CliteStrBuf` is a growable buffer that makes
  `sprintf` overflow structurally impossible.
- **UTF-8 first** — Built-in validation, safe iteration, and codepoint encoding
  via `clite_utf8`.
- **Structured logging** — Zero-allocation log path with compile-time level
  stripping and pluggable sinks.
- **Embedded-ready** — Full `CLITE_NO_STDLIB` mode for MCU targets.
  Static arena initialization from a fixed buffer. No dynamic allocation required.
- **Sanitizer-clean** — All modules are developed and tested under ASan, UBSan,
  TSan, and Valgrind from day one.

---

## Modules

CLite is organized into independent modules. Include only what you need.

| Group           | Module           | Description                                       | Header                        |
|-----------------|------------------|---------------------------------------------------|-------------------------------|
| **Foundation**  | `clite_defs`     | Primitive types, platform detection, version      | `xastudio/clite/defs.h`       |
|                 | `clite_compiler` | Portability macros (`LIKELY`, `NOINLINE`, etc.)   | `xastudio/clite/compiler.h`   |
|                 | `clite_assert`   | Safe assertions with pluggable handler            | `xastudio/clite/assert.h`     |
| **Memory**      | `clite_mem`      | Safe allocator vtable, OOM handling               | `xastudio/clite/mem.h`        |
|                 | `clite_arena`    | Bump allocator with checkpoint/restore            | `xastudio/clite/arena.h`      |
|                 | `clite_pool`     | Fixed-size object pool                            | `xastudio/clite/pool.h`       |
| **Strings**     | `clite_str`      | Immutable length-aware string view                | `xastudio/clite/str.h`        |
|                 | `clite_strbuf`   | Growable string buffer                            | `xastudio/clite/strbuf.h`     |
|                 | `clite_utf8`     | UTF-8 validation, iteration, encoding             | `xastudio/clite/utf8.h`       |
| **Collections** | `clite_slice`    | Bounds-checked fat pointer                        | `xastudio/clite/slice.h`      |
|                 | `clite_vec`      | Type-safe growable array                          | `xastudio/clite/vec.h`        |
|                 | `clite_map`      | Type-safe open-addressing hash map                | `xastudio/clite/map.h`        |
|                 | `clite_list`     | Intrusive doubly-linked list                      | `xastudio/clite/list.h`       |
| **Errors**      | `clite_result`   | `Result<T, E>` — explicit success/error type      | `xastudio/clite/result.h`     |
|                 | `clite_option`   | `Option<T>` — explicit nullable value             | `xastudio/clite/option.h`     |
|                 | `clite_panic`    | Controlled panic with pluggable handler           | `xastudio/clite/panic.h`      |
| **Diagnostics** | `clite_log`      | Structured, zero-allocation logging               | `xastudio/clite/log.h`        |

Or include everything at once:

```c
#include <xastudio/clite/clite.h>
```

---

## Requirements

| Requirement     | Minimum         | Recommended     |
|-----------------|-----------------|-----------------|
| C Standard      | C11             | C17             |
| CMake           | 3.16            | 3.25+           |
| GCC             | 8.0             | 14.0            |
| Clang           | 7.0             | 18.0            |
| MSVC            | 19.20 (VS 2019) | 19.40 (VS 2022) |

No third-party runtime dependencies. The test suite uses
[Unity](https://github.com/ThrowTheSwitch/Unity) (vendored).

---

## Platform Support

### Tier 1 — Fully tested in CI on every commit

| Platform    | Architecture              | Compiler          |
|-------------|---------------------------|-------------------|
| Linux       | x86-64, ARM64, ARMv7      | GCC, Clang        |
| macOS       | x86-64, ARM64             | Clang             |
| Windows     | x86-64                    | MSVC, Clang-cl    |
| Bare metal  | ARMv7-M, ARMv8-M          | GCC (arm-none-eabi), IAR, Keil |

### Tier 2 — Best-effort, not in primary CI

| Platform       | Notes                                 |
|----------------|---------------------------------------|
| FreeBSD/OpenBSD| Expected to work                      |
| WebAssembly    | Via Clang + wasi-sdk                  |
| Android NDK    | ARM64, x86-64                         |

---

## Getting Started

### 1. Clone and build

```sh
git clone https://github.com/xastudio360/clite.git
cd clite
cmake -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build
ctest --test-dir build --output-on-failure
```

### 2. Write your first CLite program

```c
// main.c
#include <xastudio/clite/clite.h>

// Define a typed Result: success = int, error = CliteStatus
CLITE_RESULT_DEFINE(IntResult, int, CliteStatus)

static IntResult parse_positive(CliteStr input) {
    if (clite_str_is_empty(input)) {
        return IntResult_err(CLITE_ERR_INVALID);
    }

    // ... parsing logic ...
    int value = 42;

    if (value <= 0) {
        return IntResult_err(CLITE_ERR_INVALID);
    }
    return IntResult_ok(value);
}

int main(void) {
    CliteStr input = CLITE_STR("42");
    IntResult r = parse_positive(input);

    if (IntResult_is_err(r)) {
        CLITE_LOG_ERROR("Parse failed: %s",
            clite_status_str(IntResult_unwrap_err(r)).ptr);
        return 1;
    }

    CLITE_LOG_INFO("Parsed value: %d", IntResult_unwrap(r));
    return 0;
}
```

### 3. Compile

```sh
gcc -std=c17 -Wall -Wextra -Werror \
    -I/path/to/clite/include \
    main.c -L/path/to/clite/build -lclite \
    -o main
```

---

## Building from Source

### CMake options

| Option                        | Default | Description                              |
|-------------------------------|---------|------------------------------------------|
| `CLITE_BUILD_TESTS`           | `ON`    | Build unit and integration test suite    |
| `CLITE_BUILD_SAMPLES`         | `ON`    | Build sample programs                    |
| `CLITE_BUILD_DOCS`            | `OFF`   | Generate Doxygen API reference           |
| `CLITE_RELEASE`               | `OFF`   | Disable bounds checks and assertions     |
| `CLITE_NO_STDLIB`             | `OFF`   | Strip all `<stdlib.h>` dependencies      |
| `CLITE_SANITIZERS`            | `OFF`   | Enable ASan + UBSan (Debug builds only)  |
| `CLITE_LOG_LEVEL`             | `DEBUG` | Compile-time minimum log level           |

### Example: release build with sanitizers off

```sh
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCLITE_RELEASE=ON \
  -DCLITE_BUILD_TESTS=OFF
cmake --build build --config Release
```

### Example: embedded (no stdlib) build

```sh
cmake -B build-embedded \
  -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/arm-none-eabi.cmake \
  -DCLITE_NO_STDLIB=ON \
  -DCLITE_RELEASE=ON \
  -DCLITE_BUILD_TESTS=OFF \
  -DCLITE_BUILD_SAMPLES=OFF
cmake --build build-embedded
```

---

## Usage with CMake

After installation (or via `add_subdirectory`):

```cmake
# Link only the modules you need
find_package(Clite REQUIRED)

target_link_libraries(my_app PRIVATE
    xastudio::clite::mem
    xastudio::clite::str
    xastudio::clite::log
)

# Or link the full library
target_link_libraries(my_app PRIVATE xastudio::clite)
```

---

## Usage with Meson

```meson
clite_dep = dependency('clite', version : '>=0.1.0')

executable('my_app', 'main.c',
    dependencies : clite_dep)
```

---

## Samples

Ready-to-run examples are in the [`samples/`](samples/) directory:

| Sample                         | Demonstrates                                    |
|--------------------------------|-------------------------------------------------|
| `01_hello_result.c`            | File open → read → parse with full error propagation |
| `02_arena_allocator.c`         | Arena allocator end-to-end                      |
| `03_safe_strings.c`            | CliteStr + CliteStrBuf, no sprintf              |
| `04_typed_vec.c`               | Type-safe vector with CLITE_VEC_DEFINE          |
| `05_logging.c`                 | Structured logging with a custom JSON sink      |
| `06_embedded_no_stdlib.c`      | All modules in CLITE_NO_STDLIB mode             |

Build and run a sample:

```sh
cmake --build build --target clite_sample_03
./build/samples/03_safe_strings
```

---

## Documentation

Full API reference and guides are available at:
**[xastudio360.github.io/clite](https://xastudio360.github.io/clite)**

| Document                                              | Description                             |
|-------------------------------------------------------|-----------------------------------------|
| [Getting Started](docs/getting-started.md)            | Build, link, first program              |
| [Foundation](docs/modules/foundation.md)              | `defs`, `compiler`, `assert`            |
| [Memory](docs/modules/memory.md)                      | Allocators, arena, pool                 |
| [Strings](docs/modules/strings.md)                    | CliteStr, CliteStrBuf, UTF-8            |
| [Collections](docs/modules/collections.md)            | Slice, Vec, Map, List                   |
| [Error Handling](docs/modules/error-handling.md)      | Result, Option, panic                   |
| [Design Decisions](docs/design-decisions.md)          | Why CLite is built the way it is        |
| [Porting Guide](docs/porting-guide.md)                | New platforms, CLITE_NO_STDLIB          |
| [Roadmap](ROADMAP.md)                                 | Development roadmap: MVP → 1.0.0        |
| [Changelog](CHANGELOG.md)                             | Version history                         |

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before
opening a pull request. Key points:

- Branch from `develop`, not `main`
- Every PR must include tests and a `CHANGELOG.md` entry
- Run `clang-format` and `clang-tidy` before submitting
- Minimum one maintainer approval required to merge

See [CONTRIBUTORS.md](CONTRIBUTORS.md) for the list of contributors.

---

## Security

Security vulnerabilities must be reported **privately** via
[GitHub Security Advisories](https://github.com/xastudio360/clite/security/advisories/new).
**Do not open a public issue for security vulnerabilities.**

Response SLA:

| Severity   | Response time |
|------------|---------------|
| Minor      | 2–4 weeks     |
| Moderate   | 1–2 weeks     |
| Critical   | < 1 week      |

See [SECURITY.md](SECURITY.md) for the full security policy.

---

## License

CLite is released under the [Apache License 2.0](LICENSE).

```
Copyright (c) XA Studio (eXtended Attention Studio).

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0
```

---

<div align="center">
  <sub>Built with precision by <a href="https://github.com/xastudio360">XA Studio</a></sub>
</div>
