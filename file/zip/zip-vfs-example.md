# zip-vfs-example.tcl
The script creates test files and directories.

It uses three methods to create ZIP archives:
+ External ZIP command (Linux: zip, Windows: ?, MacOs:?)
+ mkzip from zipfile::mkzip
+ zipfile::encode

It provides options to extract ZIP archives:
+ vfs::zip
+ zipfile::decode

A simple GUI using Tk to select and display results.

## mkzip
```
# a directory
set zipfile [file join $sourcedir "testall.zip"]
set options [list -directory [file join $sourcedir]]
::zipfile::mkzip::mkzip $zipfile {*}$options
```
```
# a single file
set zipfile [file join $sourcedir "testfile01.zip"]
set file_to_zip [file join $sourcedir testfile01.txt]
set tempdir [fileutil::maketempdir]
set temp_file [file join $tempdir testfile01.txt]
file copy -force $file_to_zip $temp_file
set options [list -directory [file join $tempdir]  testfile01.txt]
:zipfile::mkzip::mkzip $zipfile {*}$options
file delete -force $tempdir
```

## zipfile
### zipfile::encode
```
# ::zipfile::encode ?objectName?
#  <encoder> comment: text
#  <encoder> file: dst owned src ?noCompress?
#  <encoder> write archive
set zip [zipfile::encode create myZipEncoder]
$zip file: "testfile01.txt" 0 "[file join $sourcedir tmpzip testfile01.txt]"
$zip file: "testfile02.txt" 0 "[file join $sourcedir tmpzip testfile02.txt]"
$zip file: "data1/testfile11.txt" 0 "[file join $sourcedir tmpzip data1 testfile11.txt]"
$zip file: "data1/testfile12.txt" 0 "[file join $sourcedir tmpzip data1 testfile12.txt]"
$zip file: "data2/" 0 "[file join $sourcedir tmpzip data2/ ]"
$zip write "[file join $sourcedir testall.zip]"
$zip destroy
```

### zipfile::decode
```
::zipfile::decode::open $openfilename
set dArchive [::zipfile::decode::archive]
::zipfile::decode::files $dArchive
::zipfile::decode::unzip $dArchive $targetdir
::zipfile::decode::close
```
### vfs::zip
+ problem with atime and mtime
+ 1 and 2 not recommended because of cd to zip dir?

```
# 1
set mnt_file [vfs::zip::Mount $openfilename $openfilename]
cd $openfilename
set zfiles [glob *]
foreach zfile $zfiles {
  file copy -force $zfile [file join $targetdir $zfile]
}
cd ..
vfs::zip::Unmount $mnt_file $openfilename
````
```
# 2
set mnt_file [vfs::zip::Mount $openfilename /_zipfile]
cd /_zipfile
set zfiles [glob *]
foreach zfile $zfiles {
 file copy -force $zfile [file join $targetdir $zfile]
}
cd ..
vfs::zip::Unmount $mnt_file /_zipfile
````
```
# 3
set mnt_file [vfs::zip::Mount $openfilename $openfilename]
set zfiles [glob $openfilename/*]
foreach zfile $zfiles {
 file copy -force $zfile [file join $targetdir [file tail $zfile]]
}
vfs::zip::Unmount $mnt_file $openfilename
````
```
# 4
set mnt_file [vfs::zip::Mount $openfilename /_zipfile]
set zfiles [glob /_zipfile/*]
foreach zfile $zfiles {
 file copy -force $zfile [file join $targetdir [file tail $zfile]]
}
vfs::zip::Unmount $mnt_file /_zipfile
````

