# ==============================================================================
# CLite — cmake/CliteCompilerFlags.cmake
# Copyright (c) XA Studio (eXtended Attention Studio).
# Licensed under the Apache License, Version 2.0.
# See LICENSE in the project root for license information.
#
# Project : xastudio.clite
# Author  : XA Studio <github.com/xastudio360>
# Created : 2026-05-29
#
# Provides: clite_set_compiler_flags(<target>)
# Applies the authoritative set of warning and hardening flags to <target>.
# ==============================================================================

function(clite_set_compiler_flags target)

    # --------------------------------------------------------------------------
    # GCC and Clang
    # --------------------------------------------------------------------------
    if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang|AppleClang")

        set(_flags
            # Core warning set — mandatory
            -Wall
            -Wextra
            -Wpedantic

            # Explicit C standard conformance
            -Wstrict-prototypes
            -Wmissing-prototypes
            -Wmissing-declarations

            # Pointer and type safety
            -Wpointer-arith
            -Wcast-align
            -Wcast-qual
            -Wstrict-aliasing=2

            # Integer safety
            -Wsign-conversion
            -Wconversion
            -Wdouble-promotion

            # Undefined and implementation-defined behavior
            -Wundef
            -Wshadow
            -Wredundant-decls

            # Initialization
            -Wuninitialized
            -Wmissing-field-initializers

            # Format string safety
            -Wformat=2
            -Wformat-nonliteral
            -Wformat-security

            # Implicit fallthrough in switch
            -Wimplicit-fallthrough

            # Null safety
            -Wnull-dereference

            # Stack usage visibility (not a hard limit, informational)
            -Wstack-usage=4096
        )

        # GCC-specific flags
        if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
            list(APPEND _flags
                -Wlogical-op            # Suspicious uses of logical operators
                -Wduplicated-cond       # Duplicated condition in if-else chain
                -Wduplicated-branches   # Duplicated branches in if-else chain
                -Wtrampolines           # Warn if GCC generates trampolines
                -Walloca                # Forbid alloca() use
            )
        endif()

        # Clang-specific flags
        if(CMAKE_C_COMPILER_ID MATCHES "Clang|AppleClang")
            list(APPEND _flags
                -Weverything
                # Suppress Weverything noise that is not actionable in C:
                -Wno-padded             # Struct padding is acceptable
                -Wno-covered-switch-default  # Default in fully-covered switch is intentional
                -Wno-declaration-after-statement  # C99+ feature we allow
                -Wno-unsafe-buffer-usage  # CLite provides its own bounds checking
                -Wno-pre-c11-compat    # We target C11+
            )
        endif()

        # Warnings-as-errors — applied only when explicitly requested
        if(CLITE_WARNINGS_AS_ERRORS)
            list(APPEND _flags -Werror)
        endif()

        # Hardening flags (non-sanitizer)
        set(_hardening_flags
            # Stack protector
            -fstack-protector-strong

            # Fortify source (only meaningful in release with optimizations)
            $<$<NOT:$<CONFIG:Debug>>:-D_FORTIFY_SOURCE=2>

            # Disable implicit function declarations becoming extern int
            -Wimplicit-function-declaration
        )

        target_compile_options(${target} PRIVATE
            ${_flags}
            ${_hardening_flags}
        )

    # --------------------------------------------------------------------------
    # MSVC
    # --------------------------------------------------------------------------
    elseif(MSVC)

        set(_flags
            /W4             # High warning level (equivalent to -Wall -Wextra)
            /WX             # Treat warnings as errors (when CLITE_WARNINGS_AS_ERRORS)

            /wd4200         # Zero-length array in struct (used in clite_str internals)
            /wd4201         # Nameless struct/union (used in result/option types)

            # SDL checks — additional security-relevant warnings
            /sdl

            # Conformance mode — closest to standard C
            /permissive-
            /Zc:preprocessor  # Standard preprocessor (required for MSVC 2019+)

            # Spectre mitigation (available in MSVC 2017 15.7+)
            /Qspectre
        )

        if(NOT CLITE_WARNINGS_AS_ERRORS)
            list(REMOVE_ITEM _flags /WX)
        endif()

        target_compile_options(${target} PRIVATE ${_flags})

        # Suppress MSVC's deprecation of POSIX names
        target_compile_definitions(${target} PRIVATE
            _CRT_SECURE_NO_WARNINGS
            _CRT_NONSTDC_NO_WARNINGS
        )

    else()
        message(WARNING
            "[CLite] Unrecognized compiler: ${CMAKE_C_COMPILER_ID}. "
            "No compiler flags applied. Build may succeed but is untested."
        )
    endif()

endfunction()
