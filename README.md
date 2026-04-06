# AubergineMachine

AubergineMachine is a playful Ruby 4+ 6502 computer built on top of the local
`mos6502-workbench` gem in `../6502`.

Right now it boots a tiny monitor for `AubergineOS`, renders a virtual terminal
in a default amber `ratatui-ruby` dashboard, accepts keyboard input, echoes it
back from the guest, and includes a host-backed virtual filesystem foundation.

## Current Features

- Ruby 4+ project using `mos6502-workbench` from `../6502`
- Assembler-driven boot ROM
- Virtual text terminal mapped into the machine
- Host TUI built with `ratatui-ruby`
- Default amber terminal styling with a visible cursor
- Guest keyboard input queue
- Tiny boot monitor that prints a prompt and echoes typed input
- Host-backed virtual filesystem rooted in `guest_fs`
- File activity indicator in the TUI

## Project Layout

- `bin/boot`: plain CLI boot runner
- `bin/tui`: interactive `ratatui-ruby` dashboard
- `bin/fs`: host-side guest-filesystem helper
- `lib/aubergine_machine/`: machine code
- `spec/`: tests
- `plan.md`: roadmap
- `agent.md`: contributor/agent guidance

## Requirements

- Ruby 4.0 or newer
- Bundler

Install dependencies with:

```bash
bundle install
```

## Running The Machine

Boot the machine in plain CLI mode:

```bash
bundle exec ruby bin/boot
```

That boots the ROM far enough to show the same prompt-ready state as the TUI.

You can also queue guest input from the CLI:

```bash
bundle exec ruby bin/boot --input HI
```

Useful options:

```bash
bundle exec ruby bin/boot --columns 80 --rows 25
bundle exec ruby bin/boot --instructions 512
bundle exec ruby bin/boot --input "HELLO" --input-instructions 128
```

## Running The TUI

Start the interactive dashboard:

```bash
bundle exec ruby bin/tui
```

Start paused:

```bash
bundle exec ruby bin/tui --paused
```

Plain keys are sent to the guest terminal input queue.
Bench controls use Meta, which is typically `Alt` in terminal emulators.

Current bench controls:

- `Meta+p`: pause or run
- `Meta+n`: single-step while paused
- `Meta+r`: reset
- `Meta+f`: jump back to full speed
- `Meta+[` / `Meta+]`: adjust speed
- `Meta+q`: quit

The current dashboard is intentionally lightweight. It shows:

- the virtual terminal
- machine mode
- RAM usage
- queued input count
- file activity indicator
- current speed

## Guest Filesystem

The guest filesystem is rooted at:

```bash
bundle exec ruby bin/fs root
```

By default that is:

```text
guest_fs
```

Basic host-side filesystem commands:

```bash
bundle exec ruby bin/fs list
bundle exec ruby bin/fs write hello.txt HELLO
bundle exec ruby bin/fs read hello.txt
bundle exec ruby bin/fs delete hello.txt
```

The filesystem is sandboxed to the guest root. Attempts to escape it are
rejected.

The TUI reads file activity from the shared guest root, so writes performed via
`bin/fs` can light the file indicator in a running dashboard.

## Current Boot Behaviour

The boot ROM is assembled from source through the gem's two-pass assembler.

On boot, the machine:

1. prints an AubergineOS greeting
2. prints a directory listing from the guest-facing filesystem device
3. enters a tiny shell loop
4. supports `help`, `clear`, `ls`, `cat <file>`, `cp <src> <dst>`, `load <file>`, `new`, `pop`, `run`, `save <file>`, `edit <text>`, `show`, `append <text>`, `write <file> <text>`, and `rm <file>`

This is intentionally small and temporary. It is the beginning of the future
OS shell, not the final shell itself.

Example guest commands through `bin/boot`:

```bash
bundle exec ruby bin/boot --instructions 1024 --input $'help\r' --input-instructions 512
bundle exec ruby bin/boot --instructions 1024 --input $'clear\r' --input-instructions 768
bundle exec ruby bin/boot --instructions 1024 --input $'cat hello.txt\r' --input-instructions 768
bundle exec ruby bin/boot --instructions 1024 --input $'cp hello.txt backup.txt\r' --input-instructions 1024
bundle exec ruby bin/boot --instructions 1024 --input $'load demo.basic\r' --input-instructions 768
bundle exec ruby bin/boot --instructions 1024 --input $'new\r' --input-instructions 512
bundle exec ruby bin/boot --instructions 1024 --input $'pop\r' --input-instructions 512
bundle exec ruby bin/boot --instructions 1024 --input $'run\r' --input-instructions 512
bundle exec ruby bin/boot --instructions 1024 --input $'save copy.basic\r' --input-instructions 768
bundle exec ruby bin/boot --instructions 1024 --input $'edit 10 PRINT \"HELLO\"\rappend 20 PRINT \"BYE\"\rpop\rshow\rsave hello.basic\r' --input-instructions 3584
bundle exec ruby bin/boot --instructions 1024 --input $'write notes.txt HELLO\r' --input-instructions 1024
bundle exec ruby bin/boot --instructions 1024 --input $'rm notes.txt\r' --input-instructions 768
```

`cp` copies one guest file to another through the filesystem device. `load`
copies a file into guest RAM at `$0400`. `run` calls that buffer as a
subroutine, so small machine-code programs can return to the shell with `RTS`.
`new` clears the shared text/program buffer. `pop` removes the last text line.
`save` writes that buffer back out to a guest file. `edit`, `show`, and
`append` now act as a tiny line-oriented editor inside the guest.

Current RAM workspace layout:

- `$0000-$00FF`: zero page
- `$0100-$01FF`: stack
- `$00F0-$00F9`: shell scratch state
- `$0200-$023F`: command buffer
- `$0400-$047F`: load/edit buffer

## Testing

Run the test suite with:

```bash
bundle exec rspec
```

## Next Direction

The next major step is to grow the guest shell into a more capable AubergineOS
environment with better line editing, richer filesystem commands, and eventually
a text editor and program loader.
