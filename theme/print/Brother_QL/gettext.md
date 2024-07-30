Problem with gettext
```
append result err_GetText [catch {set objGetText [$bpacDoc -call GetText 1 0,Company]} res] objGetText $res
```
```
 error with GetText:  Parameter error. Offending parameter position 2. Typenkonflikt.
```

VARIANT_BOOL bpac::IDocument::GetText (LONG index, ref BSTR text)
+ Acquires the text data of the specified line. 
+ Returns the line number of the text in the document.
+ Arguments:
  + index  	Index (0 onwards) of the text line to be acquired
  +  text  	Pointer to the buffer in which text is to be acquired

Returned value: Success or Failure
