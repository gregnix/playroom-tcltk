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
set zipfile [file join $zipdir "testfile01.zip"]
set options [list -directory [file join $sourcedir]]
::zipfile::mkzip::mkzip $zipfile {*}$options
```
```
# a single file, 
set zipfile [file join $zipdir "testfile01.zip"]
set file_to_zip [file join $sourcedir testfile01.txt]
set tempdir [fileutil::maketempdir]
set temp_file [file join $tempdir testfile01.txt]
file copy -force $file_to_zip $temp_file
set options [list -directory [file join $tempdir]  testfile01.txt]
:zipfile::mkzip::mkzip $zipfile {*}$options
file delete -force $tempdir
```
```
# a single file
set zipfile [file join $zipdir testfile01.zip]
set pwd [pwd]
cd [file join $sourcedir]
set options [list testfile01.txt]
::zipfile::mkzip::mkzip $zipfile {*}$options
cd $pwd
```

```
```

## zipfile
### zipfile::encode
```
# ::zipfile::encode ?objectName?
#  <encoder> comment: text
#  <encoder> file: dst owned src ?noCompress?
#  <encoder> write archive
set zip [zipfile::encode create myZipEncoder]
# Use fileutil::find to get a list of all files in the source directory
set files [fileutil::find $sourcedir]
# Iterate over the list of files and add them to the ZIP file
  foreach file $files {
    if {[file isdirectory $file]} {
      set relpath [file tail $file]
      $zip file: $relpath 0 {} 0
      continue
   } else {
     set relpath [fileutil::stripPath $sourcedir $file]
    $zip file: $relpath 0 $file
  }
}
# Write the ZIP file
$zip write [file join $zipdir testall.zip]
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

