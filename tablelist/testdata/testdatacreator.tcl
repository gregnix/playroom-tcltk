#!/usr/bin/tclsh

#20240526
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
proc testDataalnum {count {class alnum} {min 3} {max 10}} {
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
    upvar 0 $class noList

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
        if {$class == "number"} {
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
proc testData {count {intmax 100} {format {%Y-%m-%dT%T}}} {
    set data {}
    set time [clock scan now]
    for {set i 0} {$i < $count} {incr i} {
        set temp [list]
        lappend temp $i
        lappend temp [numberToAlphabeticString $i upper]
        #lappend temp [numberToAlphabeticString $i lower]
        #lappend temp [numberToAlphabeticString $i alnum]
        #lappend temp [numberToAlphabeticString $i alpha]
        lappend temp [numberToAlphabeticString $i number]
        lappend temp [clock format [expr {$time + $i}] -format $format]
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
    puts "Generating data: [time {set data [testData 100000]}]"
    # Output random values
    puts "Data length: [llength $data]"
    puts "id id id id rand..rand"
    puts "count upper number date floating_poin integer alnum alnum_grp alpha upper lower number zeronumber date"
    puts "Range entries: \n[join [lrange $data 0 5] \n]"
    puts "Range entries: \n[join [lrange $data 108 113] \n]"
    puts "Range entries: \n[join [lrange $data end-5 end] \n]"
}

if {0} {

Generating data: 22687100 microseconds per iteration
Data length: 100000
id id id id rand..rand
count upper number date floating_poin integer alnum alnum_grp alpha upper lower number zeronumber date
Range entries: 
0 A 0 2024-05-26T21:12:22 0.6494363460919989 7 MJ2L2J5 {ctvb QBK jm5H} iofJOqT NWO yucqbzgd 288 325 2006-11-27T18:20:20
1 B 1 2024-05-26T21:12:23 0.9110692436392741 34 dWUu7h {IPGN9 PWnzv jTX} HgGvdywxa VHLWT swvsbdu 826 66 2001-01-05T05:26:42
2 C 2 2024-05-26T21:12:24 0.17341128651677226 52 frRLF {R5WP cYMv1 A9i} LfDOr HVNU oqfnwdrz 0 387 1981-03-11T22:32:39
3 D 3 2024-05-26T21:12:25 0.7748862261766969 51 S74GKubj {73tY HWu8 WnCI} hwi GNGNSZDF iaslzaikfe 39 7 1982-11-05T07:27:34
4 E 4 2024-05-26T21:12:26 0.14057288371984517 60 2FRwI {CRz lXxm s4ZgG} QAwWQ IXAM eor 892 385 2009-05-31T10:07:01
5 F 5 2024-05-26T21:12:27 0.3906174653166055 10 EAjg5frrp {5SCA uqbh 03St2} QsqTY QFMAC yiskwpn 102 936 1977-09-29T18:24:43
Range entries: 
108 DE 98 2024-05-26T21:14:10 0.9624034375708567 11 ADYQh8MM {J1m2A c3U jLp} cLNwNtGe MIJ rdtruyvjaz 6 072 1979-02-15T18:21:56
109 DF 99 2024-05-26T21:14:11 0.005942751190598472 87 7dY {AEY IuFC 2fZvC} VJFZvaqDF RPNIRL qswmamoy 262 956 1983-08-20T11:13:16
110 DG 000 2024-05-26T21:14:12 0.844586075676878 95 JqI {uxDQP TlU DKX} ERSibM OXKGJ huka 15 8 2018-03-19T15:13:40
111 DH 001 2024-05-26T21:14:13 0.18882391051800174 56 ugzY {C2V GeN BHs} PCYKSJkBJ HXLRAGX ffrzvlcwpw 32 85 1995-11-19T17:41:31
112 DI 002 2024-05-26T21:14:14 0.46993247348346395 15 NQN85R {sKFS Fses6 BiSV} IEjZurK ITXRLQPG rmi 9 76 2012-10-26T07:33:55
113 DJ 003 2024-05-26T21:14:15 0.5461860134015726 74 VzL8 {ACXa f5K 0d0} ZjOg MFGXQFRGAD vhqwuod 10 972 1986-08-28T07:43:15
Range entries: 
99994 EQWY 88884 2024-05-28T00:58:56 0.8622236199966742 39 uFF8eQXhV {PKO4 Opcm gkf} xbLiJgow UOIIKN ejtbqyx 14 39 2004-01-31T23:20:16
99995 EQWZ 88885 2024-05-28T00:58:57 0.009181709033056026 31 n6F6VP4 {L0WxW Uu2es tPd} DqHB VNPPVLLY bvtpwvdk 48 42 2023-08-06T23:46:07
99996 EQXA 88886 2024-05-28T00:58:58 0.40850529559352683 74 eaf {0Grma 1oO Va6} SjaPSkHI OODDP kpdthmqk 6 5 2021-10-05T15:16:30
99997 EQXB 88887 2024-05-28T00:58:59 0.3852897418594406 56 hgFJRLhTD {bXee 5xn7b ltQ} YxdCdmIvw ZZSVPYTWDN fvbdkqxyhh 96 987 1981-01-23T00:09:52
99998 EQXC 88888 2024-05-28T00:59:00 0.23087333898566353 28 J2nMNwu192 {FPC 38jc ram} NestLyLJSV TGJ fwtlwfbhd 15 092 1989-11-13T05:12:17
99999 EQXD 88889 2024-05-28T00:59:01 0.6830733579970306 41 tfWfdPY0B0 {uuz AgR1 4nv} CcxhPxNh SFNK svhgvop 5 42 2010-12-13T21:54:18


}












