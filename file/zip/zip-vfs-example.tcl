#! /usr/bin/env tclsh


#20240601

package require Tk
package require vfs::zip
package require fileutil
package require md5
package require zipfile::decode

#https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/zip/decode.md
#https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/zip/encode.md
#https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/fileutil/fileutil.md
#https://wiki.tcl-lang.org/page/vfs%3A%3Azip
#https://wiki.tcl-lang.org/page/tclVFS+examples


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
# extern: zip
proc makeTestfiles {sourcedir} {
    #make testfiles and zip
    file mkdir [file join $sourcedir tmpzip data1]
    file mkdir [file join $sourcedir tmpzip data2]
    ::fileutil::touch  [file join $sourcedir tmpzip testfile01.txt]
    ::fileutil::touch  [file join $sourcedir tmpzip testfile02.txt]
    ::fileutil::touch  [file join $sourcedir tmpzip data1 testfile11.txt]
    ::fileutil::touch  [file join $sourcedir tmpzip data1 testfile12.txt]

    # extern zip from Linux
    set pwd [pwd]
    cd [file join $sourcedir tmpzip]
    file delete -force ../testall.zip
    file delete -force ../testfile01.zip
    set cmd  [list zip -v -r ../testall.zip . -i *]
    lappend cmdres cmd1 [exec {*}$cmd]
    set cmd  [list zip -v -r -D ../testfile01.zip . -i testfile01.txt]
    lappend cmdres \n
    lappend cmdres cmd2 [exec {*}$cmd]
    lappend cmdres \n
    cd $pwd
    return $cmdres
}

proc vfstozip {openfilename targetdir dirname  {select 3}} {
    # manual options 1 - 4
    # 1 change in mounted dir, file.zip == mount
    # 2 change in mounted dir, file.zip != mount
    # 3 file.zip == mount
    # 4 file.zip != mount
    set output "\n Seletcetion_${select}_$openfilename"
    switch $select {
        1 {
            set mnt_file [vfs::zip::Mount $openfilename $openfilename]
            cd $openfilename
            set zfiles [glob *]
            lappend output  "zfiles: $zfiles :: pwd : [pwd]"
            lappend output  [join [glob -directory $dirname {*}] \n]
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
            lappend output  "zfiles: $zfiles :: pwd : [pwd]"
            lappend output  [join [glob -directory $dirname {*}] \n]
            foreach zfile $zfiles {
                file copy -force $zfile [file join $targetdir $zfile]
            }
            cd ..
            vfs::zip::Unmount $mnt_file /_zipfile
        }
        3 {
            set mnt_file [vfs::zip::Mount $openfilename $openfilename]
            set zfiles [glob $openfilename/*]
            lappend output  "zfiles: $zfiles :: pwd : [pwd]"
            lappend output   [join [glob -directory $dirname {*}] \n]
            foreach zfile $zfiles {
                file copy -force $zfile [file join $targetdir [file tail $zfile]]
            }
            vfs::zip::Unmount $mnt_file $openfilename
        }
        4 {
            set mnt_file [vfs::zip::Mount $openfilename /_zipfile]
            set zfiles [glob /_zipfile/*]
            lappend output  "zfiles: $zfiles :: pwd : [pwd]"
            lappend output  [join [glob -directory $dirname {*}] \n]
            foreach zfile $zfiles {
                file copy -force $zfile [file join $targetdir [file tail $zfile]]
            }
            vfs::zip::Unmount $mnt_file /_zipfile
        }
    }
    return $output
}
proc zipfiletozip {openfilename targetdir} {
    set res \n
    set res "\n zipfiletozip"
    lappend res [::zipfile::decode::open $openfilename]
    set dArchive [::zipfile::decode::archive]
    lappend res [::zipfile::decode::files $dArchive]
    lappend res [::zipfile::decode::unzip $dArchive $targetdir]
    lappend res [::zipfile::decode::close]
    return $res
    
}

proc callbackvfs {w t dirname opendir sourcedir targetdir} {
    set select [$w get]
    set openfilename [tk_getOpenFile -initialdir $opendir]
    if {$openfilename eq ""} {
        puts "Keine Datei ausgewählt."
        return
    }
    set openfiledirname [file dirname $openfilename]
    set openfile [file tail $openfilename]
    set output [vfstozip $openfilename $targetdir $dirname  1]
    $t insert end "[join $output \n]"
    $t insert end "\n \n"
    $t insert end  [filetimes [file join $targetdir] testfile01.txt]
    return
}
proc callbackmake { t sourcedir} {
    set output [makeTestfiles $sourcedir]
    $t insert end \n
    $t insert end  $output\n
    $t insert end  [filetimes [file join $sourcedir tmpzip] testfile01.txt]\n\n
    return
}
proc callbackzipfile { t dirname opendir sourcedir targetdir} {
    set openfilename [tk_getOpenFile -initialdir $opendir]
    if {$openfilename eq ""} {
        puts "Keine Datei ausgewählt."
        return
    }
    set openfiledirname [file dirname $openfilename]
    set openfile [file tail $openfilename]
    set output [zipfiletozip $openfilename $targetdir]
    $t insert end "[join $output \n]"
    $t insert end "\n \n"
    $t insert end  [filetimes [file join $targetdir] testfile01.txt]
    return
}

set dirname [file dirname [info script]]
set opendir [file join $dirname source]
set sourcedir [file join $dirname source]
set targetdir [file join $dirname target]

ttk::frame .fr
text .t
ttk::combobox .fr.cb -value [list 1 2 3 4]
.fr.cb current 0
ttk::button .fr.btn -text Zip-File -command [list callbackvfs .fr.cb .t $dirname $opendir $sourcedir $targetdir]
ttk::button .fr.btnmake -text "Make zips" -command  [list callbackmake  .t  $sourcedir]
ttk::button .fr.btnzibfile -text Zipfile -command  [list callbackzipfile  .t  $dirname $opendir $sourcedir $targetdir]
pack .fr -side top -expand 0 -fill x
pack .fr.cb .fr.btn .fr.btnmake .fr.btnzibfile -side left -expand 0
pack .t -expand 1 -fill both -side bottom


if {0} {

}