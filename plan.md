# AubergineMachine Plan

## Goal

Build a small, playful 6502-based computer in Ruby using the local
`mos6502-workbench` gem from `../6502`.

This machine is not intended to be historically accurate. It should be easy to
understand, easy to extend, and fun to experiment with.

The long-term target is a self-contained virtual computer with:

- a virtual terminal embedded in a Ratatui-based TUI,
- visible machine-state panels for execution and device state,
- a small operating system that boots inside the emulated machine,
- and access to a virtual filesystem backed by files on the host.

## Constraints

- Target Ruby 4.0 or newer.
- Use the local path gem dependency in `Gemfile`.
- Prefer simple, readable code over hardware realism.
- Keep the first version bootable with as little code as possible.
- Lean on the `mos6502-workbench` assembler instead of hand-writing ROM bytes
  once the boot path is proven.

## First Milestone

Create the smallest complete machine that can boot and talk to one custom I/O
device.

Memory map:

- `0x0000-0x7EFF`: RAM
- `0x7F00`: output register device
- `0x8000-0xFFFF`: ROM

Expected boot behaviour:

- Power on from the reset vector in ROM.
- Execute a tiny program.
- Write a visible value to the output device.
- Enter a stable loop.

## Implementation Steps

1. Create a Ruby entrypoint for the machine.
2. Require `mos6502/workbench`.
3. Build a `MOS6502::Machine`.
4. Map RAM, one custom device, and ROM.
5. Implement a tiny custom device by subclassing `MOS6502::Device`.
6. Load a minimal ROM program that proves the machine boots.
7. Run the machine for a fixed number of instructions.
8. Print or trace enough state to confirm the result.

## Product Vision

The machine should eventually feel like a tiny fictional home computer. The
core user experience will be a terminal-centric interface where the emulated
computer is "running inside" a host-side Ruby TUI.

The TUI should eventually show:

- a virtual terminal screen for user I/O,
- RAM usage or occupancy telemetry,
- optional trace or event output,
- and system status such as boot state or active device activity.

The in-machine software stack should eventually include a simple operating
system with a playful identity and a minimal command environment.

The machine should also eventually support:

- file read/write access through a host-backed virtual filesystem,
- an interactive command-line interface,
- program loading from virtual disk,
- an in-machine editor for text and source files,
- and loadable guest programs that are not baked into ROM.

## Architecture Pivot

The current ROM shell and `vi` editor are useful bootstrap tools, but they
should not become the final operating system architecture.

Recommended direction from this point forward:

- keep the boot ROM small and stable,
- treat the current shell and editor as bootstrap facilities,
- define a real guest program model,
- and move AubergineOS userland out of ROM and into loadable guest programs.

That means the ROM should gradually become a monitor, loader, and recovery
environment rather than the place where all long-term OS features live.

## Recommended File Layout

- `bin/boot` or `main.rb`: executable entrypoint
- `lib/aubergine_machine.rb`: top-level project entrypoint
- `lib/aubergine_machine/devices/`: custom devices
- `lib/aubergine_machine/roms/`: ROM builders or static ROM data
- `examples/`: small experiments
- `spec/`: tests

## Near-Term Milestones

### Milestone 1: Bootable Machine

- Add one output device.
- Boot from ROM.
- Verify writes to the device.

### Milestone 2: Assembly Workflow

- Stop hand-writing ROM bytes where possible.
- Add `.asm` programs assembled through the 6502 gem's two-pass assembler.
- Load assembled output into ROM.
- Establish a repeatable "edit, assemble, boot" workflow.

### Milestone 3: Virtual Terminal

- Add a terminal device backed by mapped memory or I/O registers.
- Define how characters are written, read, and cleared.
- Add a host-side Ratatui view that renders the terminal contents.
- Keep the terminal protocol simple enough for assembly programs to use.

### Milestone 4: Machine Dashboard

- Extend the Ratatui interface to show machine state beside the terminal.
- Include registers, flags, cycle count, program counter, RAM usage, and
  memory watches.
- Add controls for stepping, resetting, pausing, and tracing.

### Milestone 5: Virtual Filesystem

- Add a host-backed virtual filesystem device or OS service layer.
- Restrict access to a defined host root directory for safety.
- Support directory listing, file reads, file writes, creation, and deletion.
- Define a simple guest-facing API that the OS shell can call.

### Milestone 6: Interactive Toy Computer

- Add an input register or keyboard-like device.
- Add a simple monitor loop or command interpreter.
- Make it possible to inspect or poke memory.

### Milestone 7: Operating System

- Create a tiny operating system that boots from ROM.
- Give it a humorous, memorable name.
- Provide a shell or monitor-like command loop inside the virtual terminal.
- Add simple services such as text output, keyboard input, and memory helpers.
- Keep long-term userland features outside the ROM wherever practical.

### Milestone 8: Text Editing

- Start with a minimal line editor for creating and changing text files.
- Evolve toward a screen-oriented modal editor once the terminal is stable.
- A `vi`-like editor is a good long-term target, but not the first editor.

### Milestone 9: Programming Language

- Choose a guest language that fits a 6502-scale machine.
- Add source loading and execution from the virtual filesystem.
- Integrate the language with the OS shell and editor workflow.

### Milestone 9A: Guest Program Runtime

- Define a stable guest program entry convention.
- Decide how executables are loaded into RAM and invoked.
- Support both text programs and raw assembled binaries.
- Separate ROM responsibilities from userland responsibilities.
- Make `run` and future shell commands operate on a documented runtime model.

### Milestone 10: Timed Devices

- Add a timer-backed device using `tick(cycles)`.
- Experiment with IRQ and NMI.
- Introduce simple scheduling or periodic events.

## Operating System Naming

Recommended candidates:

- `AubergineOS`
- `EggplantOS`
- `Purple MonOS`
- `PipOS`
- `Nightshade DOS`

Current recommendation:

- `AubergineOS`

It is simple, ties nicely to the project name, and sounds just serious enough
to be funny.

## Programming Language Direction

The machine should eventually support writing and loading programs from within
the guest environment. That said, the language choice needs to match the scale
of a playful 6502 computer.

Options:

- Tiny BASIC: familiar, approachable, historically plausible, good for quick
  experiments
- Forth: compact and very suitable for small systems, but less familiar to many
  users
- Lua: pleasant language design, but likely too large and ambitious for an
  early in-machine 6502 environment

Current recommendation:

- Start with an assembly-first OS and shell.
- Add either Tiny BASIC or a small Forth as the first in-machine language.
- Do not treat Lua as the default guest language for the first implementation.
- Prefer Tiny BASIC as the first guest-facing language once a real program
  model exists.

If a scripting language is still desired later, Lua is better treated as a
stretch goal than a foundation.

## Guest Program Model

The next concrete architecture step is to define what a guest program is.

Recommended first model:

- ROM remains responsible for boot, recovery, and loading.
- A guest executable is a raw machine-code image loaded into RAM at a fixed
  entry address.
- The first entry address should remain `0x0400` for now, because the current
  shell, loader, and tests already use it consistently.
- `run` should mean "call the program entrypoint at the active load address."
- A guest program should return control to the shell with `RTS`.
- Text source files and executable images should stay distinct concepts, even
  if they share the filesystem and editor flow.

Near-term consequences:

- `.basic` files are guest source, not directly executable images.
- assembled binaries should become first-class guest program artifacts,
- and future AubergineOS tools like the shell and editor should themselves be
  candidates for loading as programs instead of living permanently in ROM.

Recommended next commands after the runtime model is documented:

- `asm <file>`: assemble a guest source file into a runnable image
- `run <file>`: load and run a named executable image
- `basic <file>` or `basic`: enter the first guest language environment
- `sh` or equivalent: launch a loadable shell once the ROM shell becomes a
  bootstrap monitor

Immediate next thing to do:

- add a tiny guest build convention, either `build <dir>` for assembling all
  guest `.asm` files in a directory or a small manifest-driven build command
  for multi-file workflows

## Virtual Filesystem Direction

The guest should be able to read and write files that live on the host, but the
mapping should be intentionally narrow and explicit.

Recommended approach:

- expose a single host directory as the guest filesystem root,
- keep path handling simple and sandboxed,
- surface filesystem operations through OS calls or device registers,
- and make the shell the main user-facing entrypoint for file management.

Early shell commands should include:

- `ls`
- `cat`
- `write`
- `rm`
- `load`
- `run`
- `edit`
- `asm`

## Editor Direction

The machine should eventually include a text editor for source files, scripts,
and notes.

Recommended path:

- first build a line-oriented editor,
- then build a fullscreen terminal editor,
- then, if still desirable, evolve it into something `vi`-like.

Trying to start with a full `vi` clone would add a lot of complexity too early.

## Testing Plan

- Add unit tests for each custom device.
- Add a machine boot test that asserts reset, execution, and output behaviour.
- Add regression tests for ROM programs that should remain stable.
- Add tests for terminal device behaviour and screen updates.
- Add tests for host-backed virtual filesystem safety and path handling.
- Add tests for the assembler-driven ROM build path.
- Keep tests runnable on Ruby 4+.

## Definition Of Done For The First Version

- The machine boots from ROM.
- The reset vector is configured correctly.
- A custom device receives a write from the CPU.
- The machine can be run from the command line on Ruby 4+.
- The codebase is simple enough to serve as a playground for future ideas.

## Longer-Term Definition Of Success

- The machine boots into a named operating system.
- The user interacts through a virtual terminal rendered in Ratatui.
- The TUI also shows meaningful computer state for debugging and play.
- The guest can read and write files within a host-backed virtual filesystem.
- The OS exposes a command-line interface for file management and program
  loading.
- The machine includes an in-guest text editor.
- The boot ROM is small enough to act as a loader and recovery layer rather
  than the permanent home of the whole OS.
- ROM software is primarily authored in assembly and built via the gem's
  two-pass assembler.
