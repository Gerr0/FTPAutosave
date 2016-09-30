::GENERAL SETUP---------------------------------------------------------------
@ECHO OFF
VERIFY OTHER 2>NUL
SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS
IF ERRORLEVEL 1 (
	SET ErrorNum=001
	GOTO:ERROR
)
COLOR 0A & TITLE=FIREWALL TOOL
SET BOL_Write=TRUE
SET BOL_Delete=TRUE

:ARGUMENTCHECK
IF "%~1"=="/?" GOTO HELP REM Find out if user need help.
IF "%~1"=="-?" GOTO HELP
IF "%~1"=="help" GOTO HELP

:LOOPSTART
IF "%~1"=="" GOTO checkPrivileges REM Exit Loop if there are no more parameters.
IF "%~1"=="/check" SET BOL_Write=FALSE & SET BOL_Delete=FALSE && GOTO SCREEN
IF "%~1"=="/delete" SET BOL_Write=FALSE
SHIFT &	GOTO :LOOPSTART

:checkPrivileges
@ECHO OFF & CLS & ECHO.
NET FILE 1>NUL 2>NUL & IF ERRORLEVEL 1 (ECHO You must right-click and select & ECHO "RUN AS ADMINISTRATOR"  to run this tool. & ECHO. & ECHO.Exiting... & ECHO. & PAUSE & GOTO :EOF)
REM ... proceed here with admin rights ...

CD /d %~dp0

::MAIN SCREEN SETUP------------------------------------------------------------
:SCREEN
ECHO.
ECHO.----------------------------------------------------------------------
ECHO.                        FIREWALL CONFIG TOOL
ECHO.----------------------------------------------------------------------

::FIREWALL STUFF--------------------------------------------------------------
:FIREWALL
FOR %%x IN (NcFtpLs NcFtpGet) DO (
	FOR %%i IN (In Out) DO (
		ECHO.---Checking Firewall Rule [ %%x_%%i ]
		netsh advfirewall firewall show rule name=%%x_%%i
		IF NOT ERRORLEVEL 1 (
			IF %BOL_Delete% EQU TRUE (
				ECHO.---Deleting Firewall Rule [ %%x_%%i ]
				netsh advfirewall firewall delete rule name=%%x_%%i
			)
		)
		IF %BOL_Write% EQU TRUE (
			ECHO.--Creating Firewall Rule [ %%x_%%i ]
			netsh advfirewall firewall add rule action=allow profile=any protocol=any enable=yes direction=%%i name=%%x_%%i program = "%cd%\%%x.exe"
		)
		ECHO.
	)
)
TITLE=FIREWALL TOOL DONE
ECHO.---Firewall tool finished.
GOTO :FIN
:HELP
ECHO.FIREWALL
ECHO.
ECHO.Use argument "/check" to only check for rules.
ECHO.
ECHO.Use argument "/delete" to delete rules that match.
ECHO.

:FIN
ECHO.
PAUSE
