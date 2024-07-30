#!/usr/bin/env tclsh

package require vfs::zip
package require fileutil
package require zipfile::decode
package require zipfile::mkzip

# for output
proc filetimes {file} {
    file stat $file stat
    set atime  [clock format $stat(atime)]
    set ctime  [clock format $stat(ctime)]
    set mtime  [clock format $stat(mtime)]
    set file [file join {*}[lrange [file split $file] end-2 end]]
    return [join [list $file atime_ctime_mtime $atime $ctime $mtime] \n]
}

# make testfile.txt and dirs, delete old dirs
set dirname [file dirname [info script]]
set sourcedir [file join $dirname source]
set targetdir [file join $dirname target]
file delete -force  $sourcedir
file mkdir $sourcedir
file delete -force $targetdir
file mkdir [file join $targetdir vfs]
file mkdir [file join $targetdir zipfile]
::fileutil::touch  [file join $sourcedir testfile.txt]
puts [filetimes [file join $sourcedir testfile.txt]]

# make zip
set ziptestfile [file join $dirname "test.zip"]
set options [list -directory $sourcedir]
::zipfile::mkzip::mkzip $ziptestfile {*}$options

# unzip with vfs::zip
set mnt_file [vfs::zip::Mount $ziptestfile $ziptestfile]
set zfile [glob $ziptestfile/*]
file copy -force $zfile [file join $targetdir vfs [file tail $zfile]]
vfs::zip::Unmount $mnt_file $ziptestfile
puts [filetimes [file join $targetdir vfs [file tail $zfile]]]

#unzip with zipfile::decode
::zipfile::decode::open $ziptestfile
set dArchive [::zipfile::decode::archive]
::zipfile::decode::files $dArchive
::zipfile::decode::unzip $dArchive [file join $targetdir zipfile]
::zipfile::decode::close
puts [filetimes [file join $targetdir zipfile testfile.txt]]

puts \n
puts "Version [info patchlevel] $tcl_platform(os)"
puts "vfs::zip: [package version vfs::zip]"



if {0} {
Output:
vfsbug/source/testfile.txt
atime_ctime_mtime
Sun Jun 02 15:20:30 CEST 2024
Sun Jun 02 15:20:30 CEST 2024
Sun Jun 02 15:20:30 CEST 2024
target/vfs/testfile.txt
atime_ctime_mtime
Sun Jun 02 17:20:30 CEST 2024
Sun Jun 02 15:20:30 CEST 2024
Sun Jun 02 17:20:30 CEST 2024
target/zipfile/testfile.txt
atime_ctime_mtime
Sun Jun 02 15:20:30 CEST 2024
Sun Jun 02 15:20:30 CEST 2024
Sun Jun 02 15:20:30 CEST 2024


Version 8.6.14 Linux
vfs::zip: 1.0.4


}


