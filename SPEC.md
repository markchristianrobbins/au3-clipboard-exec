# Spec

This document compiles the user requirements and instructions from `AGENTS.md` and related files and provides detailed documentation of how the companion utility was architected, built, and optimized.

---
## Back to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKARCH.md](AITASKARCH.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- 🔸[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)

---

## New Specs
### Decomposing A line
- Unless otherwise specified, the default win+alt+enter command copies its text from the entire line with sendkeys
- lines must be decomposed to discover valid recognizable components
  - a line may have two URLs or two filespecs
- a single word in a line may actually be referring to a directory or a file
- when a line is input then if it has more than one recognizable token, then a picker is offered showing tokens recognized
- here are some things that are recognized not because of their form, but because of their existence
  - a directory or file name
  - a portion of a window title
- in the picker, the user is shown the number of instances of the match
- once chosen another picker can offer the instances themselves

### Special prefixes
- a + sign in front of a directory spec means new instance of dopus
- a - sign in front of a directory spec to open opus reusing the tab but then to close the tab (ctrl+f4) and keep picker up as to return to it
- a @ sign in front of a directory spec means to open or activate cursor on that directory
- a # sign in front of a directory spec means to open or activate obsidian on that directory
- a - sign in front of # or @ means to activate and close those items



## 📋 Originally Requested Specifications

- **Silent CLI Executor**: Must capture DOS command layouts (`> [Command]`) invisibly without displaying interactive Command Prompt windows (which usually interrupt user workflow).
- **Directory Opus Interoperability**: Tab-reusing and window breakout modes requested. Breaking out into a new window is triggered with the `+` prefix, while standard launches should recycle active lister tabs.
- **Micro-Seconds Search Picker performance**: The selection popup window overlay must remain instantly responsive above 10,000 index directories, without experiencing character entry latency or UI freezing.
- **Zdot Navigation Coordinates**: Must read coordinate registers in localized text structures on disk and highlight rows at the correct line index in the Cursor editor tool.

## 🎯 Implemented Technical Concerns & Optimization Features

- **Double-Process Block Prevention**:
  - **The Problem**: Running multiple overlay instances hooks overlapping keyboard interrupts, leading to locked keys and script crashes.
  - **The Solution / Code Implementation**: `_Engine_UnloadExistingInstance()` looks up a temporary `.instance.lock` storing active workspace PIDs, and uses `ProcessClose()` to shut down matching previous processes before compiling new instances.
- **Physical Modifiers Flushing**:
  - **The Problem**: Issuing virtual keystroke macros (`Send`) while the user is physically holding down modifier keys (Win, Alt, Shift) causes the system to combine key states, executing unrelated shortcuts.
  - **The Solution / Code Implementation**: The modifiers helper (`_Util_WaitForModifierRelease()`) loops and sleeps using `GetAsyncKeyState` checks until physical Win and Alt key bounds are entirely cleared, flushing states with safe SendUp macros.
- **Pre-Allocated Recycled List Controls**:
  - **The Problem**: Re-painting list controls inside fuzzy search change loops causes flickering and typing lag.
  - **The Solution / Code Implementation**: `_Picker_GUICreateRowPool` instantiates exactly 36 recycled rows on startup. The display engine `_Picker_RenderVisibleList` modifies the properties and visibility states of these pre-existing labels, maintaining constant $O(1)$ memory creation overhead.
- **Scripting.Dictionary Counts Caching**:
  - **The Problem**: Querying disk records recursively to display child folder counts as users scroll down search panel lists slows down scrolling.
  - **The Solution / Code Implementation**: `_Picker_BuildChildCounts` compiles two unified high-performance COM arrays (`Scripting.Dictionary`) caching absolute structural counts of children and grandchildren, instantly answering scroll callbacks.

---
## Go Back to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- 🔸[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)
