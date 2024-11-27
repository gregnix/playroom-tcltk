package require struct::matrix
package require report
package require textutil
package require dicttool

# Rekursive Funktion zur Darstellung eines verschachtelten Dictionarys in einer String-Variable
proc dictToreportstring {dict {indent ""} {resultVarName "output"}} {
    # Variable zur Speicherung der Ausgabe initialisieren oder erweitern
    upvar $resultVarName result

    if {[dict is_dict $dict]} {
        # Durchlaufen aller Schlüssel-Wert-Paare im Dictionary
        foreach key [dict keys $dict] {
            # Hinzufügen des Schlüssels und Vorbereiten der Einrückung für untergeordnete Elemente
            append result "${indent}${key}:\n"
            dictToreportstring [dict get $dict $key] "${indent}  " result
        }
    } else {
        # Entfernen des letzten Zeilenumbruchs, wenn vorhanden, bevor der Wert hinzugefügt wird
        if {[string length $result] > 0} {
            set result [string range $result 0 end-1]
        }
        append result "${indent}$dict\n"
    }
}

# Beispiel zur Verwendung der Funktion
#set myOutput ""
#dict2tblstring {name "John Doe" age 30} "" myOutput
#puts $myOutput



# Rekursive Funktion zur Darstellung eines verschachtelten Dictionarys in einem Text-Widget
proc dictToreportwidget {widget dict {indent ""}} {
    # Überprüfung, ob der Wert ein Dictionary ist
    if {[dict is_dict $dict]} {
        # Durchlaufen aller Schlüssel-Wert-Paare im Dictionary
        foreach key [dict keys $dict] {
            $widget insert end "${indent}${key}:\n"
            # Rekursiver Aufruf zur Darstellung des untergeordneten Dictionarys, mit erhöhter Einrückung
            dictToreportwidget $widget [dict get $dict $key] "${indent}  "
        }
    } else {
        # Ausgabe des Werts, wenn es sich nicht um ein Dictionary handelt
        $widget insert "end -1l -1c" "${indent}$dict"
    }
}
 

proc listToreport {list {tw .frtext.text}} {
		if {[llength $list] > 1 } {
				::report::defstyle resultlist {{n 1}} {
						set templ_d  [lreplace [lreplace \
                    [split "[string repeat "  x" [columns]]  " x] \
                    0 0 {}] end end {}]
						set templ_tc [lreplace [lreplace \
                    [split "[string repeat "  x=x" [columns]]  " x] \
                    0 0 {}] end end {}]
						data        set $templ_d
						topdata     set [data get]
						topcapsep   set $templ_tc
						topcapsep   enable
						tcaption    $n
				}
				::struct::matrix m
				set thisrow 0
				set rowheader [lindex $list 0]
				foreach x [lrange $list 1 end] {
						set thiscol 0
						if { $thisrow == 0 } {
								set ncols [llength $rowheader]
								m add columns $ncols
								m add row
								foreach col $rowheader {
										m set cell $thiscol $thisrow $col
										incr thiscol
								}
								incr thisrow
								set thiscol 0
						}
						m add row
						foreach col $x {
								m set cell $thiscol $thisrow [::textutil::untabify2 [concat {*}$col] 4]
								incr thiscol
						}
						incr thisrow
						set nrows $thisrow
				}
				::report::report r $ncols style resultlist

				if {[winfo exists $tw]} {
						$tw insert end [r printmatrix m]
				} else {
						puts [r printmatrix m]
				}
				m destroy
				r destroy
				::report::rmstyle resultlist
		} else {
				puts $list
		}
}

