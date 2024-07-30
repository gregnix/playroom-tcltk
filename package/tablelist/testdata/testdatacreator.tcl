#!/usr/bin/tclsh

#20240528
# Help procedure to remove leading zeros from a string
proc removeLeadingZeros {str} {
    if {$str eq "0"} {
        return "0"
    }
    set result [string trimleft $str 0]
    if {$result == "" } {
        set result 0
    }
    return $result
}

# Procedure to generate a list of alphabetic sequences
proc generateAlphabeticSequence {n {class upper}} {
    set resultList {}
    for {set i 0} {$i < $n} {incr i} {
        set result [numberToAlphabeticString $i $class]
        lappend resultList $result
    }
    return $resultList
}

# Helper procedure to convert a number to alphabetic string
proc numberToAlphabeticString {num {class upper}} {
    set upper "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    set lower "abcdefghijklmnopqrstuvwxyz"
    set alpha "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    set alnum "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    set number "0123456789"
    set uxnumber "0123456789ABCDEF"
    set lxnumber "0123456789abcdef"
    set bnumber "01"

    # Use the appropriate character class
    upvar 0 $class alphabet

    set base [string length $alphabet]
    set result ""

    while {$num >= 0} {
        set remainder [expr {$num % $base}]
        set result [string index $alphabet $remainder]$result
        set num [expr {$num / $base - 1}]
        if {$num < 0} {break}  ;# To handle the final iteration correctly
    }
    return $result
}


# Generates alphanumeric test data with words of minimum and maximum length
# class: alnum, alpha, upper, lower, number, zeronumber
# 48-123 all char
# 48-57: 0-9, 65-90: A-Z, 97-122: a-z
# list alnum: all characters that should not be used between 48 and 123, if selected alnum
# list alpha: all characters that should not be used when selecting alnum and no numbers
# list upper: all characters that should not be used when selecting alnum, no numbers and no lowercase letters
# list lower: all characters that should not be used when selecting alnum, no numbers and no uppercase letters
# list number:all characters that should not be used when selecting alnum, no uppercase letters and no lowercase letters
# list zeronumber: all characters that should not be used when selecting alnum, no uppercase letters,no lowercase letters and no numbers with leading 0, except 0
proc testDataalnum {count {*class alnum} {min 3} {max 10}} {
    # List of non-alphanumeric ASCII codes
    set alnum [list 58 59 60 61 62 63 64 91 92 93 94 95 96]

    # Initialize the character class lists
    set alpha $alnum
    for {set i 48} {$i < 59} {incr i} {
        lappend alpha $i
    }
    set upper $alpha
    for {set i 91} {$i < 123} {incr i} {
        lappend upper $i
    }
    set lower $alpha
    for {set i 65} {$i < 91} {incr i} {
        lappend lower $i
    }
    set number $alnum
    for {set i 60} {$i < 123} {incr i} {
        lappend number $i
    }
    set zeronumber $number

    # Use the appropriate character class
    upvar 0 ${*class} noList

    # Generate the test data
    set resultList {}
    for {set i 0} {$i < $count} {incr i} {
        set string ""
        set length [expr {int(rand() * ($max - $min + 1)) + $min}]
        for {set j 0} {$j < $length} {incr j} {
            set val [expr {int(rand() * 75) + 48}]
            if {$val in $noList} {
                incr j -1
                continue
            }
            append string [format %c $val]
        }
        if {${*class} == "number"} {
            lappend resultList [removeLeadingZeros $string]
        } else {
            lappend resultList $string
        }
    }
    return $resultList
}

# Generates floating-point, integer, and alphanumeric data
#date format
# {%G-W%V-%u} - ISO week date format
# {%Y-%m-%d %H:%M:%S} - Standard date-time format
# {%Y-%m-%dT%T} - ISO 8601 date-time format
# timepoint: now,2021-04-02,2001-02-28T12:15:00
# timeadd:  seconds, minutes, hours, days, weeks, months, or years
proc testData {count {intmax 100} {timepoint now} {timeadd seconds} {format {%Y-%m-%dT%T}} } {
    set data {}
    set time [clock scan $timepoint]
    for {set i 0} {$i < $count} {incr i} {
        set temp [list]
        lappend temp $i ;# id integer
        #lappend temp [numberToAlphabeticString $i alnum] ;# id string
        #lappend temp [numberToAlphabeticString $i alpha] ;# id string
        lappend temp [numberToAlphabeticString $i upper] ;# id string
        #lappend temp [numberToAlphabeticString $i lower] ;# id string        
        lappend temp [numberToAlphabeticString $i number] ;# id string
        lappend temp [numberToAlphabeticString $i uxnumber] ;# id string
        lappend temp [numberToAlphabeticString $i bnumber] ;# id string
        lappend temp [clock format [expr {$time + $i}] -format $format] ;# id time
        lappend temp [clock format [clock add $time $i $timeadd] -format $format] ;# id time
        # random time intervals: [clock add $time [incr j [expr {$i + int(rand() * $intmax) }]] $timeadd]
        lappend temp [clock format [clock add $time [incr j [expr {$i + int(rand() * $intmax) }]] $timeadd] -format $format] ;# id time
        lappend temp [expr {rand()}]
        lappend temp [expr {int(rand() * $intmax)}]
        lappend temp [testDataalnum 1 alnum 3 10] 
        lappend temp [testDataalnum 3 alnum 3 5] 
        lappend temp [testDataalnum 1 alpha 3 10] 
        lappend temp [testDataalnum 1 upper 3 10] 
        lappend temp [testDataalnum 1 lower 3 10] 
        lappend temp [testDataalnum 1 number 1 3] 
        lappend temp [testDataalnum 1 zeronumber 1 3] 
        lappend temp [clock format [expr {int(rand() * $time)}] -format $format]
        lappend data $temp
    }
    return $data
}


# Example usage
if {[info script] eq $argv0} {
    puts "Generating data: [time {set data [testData 1000 100 2001-02-28T12:01:01 seconds]}]"
    # Output random values
    puts "Data length: [llength $data]"
    puts "Range entries: \n[join [lrange $data 0 5] \n]"
    puts "Range entries: \n[join [lrange $data 9 18] \n]"
    puts "Range entries: \n[join [lrange $data 108 113] \n]"
    puts "Range entries: \n[join [lrange $data end-5 end] \n]"
}

if {0} {

Generating data: 335491 microseconds per iteration
Data length: 1000
Range entries: 
0 A 0 0 0 2001-02-28T12:01:01 2001-02-28T12:01:01 2001-02-28T12:01:26 0.5395130340659586 59 8G90kNCS {eWoNt D86 fWH3R} qMshOvuu XQBPZLY gammjdvtk 6 1 1988-08-15T05:14:01
1 B 1 1 1 2001-02-28T12:01:02 2001-02-28T12:01:02 2001-02-28T12:01:50 0.2560603037737591 60 Db7 {cK7r bSY nZDjz} ouZL IOCLKSGJNK svhvl 336 1 1992-09-08T02:15:09
2 C 2 2 00 2001-02-28T12:01:03 2001-02-28T12:01:03 2001-02-28T12:03:27 0.1384095648016825 24 P46WM {Rhfy 9VOtR 5auLr} zBpt OSOTUU loylw 53 7 1978-12-18T05:34:16
3 D 3 3 01 2001-02-28T12:01:04 2001-02-28T12:01:04 2001-02-28T12:04:22 0.11728372383736248 18 3yj {Zi4Id PB7N T4Q7r} TlGb TJVM zorj 529 8 1988-05-24T12:49:50
4 E 4 4 10 2001-02-28T12:01:05 2001-02-28T12:01:05 2001-02-28T12:04:39 0.9047327846776381 84 7QUUUya9 {ih5ou tvDNL kMZ} iIoZqy XXWSDFITY evwenbdmx 711 39 1980-08-08T11:52:31
5 F 5 5 11 2001-02-28T12:01:06 2001-02-28T12:01:06 2001-02-28T12:05:22 0.9168481188439057 46 x0b3VZZD {Mt1A Yjaa CFxCA} nrtxKlow IONBILRTT rae 6 18 1986-12-18T12:25:56
Range entries: 
9 J 9 9 011 2001-02-28T12:01:10 2001-02-28T12:01:10 2001-02-28T12:12:05 0.10635649371256889 53 ExJ {zjawv fOtWa emXYl} VCv XJHGAA dwuhwlha 9 8 1972-01-31T04:52:39
10 K 00 A 100 2001-02-28T12:01:11 2001-02-28T12:01:11 2001-02-28T12:13:08 0.03539359990292862 86 RheSdLE9Ww {2NAj 8vIp GhTGd} ucy FVF imewmqqo 8 70 1994-04-10T06:45:30
11 L 01 B 101 2001-02-28T12:01:12 2001-02-28T12:01:12 2001-02-28T12:13:42 0.43797574957738433 5 1sGG4EvOzx {tWN 6d49 5LBY} UMYbL NKMPKCTDSH mjz 0 03 2000-04-22T12:20:53
12 M 02 C 110 2001-02-28T12:01:13 2001-02-28T12:01:13 2001-02-28T12:14:16 0.8233278644379823 67 HW1N332 {FuhI xKP 3fQ} pQfqf DVACEGBFV bpnqtpz 99 1 1976-02-19T22:37:27
13 N 03 D 111 2001-02-28T12:01:14 2001-02-28T12:01:14 2001-02-28T12:14:42 0.3302220098349368 4 KGIExT {cSXi NnAv2 i6iu} dNWaNGWdy MEZUWKEFNW zrpevvtt 9 718 1973-12-25T14:34:49
14 O 04 E 0000 2001-02-28T12:01:15 2001-02-28T12:01:15 2001-02-28T12:16:31 0.7965455953015692 54 KNgZS {n9y JHt HYZ} MQVyPaBkcA ZJYKDNDEE jrsllkwgha 473 186 1996-12-22T14:17:56
15 P 05 F 0001 2001-02-28T12:01:16 2001-02-28T12:01:16 2001-02-28T12:17:12 0.7334421648333976 96 GiOC {xphS QW37r RAL} irFgG BIYXE ade 70 687 1978-11-05T02:57:13
16 Q 06 00 0010 2001-02-28T12:01:17 2001-02-28T12:01:17 2001-02-28T12:18:54 0.6930968033583355 87 Zo5 {kGBc U36kW WSuvG} PdvtU STWL mcuq 876 928 1980-03-23T15:38:46
17 R 07 01 0011 2001-02-28T12:01:18 2001-02-28T12:01:18 2001-02-28T12:20:40 0.8748252489021165 18 ziR {HLH dlmRv D16d} TfkgjtL IGNFTQF gnwpo 999 96 1978-07-11T02:44:45
18 S 08 02 0100 2001-02-28T12:01:19 2001-02-28T12:01:19 2001-02-28T12:21:05 0.04382826250224759 62 JV4ex {RdgXp wvD DZd} rLskw QXMZVIEW wjpcxc 994 7 1997-09-06T02:10:04
Range entries: 
108 DE 98 5C 101110 2001-02-28T12:02:49 2001-02-28T12:02:49 2001-02-28T15:09:34 0.278353783897289 29 i9pkBf {uaby HdBB wN2ID} qflHAkVOy AZWCTTUMV aqoxhsp 5 63 1994-10-10T20:46:46
109 DF 99 5D 101111 2001-02-28T12:02:50 2001-02-28T12:02:50 2001-02-28T15:12:02 0.15683885251956006 99 T8gI5oW1gp {Vv6 NRY r9H5b} OeS TDVB nijbfnr 0 676 1982-09-22T21:11:29
110 DG 000 5E 110000 2001-02-28T12:02:51 2001-02-28T12:02:51 2001-02-28T15:14:32 0.49142588278810767 39 uPzd8wu {RKArV mZ3 DcW} mlUoc DLH kldxhlcyn 484 6 1975-12-01T23:11:27
111 DH 001 5F 110001 2001-02-28T12:02:52 2001-02-28T12:02:52 2001-02-28T15:16:26 0.718784469048858 61 CjTFotf8W {J3IlG 7yDF gKT} xTQW QGQABJH ynncdcjrs 8 851 1971-11-17T09:42:19
112 DI 002 60 110010 2001-02-28T12:02:53 2001-02-28T12:02:53 2001-02-28T15:18:25 0.1361087877937168 58 QIZAYkhL {U3Qv MltEn vbz} KheJs LVVIECDYVA iddjpwc 57 070 1974-12-28T22:33:07
113 DJ 003 61 110011 2001-02-28T12:02:54 2001-02-28T12:02:54 2001-02-28T15:21:45 0.21238478562440014 55 sanD {QW2 EYev eOq} PyIUkuO AWVHLACW hgwixahqy 654 247 1975-04-19T07:59:08
Range entries: 
994 ALG 884 2D2 111100100 2001-02-28T12:17:35 2001-02-28T12:17:35 2001-03-06T18:51:55 0.8223338056459715 96 iTifZ05 {ODq xyMY6 Occ} JaAJ NHTOSY ejzxgzd 19 60 1993-03-08T13:10:32
995 ALH 885 2D3 111100101 2001-02-28T12:17:36 2001-02-28T12:17:36 2001-03-06T19:10:06 0.23394421871469553 90 YhaoaS {S2ER AvOPV hGoh} tffgct OSHEMWIJ oxks 0 524 1971-05-09T05:10:05
996 ALI 886 2D4 111100110 2001-02-28T12:17:37 2001-02-28T12:17:37 2001-03-06T19:27:08 0.3137247964338049 77 nbuvEBzAJc {Gxfw EnFEJ vC0G} VuoVNoX WVGXINV rttioqo 670 3 1971-06-27T19:39:23
997 ALJ 887 2D5 111100111 2001-02-28T12:17:38 2001-02-28T12:17:38 2001-03-06T19:44:36 0.6427203275462241 20 NTAhmTk {iD0e Dg6 zdDB} uvqumdNAX SSGITDRRSP vshxns 76 81 1978-07-26T18:53:43
998 ALK 888 2D6 111101000 2001-02-28T12:17:39 2001-02-28T12:17:39 2001-03-06T20:01:35 0.8540008100001145 19 cgwNbo {oO0r dwFtx zX8JV} SjFjWVzIWz LTOAKMVK eypilobqot 7 769 1987-09-07T22:50:23
999 ALL 889 2D7 111101001 2001-02-28T12:17:40 2001-02-28T12:17:40 2001-03-06T20:19:35 0.6760530027915039 42 HZLTd {Taq TJs 2qV} pUdh IMMJGOQWV gnb 11 675 1999-05-09T06:33:23




}












