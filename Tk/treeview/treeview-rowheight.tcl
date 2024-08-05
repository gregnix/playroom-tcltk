#https://core.tcl-lang.org/tk/tktview/2439015

package require Tk
ttk::style configure Treeview -rowheight 40

font configure TkDefaultFont -size 20
ttk::treeview .tv -columns 1 -show {}
foreach c {1 2 3} { .tv insert {} end -values {Text} }
pack .tv