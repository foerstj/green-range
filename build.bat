:: This script is supposed to be executed from your DS installation folder.
:: TankCreator and gaspy are expected to be in sibling dirs.

:: name of map
set map=green-range
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
:: path of GasPy
set gaspy=..\gaspy

:: param
set mode=%1
echo %mode%

:: pre-build checks
pushd %gaspy%
venv\Scripts\python -m build.check_player_world_locations %map%
if %errorlevel% neq 0 pause
venv\Scripts\python -m build.check_moods %map%
if %errorlevel% neq 0 pause
venv\Scripts\python -m build.check_quests %map%
if %errorlevel% neq 0 pause
venv\Scripts\python -m build.check_dupe_node_ids %map%
if %errorlevel% neq 0 pause
popd

:: Compile map file
rmdir /S /Q "%tmp%\Bits"
robocopy "%doc_dsloa%\Bits\world\maps\%map%" "%tmp%\Bits\world\maps\%map%" /E
::robocopy "%doc_dsloa%\Bits\world\maps\%map%" "%tmp%\Bits\world\maps\%map%" /E /xd regions
::robocopy "%doc_dsloa%\Bits\world\maps\%map%\regions\dream-cave-a" "%tmp%\Bits\world\maps\%map%\regions\dream-cave-a" /E
::robocopy "%doc_dsloa%\Bits\world\maps\%map%\regions\dream-cave-b" "%tmp%\Bits\world\maps\%map%\regions\dream-cave-b" /E
::robocopy "%doc_dsloa%\Bits\world\maps\%map%\regions\dream-cave-bottom" "%tmp%\Bits\world\maps\%map%\regions\dream-cave-bottom" /E
::robocopy "%doc_dsloa%\Bits\world\maps\%map%\regions\mountains-x11z08" "%tmp%\Bits\world\maps\%map%\regions\mountains-x11z08" /E
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
robocopy "%doc_dsloa%\Bits\world\ai\jobs\%res%" "%tmp%\Bits\world\ai\jobs\%res%" /E
robocopy "%doc_dsloa%\Bits\world\contentdb\components" "%tmp%\Bits\world\contentdb\components" /E
robocopy "%doc_dsloa%\Bits\world\contentdb\templates\%res%" "%tmp%\Bits\world\contentdb\templates\%res%" /E
robocopy "%doc_dsloa%\Bits\world\contentdb\templates\minibits" "%tmp%\Bits\world\contentdb\templates\minibits" /E
robocopy "%doc_dsloa%\Bits\world\global\moods\%res%" "%tmp%\Bits\world\global\moods\%res%" /E
robocopy "%doc_dsloa%\Bits\world\global\effects" "%tmp%\Bits\world\global\effects" %res%-* /S
robocopy "%doc_dsloa%\Bits\world\global\effects" "%tmp%\Bits\world\global\effects" minibits-* /S
pushd %gaspy%
venv\Scripts\python -m build.swap_music_tracks "%tmp%\Bits"
if %errorlevel% neq 0 pause
popd
pause
%tc%\RTC.exe -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsres" -copyright "CC-BY-SA 2022" -title "%map_cs%" -author "Johannes Förstner"
if %errorlevel% neq 0 pause

if not "%mode%"=="light" (
  call "%doc_dsloa%\Bits\build-music.bat"
)

:: Cleanup
rmdir /S /Q "%tmp%\Bits"
