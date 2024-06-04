#! /usr/bin/env tclsh

#20240604
package require Tk
package require vfs::zip
package require fileutil
package require md5
package require zipfile::decode
package require zipfile::encode
package require zipfile::mkzip

#https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/fileutil/fileutil.md
proc copydirectory {srcdir dstdir} {
    # Ensure the source directory exists
    if {![file exists $srcdir]} {
        error "Source directory $srcdir does not exist"
    }
    # Create the destination directory if it does not exist
    if {![file exists $dstdir]} {
        file mkdir $dstdir
    }
    # Get the list of all files and directories in the source directory
    set entries [fileutil::find $srcdir]
    # Iterate over each entry and copy it to the destination directory
    foreach entry $entries {
        set relpath [fileutil::stripPath $srcdir $entry]
        set dest [file join $dstdir $relpath]
        if {[file isdirectory $entry]} {
            # Create the directory in the destination path
            file mkdir $dest
        } else {
            # Copy the file to the destination path
            file copy -force $entry $dest
        }
    }
}


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
    file mkdir [file join $sourcedir data01]
    file mkdir [file join $sourcedir data01 data11]
    file mkdir [file join $sourcedir data02]
    ::fileutil::touch  [file join $sourcedir testfile01.txt]
    ::fileutil::touch  [file join $sourcedir testfile02.txt]
    ::fileutil::touch  [file join $sourcedir data01 testfile11.txt]
    ::fileutil::touch  [file join $sourcedir data01 testfile12.txt]
    lappend res [join [glob -nocomplain -directory [file join $sourcedir ] {*}] \n]
    lappend res [join [glob -nocomplain -directory [file join $sourcedir data01] {*}] \n]
    lappend res [join [glob -nocomplain -directory [file join $sourcedir data02] {*}] \n]
    return [join $res \n]
}
# extern: zip
proc filetoExternZip {sourcedir zipdir} {
    lappend res [makeTestfile $sourcedir]
    lappend res " \n"
    lappend res "extern zip \n"


    set pwd [pwd]
    cd [file join $sourcedir]

    file mkdir $zipdir
    file delete -force [file join $zipdir testall.zip]
    set cmd  [list zip -v -r [file join $zipdir testall.zip] . -i *]
    lappend res cmd1 [exec {*}$cmd]

    file delete -force [file join $zipdir testfile01.zip]
    set cmd  [list zip -v -r -D [file join $zipdir testfile01.zip] . -i testfile01.txt]
    lappend res \n
    lappend res cmd2 [exec {*}$cmd]

    lappend res \n
    cd $pwd
    return $res
}

# empty directories missing
proc filetoMkZip {sourcedir zipdir} {
    lappend res [makeTestfile $sourcedir]
    lappend res " \n"
    lappend res "mkzip \n"

    file mkdir $zipdir
    file delete -force [file join $zipdir testall.zip]
    set zipfile [file join $zipdir testall.zip]
    set options [list -directory [file join $sourcedir]]
    lappend res [::zipfile::mkzip::mkzip $zipfile {*}$options]

    file delete -force  [file join $zipdir testfile01.zip]
    set zipfile [file join $zipdir testfile01.zip]
    if {0} {
        set file_to_zip [file join $sourcedir testfile01.txt]
        set tempdir [::fileutil::maketempdir]
        set temp_file [file join $tempdir testfile01.txt]
        file copy -force $file_to_zip $temp_file
        set options [list -directory [file join $tempdir] testfile01.txt]
        ::zipfile::mkzip::mkzip $zipfile {*}$options
        file delete -force $tempdir
    } else {
        set pwd [pwd]
        cd [file join $sourcedir]
        set options [list testfile01.txt]
        ::zipfile::mkzip::mkzip $zipfile {*}$options
        cd $pwd
    }
    return $res
}

#empty directories missing
proc filetoZipFile {sourcedir zipdir} {
    lappend res [makeTestfile $sourcedir]
    lappend res " \n"
    lappend res "fileToZipFile $sourcedir \n"

    file mkdir $zipdir
    file delete -force [file join $zipdir testall.zip]

    # Create the zipfile::encode object
    set zip [zipfile::encode create myZipEncoder]
    lappend res "\nzip: $zip "

    # Use fileutil::find to get a list of all files in the source directory
    set files [fileutil::find $sourcedir]
    puts $files
    # Iterate over the list of files and add them to the ZIP file
    foreach file $files {
        if {[file isdirectory $file]} {
            puts "dir file: $file"
            set relpath [file tail $file]
            puts "dir relpath: $relpath"
            $zip file: $relpath 0 {} 0
            continue
        } else {
            set relpath [fileutil::stripPath $sourcedir $file]
            puts "file: $file"
            puts "relpath: $relpath"
            $zip file: $relpath 0 $file
        }
    }

    # Write the ZIP file
    $zip write [file join $zipdir testall.zip]
    lappend res [$zip destroy]

    # Now create a ZIP with only testfile01.txt
    file delete -force [file join $zipdir testfile01.zip]
    set zip [zipfile::encode create myZipEncoder]
    lappend res "\nzip: $zip "
    set single_file [file join $sourcedir testfile01.txt]
    $zip file: "testfile01.txt" 0 $single_file
    $zip write [file join $zipdir testfile01.zip]
    lappend res [$zip destroy]
    return $res
}





proc vfsziptofiles {openfilename targetdir {select 3}} {
    # manual options 1 - 4
    # 1 file.zip == mount
    # 2 file.zip != mount
    # 3 file.zip == mount, singlefile
    # 4 file.zip != mount
    lappend res " \n"
    lappend res "\n Seletcetion_${select}_$openfilename"
    switch $select {
        1 {
            set mnt_file [vfs::zip::Mount $openfilename $openfilename]
            lappend res  [join [glob -directory $openfilename {*}] \n]
            copydirectory $openfilename $targetdir
            vfs::zip::Unmount $mnt_file $openfilename
        }
        2  {
            set mnt_file [vfs::zip::Mount $openfilename /_zipfile]
            cd /_zipfile
            lappend res  [join [glob -directory /_zipfile {*}] \n]
            copydirectory /_zipfile $targetdir
            vfs::zip::Unmount $mnt_file /_zipfile
        }
        3 {
            set singleFile testfile02.txt
            set mnt_file [vfs::zip::Mount $openfilename $openfilename]
            set zfile [glob -tails -directory $openfilename $singleFile]
            lappend res  "zfile: $zfile "
            lappend res   [join [glob -tails -directory $openfilename *] \n]
            file mkdir [file dirname [file join $targetdir $zfile]]
            file copy -force [file join $openfilename $zfile] [file join $targetdir $zfile]
            vfs::zip::Unmount $mnt_file $openfilename
        }
        4 {
            set singleFile testfile02.txt
            set mnt_file [vfs::zip::Mount $openfilename /_zipfile]
            set zfile [glob -tails -directory /_zipfile $singleFile]
            lappend res  "zfile: $zfile"
            lappend res  [join [glob -tails -directory /_zipfile *] \n]
            file mkdir [file dirname [file join $targetdir $zfile]]
            file copy -force [file join /_zipfile $zfile] [file join $targetdir $zfile]
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
proc callbVfs {w tlog sourcedir targetdir zipdir} {
    set select [$w get]
    set openfilename [tk_getOpenFile -initialdir $zipdir]
    if {$openfilename eq ""} {
        puts "No File select."
        return
    }
    set res [vfsziptofiles $openfilename $targetdir $select]

    $tlog insert end "[join $res \n]"
    $tlog insert end "\n \n"
    $tlog insert end  [filetimes [file join $targetdir] testfile01.txt]

    return
}
proc callbMakeExternZip {tlog sourcedir zipdir} {
    set res [filetoExternZip $sourcedir $zipdir]

    $tlog insert end \n
    $tlog insert end  $res\n
    $tlog insert end  [filetimes [file join $sourcedir] testfile01.txt]\n\n

    return
}
proc callbZipfile {tlog sourcedir targetdir zipdir} {
    set openfilename [tk_getOpenFile -initialdir $zipdir]
    if {$openfilename eq ""} {
        puts "No file select."
        return
    }
    set res [zipfiletofiles $openfilename $targetdir]

    $tlog insert end "[join $res \n]"
    $tlog insert end "\n \n"
    $tlog insert end  [filetimes [file join $targetdir] testfile01.txt]

    return
}
proc callbMakezipfile {tlog sourcedir zipdir} {
    set res [filetoZipFile $sourcedir $zipdir]

    $tlog insert end \n
    $tlog insert end  $res\n
    $tlog insert end  [filetimes [file join $sourcedir] testfile01.txt]\n\n

    return
}

proc callbMakemkzip {tlog sourcedir zipdir} {
    set res [filetoMkZip $sourcedir $zipdir]

    $tlog insert end \n
    $tlog insert end  $res\n
    $tlog insert end  [filetimes [file join $sourcedir] testfile01.txt]\n\n

    return
}

proc callbReset {tlog  sourcedir targetdir zipdir} {
    $tlog delete 1.0 end
    $tlog insert end " [info patchlevel] :: [info nameofexecutable] :: $::tcl_platform(os) \n"
    $tlog insert end " vfs: [package version vfs] :: vfs::zip: [package version vfs::zip] ::"
    $tlog insert end " zipfile::encode: [package version zipfile::encode] :: zipfile::mkzip: [package version zipfile::mkzip]\n "
    $tlog insert end " sourcedir: $sourcedir\n"
    $tlog insert end " targetdir: $targetdir\n"
    $tlog insert end " zipdir: $zipdir\n"
    $tlog insert end "  \n"
    file delete -force $sourcedir
    file delete -force $targetdir
    file delete -force $zipdir

}

proc callbDir {dirname} {
    eval exec {*}[auto_execok xdg-open] $dirname &
}

###################################
#Main

#init
set dirname [file dirname [info script]]
set sourcedir [file join $dirname source]
set targetdir [file join $dirname target]
set zipdir [file join $dirname zipdir]

file mkdir $zipdir

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
set cbVfsSelect [ttk::combobox $frbtn.cb -value [list 1 2 3 4 5] -width 3]
$cbVfsSelect current 0

ttk::button $frbtn.btnvfszip -text "vfs::zip" -command [list callbVfs $cbVfsSelect $tlog $sourcedir $targetdir $zipdir]
ttk::button $frbtn.btnmakeExternZip -text "Make Extern zip" -command  [list callbMakeExternZip  $tlog $sourcedir $zipdir]
ttk::button $frbtn.btnzibfile -text "zipfile::decode" -command  [list callbZipfile  $tlog $sourcedir $targetdir $zipdir]
ttk::button $frbtn.btnmakezipfile -text "Make zipfile" -command  [list callbMakezipfile  $tlog  $sourcedir $zipdir]
ttk::button $frbtn.btnmakemkzip -text "Make mkzip" -command  [list callbMakemkzip  $tlog  $sourcedir $zipdir]
ttk::button $frbtn.btntreset -text "tlog and delete dirs" -command [list callbReset $tlog $sourcedir $targetdir $zipdir]
ttk::button $frbtn.btndir -text "Dir" -command [list callbDir $dirname]

pack $frbtn -side top -expand 0 -fill x
pack $lbVfsselect $cbVfsSelect $frbtn.btnvfszip $frbtn.btnzibfile $frbtn.btnmakeExternZip $frbtn.btnmakezipfile  \
$frbtn.btnmakemkzip $frbtn.btntreset $frbtn.btndir -side left -expand 0
pack $frt -expand 1 -fill both -side bottom

$tlog delete 1.0 end
$tlog insert end " [info patchlevel] :: [info nameofexecutable] :: $::tcl_platform(os) \n"
$tlog insert end " vfs: [package version vfs] :: vfs::zip: [package version vfs::zip] ::"
$tlog insert end " zipfile::encode: [package version zipfile::encode] :: zipfile::mkzip: [package version zipfile::mkzip]\n "
$tlog insert end " sourcedir: $sourcedir\n"
$tlog insert end " targetdir: $targetdir\n"
$tlog insert end " zipdir: $zipdir\n"
$tlog insert end "  \n"