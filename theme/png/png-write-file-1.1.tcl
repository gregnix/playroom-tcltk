#! /usr/bin/env tclsh

#https://wiki.tcl-lang.org/page/Write+PNG+File+%28without+using+Tk%29
#https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/png/png.md
#write png without Tk
#add transparency
#add filter
#add compressionLevel

package provide PNG 1.1
package require Tcl 8.6
namespace eval PNG {
    namespace ensemble create -subcommands write

    proc applyFilterNone {scanline} {
        set data [binary format c 0]
        foreach byte $scanline {
            append data [binary format c $byte]
        }
        return $data
    }

    proc applyFilterSub {scanline} {
        set data [binary format c 1]
        set prev 0
        foreach byte $scanline {
            set filtered [expr {$byte - $prev}]
            append data [binary format c $filtered]
            set prev $byte
        }
        return $data
    }

    proc applyFilterUp {scanline prevline} {
        set data [binary format c 2]
        for {set i 0} {$i < [llength $scanline]} {incr i} {
            if {[llength $prevline] > 0} {
                set filtered [expr {[lindex $scanline $i] - [lindex $prevline $i]}]
            } else {
                set filtered [lindex $scanline $i]
            }
            append data [binary format c $filtered]
        }
        return $data
    }

    proc applyFilterAverage {scanline prevline} {
        set data [binary format c 3]
        set prev 0
        for {set i 0} {$i < [llength $scanline]} {incr i} {
            if {[llength $prevline] > 0} {
                set avg [expr {($prev + [lindex $prevline $i]) / 2}]
            } else {
                set avg [expr {$prev / 2}]
            }
            set filtered [expr {[lindex $scanline $i] - $avg}]
            append data [binary format c $filtered]
            set prev [lindex $scanline $i]
        }
        return $data
    }

    proc applyFilterPaeth {scanline prevline} {
        set data [binary format c 4] 
        set prev 0
        set prevprev 0
        for {set i 0} {$i < [llength $scanline]} {incr i} {
            set a $prev
            if {[llength $prevline] > 0} {
                set b [lindex $prevline $i]
            } else {
                set b 0
            }
            set c $prevprev
            set p [expr {$a + $b - $c}]
            set pa [expr {abs($p - $a)}]
            set pb [expr {abs($p - $b)}]
            set pc [expr {abs($p - $c)}]
            if {$pa <= $pb && $pa <= $pc} {
                set pr $a
            } elseif {$pb <= $pc} {
                set pr $b
            } else {
                set pr $c
            }
            set filtered [expr {[lindex $scanline $i] - $pr}]
            append data [binary format c $filtered]
            set prev [lindex $scanline $i]
            set prevprev $b
        }
        return $data
    }

    proc calculateSize {data} {
        return [string length [zlib deflate $data]]
    }

    proc findBestFilter {scanline prevline} {
        set filters {
            {applyFilterNone ${scanline}}
            {applyFilterSub ${scanline}}
            {applyFilterUp $scanline $prevline}
            {applyFilterAverage $scanline $prevline}
            {applyFilterPaeth $scanline $prevline}
        }
        set bestFilter ""
        set minSize -1
        foreach filter $filters {
            set filteredData [eval $filter]
            set size [calculateSize $filteredData]
            if {$minSize == -1 || $size < $minSize} {
                set minSize $size
                set bestFilter $filteredData
            }
        }
        return $bestFilter
    }

    proc write { filename palette image {compressionLevel 6} } {
        set fid [open ${filename} w]
        fconfigure ${fid} -translation binary
        set width [llength [lindex ${image} 0]]
        set height [llength ${image}]
        puts -nonewline ${fid} [binary format c8 {137 80 78 71 13 10 26 10}]
        #puts "PNG signature written."
        set data {}
        append data [binary format I ${width}]
        append data [binary format I ${height}]
        append data [binary format c5 {8 3 0 0 0}]
        Chunk ${fid} "IHDR" ${data}
        #puts "IHDR chunk written."
        set data {}
        set tdata {}
        set palette-size 0
        foreach color ${palette} {
            set rgb [string range ${color} 0 5]
            set alpha [string range ${color} 6 7]
            append data [binary format H6 ${rgb}]
            if {${alpha} ne ""} {
                append tdata [binary format c [format %d 0x${alpha}]]
            } else {
                append tdata [binary format c 255]
            }
            incr palette-size
        }
        if { ${palette-size} < 256 } {
            set fill [binary format H6 000000]
            append data [string repeat ${fill} [expr {256-${palette-size}}]]
            append tdata [string repeat [binary format c 255] [expr {256-${palette-size}}]]
        }
        Chunk ${fid} "PLTE" ${data}
        #puts "PLTE chunk written."
        if {[string length ${tdata}] > 0} {
            Chunk ${fid} "tRNS" ${tdata}
            #puts "tRNS chunk written."
        }
        set data {}

        set prevline {}
        foreach scanline ${image} {
            set bestFilter [findBestFilter $scanline $prevline]
            append data $bestFilter
            set prevline $scanline
        }

        #puts "Data before compression: [binary encode hex ${data}]"
        set cdata [binary format H* 78da]
        append cdata [zlib deflate $data $compressionLevel]
        append cdata [binary format I [zlib adler32 ${data}]]
        Chunk ${fid} "IDAT" ${cdata}
        #puts "IDAT chunk written."
        Chunk ${fid} "IEND"
        #puts "IEND chunk written."
        close ${fid}
        #puts "File ${filename} closed."
    }

    proc Chunk { fid type {data ""} } {
        set length [binary format I [string length ${data}]]
        puts -nonewline ${fid} ${length}
        puts -nonewline ${fid} [encoding convertto ascii ${type}]
        if { ${data} ne "" } {
            puts -nonewline ${fid} ${data}
        }
        set crcdata "${type}${data}"
        set crc [zlib crc32 ${crcdata}]
        puts -nonewline ${fid} [binary format I ${crc}]
    }
}

# Example
if {[info script] eq $argv0} {
    set palette {FFFFFF00 000000FF FF0000FF 00FF00FF 0000FFFF FFFF00FF FF00FFFF}
    set image {
        {1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1}
        {1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
        {1 0 0 1 1 1 1 1 1 1 1 0 0 0 3 3 3 3 0 0 0 2 2 0 0 0 0 0 0 0 0 1}
        {1 0 0 1 1 1 1 1 1 1 1 0 0 3 3 3 3 3 3 0 0 2 2 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 0 0 3 3 0 0 2 2 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 0 0 0 0 0 0 2 2 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 0 0 0 0 0 0 2 2 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 0 0 0 0 0 0 2 2 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 0 0 0 0 0 0 2 2 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 0 0 3 3 0 0 2 2 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 1 1 0 0 0 0 0 3 3 3 3 3 3 0 0 2 2 2 2 2 2 2 0 0 0 1}
        {1 0 0 0 0 0 1 1 0 0 0 0 0 0 3 3 3 3 0 0 0 2 2 2 2 2 2 2 0 0 0 1}
        {1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
        {1 0 4 4 4 4 4 4 0 0 0 1 1 0 0 0 0 1 1 0 0 6 6 6 6 6 6 6 6 0 0 1}
        {1 0 4 4 4 4 4 4 4 0 0 1 1 0 0 0 0 1 1 0 0 6 6 6 6 6 6 6 6 0 0 1}
        {1 0 4 4 0 0 0 4 4 0 0 1 1 1 0 0 0 1 1 0 0 6 6 0 0 0 0 0 0 0 0 1}
        {1 0 4 4 0 0 0 4 4 0 0 1 1 1 1 0 0 1 1 0 0 6 6 0 0 0 0 0 0 0 0 1}
        {1 0 4 4 0 0 0 4 4 0 0 1 1 0 1 1 0 1 1 0 0 6 6 0 0 6 6 6 6 0 0 1}
        {1 0 4 4 4 4 4 4 4 0 0 1 1 0 0 1 1 1 1 0 0 6 6 0 0 6 6 6 6 0 0 1}
        {1 0 4 4 4 4 4 4 0 0 0 1 1 0 0 0 1 1 1 0 0 6 6 0 0 0 0 6 6 0 0 1}
        {1 0 4 4 0 0 0 0 0 0 0 1 1 0 0 0 0 1 1 0 0 6 6 0 0 0 0 6 6 0 0 1}
        {1 0 4 4 0 0 0 0 0 0 0 1 1 0 0 0 0 1 1 0 0 6 6 6 6 6 6 6 6 0 0 1}
        {1 0 4 4 0 0 0 0 0 0 0 1 1 0 0 0 0 1 1 0 0 6 6 6 6 6 6 6 6 0 0 1}
        {1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
        {1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1}
        {1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1}
    }
    PNG write test-1.1.png ${palette} ${image}
    PNG write test-1.1-9.png $palette $image 9
    PNG write test-1.1-0.png $palette $image 0
}

if {0} {
output extern programs    

identify -verbose  test-1.1.png 
Image: test-1.1.png
  Format: PNG (Portable Network Graphics)
  Geometry: 32x32
  Class: DirectClass
  Type: true color with transparency
  Depth: 1 bits-per-pixel component
  Channel Depths:
    Red:      1 bits
    Green:    1 bits
    Blue:     1 bits
    Opacity:  1 bits
  Channel Statistics:
    Red:
      Minimum:                     0.00 (0.0000)
      Maximum:                 65535.00 (1.0000)
      Mean:                    47359.28 (0.7227)
      Standard Deviation:      29353.54 (0.4479)
    Green:
      Minimum:                     0.00 (0.0000)
      Maximum:                 65535.00 (1.0000)
      Mean:                    44159.33 (0.6738)
      Standard Deviation:      30738.54 (0.4690)
    Blue:
      Minimum:                     0.00 (0.0000)
      Maximum:                 65535.00 (1.0000)
      Mean:                    48255.26 (0.7363)
      Standard Deviation:      28890.37 (0.4408)
    Opacity:
      Minimum:                     0.00 (0.0000)
      Maximum:                 65535.00 (1.0000)
      Mean:                    41855.36 (0.6387)
      Standard Deviation:      31497.44 (0.4806)
  Opacity: (255,255,255,255)	  #FFFFFFFF
  Filesize: 1.2Ki
  Interlace: No
  Orientation: Unknown
  Background Color: white
  Border Color: #DFDFDF00
  Matte Color: #BDBDBD00
  Page geometry: 32x32+0+0
  Compose: Over
  Dispose: Undefined
  Iterations: 0
  Compression: Zip
  Png:IHDR.color-type-orig: 3
  Png:IHDR.bit-depth-orig: 8
  Signature: 2bd2e09d48468890613f39aae7c3358eadfdf1b78dfb1d297e234a870577811b
  Tainted: False
  Elapsed Time: 0m:0.000184s
  Pixels Per Second: 5.3Mi


pngcheck -vv  test-1.1.png 
zlib warning:  different version (expected 1.2.13, using 1.3.1)

File: test-1.1.png (1250 bytes)
  chunk IHDR at offset 0x0000c, length 13
    32 x 32 image, 8-bit palette, non-interlaced
  chunk PLTE at offset 0x00025, length 768: 256 palette entries
  chunk tRNS at offset 0x00331, length 256: 256 transparency entries
  chunk IDAT at offset 0x0043d, length 145
    zlib: deflated, 32K window, maximum compression
    row filters (0 none, 1 sub, 2 up, 3 avg, 4 paeth):
      0 0 2 2 2 2 0 4 2 2 2 2 2 2 0 2 2 2 0 2 2 2 2 4 2
      2 4 2 0 2 2 0 (32 out of 32)
  chunk IEND at offset 0x004da, length 0
No errors detected in test-1.1.png (5 chunks, -22.1% compression).
 

}
