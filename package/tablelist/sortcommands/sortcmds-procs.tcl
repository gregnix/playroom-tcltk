
    
if {0} {    
#from  Tablelist:
-sortmode mode
Specifies how to compare the column's elements when invoking the sortbycolumn command with the given column index as first argument or the sortbycolumnlist command having the given column index as element of its first argument.  mode may have any of the following values:

  ascii
Use string comparison with Unicode code-point collation order (the name is for backward-compatibility reasons).  This is the default.
  asciinocase
This is the same as ascii, except that comparisons are handled in a case-insensitive manner.
  command
Use the command specified by the -sortcommand column configuration option to compare the column's elements.
  dictionary
Use dictionary-style comparison.  This is the same as ascii, except: (a) case is ignored except as a tie-breaker; (b) if two strings contain embedded numbers, the numbers compare as integers, not characters.  For example, bigBoy sorts between bigbang and bigboy, and x10y sorts between x9y and x11y.
  integer
Convert the elements to integers and use integer comparison.  If any of the elements cannot be converted to an integer (e.g., because it is an empty string) then a sort attempt will generate an error.  See the description of the -formatcommand option for the recommended way to avoid this problem.
  real
Convert the elements to floating-point values and use floating-point comparison.  If any of the elements cannot be converted to a floating-point value (e.g., because it is an empty string) then a sort attempt will generate an error.  See the description of the -formatcommand option for the recommended way to avoid this problem.
}

# Examples, but are already available with sortmode
# Procedure to compare
proc sortCmd {a b} {
    if {$a < $b} {
        return -1
    } elseif {$a > $b} {
        return 1
    } else {
        return 0
    }
    return 0
}

# Procedure to compare two string values in dictionary order
proc sortCmdDictionary {a b} {
    return [string compare $a $b]
}

# Procedure to compare two string values case-insensitively
proc sortCmdNoCase {a b} {
    return [string compare -nocase $a $b]
}


