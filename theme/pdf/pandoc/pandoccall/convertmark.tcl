#! /usr/bin/env tclsh


# TinyTex with pdflatex

proc pandocpdflatexExists {} {
    switch -- $::tcl_platform(platform) {
        windows {
            #set cmd   [file join $::env(APPDATA) TinyTex bin windows pdflatex.exe]
            #puts $cmd
            #puts [file exists $cmd]
            #puts "where:  [exec where pdflatex]"
            set where where
            set pdflatexCmd pdflatex.exe
            set pandocCmd pandoc.exe
        }
        unix {
            # Pfad zu pdflatex hinzufügen, env ist eine globale variable
            set pdflatexPath "/home/greg/.TinyTeX/bin/x86_64-linux"
            set ::env(PATH) "$pdflatexPath:$::env(PATH)"
            # Überprüfen, ob pdflatex installiert ist
            set where which
            set pdflatexCmd pdflatex
            set pandocCmd pandoc
        }
        macintosh {


        }
        default {

        }
    }
    
    if { [catch {exec $where $pandocCmd} msg1] != 0  || [catch {exec $where $pdflatexCmd} msg2] != 0} {
        puts "pdflatex oder pandoc ist nicht installiert oder wird nicht gefunden. Bitte überprüfen Sie die Installation."
        return "Fehler pandoc: $msg1 :: pdflatex: $msg2"
    }
    return "ok"
}

puts "pandoc pdflatex : [pandocpdflatexExists]"

# Funktion zum Konvertieren von Markdown-Dateien in HTML und PDF
proc convertMarkdown {inputFile yamlFile outputDir} {
    set fileName [file rootname [file tail $inputFile]]

    set outputHTML [file join $outputDir "${fileName}.html"]
    set outputPDF [file join $outputDir "${fileName}.pdf"]

    # HTML konvertieren
    set cmdHTML [list pandoc $inputFile --metadata-file $yamlFile -o $outputHTML]
    eval exec $cmdHTML

    # PDF konvertieren
    set cmdPDF [list pandoc $inputFile --pdf-engine=pdflatex --metadata-file $yamlFile -o $outputPDF]
    eval exec $cmdPDF


    puts "Konvertierung abgeschlossen: $outputHTML und $outputPDF"
    return [list [file normalize $outputHTML]  [file normalize $outputPDF]]
}


# Beispielaufruf
if {[info script] eq $argv0} {
    set inputFile "example.md"
    set yamlFile "metadata.yaml"
    set outputDir "output"

    # Überprüfen, ob Ausgabeverzeichnis existiert, andernfalls erstellen
    if {![file exists $outputDir]} {
        file mkdir $outputDir
    }

    # Konvertierung ausführen
    set outputList [convertMarkdown $inputFile $yamlFile $outputDir]

    
    #pdfViewer call
    proc pdfViewer {pdffile} {
        # platform
        switch -- $::tcl_platform(platform) {
            windows {
                set os "windows"
                exec cmd /c "" $pdffile
            }
            unix {
                set os "unix"
                exec {*}[auto_execok xdg-open] $pdffile
            }
            macintosh {
                set os "macintosh"

            }
            default {
                set os "default"
            }
        }
    }
    puts "outputList: $outputList"
    pdfViewer [lindex $outputList 1]


}


if {0} {

}