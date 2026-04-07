# AubergineMachine Agent Guide

## Project Summary

This project is a toy computer built on top of the local
`mos6502-workbench` gem in `../6502`. The goal is to create a small 6502-based
machine that is easy to read, easy to modify, and enjoyable to experiment with.

The long-term product is a fictional 6502 computer with its own operating
system, a virtual terminal, a host-backed virtual filesystem, and a host-side
TUI written with `ratatui-ruby`.

## Runtime Target

- Ruby 4.0 or newer only.

Any code, scripts, examples, or tests added to this project should assume Ruby
4+ semantics and should not be written for older Ruby compatibility.

## Core Priorities

1. Keep the machine bootable.
2. Keep the architecture simple.
3. Prefer clarity over realism.
4. Make experimentation easy.
5. Design toward a terminal-first user experience.
6. Keep the boot ROM small enough to remain a bootstrap layer.
7. Make the guest OS useful for editing files and loading programs.

## Technical Direction

- Use `require 'mos6502/workbench'` as the canonical gem entrypoint.
- Build the machine around `MOS6502::Machine`, `MOS6502::Bus`, and custom
  subclasses of `MOS6502::Device`.
- Use the gem's built-in two-pass assembler for ROM and OS development once the
  machine boot path exists.
- Prefer explicit memory maps and small device classes.
- Start with one ROM, one RAM region, and one output-oriented I/O device.
- Treat tracing and observability as first-class features for debugging.
- Plan for a Ratatui dashboard that includes both terminal output and machine
  state views.
- Design for a host-backed virtual filesystem that is intentionally sandboxed to
  a chosen directory.

## Expected Memory Map For Early Work

- `0x0000-0x7EFF`: RAM
- `0x7F00`: primary output device
- `0x8000-0xFFFF`: ROM

This map can change later, but early work should avoid needless complexity.

## Planned User Interface

The eventual host-side UI should be a Ratatui application that shows:

- a virtual terminal for the emulated computer,
- CPU registers and flags,
- execution status and cycle count,
- memory watch regions,
- and optional trace or log output.

Changes should move the project toward this combined "computer plus dashboard"
experience rather than treating the TUI as an afterthought.

## Operating System Direction

The machine is expected to grow into a tiny operating system environment rather
than remaining only a ROM demo.

The current ROM shell and editor should be treated as bootstrap facilities, not
the final home for all AubergineOS features. Future work should prefer
loadable userland programs over continually enlarging the boot ROM.

Preferred current OS name:

- `AubergineOS`

Other acceptable names:

- `EggplantOS`
- `Purple MonOS`
- `PipOS`
- `Nightshade DOS`

Unless the user chooses otherwise, treat `AubergineOS` as the default working
name in future scaffolding and documentation.

## Filesystem Direction

The guest OS is expected to read and write a virtual filesystem that maps onto a
directory on the host.

Guidelines:

- Keep the guest-visible filesystem rooted in one explicit host directory.
- Treat path sanitization and sandboxing as mandatory.
- Prefer a narrow, testable guest API over ad hoc host access.
- Make shell commands the main way users interact with files.

Expected shell capabilities:

- listing files,
- reading files,
- writing files,
- deleting files,
- loading programs,
- and launching an editor.

## Programming Language Direction

The machine should eventually support user programming from within the guest
environment, but the language choice should fit a small 6502-style computer.

Current recommendation:

- Use assembly first for ROM and OS bring-up.
- Treat Tiny BASIC or Forth as the strongest candidates for the first guest
  language.
- Prefer Tiny BASIC as the default first guest language once a proper program
  model exists.
- Do not assume Lua is the first practical guest language; it is more suitable
  as a stretch goal if the project grows substantially.

When making design choices, favor the path that keeps interactive programming
possible without requiring a heavyweight runtime.

## Editor Direction

The guest should eventually include a text editor reachable from the shell.

Recommended progression:

- start with a line editor,
- then move to a fullscreen screen editor,
- then consider `vi`-like modal editing if the terminal and OS model support
  it cleanly.

The current in-ROM `vi` implementation is a strong bootstrap tool, but future
iterations should be movable into a loadable AubergineOS userland program.

## Guest Program Model

When making runtime or shell decisions, assume this near-term model unless the
user asks to change it:

- the boot ROM boots, recovers, and loads,
- raw machine-code guest programs are loaded into RAM and entered at a fixed
  address,
- the current default entrypoint is `0x0400`,
- `run` means "execute the currently loaded program and expect `RTS` to
  return",
- and text sources such as `.basic` files are not the same thing as executable
  images.

Future shell/editor tools should be designed so they can become loadable guest
programs rather than permanent ROM features.

## Working Style

- Make the smallest useful change first.
- Add code in a way that preserves a runnable boot path.
- Prefer plain Ruby objects and small classes.
- Avoid premature abstractions unless repeated patterns clearly justify them.
- Keep comments short and only where they improve understanding.

## Suggested Development Sequence

1. Add a machine entrypoint.
2. Add one custom output device.
3. Add a minimal boot ROM.
4. Verify execution with traces or printed state.
5. Move ROM logic into assembly source using the gem assembler.
6. Add a virtual terminal device and protocol.
7. Add a host-backed virtual filesystem boundary.
8. Build an OS shell with file-management and program-loading commands.
9. Define the guest program/runtime model and executable conventions.
10. Add a simple editor.
11. Build a Ratatui shell around the machine.
12. Add tests.
13. Expand into guest-language support and more devices.

## Testing Expectations

- New devices should have focused tests.
- Boot behaviour should have an end-to-end machine test.
- Terminal behaviour should be testable without a live TUI session.
- Assembler-generated ROM outputs should have verification coverage where
  practical.
- Virtual filesystem operations must have safety and path-boundary tests.
- If a change affects execution flow, include a verification path.

## What To Avoid

- Do not optimize for cycle-perfect emulation unless the project explicitly
  shifts in that direction.
- Do not introduce framework-heavy structure for a tiny codebase.
- Do not trade readability for cleverness.

## Good Outcomes

A successful contribution leaves the project in a state where someone can:

- understand the memory map quickly,
- run the machine on Ruby 4+,
- assemble ROM software with the bundled 6502 toolchain,
- interact with the machine through a virtual terminal,
- manage guest files through a host-backed virtual filesystem,
- edit guest files from inside the machine,
- see how devices connect to the bus,
- and extend the computer without reverse-engineering the whole codebase.
