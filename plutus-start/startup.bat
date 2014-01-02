@echo off
if "%OS%" == "Windows_NT" setlocal
rem ---------------------------------------------------------------------------
rem Start script for the PLUTUS Platform
rem
rem ---------------------------------------------------------------------------

rem Guess PLUTUS_HOME if not defined

set "CURRENT_DIR=%cd%"
if not "%PLUTUS_HOME%" == "" goto gotHome
set "PLUTUS_HOME=%CURRENT_DIR%"
if exist "%PLUTUS_HOME%\bin\plutus.bat" goto okHome
cd ..
set "CATALINA_HOME=%cd%"
cd "%CURRENT_DIR%"
:gotHome
if exist "%PLUTUS_HOME%\bin\catalina.bat" goto okHome
echo Thre PLUTUS_HOME environment variable is not defined correctly
echo This environment variable is needed to run this program
goto end
:okHome

set "EXECUTABLE=%PLUTUS_HOME%\bin\plutus.bat"

rem Check that target executable exists
if exist "%EXECUTABLE%" goto okExec
echo Cannot find "%EXECUTABLE%"
echo This file is needed to run this program
goto end
:okExec

rem Get remaining unshifted command line arguments and save them in the
set CMD_LINE_ARGS=
:setArgs
if ""%1""=="""" goto doneSetArgs
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
shift
goto setArgs
:doneSetArgs


call "%EXECUTABLE%"  %CMD_LINE_ARGS%

:end
pause