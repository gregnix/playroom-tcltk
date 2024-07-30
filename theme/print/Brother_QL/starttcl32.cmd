@echo off
setlocal

set Scriptpath=%cd%
set Tclscript=brqlprintbpac.tcl

set PATH=C:\Tcl.32\bin;%PATH%

set Tclprog=C:/Tcl.32/bin/wish.exe
set cmdtitle="Starter %Tclscript% in 32bit env"

start %cmdtitle% /d %Scriptpath%  %Tclprog% %Tclscript%

endlocal
exit

rem Explanation
rem/||(
starttcl32.cmd in ./

set Tclprog=C:/Tcl.32/bin/wish.exe
start %cmdtitle% /d %Scriptpath%  %Tclprog% %Tclscript%
 or
set Tclprog=C:/Tcl.32/bin/tclsh.exe
start %cmdtitle% /min /d %Scriptpath%  %Tclprog% %Tclscript%

%cd%: Type cd without parameters to display the current drive and directory.

 PATH 
Set the entry C:\Tcl.32\bin at the beginning of the PATH
set PATH=C:\Tcl.32\bin;%PATH%

64bit install in C:\Tcl: C:\Tcl\bin
32bit install in C:\Tcl\bin: C:\Tcl.32\bin

setlocal: Starts limiting the scope of changes.
endlocal: Stops limiting the scope of changes.
start: Launches a separate Command Prompt window to run a specified program or command.
)                                                               
