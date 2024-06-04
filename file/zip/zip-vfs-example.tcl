#! /usr/bin/env tclsh

#20240604
package require Tk
package require vfs::zip
package require fileutil
package require md5
package require zipfile::decode
package require zipfile::encode
package require zipfile::mkzip

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
proc filetoExternZip {sourcedir zipdir singlefile} {
    lappend res [makeTestfile $sourcedir]
    lappend res " \n"
    lappend res "extern zip \n"

    set pwd [pwd]
    cd [file join $sourcedir]

    file mkdir $zipdir
    file delete -force [file join $zipdir testall.zip]
    set cmd  [list zip -v -r [file join $zipdir testall.zip] . -i *]
    lappend res cmd1 [exec {*}$cmd]

    set singlezip [string map {.txt .zip} $singlefile]
    file delete -force [file join $zipdir $singlezip]
    set cmd  [list zip -v -r -D [file join $zipdir $singlezip] . -i $singlefile]
    lappend res \n
    lappend res cmd2 [exec {*}$cmd]

    lappend res \n
    cd $pwd
    return $res
}

# empty directories missing
proc filetoMkZip {sourcedir zipdir singlefile} {
    lappend res [makeTestfile $sourcedir]
    lappend res " \n"
    lappend res "mkzip \n"

    file mkdir $zipdir
    file delete -force [file join $zipdir testall.zip]
    set zipfile [file join $zipdir testall.zip]
    set options [list -directory [file join $sourcedir]]
    lappend res [::zipfile::mkzip::mkzip $zipfile {*}$options]

    set singlezip [string map {.txt .zip} $singlefile]
    file delete -force [file join $zipdir $singlezip]
    set zipfile [file join $zipdir $singlezip]
    set pwd [pwd]
    cd [file join $sourcedir]
    set options [list $singlefile]
    ::zipfile::mkzip::mkzip $zipfile {*}$options
    cd $pwd

    return $res
}

#empty directories missing
proc filetoZipFile {sourcedir zipdir singlefile} {
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
    # Iterate over the list of files and add them to the ZIP file
    foreach file $files {
        if {[file isdirectory $file]} {
            set relpath [file tail $file]
            $zip file: $relpath 0 {} 0
            # problem empty dir
            continue
        } else {
            set relpath [fileutil::stripPath $sourcedir $file]
            $zip file: $relpath 0 $file
        }
    }

    # Write the ZIP file
    $zip write [file join $zipdir testall.zip]
    lappend res [$zip destroy]

    # Now create a ZIP with only testfile01.txt
    set singlezip [string map {.txt .zip} $singlefile]
    file delete -force [file join $zipdir $singlezip]
    set zip [zipfile::encode create myZipEncoder]
    lappend res "\nzip: $zip "
    set single_file [file join $sourcedir $singlefile]
    $zip file: "$singlefile" 0 $single_file
    $zip write [file join $zipdir $singlezip]
    lappend res [$zip destroy]
    return $res
}

proc vfsziptofiles {openfilename targetdir singlefile {select 3}} {
    # manual options 1 - 4
    # 1 file.zip == mount
    # 2 file.zip != mount
    # 3 file.zip == mount,singlefile
    # 4 file.zip != mount singlefile
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
            set mnt_file [vfs::zip::Mount $openfilename $openfilename]
            set zfile [glob -tails -directory $openfilename $singlefile]
            lappend res  "zfile: $zfile "
            lappend res   [join [glob -tails -directory $openfilename *] \n]
            file mkdir [file dirname [file join $targetdir $zfile]]
            file copy -force [file join $openfilename $zfile] [file join $targetdir $zfile]
            vfs::zip::Unmount $mnt_file $openfilename
        }
        4 {
            set mnt_file [vfs::zip::Mount $openfilename /_zipfile]
            set zfile [glob -tails -directory /_zipfile $singlefile]
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
# callback
proc callbVfs {w tlog sourcedir targetdir zipdir singlefile} {
    set select [$w get]
    set openfilename [tk_getOpenFile -initialdir $zipdir]
    if {$openfilename eq ""} {
        puts "No File select."
        return
    }
    set res [vfsziptofiles $openfilename $targetdir $singlefile $select]

    $tlog insert end "[join $res \n]"
    $tlog insert end "\n \n"
    $tlog insert end  [filetimes [file join $targetdir] $singlefile]

    return
}

proc callbZipfile {tlog sourcedir targetdir zipdir singlefile} {
    set openfilename [tk_getOpenFile -initialdir $zipdir]
    if {$openfilename eq ""} {
        puts "No file select."
        return
    }
    set res [zipfiletofiles $openfilename $targetdir]

    $tlog insert end "[join $res \n]"
    $tlog insert end "\n \n"
    $tlog insert end  [filetimes [file join $targetdir] $singlefile]

    return
}

# Make zips
proc callbMakeZip {tlog type sourcedir zipdir singlefile} {
    switch $type {
        ExternZip {
            set res [filetoExternZip $sourcedir $zipdir $singlefile]
        }
        ZipFile {
            set res [filetoZipFile $sourcedir $zipdir $singlefile]
        }
        MkZip {
            set res [filetoMkZip $sourcedir $zipdir $singlefile]
        }
    }

    $tlog insert end \n
    $tlog insert end  $res\n
    $tlog insert end  [filetimes [file join $sourcedir] $singlefile]\n\n

    return
}


proc callbReset {tlog  sourcedir targetdir zipdir singlefile} {
    $tlog delete 1.0 end
    $tlog insert end "  \n"
    file delete -force $sourcedir
    file delete -force $targetdir
    file delete -force $zipdir
}

proc callbDir {dirname} {
    switch $::tcl_platform(platform) {
        unix	{
            eval exec {*}[auto_execok xdg-open] $dirname &
        }
        windows	{
          eval exec  {*}[auto_execok start] $dirname &
        }
        macintosh	{
            
        }
    }
}

###################################
#Main

#init
set dirname [file dirname [info script]]
set sourcedir [file join $dirname source]
set targetdir [file join $dirname target]
set zipdir [file join $dirname zipdir]
set singlefile testfile02.txt
# mkdir
file mkdir $sourcedir
file mkdir $targetdir
file mkdir $zipdir

#Gui
#frames
set frbtn [ttk::frame .frbtn]
set frh [ttk::frame .frh]
set frt [ttk::frame .frt]

#tlog
set tlog [text $frt.t -setgrid true -wrap none -width 120 \
    -yscrollcommand "$frt.vset set" -xscrollcommand "$frt.hset set"]
scrollbar $frt.vset -orient vert -command "$tlog yview"
scrollbar $frt.hset -orient hori -command "$tlog xview"
pack $frt.hset -side bottom -fill x
pack $frt.vset -side right -fill y
pack $tlog -side left -fill both -expand true

# vfs handling
set lbVfsselect [ttk::label $frbtn.lb -text "vfs::zip Mount handling: "]
set cbVfsSelect [ttk::combobox $frbtn.cb -value [list 1 2 3 4 ] -width 3]
$cbVfsSelect current 0

ttk::button $frbtn.btnvfszip -text "vfs::zip" -command [list callbVfs $cbVfsSelect $tlog $sourcedir $targetdir $zipdir $singlefile]
ttk::button $frbtn.btnzibfile -text "zipfile::decode" -command  [list callbZipfile $tlog $sourcedir $targetdir $zipdir $singlefile]
ttk::button $frbtn.btnmakeExternZip -text "Make Extern zip" -command  [list callbMakeZip $tlog ExternZip $sourcedir $zipdir $singlefile]
ttk::button $frbtn.btnmakezipfile -text "Make zipfile" -command  [list callbMakeZip $tlog ZipFile $sourcedir $zipdir $singlefile]
ttk::button $frbtn.btnmakemkzip -text "Make mkzip" -command  [list callbMakeZip $tlog MkZip $sourcedir $zipdir $singlefile]
ttk::button $frbtn.btntreset -text "tlog and delete dirs" -command [list callbReset $tlog $sourcedir $targetdir $zipdir $singlefile]
ttk::button $frbtn.btndir -text "Dir" -command [list callbDir $dirname]

set thelp [text $frh.thelp -height 12]
pack $thelp -fill x -expand 1

pack $frbtn -side top -expand 0 -fill x
pack $lbVfsselect $cbVfsSelect $frbtn.btnvfszip $frbtn.btnzibfile $frbtn.btnmakeExternZip $frbtn.btnmakezipfile  \
    $frbtn.btnmakemkzip $frbtn.btntreset $frbtn.btndir -side left -expand 0
pack $frt -expand 1 -fill both -side bottom
pack $frh -expand 0 -fill x -side bottom


$thelp insert end "# $::tcl_platform(os) :: [info patchlevel] :: [info nameofexecutable]
# vfs: [package version vfs] :: vfs::zip: [package version vfs::zip] :: zipfile::encode: [package version zipfile::encode] :: zipfile::mkzip: [package version zipfile::mkzip]
# # vfs options 1 - 4
# 1 file.zip == mount
# 2 file.zip != mount
# 3 file.zip == mount,singlefile
# 4 file.zip != mount singlefile
# sourcedir: $sourcedir  -- makeTestfile
# targetdir: $targetdir -- vfsziptofiles, zipfiletofiles
# zipdir: $zipdir -- filetoExternZip, filetoZipFile, filetoMkZip
# singlefile: $singlefile
# zipfile and mkzip: no empty directoriesm but zip (extern)"


$thelp configure -state disabled


$tlog delete 1.0 end
$tlog insert end "  \n"