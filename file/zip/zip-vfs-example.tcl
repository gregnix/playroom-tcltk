#! /usr/bin/env tclsh

#20240602
package require Tk
package require vfs::zip
package require fileutil
package require md5
package require zipfile::decode
package require zipfile::encode
package require zipfile::mkzip

# for debug
proc filetimes {path item} {
    set md5 [md5::md5 -hex -file [file join $path $item]]
    file stat [file join $path $item] stat
    set atime  [clock format $stat(atime)]
    set ctime  [clock format $stat(ctime)]
    set mtime  [clock format $stat(mtime)]
    return [join [list $item $path atime_ctime_mtime $atime $ctime $mtime $md5] \n]
}
# making testfiles and directories
proc makeTestfile {sourcedir} {
    #make testfile
    lappend res " \n"
    lappend res "Maketestfile\n"
    file mkdir [file join $sourcedir tmpzip data1]
    file mkdir [file join $sourcedir tmpzip data2]
    ::fileutil::touch  [file join $sourcedir tmpzip testfile01.txt]
    ::fileutil::touch  [file join $sourcedir tmpzip testfile02.txt]
    ::fileutil::touch  [file join $sourcedir tmpzip data1 testfile11.txt]
    ::fileutil::touch  [file join $sourcedir tmpzip data1 testfile12.txt]
    lappend res [join [glob -nocomplain -directory [file join $sourcedir tmpzip] {*}] \n]
    lappend res [join [glob -nocomplain -directory [file join $sourcedir tmpzip data1] {*}] \n]
    lappend res [join [glob -nocomplain -directory [file join $sourcedir tmpzip data2] {*}] \n]
    return [join $res \n]
}
# extern: zip
proc filetoExternZip {sourcedir} {
    lappend res [makeTestfile $sourcedir]
    lappend res " \n"
    lappend res "extern zip \n"
    # extern zip from Linux
    set pwd [pwd]
    cd [file join $sourcedir tmpzip]
    file delete -force ../testall.zip
    file delete -force ../testfile01.zip
    set cmd  [list zip -v -r ../testall.zip . -i *]
    lappend res cmd1 [exec {*}$cmd]
    set cmd  [list zip -v -r -D ../testfile01.zip . -i testfile01.txt]
    lappend res \n
    lappend res cmd2 [exec {*}$cmd]
    lappend res \n
    cd $pwd

    return $res
}
proc filetoMkZip {sourcedir} {
    lappend res [makeTestfile $sourcedir]
    lappend res " \n"
    lappend res "mkzip \n"

    file delete -force  [file join $sourcedir testall.zip]
    set zipfile [file join $sourcedir "testall.zip"]
    set options [list -directory [file join $sourcedir tmpzip]]
    lappend res [::zipfile::mkzip::mkzip $zipfile {*}$options]

    file delete -force  [file join $sourcedir testfile01.zip]
    set zipfile [file join $sourcedir "testfile01.zip"]
    set file_to_zip [file join $sourcedir tmpzip testfile01.txt]
    set tempdir [fileutil::tempdir mkzip]
    set temp_file [file join $tempdir testfile01.txt]
    file copy -force $file_to_zip $temp_file
    set options [list -directory [file join $tempdir]  testfile01.txt]
    #set options [list  -directory [file join $sourcedir tmpzip] -exclude {*} [file join $sourcedir tmpzip testfile01.txt]]
    #set options [list -directory [file join $sourcedir tmpzip] -exclude {d* *02.txt}]
    #set options [list  [file join $sourcedir tmpzip testfile01.txt]]
    ::zipfile::mkzip::mkzip $zipfile {*}$options
    file delete -force $tempdir

    return $res
}
proc filetoZipFile {sourcedir} {
    lappend res [makeTestfile $sourcedir]
    lappend res " \n"
    lappend res "fileToZipFile $sourcedir \n"

    file delete -force  [file join $sourcedir testall.zip]
    set zip [zipfile::encode create myZipEncoder]
    lappend res "\nzip: $zip "
    $zip file: "testfile01.txt" 0 "[file join $sourcedir tmpzip testfile01.txt]"
    $zip file: "testfile02.txt" 0 "[file join $sourcedir tmpzip testfile02.txt]"
    $zip file: "data1/testfile11.txt" 0 "[file join $sourcedir tmpzip data1 testfile11.txt]"
    $zip file: "data1/testfile12.txt" 0 "[file join $sourcedir tmpzip data1 testfile12.txt]"
    #$zip file: "data2/" 0 "[file join $sourcedir tmpzip data2/ ]"
    $zip write "[file join $sourcedir testall.zip]"
    lappend res [$zip destroy]

    file delete -force  [file join $sourcedir testfile01.zip]
    set zip [zipfile::encode create myZipEncoder]
    lappend res "\nzip: $zip "
    $zip file: "testfile01.txt" 0 "[file join $sourcedir tmpzip testfile01.txt]"
    $zip write "[file join $sourcedir testfile01.zip]"
    lappend res [$zip destroy]
    return $res
}

proc vfsziptofiles {openfilename targetdir dirname  {select 3}} {
    # manual options 1 - 4
    # 1 change in mounted dir, file.zip == mount
    # 2 change in mounted dir, file.zip != mount
    # 3 file.zip == mount
    # 4 file.zip != mount
    lappend res " \n"
    lappend res "\n Seletcetion_${select}_$openfilename"
    switch $select {
        1 {
            set mnt_file [vfs::zip::Mount $openfilename $openfilename]
            cd $openfilename
            set zfiles [glob *]
            lappend res  "zfiles: $zfiles :: pwd : [pwd]"
            lappend res  [join [glob -directory $dirname {*}] \n]
            foreach zfile $zfiles {
                file copy -force $zfile [file join $targetdir $zfile]
            }
            cd ..
            vfs::zip::Unmount $mnt_file $openfilename
        }
        2  {
            set mnt_file [vfs::zip::Mount $openfilename /_zipfile]
            cd /_zipfile
            set zfiles [glob *]
            lappend res  "zfiles: $zfiles :: pwd : [pwd]"
            lappend res  [join [glob -directory $dirname {*}] \n]
            foreach zfile $zfiles {
                file copy -force $zfile [file join $targetdir $zfile]
            }
            cd ..
            vfs::zip::Unmount $mnt_file /_zipfile
        }
        3 {
            set mnt_file [vfs::zip::Mount $openfilename $openfilename]
            set zfiles [glob $openfilename/*]
            lappend res  "zfiles: $zfiles :: pwd : [pwd]"
            lappend res   [join [glob -directory $dirname {*}] \n]
            foreach zfile $zfiles {
                file copy -force $zfile [file join $targetdir [file tail $zfile]]
            }
            vfs::zip::Unmount $mnt_file $openfilename
        }
        4 {
            set mnt_file [vfs::zip::Mount $openfilename /_zipfile]
            set zfiles [glob /_zipfile/*]
            lappend res  "zfiles: $zfiles :: pwd : [pwd]"
            lappend res  [join [glob -directory $dirname {*}] \n]
            foreach zfile $zfiles {
                file copy -force $zfile [file join $targetdir [file tail $zfile]]
            }
            vfs::zip::Unmount $mnt_file /_zipfile
        }
    }
    return $res
}
proc zipfiletofiles {openfilename targetdir} {
    lappend res " \n"
    lappend res "\n zipfiletofiles"
    lappend res [::zipfile::decode::open $openfilename]
    set dArchive [::zipfile::decode::archive]
    lappend res [::zipfile::decode::files $dArchive]
    lappend res [::zipfile::decode::unzip $dArchive $targetdir]
    lappend res [::zipfile::decode::close]
    return $res

}
# callback s
proc callbVfs {w t dirname opendir sourcedir targetdir} {
    set select [$w get]
    set openfilename [tk_getOpenFile -initialdir $opendir]
    if {$openfilename eq ""} {
        puts "No File select."
        return
    }
    set openfiledirname [file dirname $openfilename]
    set openfile [file tail $openfilename]
    set res [vfsziptofiles $openfilename $targetdir $dirname  1]

    $t insert end "[join $res \n]"
    $t insert end "\n \n"
    $t insert end  [filetimes [file join $targetdir] testfile01.txt]

    return
}
proc callbMakeExternZip { t sourcedir} {
    set res [filetoExternZip $sourcedir]

    $t insert end \n
    $t insert end  $res\n
    $t insert end  [filetimes [file join $sourcedir tmpzip] testfile01.txt]\n\n

    return
}
proc callbZipfile { t dirname opendir sourcedir targetdir} {
    set openfilename [tk_getOpenFile -initialdir $opendir]
    if {$openfilename eq ""} {
        puts "No file select."
        return
    }
    set openfiledirname [file dirname $openfilename]
    set openfile [file tail $openfilename]
    set res [zipfiletofiles $openfilename $targetdir]

    $t insert end "[join $res \n]"
    $t insert end "\n \n"
    $t insert end  [filetimes [file join $targetdir] testfile01.txt]

    return
}
proc callbMakezipfile { t sourcedir} {
    set res [filetoZipFile $sourcedir]

    $t insert end \n
    $t insert end  $res\n
    $t insert end  [filetimes [file join $sourcedir tmpzip] testfile01.txt]\n\n

    return
}

proc callbMakemkzip { t sourcedir} {
    set res [filetoMkZip $sourcedir]

    $t insert end \n
    $t insert end  $res\n
    $t insert end  [filetimes [file join $sourcedir tmpzip] testfile01.txt]\n\n

    return
}

###################################
#Main

#init
set dirname [file dirname [info script]]
set opendir [file join $dirname source]
set sourcedir [file join $dirname source]
set targetdir [file join $dirname target]

#Gui
set frbtn [ttk::frame .frbtn]
set frt [ttk::frame .frt]

#tlog
set tlog [text $frt.t -setgrid true -wrap none -width 120 \
-yscrollcommand "$frt.vset set" -xscrollcommand "$frt.hset set"]
scrollbar $frt.vset -orient vert -command "$tlog yview"
scrollbar $frt.hset -orient hori -command "$tlog xview"
pack $frt.hset -side bottom -fill x
pack $frt.vset -side right -fill y
pack $tlog -side left -fill both -expand true

set lbVfsselect [ttk::label $frbtn.lb -text "vfs::zip Mount handling: "]
set cbVfsSelect [ttk::combobox $frbtn.cb -value [list 1 2 3 4] -width 3]
$cbVfsSelect current 0

ttk::button $frbtn.btnvfszip -text "vfs::zip" -command [list callbVfs $cbVfsSelect $tlog $dirname $opendir $sourcedir $targetdir]
ttk::button $frbtn.btnmakeExternZip -text "Make Extern zip" -command  [list callbMakeExternZip  $tlog  $sourcedir]
ttk::button $frbtn.btnzibfile -text "zipfile::decode" -command  [list callbZipfile  $tlog  $dirname $opendir $sourcedir $targetdir]
ttk::button $frbtn.btnmakezipfile -text "Make zipfile" -command  [list callbMakezipfile  $tlog  $sourcedir]
ttk::button $frbtn.btnmakemkzip -text "Make mkzip" -command  [list callbMakemkzip  $tlog  $sourcedir]
ttk::button $frbtn.btntreset -text "tlog clean" -command [list $tlog delete 1.0 end]
pack $frbtn -side top -expand 0 -fill x
pack  $lbVfsselect $cbVfsSelect $frbtn.btnvfszip $frbtn.btnzibfile $frbtn.btnmakeExternZip $frbtn.btnmakezipfile  $frbtn.btnmakemkzip $frbtn.btntreset -side left -expand 0
pack $frt -expand 1 -fill both -side bottom
$tlog insert end " dirname: $dirname\n"
$tlog insert end " opendir: $opendir\n"
$tlog insert end " sourcedir: $sourcedir\n"
$tlog insert end " targetdir: $targetdir\n"
$tlog insert end "  \n"
