# colordb – Unified Tcl/Tk Color Name Utility

The `colordb` module provides a unified interface for loading, merging, comparing, and displaying symbolic color definitions from multiple standard sources in Tcl/Tk.

## Supported Sources

The module supports reading and merging color definitions from:

- `/usr/share/X11/rgb.txt` – X11 color list (default system path)
- `colors.n` – Tk manual page describing symbolic color names
- `merged.txt` – optional custom merged dataset

> The file `colors.tcl` has been removed in favor of more canonical and complete sources.

## Features

- Parses `rgb.txt` and `colors.n` into Tcl `dict` structures
- Normalizes and merges multiple sources into one dictionary
- Checks if a color name is valid in the current `Tk` environment (`winfo rgb`)
- Supports:
  - Comparison between color dictionaries (missing, mismatched values)
  - Export to:
    - X11 `rgb.txt`-style format
    - CSV format (including `winfo` data)
    - Table with live color previews (`tablelist_tile`)
  - Filtering, sorting, and interactive browsing
  - Export of filtered/selected table data

## GUI Table Viewer

The GUI includes a `tablelist_tile`-based widget with:

- Color previews
- Multiple sort and selection modes
- Filtering by `winfo` availability
- Export/import options (CSV and X11 format)

## Requirements

- Tcl 8.6+
- Tk
- tablelist_tile (for GUI)
