# AubergineOS Program Model

## Purpose

This document defines the first real guest program/runtime model for
AubergineMachine.

The goal is to stop treating the boot ROM as the permanent home of the entire
operating system and to give AubergineOS a clear path toward loadable userland
programs.

## Current Direction

The boot ROM should become a bootstrap monitor, loader, and recovery layer.

It can continue to provide:

- bootstrapping,
- filesystem access,
- a minimal shell or monitor,
- and enough editing/loading support to recover the machine.

It should not be the final home of every long-term shell, editor, and language
feature.

## First Runtime Convention

The first executable model is intentionally simple:

- a guest executable is a raw machine-code image,
- it is loaded into RAM at `0x0400`,
- execution starts at `0x0400`,
- and control returns to the ROM shell when the guest program executes `RTS`.

That means the current `load` and `run` behavior is not a temporary hack
anymore. It is the first official program convention.

## Program Types

There are three useful file categories to keep separate:

1. Source files
   - examples: `.asm`, `.basic`
   - edited by the user
   - not directly executable

2. Executable images
   - examples: `.prg`, `.bin`, `.run`
   - raw bytes intended to be loaded at `0x0400`
   - directly runnable by `run`

3. ROM/bootstrap assets
   - boot monitor code and recovery tooling
   - always available without loading from the guest filesystem

For now, the extension does not need to be enforced by the machine. The
important part is the conceptual separation.

## Why `0x0400`

`0x0400` remains the default load address because it is already a stable part
of the project:

- it is in RAM,
- it stays clear of zero page and the hardware stack,
- it is already used by the current shell and tests,
- and it is easy to reason about while the machine is still small.

This can change later, but it should only change once there is a better
documented process model and memory map.

## Responsibilities

### Boot ROM

- initialize the machine,
- provide a minimal fallback shell or monitor,
- load executable images,
- run the currently loaded program,
- and recover when no userland tools are available.

### Guest Userland

- richer shell experience,
- fullscreen editor,
- assembler or language tools,
- and future AubergineOS applications.

The project should move features from ROM to userland when they become stable
enough to live as guest programs.

## Near-Term Command Model

Recommended semantics:

- `load <file>`: read a raw executable image or source payload into the active
  load buffer
- `run`: execute the currently loaded executable at `0x0400`
- `run <file>`: convenience form that loads then runs a named executable
- `asm <file>`: assemble guest source into a runnable image
- `asm <file> <output>`: assemble guest source into a caller-chosen image path
- `basic <file>` or `basic`: future entrypoint into the first guest language

## Language Direction

The first guest-facing language should be Tiny BASIC, not Lua.

Why:

- it fits the scale and personality of the machine,
- it pairs well with a text terminal and simple editor,
- it works naturally with `.basic` source files,
- and it is a much smaller systems target than embedding Lua semantics into the
  guest too early.

Lua can still exist later as a stretch goal if the system grows.

## Suggested Next Implementation Steps

1. Keep the ROM shell usable, but stop adding large permanent subsystems to it.
2. Add a documented notion of executable guest images.
3. Expand the guest assembly workflow beyond default `.program` output.
4. Start moving shell/editor behavior toward loadable AubergineOS programs.
5. Add the first Tiny BASIC workflow once executable loading feels solid.
