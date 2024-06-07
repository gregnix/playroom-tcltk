```

#set bodyTag [$tbl bodytag]
#bind $bodyTag <Double-1>   [list callbDouble1 %W %x %y]
proc callbDouble1 {W x y } {
    foreach {tbl x y} [tablelist::convEventFields $W $x $y] {}
    set row [$tbl containing  $y]
    set rows [$tbl curselection]
    set curcellselection [$tbl curcellselection]
    lappend  parentsRoot root [$tbl childkeys root]
    set parentkey [$tbl parentkey $row]
    set childcount [$tbl childcount $row]
    set childindex [$tbl childindex $row]
    set descendantcount [$tbl  descendantcount $row]
    set childkeys  [$tbl childkeys $parentkey]
    set depth [$tbl depth $parentkey]
    set noderow [$tbl noderow $parentkey $childindex]
    set childKindex [lindex $childkeys $childindex]
    set toplevelkey [$tbl toplevelkey $row]

    puts \n
    puts "tbl: $tbl :: W: $W :: row: $row :: rows : $rows :: noderow: $noderow ::"
    puts "parentsRoot: $parentsRoot ::  parentkey: $parentkey ::  descendantcount: $descendantcount"
    puts "childcount : $childcount :: childindex: $childindex :: childkeys: $childkeys :: depth : $depth"
}


proc populateTree {tbl} {
  # Einträge als Baumstruktur hinzufügen
    set root [$tbl insert end [list "Root" "" ""]]

    set folder1 [$tbl insertchild $root end [list "Ordner1" "" ""]]
    $tbl insertchild $folder1 end [list "Datei1.txt" "15KB" "2023-01-01"]
    $tbl insertchild $folder1 end [list "Datei2.txt" "20KB" "2023-01-02"]

    set folder2 [$tbl insertchild $root end [list "Ordner2" "" ""]]
    $tbl insertchild $folder2 end [list "Bild1.png" "2MB" "2023-01-03"]
    $tbl insertchild $folder2 end [list "Dokument1.docx" "45KB" "2023-01-04"]
}

```

### Output:
```
tbl: .main.tbl :: W: .main.tbl.body :: row: 0 :: rows : 0 :: noderow: 0 ::
parentsRoot: root k0 ::  parentkey: root ::  descendantcount: 6
childcount : 2 :: childindex: 0 :: childkeys: k0 :: depth : 0


tbl: .main.tbl :: W: .main.tbl.body :: row: 1 :: rows : 1 :: noderow: 1 ::
parentsRoot: root k0 ::  parentkey: k0 ::  descendantcount: 2
childcount : 2 :: childindex: 0 :: childkeys: k1 k4 :: depth : 1


tbl: .main.tbl :: W: .main.tbl.body :: row: 2 :: rows : 2 :: noderow: 2 ::
parentsRoot: root k0 ::  parentkey: k1 ::  descendantcount: 0
childcount : 0 :: childindex: 0 :: childkeys: k2 k3 :: depth : 2


tbl: .main.tbl :: W: .main.tbl.body :: row: 3 :: rows : 3 :: noderow: 3 ::
parentsRoot: root k0 ::  parentkey: k1 ::  descendantcount: 0
childcount : 0 :: childindex: 1 :: childkeys: k2 k3 :: depth : 2

```




