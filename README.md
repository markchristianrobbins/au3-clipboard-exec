# Clipboard Exec Engine

[![Engine Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](#)
[![Environment](https://img.shields.io/badge/environment-Windows_/_AutoIt3-green.svg)](#)
[![License](https://img.shields.io/badge/license-MIT-purple.svg)](#)

![icon.jpg]
A high-performance Windows systems tray automation framework written in AutoIt v3 that captures system window context, analyzes clipboard strings via Regular Expression routing pipelines, and directs commands down target application workflows.

The system handles everything from seamless Directory Opus folder launches (tab-reusing or new breakout-windows) to executing hidden standard shell commands and piping live console summaries directly back into focus arrays. It features an interactive, stunningly styled, custom borderless Search Picker GUI that sorts wildcard queries, matches sub-strings, remembers and persists folder history, and brand-colors listings dynamically on the fly.

---
## Go to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKARCH.md](AITASKARCH.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- 🔸[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)

---

## ✨ Core Highlights & Features

- **Context-Aware Keystroke Profiles**: Maps foreground window classes (like Cursor or Directory Opus) to configurable keystroke macros, allowing text selection triggers based on active environments.
- **Regular Expression Router**: Categorizes text buffers into URLs, local directories, temporal Zdot coordinators, or systems console shell operations.
- **Silent CLI Executor**: Supports standard CLI operations invisibly, piping output lists (StdOut+StdErr) straight back into clipboard grids with zero terminal flickering.
- **Dynamic Search Picker Overlay**: A gorgeous, mouse-hover and arrow-key responsive borderless popup window. It implements character-subdivision fuzzy highlights and unique folder branding hues computed from ASCII hashes.
- **Sub-Directory Explorer Mode**: Deep-scroll and explore child subdirectories recursively within search panels, with custom backspace levels and folder-children indicators.

## 🚀 Quick Start / Installation Guide

### Prerequisites
- **Target OS**: Windows 10 or 11 (64-bit).
- **Runtime Environment**: AutoIt v3 compiler and interpreter files installed (downloadable from official AutoIt sites).
- **Target Editors & Listers**: Directory Opus and Cursor IDE installed under default application filepaths.

### Setup Instructions

1. **Deploy Repository**:
   Extract source scripts to your primary script directory:
   ```bash
   mkdir -p "C:\_\au3-clipboard-exec"
   ```
2. **Deploy Local Database Directories**:
   Setup the central data repository folders storing profiles:
   ```bash
   mkdir -p "C:\$data"
   mkdir -p "C:\$data\zdoti"
   ```
3. **Configure Settings**:
   Create and update `C:\$data\clipboard-exec.ini` and `C:\$data\apps.ini` mapping profiles (see profiles reference below).
4. **Boot Utility**:
   Double click `clipboard-exec.au3` to boot the utility or run via cmd:
   ```bash
   "C:\Program Files (x86)\AutoIt3\AutoIt3.exe" "./clipboard-exec.au3"
   ```
   An startup chime plays and a windows toast confirms: *"Engine initialized and listening for hotkeys."*

## ⚙️ Main Configurations

The workspace settings are populated and controlled using the configuration files:

| Configuration Key | Default Value | Description |
| :--- | :--- | :--- |
| **`sendkeys`** under `[Cursor]` | `{HOME}+{END}^c` | Defines copying macros sent when pressing the scanner shortcut. |
| **`$g_sMainIni`** | `C:\$data\clipboard-exec.ini` | The central configuration file location. |
| **`$g_sDOpusRt`** | `C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe` | Path to Directory Opus lister routing compiler. |
| **`$g_sCursorBin`** | `C:\Users\Mark\AppData\Local\Programs\cursor\Cursor.exe` | Path to the Cursor editor executable binary. |

---
## Go Back to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- 🔸[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)
