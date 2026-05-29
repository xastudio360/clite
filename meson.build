# ==============================================================================
# CLite — meson.build
# Copyright (c) XA Studio (eXtended Attention Studio).
# Licensed under the Apache License, Version 2.0.
# See LICENSE in the project root for license information.
#
# Project : xastudio.clite
# Author  : XA Studio <github.com/xastudio360>
# Created : 2025-05-25
#
# Minimum Meson version : 0.60.0
# Usage:
#   meson setup build
#   meson compile -C build
#   meson test -C build
# ==============================================================================

project('clite',
    'c',
    version         : '0.1.0',
    license         : 'Apache-2.0',
    meson_version   : '>=0.60.0',
    default_options : [
        'c_std=c17',
        'warning_level=3',      # -Wall -Wextra -Wpedantic
        'werror=true',
        'default_library=both', # Build static and shared by default
        'b_ndebug=if-release',  # NDEBUG in Release builds
    ],
)

# ==============================================================================
# Version components
# Must be kept in sync with CMakeLists.txt and include/xastudio/clite/defs.h.
# ==============================================================================
version_major = 0
version_minor = 1
version_patch = 0
version_build = 1
version_full  = '@0@.@1@.@2@-@3@'.format(
    version_major, version_minor, version_patch, version_build)

# ==============================================================================
# Compiler and host info
# ==============================================================================
cc      = meson.get_compiler('c')
host_os = host_machine.system()   # 'linux' | 'darwin' | 'windows' | 'bare metal'
host_cpu= host_machine.cpu_family() # 'x86_64' | 'aarch64' | 'arm' | ...

message('CLite @0@ — Meson build'.format(version_full))
message('  Compiler : @0@ @1@'.format(cc.get_id(), cc.version()))
message('  Host OS  : @0@'.format(host_os))
message('  Host CPU : @0@'.format(host_cpu))

# ==============================================================================
# Options
# ==============================================================================
opt_release     = get_option('clite_release')
opt_no_stdlib   = get_option('clite_no_stdlib')
opt_sanitizers  = get_option('clite_sanitizers')
opt_coverage    = get_option('clite_coverage')
opt_tests       = get_option('clite_tests')
opt_samples     = get_option('clite_samples')
opt_log_level   = get_option('clite_log_level')

# ==============================================================================
# Compiler flags
# ==============================================================================
_common_args = []
_common_link_args = []

if cc.get_id() in ['gcc', 'clang']
    _common_args += [
        # Core
        '-Wall', '-Wextra', '-Wpedantic',

        # Prototype and declaration hygiene
        '-Wstrict-prototypes',
        '-Wmissing-prototypes',
        '-Wmissing-declarations',

        # Pointer and type safety
        '-Wpointer-arith',
        '-Wcast-align',
        '-Wcast-qual',
        '-Wstrict-aliasing=2',

        # Integer safety
        '-Wsign-conversion',
        '-Wconversion',
        '-Wdouble-promotion',

        # Undefined behavior / implementation-defined
        '-Wundef',
        '-Wshadow',
        '-Wredundant-decls',

        # Initialization
        '-Wuninitialized',
        '-Wmissing-field-initializers',

        # Format string safety
        '-Wformat=2',
        '-Wformat-nonliteral',
        '-Wformat-security',

        # Control flow
        '-Wimplicit-fallthrough',
        '-Wnull-dereference',
    ]

    if cc.get_id() == 'gcc'
        _common_args += [
            '-Wlogical-op',
            '-Wduplicated-cond',
            '-Wduplicated-branches',
            '-Walloca',
        ]
    endif

    if cc.get_id() == 'clang'
        _common_args += [
            '-Wno-padded',
            '-Wno-declaration-after-statement',
        ]
    endif

    # Stack protector
    if cc.has_argument('-fstack-protector-strong')
        _common_args += ['-fstack-protector-strong']
    endif

elif cc.get_id() == 'msvc'
    _common_args += [
        '/W4',
        '/WX',
        '/sdl',
        '/permissive-',
    ]
    # Zc:preprocessor requires MSVC 2019+
    if cc.has_argument('/Zc:preprocessor')
        _common_args += ['/Zc:preprocessor']
    endif
endif

# ------------------------------------------------------------------------------
# Sanitizers
# ------------------------------------------------------------------------------
if opt_sanitizers
    if cc.get_id() in ['gcc', 'clang']
        _san_args = [
            '-fsanitize=address,undefined',
            '-fno-omit-frame-pointer',
            '-fno-optimize-sibling-calls',
        ]
        _common_args      += _san_args
        _common_link_args += _san_args
        message('  Sanitizers : ASan + UBSan ENABLED')
    else
        warning('Sanitizers requested but not supported for this compiler — skipping.')
    endif
endif

# ------------------------------------------------------------------------------
# Coverage
# ------------------------------------------------------------------------------
if opt_coverage
    if cc.get_id() in ['gcc', 'clang']
        _cov_args = ['--coverage', '-fprofile-arcs', '-ftest-coverage']
        _common_args      += _cov_args
        _common_link_args += ['--coverage']
        message('  Coverage   : gcov instrumentation ENABLED')
    else
        warning('Coverage instrumentation not supported for this compiler — skipping.')
    endif
endif

# ==============================================================================
# Compile definitions
# ==============================================================================
_common_defs = [
    'CLITE_VERSION_MAJOR=@0@'.format(version_major),
    'CLITE_VERSION_MINOR=@0@'.format(version_minor),
    'CLITE_VERSION_PATCH=@0@'.format(version_patch),
    'CLITE_VERSION_BUILD=@0@'.format(version_build),
    'CLITE_LOG_LEVEL_@0@'.format(opt_log_level),
]

if opt_release
    _common_defs += ['CLITE_RELEASE']
    message('  Release    : bounds checks DISABLED')
endif

if opt_no_stdlib
    _common_defs += ['CLITE_NO_STDLIB']
    message('  No-stdlib  : ENABLED')
endif

# ==============================================================================
# Include directories
# ==============================================================================
clite_inc = include_directories('include')

# ==============================================================================
# Source files
# (Populated incrementally as phases complete. Phase 0: empty.)
# ==============================================================================

# Phase 1 — Foundation (header-only)
sources_foundation = []

# Phase 2 — Memory
sources_memory = [
    'src/mem.c',
    'src/arena.c',
    'src/pool.c',
]

# Phase 3 — Strings
sources_strings = [
    'src/str.c',
    'src/strbuf.c',
    'src/utf8.c',
]

# Phase 4 — Collections
sources_collections = [
    'src/vec.c',
    'src/map.c',
]

# Phase 5 — Errors & Logging
sources_errors = [
    'src/log.c',
]

# Phase 6 — FFI
sources_ffi = [
    'src/ffi.c',
]

# Aggregate
clite_sources = (
    sources_foundation +
    sources_memory     +
    sources_strings    +
    sources_collections+
    sources_errors     +
    sources_ffi
)

# ==============================================================================
# Main library target
# ==============================================================================
clite_lib = library('clite',
    sources             : clite_sources,
    include_directories : clite_inc,
    c_args              : _common_args,
    link_args           : _common_link_args,
    c_shared_args       : ['-fvisibility=hidden'],
    version             : meson.project_version(),
    soversion           : version_major.to_string(),
    install             : true,
)

# Dependency object — consumers use this with declare_dependency()
clite_dep = declare_dependency(
    link_with           : clite_lib,
    include_directories : clite_inc,
    compile_args        : _common_defs,
)

# ==============================================================================
# pkg-config
# ==============================================================================
pkg = import('pkgconfig')
pkg.generate(
    clite_lib,
    name         : 'clite',
    filebase     : 'clite',
    description  : 'A forgiving, safe, and modern programming library for C.',
    version      : version_full,
    url          : 'https://github.com/xastudio360/clite',
    subdirs      : 'xastudio/clite',
)

# ==============================================================================
# Install headers
# ==============================================================================
install_headers(
    'include/xastudio/clite/clite.h',
    'include/xastudio/clite/defs.h',
    'include/xastudio/clite/compiler.h',
    'include/xastudio/clite/assert.h',
    'include/xastudio/clite/mem.h',
    'include/xastudio/clite/arena.h',
    'include/xastudio/clite/pool.h',
    'include/xastudio/clite/rc.h',
    'include/xastudio/clite/str.h',
    'include/xastudio/clite/strbuf.h',
    'include/xastudio/clite/utf8.h',
    'include/xastudio/clite/slice.h',
    'include/xastudio/clite/vec.h',
    'include/xastudio/clite/map.h',
    'include/xastudio/clite/list.h',
    'include/xastudio/clite/result.h',
    'include/xastudio/clite/option.h',
    'include/xastudio/clite/panic.h',
    'include/xastudio/clite/io.h',
    'include/xastudio/clite/path.h',
    'include/xastudio/clite/fmt.h',
    'include/xastudio/clite/atomic.h',
    'include/xastudio/clite/mutex.h',
    'include/xastudio/clite/thread.h',
    'include/xastudio/clite/log.h',
    'include/xastudio/clite/trace.h',
    'include/xastudio/clite/ffi.h',
    'include/xastudio/clite/ffi_wasm.h',
    subdir : 'xastudio/clite',
)

# ==============================================================================
# Tests
# ==============================================================================
if opt_tests
    # Unity test framework
    unity_proj = subproject('unity',
        default_options : ['default_library=static'],
        required         : false,
    )

    if unity_proj.found()
        unity_dep = unity_proj.get_variable('unity_dep')
    else
        # Fallback: expect Unity source vendored under tests/vendor/unity/
        unity_src = files('tests/vendor/unity/src/unity.c')
        unity_lib = static_library('unity', unity_src,
            include_directories : include_directories('tests/vendor/unity/src'),
        )
        unity_dep = declare_dependency(
            link_with           : unity_lib,
            include_directories : include_directories('tests/vendor/unity/src'),
        )
    endif

    # Helper: register a unit test
    # Usage: clite_test('mem', 'tests/unit/test_mem.c')
    # (Uncommented as phases complete)

    # Phase 1 — Foundation
    # clite_test = executable('test_defs',     'tests/unit/test_defs.c',     dependencies : [clite_dep, unity_dep])
    # test('unit::defs',     clite_test, timeout : 30)
    # clite_test = executable('test_compiler', 'tests/unit/test_compiler.c', dependencies : [clite_dep, unity_dep])
    # test('unit::compiler', clite_test, timeout : 30)
    # clite_test = executable('test_assert',   'tests/unit/test_assert.c',   dependencies : [clite_dep, unity_dep])
    # test('unit::assert',   clite_test, timeout : 30)

    # Phase 2 — Memory
    # clite_test = executable('test_mem',   'tests/unit/test_mem.c',   dependencies : [clite_dep, unity_dep])
    # test('unit::mem',   clite_test, timeout : 30)
    # clite_test = executable('test_arena', 'tests/unit/test_arena.c', dependencies : [clite_dep, unity_dep])
    # test('unit::arena', clite_test, timeout : 30)
    # clite_test = executable('test_pool',  'tests/unit/test_pool.c',  dependencies : [clite_dep, unity_dep])
    # test('unit::pool',  clite_test, timeout : 30)

    # Phase 3 — Strings
    # clite_test = executable('test_str',    'tests/unit/test_str.c',    dependencies : [clite_dep, unity_dep])
    # test('unit::str',    clite_test, timeout : 30)
    # clite_test = executable('test_strbuf', 'tests/unit/test_strbuf.c', dependencies : [clite_dep, unity_dep])
    # test('unit::strbuf', clite_test, timeout : 30)
    # clite_test = executable('test_utf8',   'tests/unit/test_utf8.c',   dependencies : [clite_dep, unity_dep])
    # test('unit::utf8',   clite_test, timeout : 30)

    # Phase 4 — Collections
    # clite_test = executable('test_slice', 'tests/unit/test_slice.c', dependencies : [clite_dep, unity_dep])
    # test('unit::slice', clite_test, timeout : 30)
    # clite_test = executable('test_vec',   'tests/unit/test_vec.c',   dependencies : [clite_dep, unity_dep])
    # test('unit::vec',   clite_test, timeout : 30)
    # clite_test = executable('test_map',   'tests/unit/test_map.c',   dependencies : [clite_dep, unity_dep])
    # test('unit::map',   clite_test, timeout : 30)
    # clite_test = executable('test_list',  'tests/unit/test_list.c',  dependencies : [clite_dep, unity_dep])
    # test('unit::list',  clite_test, timeout : 30)

    # Phase 5 — Errors & Logging
    # clite_test = executable('test_result', 'tests/unit/test_result.c', dependencies : [clite_dep, unity_dep])
    # test('unit::result', clite_test, timeout : 30)
    # clite_test = executable('test_option', 'tests/unit/test_option.c', dependencies : [clite_dep, unity_dep])
    # test('unit::option', clite_test, timeout : 30)
    # clite_test = executable('test_panic',  'tests/unit/test_panic.c',  dependencies : [clite_dep, unity_dep])
    # test('unit::panic',  clite_test, timeout : 30)
    # clite_test = executable('test_log',    'tests/unit/test_log.c',    dependencies : [clite_dep, unity_dep])
    # test('unit::log',    clite_test, timeout : 30)

endif  # opt_tests

# ==============================================================================
# Samples
# ==============================================================================
if opt_samples
    # Samples are added as phases complete.
    # clite_sample = executable('clite_sample_01_hello_result',
    #     'samples/01_hello_result.c',
    #     dependencies : clite_dep,
    # )
endif  # opt_samples

# ==============================================================================
# Summary
# ==============================================================================
summary({
    'Version'       : version_full,
    'C standard'    : get_option('c_std'),
    'Build type'    : get_option('buildtype'),
    'Prefix'        : get_option('prefix'),
}, section : 'CLite — XA Studio', bool_yn : true)

summary({
    'Release mode'  : opt_release,
    'No-stdlib'     : opt_no_stdlib,
    'Sanitizers'    : opt_sanitizers,
    'Coverage'      : opt_coverage,
    'Log level'     : opt_log_level,
}, section : 'Options', bool_yn : true)

summary({
    'Tests'         : opt_tests,
    'Samples'       : opt_samples,
}, section : 'Targets', bool_yn : true)
