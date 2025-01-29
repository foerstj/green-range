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

:: tank properties
set year=2025
set copyright=CC-BY-SA %year%
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
  venv\Scripts\python -m build.pre_build_checks %map% --check !checks! --bits "%bits%"
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
  for %%r in (ehb-border mountains-x00z19) do (
    robocopy "%bits%\world\maps\%map%\regions\%%r" "%tmp%\Bits\world\maps\%map%\regions\%%r" /E
  )
)
pushd %gaspy%
venv\Scripts\python -m build.fix_start_positions_required_levels %map% --bits "%tmp%\Bits"
if %errorlevel% neq 0 pause
setlocal EnableDelayedExpansion
if "%mode%"=="release" (
  venv\Scripts\python -m build.add_world_levels %map% --bits "%tmp%\Bits" --template-bits "%bits%"
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
venv\Scripts\python -m build.swap_music_tracks --bits "%tmp%\Bits"
if %errorlevel% neq 0 pause
popd
"%tc%\RTC.exe" -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsres" -copyright "%copyright%" -title "%title%" -author "%author%"
if %errorlevel% neq 0 pause

setlocal EnableDelayedExpansion
if not "%mode%"=="light" (
  :: Compile music resource file
  rmdir /S /Q "%tmp%\Bits"
  robocopy "%bits%\world\global\moods\%map%" "%tmp%\Bits\world\global\moods\%map%" /E
  robocopy "%bits%\sound\music" "%tmp%\Bits\sound\music" /E
  "%tc%\RTC.exe" -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs% music.dsres" -copyright "%copyright%" -title "%title%" -author "%author%"
  if !errorlevel! neq 0 pause

  :: Compile German language resource file
  rmdir /S /Q "%tmp%\Bits"
  robocopy "%bits%\language" "%tmp%\Bits\language" %res%-* /S
  robocopy "%bits%\language" "%tmp%\Bits\language" minibits-* /S
  :: overwrite textures
  robocopy "%bits%\art" "%tmp%\Bits\art" /S *.de.raw
  pushd "%tmp%\Bits\art\bitmaps\items\grass"
  for %%F in (*.de.raw) do (
    set "name=%%F"
    ren "!name!" "!name:.de=!"
  )
  popd
  :: tank it
  "%tc%\RTC.exe" -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.de.dsres" -copyright "%copyright%" -title "%title%" -author "%author%"
  if !errorlevel! neq 0 pause
)
endlocal

:: Cleanup
rmdir /S /Q "%tmp%\Bits"
