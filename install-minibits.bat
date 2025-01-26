:: path of Bits dir
set bits=%~dp0.

pushd %gaspy%
venv\Scripts\python -m build.install_minibits --minibits "%minibits%" --bits "%bits%"
if %errorlevel% neq 0 pause
popd
