@echo off
if [%1]==[] goto :type

(for %%a in (%*) do (
echo %%a
))

goto :end

:type
type "c:\tmp\program files\testbat.bat"


:end