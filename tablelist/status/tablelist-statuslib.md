# Tablelist Status Library Manual

## Overview
This library provides functions to save and restore the status of a tablelist widget in Tcl/Tk. The status includes sorting information, selected rows, scroll position, visible rows and columns, and column widths. It supports sorting by a specified column ID (`sortID`) and allows for different sorting modes.

## Functions

### `save_tablelist_status`
Saves the current status of a tablelist widget.

**Usage:**
```tcl
set statusDict [save_tablelist_status $tbl ?sortModus? ?sortID?]

restore_tablelist_status $tbl $statusDict

```
+ tbl: The tablelist widget.
+ statusDict: The dictionary containing the saved status.
+ sortID: Optional. The ID of the column to sort by. Default is 0.
+ sortModus: Optional. The sorting mode. Default is 1 (sort by sortID).
+ sortModus 1: with sortID
+ sortModus 0: without sortID, with sortorder and sortcolumn, problem with both == ""
+ sortListByIndex

This function sorts a list of values based on a given sort index. It handles cases where the entire table is passed as a single value and ensures that missing IDs are added to the sort index.

### Todo
+ sortID 1: new lines how to sort?
+ sortModus 0: Sorting with non-unique sortid not clear for the values with non-unique sortid
+ sortModus 1: Sorting with non-unique sortid not clear for the values with non-unique sortid
+ problem columns width
