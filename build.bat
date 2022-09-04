:: This script is supposed to be executed from your DS installation folder.
:: TankCreator and gaspy are expected to be in sibling dirs.

:: name of map
set map=green-range
:: name of map, case-sensitive
set map_cs=Green Range
:: path of DSLOA documents dir (where Bits are)
set doc_dsloa=%USERPROFILE%\Documents\Dungeon Siege LoA
:: path of DS installation
set ds=.
:: path of TankCreator
set tc=..\TankCreator
:: path of GasPy
set gaspy=..\gaspy

:: param
set mode=%1
echo %mode%

:: pre-build checks
pushd %gaspy%
venv\Scripts\python -m build.check_player_world_locations %map%
if %errorlevel% neq 0 pause
popd

:: Compile map file
rmdir /S /Q "%tmp%\Bits"
robocopy "%doc_dsloa%\Bits\world\maps\%map%" "%tmp%\Bits\world\maps\%map%" /E
pushd %gaspy%
venv\Scripts\python -m build.fix_start_positions_required_levels %map% "%tmp%\Bits"
if %errorlevel% neq 0 pause
popd
%tc%\RTC.exe -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsmap" -copyright "CC-BY-SA 2022" -title "%map_cs%" -author "Johannes Förstner"
if %errorlevel% neq 0 pause

:: Compile main resource file
rmdir /S /Q "%tmp%\Bits"
robocopy "%doc_dsloa%\Bits\art" "%tmp%\Bits\art" /E /xf .gitignore /xf *.psd
robocopy "%doc_dsloa%\Bits\sound\effects" "%tmp%\Bits\sound\effects" /E
robocopy "%doc_dsloa%\Bits\world\ai\jobs\%map%" "%tmp%\Bits\world\ai\jobs\%map%" /E
robocopy "%doc_dsloa%\Bits\world\contentdb\templates\%map%" "%tmp%\Bits\world\contentdb\templates\%map%" /E
robocopy "%doc_dsloa%\Bits\world\global\moods\%map%" "%tmp%\Bits\world\global\moods\%map%" /E
SETLOCAL EnableDelayedExpansion
for /f %%f in ('dir /b %tmp%\Bits\world\global\moods\%map%') do (
  set moods_file=Bits\world\global\moods\%map%\%%f
  powershell -Command "(Get-Content '%doc_dsloa%\!moods_file!') -replace 'standard_track = (.*); // (.*)','standard_track = $2; // $1' | Out-File -encoding ASCII '%tmp%\!moods_file!'"
  if %errorlevel% neq 0 pause
)
%tc%\RTC.exe -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsres" -copyright "CC-BY-SA 2022" -title "%map_cs%" -author "Johannes Förstner"
if %errorlevel% neq 0 pause

if not "%mode%"=="light" (
  call "%doc_dsloa%\Bits\build-music.bat"
)

:: Cleanup
rmdir /S /Q "%tmp%\Bits"
