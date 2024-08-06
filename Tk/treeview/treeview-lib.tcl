namespace eval tvlib {
  proc band {tree {parent {}} {i 0}} {
    foreach item [$tree children $parent] {
      set t [expr {$i % 2}]
      $tree tag remove band0 $item
      $tree tag remove band1 $item
      $tree tag add band$t $item
      incr i
      set i [band $tree $item $i]
    }
    return $i
  }

  proc band_init {tree {color0 #FFFFFF} {color1 #F0F0F0}} {
    $tree tag configure band0 -background $color0
    $tree tag configure band1 -background $color1
    bind $tree <<TVItemsChanges>> [list [namespace current]::band $tree]
  }

  proc band_event {tree} {
    event generate $tree <<TVItemsChanges>> -data [$tree selection]
  }
}









