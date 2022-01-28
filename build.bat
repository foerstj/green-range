:: This script is supposed to be executed from your DS installation folder.
:: TankCreator is expected to be in a sibling dir.

:: name of map
set map=green-range
:: path of DSLOA documents dir (where Bits are)
set doc_dsloa=%USERPROFILE%\Documents\Dungeon Siege LoA
:: path of DS installation
set ds=.
:: path of TankCreator
set tc=..\TankCreator

:: Compile map file
rmdir /S /Q "%tmp%\Bits"
robocopy "%doc_dsloa%\Bits\world\maps\%map%" "%tmp%\Bits\world\maps\%map%" /E
%tc%\RTC.exe -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsmap" -copyright "CC-BY-SA 2021" -title "%map%" -author "Johannes Förstner"
if %errorlevel% neq 0 pause

:: Cleanup
rmdir /S /Q "%tmp%\Bits"
