#! /usr/bin/env tclsh

# 20250129
# table with notbooks an db table and views
# 
# todo
# import / export csv with tclcsv
# json with rl_json
# save / load sql editor
# more informatin from sqlite3
# better support tree widget
# manual / example sql 
# output as text and/or tablelist_title
# extra toplevel for extra output

# platform
switch -- $::tcl_platform(platform) {
  windows {
    set os "windows"
    tcl::tm::path add  ../tm
  }
  unix {
    set os "unix"
    tcl::tm::path add  ../tm
  }
  macintosh {
    tcl::tm::path add  ../tm

  }
  default {
    tcl::tm::path add  ../tm
  }
}


package require Tk
package require tablelist_tile
package require tdbc::sqlite3
package require reportlib

namespace eval tablesql {

}

if {![info exists dirname] } {
  set dirname [file dirname [info script ]]
}


set searchname sql-infodb-proc-0.2.tcl
if {[file exists [file join $dirname $searchname]]} {
  source -encoding utf-8 [file join $dirname  $searchname]
} elseif {[file exists [file join $dirname lib $searchname]]} {
  source -encoding utf-8 [file join $dirname lib $searchname]
}

if {![info exists dbconnS]} {
  puts "# Datenbankverbindung herstellen"
  set searchname "my-database.sqlite3"
  if {[file exists [file join $dirname data $searchname]]} {
    set dbconnS [tdbc::sqlite3::connection create db [file join $dirname data  "my-database.sqlite3"]]
  } elseif {[file exists [file normalize [file join $dirname ../ data $searchname]]]} {
    set dbconnS [tdbc::sqlite3::connection create db [file normalize [file join $dirname ../ data  "my-database.sqlite3"]]]
  }
}

#sql-infodb-proc-0.2.tcl
proc infoDB {db} {
  set tableStruct [dict create]

  # Fetch database list
  set dbListStmt [$db prepare "PRAGMA database_list"]
  $dbListStmt execute
  set dbList [dict create]
  $dbListStmt foreach dbRow {
    dict lappend dbList name [dict get $dbRow name]
  }
  $dbListStmt close
  dict set tableStruct databases $dbList
  # Fetch table names
  set stmt [$db prepare "SELECT name FROM sqlite_master WHERE type='table'"]
  $stmt execute
  set tableList [dict create]
  $stmt foreach row {
    dict lappend tableList table [dict get $row name]
  }
  $stmt close
  #dict set tableStruct tablelist  $tableList

  # Fetch structure and indexes of each table

  foreach tableName [dict get $tableList table] {
    set columnList [dict create]
    set columnStmt [$db prepare "PRAGMA table_info($tableName)"]
    $columnStmt execute
    $columnStmt foreach column {
      set colInfo [dict create]
      dict set colInfo  [dict get $column name]  type [dict get $column type]
      dict set colInfo  [dict get $column name]  notnull [dict get $column notnull]
      dict set colInfo  [dict get $column name]  pk [dict get $column pk]
      lappend columnList {*}$colInfo
    }
    dict set tableStruct tablelist $tableName $columnList
    $columnStmt close

    # Fetch index info
    set indexList [dict create]
    set indexStmt [$db prepare "PRAGMA index_list($tableName)"]
    $indexStmt execute
    $indexStmt foreach index {
      set indexInfo [dict create]
      dict set indexInfo  [dict get $index name] name [dict get $index name]
      dict set indexInfo  [dict get $index name] unique [dict get $index unique]
      dict set indexInfo  [dict get $index name] origin [dict get $index origin]
      lappend indexList {*}$indexInfo
    }
    dict set tableStruct indexlist $tableName $indexList
    $indexStmt close
  }

  # Fetch view names
  set stmt [$db prepare "SELECT name FROM sqlite_master WHERE type='view'"]
  $stmt execute
  set viewList [dict create]
  $stmt foreach row {
    dict lappend viewList view [dict get $row name]
  }
  $stmt close

  #dict set tableStruct viewlist  $viewList
  # Fetch structure and indexes of each view
  foreach viewName [dict get $viewList view] {
    set columnList [dict create]
    set columnStmt [$db prepare "PRAGMA table_info($viewName)"]
    $columnStmt execute
    $columnStmt foreach column {
      set colInfo [dict create]
      dict set colInfo  [dict get $column name]  type [dict get $column type]
      dict set colInfo  [dict get $column name]  notnull [dict get $column notnull]
      dict set colInfo  [dict get $column name]  pk [dict get $column pk]
      lappend columnList {*}$colInfo
    }
    dict set tableStruct viewlist $viewName $columnList
    $columnStmt close

  }
  return $tableStruct
}

namespace eval tablesql {
  variable tblDict
  variable dbconnS
  set tblDict [dict create]

  proc textFrameV  {f args} {
    ttk::frame $f
    pack $f -side top -fill both -expand true
    set t [text $f.t -setgrid true -wrap word {*}$args \
    -yscrollcommand "$f.vset set"]
    ttk::scrollbar $f.vset -orient vert -command "$f.t yview"
    pack $f.vset -side right -fill y
    pack $f.t -side left -fill both -expand true

    set popupE [menu $t.popupE]
    $popupE add command -label "Ctrl-c Copy" -command [list tk_textCopy $t]
    $popupE add command -label "Ctrl-x Cut" -command [list tk_textCut $t]
    $popupE add command -label "Ctrl-v Paste" -command [list tk_textPaste $t]
    $popupE add command -label "Ctrl-o Load" -command [list [namespace current]::loadText $t]
    $popupE add command -label "Ctrl-s SAve" -command [list [namespace current]::saveText $t]
    bind $t <3> [list tk_popup $popupE %X %Y]
    bind $t <Control-o> [list [namespace current]::loadText $t]
    bind $t <Control-s> [list [namespace current]::saveText $t]

    return $t
  }
  proc saveText {w filename} {
    set filename [tk_getSaveFile -title "Save file"]
    if {$filename ne ""} {
      if {[catch {set file [open $filename w]} err]} {
        tk_messageBox -message "Error saving file: $err" -icon error
        return
      }
      set data [$w get 1.0 end]
      puts $file $data
      close $file
    }
  }
  proc loadText {w} {
    set filename [tk_getOpenFile -title "Open file"]
    if {$filename ne ""} {
      if {[catch {set file [open $filename r]} err]} {
        tk_messageBox -message "Error opening file: $err" -icon error
        return
      }
      set data [read $file]
      close $file
      $w delete 1.0 end
      $w insert 1.0 $data
    }
  }
  proc treetblcreate {w} {
    set frt $w
    # Tree-Widget als Tablelist erstellen
    set tbl [tablelist::tablelist $frt.tbl -columns {
      0 "Name" left 0 "Type" left 0 "Not Null" left 0 "Pk" left
    } -stretch 0 -width 40 -height 40 -treecolumn 0]

    # Erweiterung und Kollaps der Knoten ermöglichen
    $frt.tbl configure -expandcommand [list [namespace current]::expandNode] -collapsecommand [list [namespace current]::collapseNode]

    # Scrollbars hinzufügen
    set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
    set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
    $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

    pack $vsb -side right -fill y
    pack $hsb -side bottom -fill x
    pack $tbl -expand yes -fill both
    #pack $frt -expand yes -fill both

    set bodyTag [$tbl bodytag]
    bind $bodyTag <Double-1>   [list callbDouble1 %W %x %y]

    return $tbl
  }
  # Event-Handler für die Erweiterung und das Kollabieren
  proc expandNode {tbl row} {
    # Hier kann Code hinzugefügt werden, um zusätzliche Daten dynamisch zu laden
    puts "Expanding node at $row"
  }

  proc collapseNode {tbl row} {
    puts "Collapsing node at $row"
  }

  proc populateTree {tv dictVAR} {
    variable treeDict
    puts $treeDict
    
    set db [$tv insertchild root end  [list "db" "" "" ""]]
    foreach p [dict keys $dictVAR] {
      set child($p) [$tv insertchild $db end  [list "$p" "" "" ""]]
      foreach cp [dict keys [dict get $dictVAR $p]] {
        set grandchild($cp) [$tv insertchild $child($p) end  [list "$cp" "" "" ""]]
        if {![dict is_dict [dict get $dictVAR $p $cp]]} {
          $tv insertchild $grandchild($cp) end  [list "[dict get $dictVAR $p $cp]" "" "" ""]
        } else {
          foreach gcp [dict keys [dict get $dictVAR $p $cp]] {
            set leaf [dict values [dict get $dictVAR $p $cp $gcp]]
            set ggrandchild($gcp) [$tv insertchild $grandchild($cp) end [list $gcp {*}$leaf]]
          }
        }

      }

    }
  }

  proc tblHistoryCreate {w} {
    set frt  $w.frt
    frame $frt
    # Create table
    set tbl [tablelist::tablelist $frt.tbl -columns {5 "ID" right 5 Thema 0 "SQL" left} \
    -stretch all  -xscroll [list $frt.h set] -yscroll [list $frt.v set] -labelcommand tablelist::sortByColumn \
    -stripebackground #f0f0f0 -selectmode single -exportselection false -height 5]

    $tbl columnconfigure 0 -sortmode dictionary

    # add scrollbar
    set vsb [scrollbar $frt.v -orient vertical -command [list $tbl yview]]
    set hsb [scrollbar $frt.h -orient horizontal -command [list $tbl xview]]

    # Add  frames
    set frb [frame $w.frb]
    pack $frb -fill x -side bottom -expand 0
    pack $frt -fill both -side top -expand true

    pack $vsb -side right -fill y -expand 0
    pack $hsb -side bottom -fill x -expand 0
    pack $tbl -fill both -expand true

    # add buttons
    set btnone [button $frb.one -text "Button One" -command [list tk_messageBox -message "Tbl: $tbl" -type ok]]
    set btntwo [button $frb.two -text "Button Two" -command [list tblcallback $tbl ]]

    pack $btnone $btntwo -side left

    # bind
    bind [$tbl bodytag] <Double-1> [list tk_messageBox -message "Tbl: $tbl\nW %W" -type ok]
    bind [$tbl bodytag] <Key-a> [list tk_messageBox -message \
    "Tbl: $tbl\nW %W\nx: %x y:%y\nX:%X Y:%Y\n [join "%k %i %s %A %K %M %N %R %S %T" \n]" -type ok]
    bind [$tbl bodytag] <Key-F4> [list $btntwo invoke]

    return $tbl
  }
  # Tablelist-Widget erstellen
  proc tblCreate {w cols suffix tabletype} {
    variable tblDict


    set frt  $w.frt_$suffix
    ttk::labelframe $frt -text "Tabelle"
    # Create table
    set tbl [tablelist::tablelist $frt.tbl -columns $cols -width 100 \
   -xscroll [list $frt.h set] -yscroll [list $frt.v set] -labelcommand tablelist::sortByColumn \
    -stripebackground #f0f0f0 -selectmode multiple -exportselection false]
    dict set tbldict tbl $tbl
    dict set tbldict cols $cols
    $tbl columnconfigure 0 -sortmode dictionary

    # add scrollbar
    set vsb [scrollbar $frt.v -orient vertical -command [list $tbl yview]]
    set hsb [scrollbar $frt.h -orient horizontal -command [list $tbl xview]]

    # Add  frames
    set frtx [ttk::labelframe $w.frtx_$suffix -text "Sql Editor zu $suffix"]
    set frb [ttk::frame $w.frb_$suffix]
    pack $frtx -fill both -side bottom -expand 1
    pack $frb -fill x -side bottom -expand 0
    pack $frt -fill both -side top -expand true

    pack $vsb -side right -fill y -expand 0
    pack $hsb -side bottom -fill x -expand 0
    pack $tbl -fill both -expand true

    # combobox
    set cbselection [ttk::combobox $frb.cbselection -values [list single  multiple ] -exportselection 0 -width 8]
    bind $cbselection <<ComboboxSelected>> [namespace code [list [namespace current]::OnComboSelected %W $tbl selectmode]]
    $cbselection current 0
    event generate $cbselection <<ComboboxSelected>>
    # add buttons
    set btnone [ttk::button $frb.one -text "Button One" -command [list tk_messageBox -message "Tbl: $tbl" -type ok]]
    set btntwo [ttk::button $frb.two -text "Button Two" -command [list [namespace current]::tblcallback $tbl $suffix edit ]]
    set btnthree [ttk::button $frb.three -text "Button Three" -command [list [namespace current]::tblcallback $tbl $suffix dictview ]]

    set txedit [textFrameV $frtx.textedit -height 4]
    set txview [textFrameV $frtx.textview -height 10]
    set tblhistory [tblHistoryCreate $frtx]
    dict set tbldict txedit $txedit
    dict set tbldict txview $txview
    dict set tbldict tblhistory $tblhistory
    pack $txedit $txview -side top -expand 1 -fill both
    pack $cbselection $btnone $btntwo $btnthree -side left


    # bind
    bind [$tbl bodytag] <Double-1> [list tk_messageBox -message "Tbl: $tbl\nW %W" -type ok]
    bind [$tbl bodytag] <Key-a> [list tk_messageBox -message \
    "Tbl: $tbl\nW %W\nx: %x y:%y\nX:%X Y:%Y\n [join "%k %i %s %A %K %M %N %R %S %T" \n]" -type ok]
    bind [$tbl bodytag] <Key-F4> [list $btntwo invoke]
    set popupE [[namespace current]::menuTable $tbl]
    bindwid
    dict set tblDict $suffix $tbldict
    return $tbl
  }

  proc tblcallback {tbl suffix swVar args} {
    variable dbconnS
    variable tblDict
    switch $swVar {
      edit {
        set tedit [dict get $tblDict $suffix txedit]
        set tview [dict get $tblDict $suffix txview]
        $tview delete 1.0 end
        set tblhistory [dict get $tblDict $suffix tblhistory]
        set sql [string trim [$tedit get 1.0 end]]
        set last [string last ";" $sql]
        set sql [lrange [split [string range $sql 0 end] ";" ] 0 end-1]
        puts [llength $sql]
        puts $sql
        $tblhistory insert end [list [clock format [clock sec] -format %Y-%m-%d,%H:%M:%S] $suffix "[join $sql ";"];"]
        listToreport  [sqlselectdb $dbconnS {*}$sql ""] $tview
      }
      dictview {
        set tview [dict get $tblDict $suffix txview]
        $tview delete 1.0 end
        dictToreportwidget $tview [dict get $tblDict $suffix]
        $tview insert end "\n\n"
        dictToreportwidget $tview $tblDict
      }
    }
    set wid [dict get $tblDict $suffix txedit]
  }

  proc OnComboSelected {w tbl type} {
    variable dbconnS
    variable tblDict
    switch $type {
      selectmode {
        $tbl configure -selectmode [$w get]
      }
      sortID {
        dict set tblDict tbloptions sortID [$w get]
        foreach v [$w cget -values] {
          $tbl header cellconfigure 0,$v -background ""
        }
        $tbl header cellconfigure 0,[$w get] -background red
      }
      sortModus {
        dict set tblDict tbloptions sortModus [$w get]
      }
    }
    #onTableChanged $tbl
  }

  proc tblInsert {tbl rows} {
    $tbl insertlist end $rows
  }
  # menu in work
  #start
  proc bindwid  {} {
    uplevel {
      set bodyTag [$tbl bodytag]
      bind $bodyTag <3> [list [namespace current]::postPopupMenu %X %Y %W %x %y]
    }
  }
  proc postPopupMenu {rootX rootY W x y args} {
    set tbl [tablelist::getTablelistPath $W]
    set row [$tbl curselection]
    set cell [$tbl curcellselection]
    puts "cell: $cell row $row X $rootX Y $rootY x $x $y $args wpx [winfo pointerx .] [winfo pointery .]"
  }
  proc menuTable {tbl args} {
    set popupE [menu $tbl.popupE]
    $popupE add command -label "hallo $args" -command [list [namespace current]::tblcallback $tbl  $args]
    $popupE add separator
    return $popupE
  }
  #end

  proc sqlselectdb {dbconn sqlstmt query_values} {
    set stmt [$dbconn prepare $sqlstmt]
    set rows {}
    try {
      set res [$stmt execute $query_values]
      try {
        while {[$res nextlist row]} {
          lappend rows $row
        }
      } finally {
        $res close
      }
    } finally {
      $stmt close
    }
    return $rows
  }

  proc generateCols {tableInfo} {
    set cols {}
    set liste [list INTEGER]
    foreach {colName colAttrs} $tableInfo {
      if {[dict get $colAttrs type] in $liste} {
        set dir right
      } else {
        set dir left
      }
      lappend cols 0 $colName $dir
    }
    return $cols
  }

  #create ttbl
  # cols: width name dir

  proc datatable {tblname db tbltype {w toplevel}} {
    set cols [generateCols [dict get  [infoDB $db] $tbltype $tblname]]
    if {$w eq "toplevel"} {
      set top [toplevel .top${tblname}]
    } else {
      set top [ttk::frame $w.f${tblname}]

      $w  add $top -text $tblname
    }

    set tbl [tblCreate $top $cols $tblname $tbltype]
    # insert data
    set sqlstmt [subst -nocommands {SELECT * FROM $tblname}]
    #set query_values [dict create tblname $tblname]
    set query_values {}
    set rows [sqlselectdb $db $sqlstmt $query_values]
    tblInsert $tbl $rows

  }

  proc createdatatable {tbltype db nb } {
    foreach name [dict keys [dict get  [infoDB $db] $tbltype]] {
      datatable $name $db $tbltype $nb
    }
  }

  proc tabChanged {w args} {
    #  puts $args
    #  puts [$w index current]
    #  puts [$w tab current -text]
    #  puts [$w select]
  }

  proc maingui {{w .}} {
    #   variable dvar
    # Prüfe, ob das Widget bereits existiert und lösche es, falls notwendig
    if {[winfo exists ${w}.frmain]} {
      destroy ${w}.frmain
    }

    set frmain [ttk::frame ${w}.frmain -width 400 -height 500 -relief sunken]
    set frtop [ttk::frame $frmain.frame_top -width 400 -height 50 -relief sunken]
    set pwhb [ttk::panedwindow $frmain.paned_horizontal -orient horizontal]
    set pwvl [ttk::panedwindow $pwhb.paned_vertical_left -orient vertical]
    set pwvr [ttk::panedwindow $pwhb.paned_vertical_right -orient vertical]

    set frame_left_top [ttk::frame $pwvl.frame_left_top -width 50 -height 50 -relief sunken]
    set frame_left_bottom [ttk::frame $pwvl.frame_left_bottom -width 50 -height 150 -relief sunken]
    set frame_right_top [ttk::frame $pwvr.frame_right_top -width 40 -height 50 -relief sunken]
    set frame_right_bottom [ttk::frame $pwvr.frame_right_bottom -width 40 -height 150 -relief sunken]

    $pwvl add $frame_left_top
    $pwvl add $frame_left_bottom
    $pwvr add $frame_right_top
    $pwvr add $frame_right_bottom
    $pwhb add $pwvl
    $pwhb add $pwvr

    pack $frtop -side top -expand 0 -fill x
    pack $pwhb -side top -expand 1 -fill both
    pack $frmain -fill both -expand yes

    dict set d widgets frame_top $frtop
    dict set d widgets frame_left_top $frame_left_top
    dict set d widgets frame_left_bottom $frame_left_bottom
    dict set d widgets frame_right_top $frame_right_top
    dict set d widgets frame_right_bottom $frame_right_bottom
    dict set dvar main_window $d
    return $dvar
  }

  set dbconnS $::dbconnS

  set dvar [maingui]
  puts $dvar
  set w [dict get $dvar main_window widgets frame_right_top]

  set nb  [ttk::notebook $w.nb]
  pack $nb -side top -expand 1 -fill both
  #pack [text $w.text -height 10] -side top -expand 1 -fill both

  set ::treetbl [treetblcreate [dict get $dvar main_window widgets frame_left_top]]
  dict set treeDict treetbl $treetbl

  # Addd tables to the notebook
  createdatatable tablelist $dbconnS $nb

  # Add views to the notebook
  createdatatable viewlist $dbconnS $nb

  ttk::notebook::enableTraversal $nb
  populateTree $treetbl [infoDB $dbconnS]
  bind $nb <<NotebookTabChanged>> [list [namespace current]::tabChanged %W]
  #puts infoDb
  #puts [dict keys [infoDB db]]
  #puts [dict keys [dict get  [infoDB db] tablelist]]
  #puts [dict keys [dict get  [infoDB db] tablelist artikel]]
  #puts [dict get  [infoDB db] tablelist artikel]

}



