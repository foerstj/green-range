:: Compile German language resource file
rmdir /S /Q "%tmp%\Bits"
robocopy "%bits%\language" "%tmp%\Bits\language" %res%-* /S
robocopy "%bits%\language" "%tmp%\Bits\language" minibits-* /S

robocopy "%bits%\art" "%tmp%\Bits\art" /S *.de.raw
pushd "%tmp%\Bits\art\bitmaps\items\grass"
setlocal enableDelayedExpansion
for %%F in (*.de.raw) do (
  set "name=%%F"
  ren "!name!" "!name:.de=!"
)
endlocal
popd

"%tc%\RTC.exe" -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.de.dsres" -copyright "%copyright%" -title "%title%" -author "%author%"
if %errorlevel% neq 0 pause
