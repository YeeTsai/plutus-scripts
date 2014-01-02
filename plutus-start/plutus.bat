@echo off

if "%OS%" == "Windows_NT" setlocal
rem ---------------------------------------------------------------------------
rem Start/Stop Script for the PLUTUS Platform
rem
rem Environment Variable Prerequisites
rem
rem   Do not set the variables in this script. Instead put them into a script
rem   setenv.bat in PLUTUS_BASE/bin to keep your customizations separate.
rem
rem   PLUTUS_HOME   May point at your PLUTUS "build" directory.
rem
rem   PLUTUS_BASE   (Optional) Base directory for resolving dynamic portions
rem                   of a PLUTUS installation.  If not present, resolves to
rem                   the same directory that PLUTUS_HOME points to.
rem
rem   PLUTUS_OPTS   (Optional) Java runtime options used when the "start",
rem                   "run" or "debug" command is executed.
rem                   Include here and not in JAVA_OPTS all options, that should
rem                   only be used by Tomcat itself, not by the stop process,
rem                   the version command etc.
rem                   Examples are heap size, GC logging, JMX ports etc.
rem
rem   PLUTUS_TMPDIR (Optional) Directory path location of temporary directory
rem                   the JVM should use (java.io.tmpdir).  Defaults to
rem                   %PLUTUS_BASE%\temp.
rem
rem   JAVA_HOME       Must point at your Java Development Kit installation.
rem                   Required to run the with the "debug" argument.
rem
rem   JRE_HOME        Must point at your Java Runtime installation.
rem                   Defaults to JAVA_HOME if empty. If JRE_HOME and JAVA_HOME
rem                   are both set, JRE_HOME is used.
rem
rem   JAVA_OPTS       (Optional) Java runtime options used when any command
rem                   is executed.
rem                   Include here and not in PLUTUS_OPTS all options, that
rem                   should be used by Tomcat and also by the stop process,
rem                   the version command etc.
rem                   Most options should go into PLUTUS_OPTS.
rem
rem   JAVA_ENDORSED_DIRS (Optional) Lists of of semi-colon separated directories
rem                   containing some jars in order to allow replacement of APIs
rem                   created outside of the JCP (i.e. DOM and SAX from W3C).
rem                   It can also be used to update the XML parser implementation.
rem                   Defaults to $PLUTUS_HOME/endorsed.
rem
rem   JPDA_TRANSPORT  (Optional) JPDA transport used when the "jpda start"
rem                   command is executed. The default is "dt_socket".
rem
rem   JPDA_ADDRESS    (Optional) Java runtime options used when the "jpda start"
rem                   command is executed. The default is 8000.
rem
rem   JPDA_SUSPEND    (Optional) Java runtime options used when the "jpda start"
rem                   command is executed. Specifies whether JVM should suspend
rem                   execution immediately after startup. Default is "n".
rem
rem   JPDA_OPTS       (Optional) Java runtime options used when the "jpda start"
rem                   command is executed. If used, JPDA_TRANSPORT, JPDA_ADDRESS,
rem                   and JPDA_SUSPEND are ignored. Thus, all required jpda
rem                   options MUST be specified. The default is:
rem
rem                   -agentlib:jdwp=transport=%JPDA_TRANSPORT%,
rem                       address=%JPDA_ADDRESS%,server=y,suspend=%JPDA_SUSPEND%
rem
rem   LOGGING_CONFIG  (Optional) Override Tomcat's logging config file
rem                   Example (all one line)
rem                   set LOGGING_CONFIG="-Djava.util.logging.config.file=%PLUTUS_BASE%\conf\logging.properties"
rem
rem   LOGGING_MANAGER (Optional) Override Tomcat's logging manager
rem                   Example (all one line)
rem                   set LOGGING_MANAGER="-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager"
rem
rem   TITLE           (Optional) Specify the title of Tomcat window. The default
rem                   TITLE is Tomcat if it's not specified.
rem                   Example (all one line)
rem                   set TITLE=Tomcat.Cluster#1.Server#1 [%DATE% %TIME%]
rem
rem
rem
rem $Id: PLUTUS.bat 1344732 2012-05-31 14:08:02Z kkolinko $
rem ---------------------------------------------------------------------------

rem Suppress Terminate batch job on CTRL+C
if not ""%1"" == ""run"" goto mainEntry
if "%TEMP%" == "" goto mainEntry
if exist "%TEMP%\%~nx0.run" goto mainEntry
echo Y>"%TEMP%\%~nx0.run"
if not exist "%TEMP%\%~nx0.run" goto mainEntry
echo Y>"%TEMP%\%~nx0.Y"
call "%~f0" %* <"%TEMP%\%~nx0.Y"
rem Use provided errorlevel
set RETVAL=%ERRORLEVEL%
del /Q "%TEMP%\%~nx0.Y" >NUL 2>&1
exit /B %RETVAL%
:mainEntry
del /Q "%TEMP%\%~nx0.run" >NUL 2>&1

rem Guess PLUTUS_HOME if not defined
set "CURRENT_DIR=%cd%"
if not "%PLUTUS_HOME%" == "" goto gotHome
set "PLUTUS_HOME=%CURRENT_DIR%"
if exist "%PLUTUS_HOME%\bin\plutus.bat" goto okHome
cd ..
set "PLUTUS_HOME=%cd%"
cd "%CURRENT_DIR%"
:gotHome

if exist "%PLUTUS_HOME%\bin\plutus.bat" goto okHome
echo The PLUTUS_HOME environment variable is not defined correctly
echo This environment variable is needed to run this program
goto end
:okHome

rem Copy PLUTUS_BASE from PLUTUS_HOME if not defined
if not "%PLUTUS_BASE%" == "" goto gotBase
set "PLUTUS_BASE=%PLUTUS_HOME%"
:gotBase

rem Ensure that any user defined CLASSPATH variables are not used on startup,
rem but allow them to be specified in setenv.bat, in rare case when it is needed.
set CLASSPATH=

rem Get standard environment variables
if not exist "%PLUTUS_BASE%\bin\setenv.bat" goto checkSetenvHome
call "%PLUTUS_BASE%\bin\setenv.bat"
goto setenvDone
:checkSetenvHome
if exist "%PLUTUS_HOME%\bin\setenv.bat" call "%PLUTUS_HOME%\bin\setenv.bat"
:setenvDone

rem Get standard Java environment variables
if exist "%PLUTUS_HOME%\bin\setclasspath.bat" goto okSetclasspath
echo Cannot find "%PLUTUS_HOME%\bin\setclasspath.bat"
echo This file is needed to run this program
goto end
:okSetclasspath
call "%PLUTUS_HOME%\bin\setclasspath.bat" %1
if errorlevel 1 goto end

rem Add on extra jar file to CLASSPATH
rem Note that there are no quotes as we do not want to introduce random
rem quotes into the CLASSPATH
if "%CLASSPATH%" == "" goto emptyClasspath
set "CLASSPATH=%CLASSPATH%;"
:emptyClasspath
set "CLASSPATH=%CLASSPATH%%PLUTUS_HOME%\bin\platform-1.0.jar"

if not "%PLUTUS_TMPDIR%" == "" goto gotTmpdir
set "PLUTUS_TMPDIR=%PLUTUS_BASE%\flowTemp"
:gotTmpdir

rem ----- Execute The Requested Command ---------------------------------------

echo Using PLUTUS_BASE:   "%PLUTUS_BASE%"
echo Using PLUTUS_HOME:   "%PLUTUS_HOME%"
echo Using PLUTUS_TMPDIR: "%PLUTUS_TMPDIR%"
if ""%1"" == ""debug"" goto use_jdk
echo Using JRE_HOME:        "%JRE_HOME%"
goto java_dir_displayed
:use_jdk
echo Using JAVA_HOME:       "%JAVA_HOME%"
:java_dir_displayed
echo Using CLASSPATH:       "%CLASSPATH%"

set _EXECJAVA=%_RUNJAVA%
set MAINCLASS=org.yeesoft.plutus.platform.PlatformRunner
set SECURITY_POLICY_FILE=
set DEBUG_OPTS=
set PLUTUS_OPTS=-e e8326bf694ad49fb9b234e2736f9bbc0 -p 8881 -d
set JNI_OPTS=-Djava.library.path=%PLUTUS_BASE%\libs\win32

if ""%1"" == ""start"" goto doStart

:doStart
shift
if not "%OS%" == "Windows_NT" goto noTitle
if "%TITLE%" == "" set TITLE=Plutus
set _EXECJAVA=start "%TITLE%" %_RUNJAVA%

:execCmd
rem Get remaining unshifted command line arguments and save them in the
set CMD_LINE_ARGS=
:setArgs
if ""%1""=="""" goto doneSetArgs
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
shift
goto setArgs
:doneSetArgs

echo Using _EXECJAVA:   "%_EXECJAVA%"
echo Using JAVA_OPTS:   "%JAVA_OPTS%"
echo Using DEBUG_OPTS:   "%DEBUG_OPTS%"
echo Using JNI_OPTS:   "%JNI_OPTS%"
echo Using PLUTUS_OPTS:   "%PLUTUS_OPTS%"
echo Using CMD_LINE_ARGS:   "%CMD_LINE_ARGS%"

rem Execute Java with the applicable properties
%_EXECJAVA% %JAVA_OPTS% %DEBUG_OPTS% %JNI_OPTS% -jar %PLUTUS_HOME%\bin\platform-1.0.jar %MAINCLASS% %PLUTUS_OPTS% %CMD_LINE_ARGS%

:end