
# vfs-time.tcl

diffs with vfs and atime, mtime

Output
```
vfsbug/source/testfile.txt
atime_ctime_mtime
Sun Jun 02 16:56:51 CEST 2024
Sun Jun 02 16:56:51 CEST 2024
Sun Jun 02 16:56:51 CEST 2024
target/vfs/testfile.txt
atime_ctime_mtime
Sun Jun 02 18:56:50 CEST 2024
Sun Jun 02 16:56:51 CEST 2024
Sun Jun 02 18:56:50 CEST 2024
target/zipfile/testfile.txt
atime_ctime_mtime
Sun Jun 02 16:56:51 CEST 2024
Sun Jun 02 16:56:51 CEST 2024
Sun Jun 02 16:56:51 CEST 2024
```
