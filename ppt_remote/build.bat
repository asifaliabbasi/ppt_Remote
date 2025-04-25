@echo off
echo Building PPT Host Controller...

REM Create virtual environment
python -m venv venv
call venv\Scripts\activate.bat

REM Install requirements
pip install -r requirements_exe.txt

REM Create executable
pyinstaller ppt_host.spec

REM Create installer
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer.iss

echo Build completed!
pause 