:: name of map, case-sensitive
set map_cs=Green Range
:: namespace of resources
set res=green-range
:: path of DSLOA documents dir (where Bits are)
set doc_dsloa=%USERPROFILE%\Documents\Dungeon Siege LoA
:: path of DS installation
set ds=.
:: path of TankCreator
set tc=..\TankCreator

:: Compile German language resource file
rmdir /S /Q "%tmp%\Bits"
robocopy "%doc_dsloa%\Bits\language" "%tmp%\Bits\language" %res%-* /S
robocopy "%doc_dsloa%\Bits\language" "%tmp%\Bits\language" minibits-* /S

robocopy "%doc_dsloa%\Bits\art" "%tmp%\Bits\art" /S *.de.raw
pushd "%tmp%\Bits\art\bitmaps\items\grass"
setlocal enableDelayedExpansion
for %%F in (*.de.raw) do (
  set "name=%%F"
  ren "!name!" "!name:.de=!"
)
endlocal
popd

%tc%\RTC.exe -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs% de.dsres" -copyright "CC-BY-SA 2023" -title "%map_cs%" -author "Johannes Förstner"
if %errorlevel% neq 0 pause
