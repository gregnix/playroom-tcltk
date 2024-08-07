namespace eval tvlib {
  proc band {tree {parent {}} {i 0} {j 0}} {
    # u j not in use
    if {0} {
      if {$j} {
        set j 0
      } else {
        set j 1
      }
    }
    foreach item [$tree children $parent] {
      #set d [tvlib::itemdepth $tree $item]
      #set e [expr {$d % 2}]
      set t [expr {$i % 2}]
      #set u [expr {($i / 2) % 2}]
      $tree tag remove band0 $item
      $tree tag remove band1 $item
      #$tree tag remove band00 $item
      #$tree tag remove band10 $item
      #$tree tag remove band10 $item
      #$tree tag remove band11 $item
      #puts "i $i t: $t u: $u j: $j [$tree item $item -text] band$t$j band$u$j d: $d  e: $e"
      $tree tag add band$t $item
      #$tree tag add band$t $item
      incr i
      set i [band $tree $item $i $j]
    }
    return $i
  }

  proc bandInit {tree {color0 #FFFFFF} {color1 #E0E0E0} {color2 #DDEEFF} {color3 #B0C4DE}} {
    $tree tag configure band0 -background $color0
    $tree tag configure band1 -background $color1
    #$tree tag configure band00 -background $color0
    #$tree tag configure band01 -background $color1
    #$tree tag configure band10 -background $color2
    #$tree tag configure band11 -background $color3
    bind $tree <<TVItemsChanges>> [list [namespace current]::band $tree]
  }

  proc bandEvent {tree} {
    event generate $tree <<TVItemsChanges>> -data [$tree selection]
  }
}

namespace eval tvlib {
  proc treesize {tree {p {}}} {
    set size 0
    foreach c [$tree children $p] {
      incr size [llength $c]
      incr size [treesize $tree $c]
    }
    return $size
  }

  proc treedepth {tree {parent {}} {depth 0}} {
    set max $depth
    foreach item [$tree children $parent] {
      set currentDepth [treedepth $tree $item [expr {$depth + 1}]]
      if {$currentDepth > $max} {
        set max $currentDepth
      }
    }
    return $max
  }
  proc itemdepth {tree item} {
    set depth 0
    while {$item ne ""} {
      set item [$tree parent $item]
      incr depth
    }
    return $depth
  }


}









