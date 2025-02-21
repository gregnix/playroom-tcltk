##  Linux

+ Directory for fonts is not one, but can be several. And then again divided into subdirectories.
+ Library directories are read-only. But here font descriptions, which can be generated dynamically, are saved in ../tclfpdf.1,6/font.


## Windows

## Fonts

```
set SYSTEM_TTFONTS "[file normalize $::env(SystemRoot)/fonts]"
set SYSTEM_TTFONTS [list "/usr/share/fonts" "/usr/local/share/fonts" "$::env(HOME)/.fonts"]
set SYSTEM_TTFONTS [list "/System/Library/Fonts"]
```
