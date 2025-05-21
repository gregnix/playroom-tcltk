# colordb – Unified Tcl/Tk Color Name Utility

The `colordb` module is a Tcl/Tk utility for loading, merging, comparing, and displaying symbolic color names from multiple standard sources.

## Sources Supported

- `/usr/share/X11/rgb.txt` — the traditional X11 color database
- `colors.tcl` — used in the Tk demo directory (`$tk_library/demos/colors.tcl`)
- `colors.n` — the Tcl/Tk man page describing symbolic color names (e.g., `/usr/local/share/man/mann/colors.n`)

## Features

- Parses and normalizes color definitions:  
  name → `{r g b hex winfo}`

- Merges color definitions from different sources into a unified dictionary

- Compares source files by:
  - Keys (i.e. available color names)
  - Hex values (for conflicting RGB definitions)

- Validates whether a color is known to the current Tk environment via `winfo rgb`

## Output Formats

- `rgb.txt` format: for compatibility or re-import
- Tabular format with `hex`, `winfo`, and 8-bit RGB values
- CSV for external tools or spreadsheets
- GUI table using `tablelist_tile`, with live color preview

## Requirements

- Tcl/Tk 8.6 or newer
- [tablelist_tile](https://www.nemethi.de/) for GUI display (optional)

## Example

```tcl
set rgb   [colordb::readRgbTxt /usr/share/X11/rgb.txt]
set manpg [colordb::readColorsN /usr/local/share/man/mann/colors.n]
set demo  [colordb::readColorsTcl $tk_library/demos/colors.tcl]

set merged [colordb::mergeDicts $rgb $manpg]

colordb::printTableColors $merged
colordb::saveMergedAsCsv $merged
colordb::showInTablelist $merged
