@ECHO OFF
IF %1.==. GOTO Usage
IF NOT EXIST %1.ASM GOTO FileNotFound
TASM.EXE -B -80 -Q -R16 %1.ASM
ECHO.
IF ERRORLEVEL 1 GOTO Error
CRPRGM82 %1.OBJ
:DelDone
DEL %1.LST
GOTO Done
:Error
ECHO %1.ASM contains errors!
DEL %1.OBJ
GOTO DelDone
:Usage
ECHO CrASH v1.1 Assembly File compiler
ECHO.
ECHO Usage:
ECHO   %0 [FileName]
ECHO.
ECHO [FileName] is the CrASH ASM source file.  Leave off the ASM extension.
GOTO Done
:FileNotFound
ECHO File Not Found: %1.ASM
:Done
ECHO.
pause
