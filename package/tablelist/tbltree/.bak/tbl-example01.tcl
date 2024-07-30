#!/usr/bin/env tclsh

package require Tk
package require tablelist_tile
set dirname [file dirname [info script]]

# Create the Tablelist widget with tree configuration
proc createTbl {w} {
   set frt [ttk::frame $w.frt]
   set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" 0 "Value" 0 "Detail"} -height 20 -width 0 \
   -selectmode single \
    -stretch all -movablerows true -acceptchildcommand "acceptChildCmd" -acceptdropcommand "acceptDropCmd"]
   $tbl columnconfigure 0 -name key
   $tbl columnconfigure 1 -name value
   set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
   set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
   $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

   pack $vsb -side right -fill y
   pack $hsb -side bottom -fill x
   pack $tbl -expand yes -fill both

   pack $frt -expand yes -fill both
   return $tbl
}

# Example functions to validate moving rows
proc acceptChildCmd {tbl targetParentNodeIdx sourceRow} {
   # Debugging output
   #puts "acceptChildCmd called with: $tbl, targetParentNodeIdx: $targetParentNodeIdx, sourceRow: $sourceRow"
   return 1  ;# For simplicity, allow all moves
}

proc acceptDropCmd {tbl targetRow sourceRow} {
   # Debugging output
   #puts "acceptDropCmd called with: $tbl, targetRow: $targetRow, sourceRow: $sourceRow"
   return 1  ;# For simplicity, allow all drops
}

proc main {} {
   set data {}
   for {set i 0} {$i < 20} {incr i} {
      lappend data [list "Test $i" $i]
   }
   # create two Tablelist and a text widget
   ttk::frame .fr
   pack .fr -side top -expand 1 -fill both

   set tbl [createTbl  .fr]
   $tbl insertlist end $data
   return $tbl
}
set tbl [main]
puts [$tbl  rowconfigure  0]
puts "bind: [bind $tbl]"

# keine reaktion

#Output:
if {0} {
/usr/bin/tclsh /home/greg/Project/github/playroom/playroom-tcltk/package/tablelist/tbltree/tbl-example01.tcl 


{-acceptchildcommand acceptChildCommand AcceptChildCommand {} acceptChildCmd} {-acceptdropcommand acceptDropCommand AcceptDropCommand {} acceptDropCmd} {-activestyle activeStyle ActiveStyle frame frame} {-aftercopycommand afterCopyCommand AfterCopyCommand {} {}} {-arrowcolor arrowColor ArrowColor black black} {-arrowdisabledcolor arrowDisabledColor ArrowDisabledColor #a3a3a3 #a3a3a3} {-arrowstyle arrowStyle ArrowStyle photo0x0 photo0x0} {-autofinishediting autoFinishEditing AutoFinishEditing 0 0} {-autoscan autoScan AutoScan 1 1} {-background background Background white white} {-bd -borderwidth} {-bg -background} {-borderwidth borderWidth BorderWidth 1 1} {-collapsecommand collapseCommand CollapseCommand {} {}} {-colorizecommand colorizeCommand ColorizeCommand {} {}} {-columns columns Columns {} {0 Key left 0 Value left 0 Detail left}} {-columntitles columnTitles ColumnTitles {} {Key Value Detail}} {-cursor cursor Cursor {} {}} {-customdragsource customDragSource CustomDragSource 0 0} {-disabledforeground disabledForeground DisabledForeground #a3a3a3 #a3a3a3} {-displayondemand displayOnDemand DisplayOnDemand 1 1} {-editendcommand editEndCommand EditEndCommand {} {}} {-editendonfocusout editEndOnFocusOut EditEndOnFocusOut 0 0} {-editendonmodclick editEndOnModClick EditEndOnModClick 1 1} {-editselectedonly editSelectedOnly EditSelectedOnly 0 0} {-editstartcommand editStartCommand EditStartCommand {} {}} {-expandcommand expandCommand ExpandCommand {} {}} {-exportselection exportSelection ExportSelection 1 1} {-fg -foreground} {-font font Font TkDefaultFont TkDefaultFont} {-forceeditendcommand forceEditEndCommand ForceEditEndCommand 0 0} {-foreground foreground Foreground black black} {-fullseparators fullSeparators FullSeparators 0 0} {-height height Height 10 20} {-incrarrowtype incrArrowType IncrArrowType up up} {-instanttoggle instantToggle InstantToggle 0 0} {-itembackground itemBackground Background {} {}} {-itembg -itembackground} {-labelbd -labelborderwidth} {-labelborderwidth labelBorderWidth BorderWidth 1 1} {-labelcommand labelCommand LabelCommand {} {}} {-labelcommand2 labelCommand2 LabelCommand2 {} {}} {-labelfg -labelforeground} {-labelfont labelFont Font TkDefaultFont TkDefaultFont} {-labelforeground labelForeground Foreground black black} {-labelpady labelPadY Pad 1 1} {-labelrelief labelRelief Relief raised raised} {-listvariable listVariable Variable {} {}} {-movablecolumns movableColumns MovableColumns 0 0} {-movablerows movableRows MovableRows 0 1} {-movecolumncursor moveColumnCursor MoveColumnCursor icon icon} {-movecursor moveCursor MoveCursor hand2 hand2} {-populatecommand populateCommand PopulateCommand {} {}} {-protecttitlecolumns protectTitleColumns ProtectTitleColumns 0 0} {-relief relief Relief sunken sunken} {-resizablecolumns resizableColumns ResizableColumns 1 1} {-resizecursor resizeCursor ResizeCursor sb_h_double_arrow sb_h_double_arrow} {-selectbackground selectBackground Foreground #4a6984 #4a6984} {-selectborderwidth selectBorderWidth BorderWidth 1 1} {-selectfiltercommand selectFilterCommand SelectFilterCommand {} {}} {-selectforeground selectForeground Background #ffffff #ffffff} {-selectmode selectMode SelectMode browse browse} {-selecttype selectType SelectType row row} {-setfocus setFocus SetFocus 1 1} {-setgrid setGrid SetGrid 0 0} {-showarrow showArrow ShowArrow 1 1} {-showbusycursor showBusyCursor ShowBusyCursor 1 1} {-showeditcursor showEditCursor ShowEditCursor 1 1} {-showhorizseparator showHorizSeparator ShowHorizSeparator 1 1} {-showlabels showLabels ShowLabels 1 1} {-showseparators showSeparators ShowSeparators 0 0} {-snipstring snipString SnipString ... ...} {-sortcommand sortCommand SortCommand {} {}} {-spacing spacing Spacing 0 0} {-state state State normal normal} {-stretch stretch Stretch {} all} {-stripebackground stripeBackground Background #e8e8e8 #e8e8e8} {-stripebg -stripebackground} {-stripefg -stripeforeground} {-stripeforeground stripeForeground Foreground {} {}} {-stripeheight stripeHeight StripeHeight 1 1} {-takefocus takeFocus TakeFocus {} {}} {-targetcolor targetColor TargetColor black black} {-tight tight Tight 0 0} {-titlecolumns titleColumns TitleColumns 0 0} {-tooltipaddcommand tooltipAddCommand TooltipAddCommand {} {}} {-tooltipdelcommand tooltipDelCommand TooltipDelCommand {} {}} {-treecolumn treeColumn TreeColumn 0 0} {-treestyle treeStyle TreeStyle gtk gtk} {-width width Width 20 0} {-xmousewheelwindow xMouseWheelWindow MouseWheelWindow {} {}} {-xscrollcommand xScrollCommand ScrollCommand {} {.fr.frt.hsb set}} {-ymousewheelwindow yMouseWheelWindow MouseWheelWindow {} {}} {-yscrollcommand yScrollCommand ScrollCommand {} {.fr.frt.vsb set}}

   
}
