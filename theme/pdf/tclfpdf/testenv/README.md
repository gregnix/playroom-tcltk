# TclFPDF Examples

This repository contains a small test scripts and helper functions to work with the **tclfpdf** package for generating PDF documents using Tcl.

##  Description
These scripts:
- Set up package paths dynamically
- Load a local  `tclfpdf` package
- Generate various PDF examples
- Ensure proper UTF-8 encoding support across different platforms (Windows, Linux )

##  Directory Structure
```
.
└── lib
    ├── pkg
    │   └── tclfpdf-master
    │       ├── addons
    │       ├── examples
    │       ├── font
    │       ├── makefont
    │       ├── manual
    │       └── misc
    └── tm

```


## ️ Encoding Support
The script dynamically adjusts the file encoding based on the operating system:
```tcl
switch $::tcl_platform(platform) {
    unix {
        set encoding utf-8
    }
    windows {
        set encoding cp1252
    }
}
# or
source -encoding [encoding system] [file join $exampledir $example]
```
This ensures proper character rendering on different platforms.

##  PDF Viewer Integration
Generated PDFs are automatically opened using the system's default viewer:
```tcl
proc pdfViewer {pdffile} {
    switch -- $::tcl_platform(platform) {
        windows { exec cmd /c "" $pdffile & }
        unix { exec {*}[auto_execok xdg-open] $pdffile & }
    }
}
```

##  Troubleshooting
- If non-Latin characters appear as `?` or are missing, check if your system supports **UTF-8**.


