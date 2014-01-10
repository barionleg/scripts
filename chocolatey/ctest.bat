@echo off

if [%1]==[] goto usage
cinst %1 -source \\chocolatey.ise.com\chocotest\%1
@echo Done.
goto :eof

:usage
@echo Usage: %0 ^<TestPackageName^>
exit /B 1



