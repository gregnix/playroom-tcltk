package require fileutil

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
