:: Compile resource file
rmdir /S /Q "%tmp%\Bits"
robocopy "%doc_dsloa%\Bits\world\global\moods\%map%" "%tmp%\Bits\world\global\moods\%map%" /E
robocopy "%doc_dsloa%\Bits\sound\music" "%tmp%\Bits\sound\music" /E
%tc%\RTC.exe -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs% music.dsres" -copyright "%copyright%" -title "%title%" -author "%author%"
if %errorlevel% neq 0 pause

:: Cleanup
rmdir /S /Q "%tmp%\Bits"
