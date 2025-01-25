:: name of map
set map=green-range
:: name of map, case-sensitive
set map_cs=Green Range
:: namespace of resources
set res=green-range

:: path of Bits dir
set bits=%~dp0.
:: path of DS installation
set ds=%DungeonSiege%
:: path of TankCreator
set tc=%TankCreator%

set copyright=CC-BY-SA 2024
set title=%map_cs%
set author=Johannes Förstner

:: param
set mode=%1
echo %mode%

:: pre-build checks
pushd %gaspy%
setlocal EnableDelayedExpansion
if not "%mode%"=="light" (
  set checks=standard
  if "%mode%"=="release" (
    set checks=all
  )
  venv\Scripts\python -m build.pre_build_checks %map% --check !checks!
  if !errorlevel! neq 0 pause
)
endlocal
popd

:: Compile map file
rmdir /S /Q "%tmp%\Bits"
if not "%mode%"=="light" (
  robocopy "%bits%\world\maps\%map%" "%tmp%\Bits\world\maps\%map%" /E /xf .gitignore
)
if "%mode%"=="light" (
  robocopy "%bits%\world\maps\%map%" "%tmp%\Bits\world\maps\%map%" /E /xd regions
  ::for %%r in (mountains-x19z00-bridge longbourne-east longbourne-main longbourne-west longbourne-west-cellar) do (
  for %%r in (dream-cave-a dream-cave-b dream-cave-bottom) do (
    robocopy "%bits%\world\maps\%map%\regions\%%r" "%tmp%\Bits\world\maps\%map%\regions\%%r" /E
  )
)
pushd %gaspy%
venv\Scripts\python -m build.fix_start_positions_required_levels %map% "%tmp%\Bits"
if %errorlevel% neq 0 pause
setlocal EnableDelayedExpansion
if "%mode%"=="release" (
  venv\Scripts\python -m build.add_world_levels %map% "%tmp%\Bits" "%bits%"
  if !errorlevel! neq 0 pause
)
endlocal
popd
"%tc%\RTC.exe" -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsmap" -copyright "%copyright%" -title "%title%" -author "%author%"
if %errorlevel% neq 0 pause

:: Compile main resource file
rmdir /S /Q "%tmp%\Bits"
robocopy "%bits%\art" "%tmp%\Bits\art" /E /xf .gitignore /xf *.psd /xf *.xcf /xf *.de.raw
robocopy "%bits%\sound\effects" "%tmp%\Bits\sound\effects" /E
robocopy "%bits%\world\ai\jobs\%res%" "%tmp%\Bits\world\ai\jobs\%res%" /E
robocopy "%bits%\world\ai\jobs\minibits" "%tmp%\Bits\world\ai\jobs\minibits" /E
robocopy "%bits%\world\contentdb\components" "%tmp%\Bits\world\contentdb\components" /E
robocopy "%bits%\world\contentdb\templates\%res%" "%tmp%\Bits\world\contentdb\templates\%res%" /E
robocopy "%bits%\world\contentdb\templates\minibits" "%tmp%\Bits\world\contentdb\templates\minibits" /E
robocopy "%bits%\world\global\moods\%res%" "%tmp%\Bits\world\global\moods\%res%" /E
robocopy "%bits%\world\global\effects" "%tmp%\Bits\world\global\effects" %res%-* /S
robocopy "%bits%\world\global\effects" "%tmp%\Bits\world\global\effects" minibits-* /S
pushd %gaspy%
venv\Scripts\python -m build.swap_music_tracks "%tmp%\Bits"
if %errorlevel% neq 0 pause
popd
"%tc%\RTC.exe" -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsres" -copyright "%copyright%" -title "%title%" -author "%author%"
if %errorlevel% neq 0 pause

if not "%mode%"=="light" (
  call "%bits%\build-music.bat"
  call "%bits%\build-de.bat"
)

:: Cleanup
rmdir /S /Q "%tmp%\Bits"
