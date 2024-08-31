proc display_token_position {text token_data} {
    # Extrahiere die relevanten Werte
    set token_type [lindex $token_data 0]
    set token_value [lindex $token_data 1]
    set line_number [lindex $token_data end-1]  ;# Vorletztes Element
    set offset [lindex $token_data end]         ;# Letztes Element
    
    # Überprüfen, ob line_number und offset numerisch sind
    if {![string is integer -strict $line_number] || ![string is integer -strict $offset]} {
        puts "Ungültige Zeilennummer oder Offset: $line_number, $offset"
        return
    }

    # Zeilenumbrüche im Text aufteilen
    set lines [split $text "\n"]
    
    # Zeile holen
    set line [lindex $lines [expr {$line_number - 1}]]

    # Position markieren
    set token_length [string length $token_value]
    set before [string range $line 0 [expr {$offset - 1}]]
    set token_part [string range $line $offset [expr {$offset + $token_length - 1}]]
    set after [string range $line [expr {$offset + $token_length}] end]
    
    # Ausgabe
    puts "Token: $token_type"
    puts "Gefunden in Zeile: $line_number, Position: $offset"
    puts "Zeile: $before[string map {\[ \\[ \] \\]} $token_part]$after"  ;# Korrektur hier
    puts "Token-Wert: $token_value"
    puts "-----------------------------"
}

proc add_token {tokens type type_value content line_number offset content_length multiline end_line end_offset {context ""} {parent ""}} {
    lappend tokens [list $type $type_value $content $line_number $offset $content_length $multiline $end_line $end_offset $context $parent]
    return $tokens
}



proc markdown_lexer {text {line_number 1} {offset 0} {parent ""} {context ""}} {
    set lines [split $text "\n"]  ;# Text in Zeilen aufteilen
    set tokens {}  ;# Liste für die Token
    set in_code_block 0
    foreach line $lines {
        # Leere Zeilen ignorieren, falls erwünscht
        if {[string trim $line] eq ""} {
            incr line_number
            continue
        }

        # Codeblock beginnen oder beenden
        if {[regexp {^```(\w*)} $line -> language]} {
            if {$in_code_block} {
                set in_code_block 0
                set tokens [add_token $tokens "CODE_BLOCK_END" "```" "" $line_number $offset 3 1 $line_number [expr {$offset + 3}] $context $parent]
            } else {
                set in_code_block 1
                set tokens [add_token $tokens "CODE_BLOCK_START" $language "" $line_number $offset 3 1 $line_number [expr {$offset + 3}] $context $parent]
            }
            incr line_number
            continue
        }

        # Wenn wir uns in einem Codeblock befinden, den gesamten Text als Code behandeln
        if {$in_code_block} {
            set tokens [add_token $tokens "CODE" "" $line $line_number $offset [string length $line] 1 $line_number [expr {$offset + [string length $line]}] "CODE_BLOCK" $parent]
            incr line_number
            continue
        }

        # Überschrift erkennen
        if {[regexp {^(#+)\s+(.*)} $line -> hashes content]} {
            set tokens [add_token $tokens "HEADER" [string length $hashes] $content $line_number $offset [string length $content] 0 0 0 $parent]

        # Ungeordnete Liste erkennen
        } elseif {[regexp {^\*\s+(.*)} $line -> content]} {
            set tokens [add_token $tokens "LIST_ITEM" "*" $content $line_number $offset [string length $content] 0 0 0 "LIST" $parent]

        # Geordnete Liste erkennen
        } elseif {[regexp {^\d+\.\s+(.*)} $line -> content]} {
            set tokens [add_token $tokens "ORDERED_LIST_ITEM" [string range $line 0 [expr {[string first " " $line] - 1]}] $content $line_number $offset [string length $content] 0 0 0 "ORDERED_LIST" $parent]

        # Tabelle erkennen
        } elseif {[regexp {^\s*\|?[-:]+\|[-:| ]*} $line] || [regexp {^\s*\|.*\|} $line]} {
            set tokens [add_token $tokens "TABLE_ROW" "" $line $line_number $offset [string length $line] 0 0 0 "TABLE" $parent]

        # Bild erkennen
        } elseif {[regexp {^(.*?)(!\[(.*?)\]\((.*?)\))(.*)$} $line -> before image alt_text img_url after]} {
            if {$before ne ""} {
                set tokens [add_token $tokens "TEXT" "" $before $line_number $offset [string length $before] 0 0 0 $context $parent]
            }
            set tokens [add_token $tokens "IMAGE" $alt_text $img_url $line_number [expr {$offset + [string first "!\[" $line]}] [string length $alt_text] 0 0 0 $context $parent]
            if {$after ne ""} {
                set tokens [concat $tokens [markdown_lexer $after $line_number [expr {$offset + [string length $line] - [string length $after]}] $parent $context]]
            }

        # Link erkennen
        } elseif {[regexp {^(.*?)(\[(.*?)\]\((.*?)\))(.*)$} $line -> before link link_text link_url after]} {
            if {$before ne ""} {
                set tokens [add_token $tokens "TEXT" "" $before $line_number $offset [string length $before] 0 0 0 $context $parent]
            }
            set tokens [add_token $tokens "LINK" $link_text $link_url $line_number [expr {$offset + [string first "\[" $line]}] [string length $link_text] 0 0 0 $context $parent]
            if {$after ne ""} {
                set tokens [concat $tokens [markdown_lexer $after $line_number [expr {$offset + [string length $line] - [string length $after]}] $parent $context]]
            }

        # Inline-Code erkennen
        } elseif {[regexp {^(.*?)(`[^`]+`)(.*)$} $line -> before code after]} {
            if {$before ne ""} {
                set tokens [add_token $tokens "TEXT" "" $before $line_number $offset [string length $before] 0 0 0 $context $parent]
            }
            set tokens [add_token $tokens "INLINE_CODE" "" [string trim $code "`"] $line_number [expr {$offset + [string first "`" $line]}] [string length $code] 0 0 0 $context $parent]
            if {$after ne ""} {
                set tokens [concat $tokens [markdown_lexer $after $line_number [expr {$offset + [string length $line] - [string length $after]}] $parent $context]]
            }

        # Blockzitat erkennen
        } elseif {[regexp {^>\s+(.*)} $line -> content]} {
            set tokens [add_token $tokens "BLOCKQUOTE" "" $content $line_number $offset [string length $content] 0 0 0 "BLOCKQUOTE" $parent]

        # Fettgedruckter Text erkennen
        } elseif {[regexp {^(.*?)(\*\*[^*]+\*\*)(.*)$} $line -> before bold after]} {
            if {$before ne ""} {
                set tokens [add_token $tokens "TEXT" "" $before $line_number $offset [string length $before] 0 0 0 $context $parent]
            }
            set tokens [add_token $tokens "BOLD" "" [string trim $bold "**"] $line_number [expr {$offset + [string first "**" $line]}] [string length $bold] 0 0 0 $context $parent]
            if {$after ne ""} {
                set tokens [concat $tokens [markdown_lexer $after $line_number [expr {$offset + [string length $line] - [string length $after]}] $parent $context]]
            }

        # Kursiver Text erkennen
        } elseif {[regexp {^(.*?)(\*[^*]+\*)(.*)$} $line -> before italic after]} {
            if {$before ne ""} {
                set tokens [add_token $tokens "TEXT" "" $before $line_number $offset [string length $before] 0 0 0 $context $parent]
            }
            set tokens [add_token $tokens "ITALIC" "" [string trim $italic "*"] $line_number [expr {$offset + [string first "*" $line]}] [string length $italic] 0 0 0 $context $parent]
            if {$after ne ""} {
                set tokens [concat $tokens [markdown_lexer $after $line_number [expr {$offset + [string length $line] - [string length $after]}] $parent $context]]
            }

        # Normaler Text (keine Markdown-Syntax erkannt)
        } else {
            set tokens [add_token $tokens "TEXT" "" $line $line_number $offset [string length $line] 0 0 0 $context $parent]
        }
        incr line_number
    }

    return $tokens
}



# Beispiel Markdown-Text
set markdown {
# Header 1

* Item 1
* Item 2

This is a [link](http://example.com) and `inline code`.

![alt text](image.jpg)

> This is a blockquote.

**Bold text** and *italic text*.

  # Kopf

# Kopf

Here is a table:

  | Header 1 | Header 2 |
  |----------|----------|
  | Row 1    | Row 2    |

```tcl
  set x 10
```

}

# Aufruf des Lexers
set tokens [markdown_lexer $markdown]
set i 0
foreach token $tokens {
  puts "Aufruf [incr i]: $token"
}

# Anzeigen der Positionen für jedes Token
foreach token $tokens {
    set type [lindex $token 0]
    set line_number [lindex $token end-1]
    set offset [lindex $token end]
    set value [lrange $token  1 end-2 ]
    puts "länge: [llength $token]  $type :::  $value ::: $line_number $offset"
}

puts \n 
foreach token $tokens {
#  display_token_position $markdown $token
}

# output
if {0} {
/usr/bin/tclsh /home/greg/Project/tcl/2024/thema/pandoc/mlexer/markdownlexerlib1.tcl 


Aufruf 1: HEADER 1 {Header 1} 2 0 8 0 0 0 {} {}
Aufruf 2: LIST_ITEM * {Item 1} 4 0 6 0 0 0 LIST {}
Aufruf 3: LIST_ITEM * {Item 2} 5 0 6 0 0 0 LIST {}
Aufruf 4: TEXT {} {This is a } 7 0 10 0 0 0 {} {}
Aufruf 5: LINK link http://example.com 7 10 4 0 0 0 {} {}
Aufruf 6: TEXT {} { and } 7 36 5 0 0 0 {} {}
Aufruf 7: INLINE_CODE {} {inline code} 7 41 13 0 0 0 {} {}
Aufruf 8: TEXT {} . 7 54 1 0 0 0 {} {}
Aufruf 9: IMAGE {alt text} image.jpg 9 0 8 0 0 0 {} {}
Aufruf 10: BLOCKQUOTE {} {This is a blockquote.} 11 0 21 0 0 0 BLOCKQUOTE {}
Aufruf 11: BOLD {} {Bold text} 13 0 13 0 0 0 {} {}
Aufruf 12: TEXT {} { and } 13 13 5 0 0 0 {} {}
Aufruf 13: ITALIC {} {italic text} 13 18 13 0 0 0 {} {}
Aufruf 14: TEXT {} . 13 31 1 0 0 0 {} {}
Aufruf 15: TEXT {} {  # Kopf} 15 0 8 0 0 0 {} {}
Aufruf 16: HEADER 1 Kopf 17 0 4 0 0 0 {} {}
Aufruf 17: TEXT {} {Here is a table:} 19 0 16 0 0 0 {} {}
Aufruf 18: TABLE_ROW {} {  | Header 1 | Header 2 |} 21 0 25 0 0 0 TABLE {}
Aufruf 19: TABLE_ROW {} {  |----------|----------|} 22 0 25 0 0 0 TABLE {}
Aufruf 20: TABLE_ROW {} {  | Row 1    | Row 2    |} 23 0 25 0 0 0 TABLE {}
Aufruf 21: CODE_BLOCK_START tcl {} 25 0 3 1 25 3 {} {}
Aufruf 22: CODE {} {  set x 10} 26 0 10 1 26 10 CODE_BLOCK {}
Aufruf 23: CODE_BLOCK_END ``` {} 27 0 3 1 27 3 {} {}
länge: 11  HEADER :::  1 {Header 1} 2 0 8 0 0 0 :::  
länge: 11  LIST_ITEM :::  * {Item 1} 4 0 6 0 0 0 ::: LIST 
länge: 11  LIST_ITEM :::  * {Item 2} 5 0 6 0 0 0 ::: LIST 
länge: 11  TEXT :::  {} {This is a } 7 0 10 0 0 0 :::  
länge: 11  LINK :::  link http://example.com 7 10 4 0 0 0 :::  
länge: 11  TEXT :::  {} { and } 7 36 5 0 0 0 :::  
länge: 11  INLINE_CODE :::  {} {inline code} 7 41 13 0 0 0 :::  
länge: 11  TEXT :::  {} . 7 54 1 0 0 0 :::  
länge: 11  IMAGE :::  {alt text} image.jpg 9 0 8 0 0 0 :::  
länge: 11  BLOCKQUOTE :::  {} {This is a blockquote.} 11 0 21 0 0 0 ::: BLOCKQUOTE 
länge: 11  BOLD :::  {} {Bold text} 13 0 13 0 0 0 :::  
länge: 11  TEXT :::  {} { and } 13 13 5 0 0 0 :::  
länge: 11  ITALIC :::  {} {italic text} 13 18 13 0 0 0 :::  
länge: 11  TEXT :::  {} . 13 31 1 0 0 0 :::  
länge: 11  TEXT :::  {} {  # Kopf} 15 0 8 0 0 0 :::  
länge: 11  HEADER :::  1 Kopf 17 0 4 0 0 0 :::  
länge: 11  TEXT :::  {} {Here is a table:} 19 0 16 0 0 0 :::  
länge: 11  TABLE_ROW :::  {} {  | Header 1 | Header 2 |} 21 0 25 0 0 0 ::: TABLE 
länge: 11  TABLE_ROW :::  {} {  |----------|----------|} 22 0 25 0 0 0 ::: TABLE 
länge: 11  TABLE_ROW :::  {} {  | Row 1    | Row 2    |} 23 0 25 0 0 0 ::: TABLE 
länge: 11  CODE_BLOCK_START :::  tcl {} 25 0 3 1 25 3 :::  
länge: 11  CODE :::  {} {  set x 10} 26 0 10 1 26 10 ::: CODE_BLOCK 
länge: 11  CODE_BLOCK_END :::  ``` {} 27 0 3 1 27 3 :::  



Press return to continue


}