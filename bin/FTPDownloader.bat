REM STARTUP-----------------------------------------------------------------
@ECHO OFF & COLOR 0A & CLS
VERIFY OTHER 2>NUL
SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS
IF ERRORLEVEL 1 (ECHO.Could not set delayed expansion or enable extensions.& PAUSE & GOTO:EOF )
SET _LogStarted=& REM <Leave this blank to clear Log>
SET "_AllArgs=%*"
IF "%~1" EQU "/debug" (SHIFT /1 & SET _Debug=TRUE) ELSE (SET _Debug=FALSE)
SET _TemplateVersion=1.4

REM ----------------------------------------------------------------------------------
SET _DebugStep=PROGRAM DATA& IF !_Debug! EQU TRUE (ECHO.#!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
SET _ProgOriginDate=20120614& REM <Project Start Date>
SET _ProgLastModDate=20160930_0215& REM <Last Modification Date>
SET _ProgName=FTPDownloader& REM <Program name>
SET _ProgVersion=!_ProgLastModDate!& REM <Program version or release>
SET _ProgDesc1=Script to count and download all
SET _ProgDesc2=Files from an FTP server.
SET _ProgDesc3=MUST BE RUN FROM Autosave.bat
SET _ProgNeedsAdmin=FALSE& REM <Change as needed>
TITLE=!_ProgName! v!_ProgVersion!

REM ----------------------------------------------------------------------------------
SET _DebugStep=CHECK DEFINED VARIABLES& IF !_Debug! EQU TRUE (ECHO.#!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
REM Check for required variables to be set.
IF NOT DEFINED _ProgRunDir (
	ECHO._ProgRunDir not set, defaulting to current.
	SET _ProgRunDir=!CD!
	ECHO. & PAUSE
)

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=ADMIN CHECK& IF !_Debug! EQU TRUE (ECHO.#!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
SET _RanAsAdmin=TRUE
NET FILE 1>NUL 2>NUL & IF ERRORLEVEL 1 (SET _RanAsAdmin=FALSE)
IF !_RanAsAdmin! EQU TRUE (CD /d %~dp0)

REM ----------------------------------------------------------------------------------
SET _DebugStep=SETUP& IF !_Debug! EQU TRUE (ECHO.#!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
SET "_FileName=%~nx0"
SET _ProgRunTimeRead=%Time%
::SET _ProgRunDir=%CD%& IF /I "%CD:~-1%" EQU "\" ( SET _ProgRunDir=%CD:~0,-1% )
SET _LogFileName=.!_ProgName!_LastRun.log
SET _LogFolder=!_ProgRunDir!\Logs
SET _LogFile=!_LogFolder!\!_LogFileName!
SET _TmpFileName=!_ProgName!.tmp
SET _TmpFile="!_ProgRunDir!\!_TmpFileName!"
SET _BinFolder=!_ProgRunDir!\bin

REM ----------------------------------------------------------------------------------
SET _DebugStep=TIME AND DATE& IF !_Debug! EQU TRUE (ECHO.#!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
WMIC OS GET LOCALDATETIME|FIND /I /V "LocalDateTime">!_TmpFile! && SET /P _OSDate=<!_TmpFile!
SET _ProgRunDateTimeSerial=%_OSDate:~0,8%_%_OSDate:~8,4%
SET _ProgRunDateSerial=%_OSDate:~0,8%
SET _ProgRunDateRead=%_OSDate:~4,2%/%_OSDate:~6,2%/%_OSDate:~0,4%& REM < mm/dd/yyyy >
REM Do not try to use Print Subroutine before defining the date and the log filename!

REM ----------------------------------------------------------------------------------
SET _DebugStep=ARGUMENT CHECK& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
SET _GotoHelp=FALSE
SET _ShowProg=FALSE
SET _NoLog=FALSE
SET _Quit=FALSE

:ARGCHECKLOOP
IF "%~1" EQU "" GOTO:ARGEND& REM <Exit Loop if there are no more arguments.>
IF "%~1" EQU "/?" SET _GotoHelp=TRUE& GOTO:ARGNEXT& REM <Check if user needs help.>
IF "%~1" EQU "-?" SET _GotoHelp=TRUE& GOTO:ARGNEXT
IF "%~1" EQU "help" SET _GotoHelp=TRUE& GOTO:ARGNEXT
IF "%~1" EQU "/help" SET _GotoHelp=TRUE& GOTO:ARGNEXT
IF "%~1" EQU "/show" SET _ShowProg=TRUE& GOTO:ARGNEXT& REM <Set flags as needed.>
IF "%~1" EQU "/nolog" SET _NoLog=TRUE& GOTO:ARGNEXT
IF "%~1" EQU "/quit" SET _Quit=TRUE& GOTO:ARGNEXT
IF "%~1" EQU "/csv" SHIFT /1 && GOTO:ARGNEXT
IF "%~1" EQU "/devicedata" SET _DevDataFile=%~2&& SHIFT /1 && GOTO:ARGNEXT
IF "%~1" EQU "/debug" ( CALL:P /debug argument must be in first position.& PAUSE & GOTO:OUT )
CALL:P Unknown argument [ %~1 ] & PAUSE & GOTO:OUT
:ARGNEXT
SHIFT /1 & GOTO :ARGCHECKLOOP
:ARGEND

REM ----------------------------------------------------------------------------------
SET _DebugStep=INITIATE DISPLAY& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
IF !_Debug! EQU FALSE (CLS)
CALL:P -----------------------------------------------
CALL:P -      !_ProgName!.bat v!_ProgVersion!       -& REM <This will be offset if values are changed>
CALL:P -----------------------------------------------
CALL:P 

REM ----------------------------------------------------------------------------------
SET _DebugStep=LOG START& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
CALL:PL Data Logging...
CALL:PL File Name: [ !_FileName! ]
CALL:PL File directory: 
CALL:PL -[ !_ProgRunDir! ]
CALL:PL Binaries directory:
CALL:PL -[ !_BinFolder! ]
CALL:PL Logs directory:
CALL:PL -[ !_LogFolder! ]
CALL:PL Program needs admin rights: [ !_ProgNeedsAdmin! ]
CALL:PL Program ran w/admin rights: [ !_RanAsAdmin! ]
CALL:PL Arguments received: [ """ !_AllArgs! """ ]
CALL:PL Arguments read:
CALL:PL /debug: [ !_Debug! ]
CALL:PL /help:  [ !_GotoHelp! ]
CALL:PL /show:  [ !_ShowProg! ]
CALL:PL /nolog: [ !_NoLog! ]
CALL:PL /quit:  [ !_Quit! ]
CALL:PL /devicedata:
CALL:PL -[ !_DevDataFile! ]
CALL:PL

REM ----------------------------------------------------------------------------------
SET _DebugStep=ERROR SETUP& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
SET _ErrorFileName=!_ProgName!.errors
SET _ErrorFile=!_BinFolder!\!_ErrorFileName!
SET /A _ErrorNum=0
SET _ErrorEnabled=TRUE
CALL:PL Error file:
CALL:PL -[ !_ErrorFile! ]
IF NOT EXIST "!_ErrorFile!" (
	CALL:P ERROR DESCRIPTION FILE NOT FOUND.
	CALL:P NO DETAILS WILL BE PROVIDED ON ERRORS.
	CALL:P
	SET _ErrorEnabled=FALSE
) ELSE ( CALL:PL Error description file found. )
REM Do not try to use Error Subroutine before defining error file!

REM ----------------------------------------------------------------------------------
SET _DebugStep=OS NAME& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
WMIC OS GET NAME|FIND /I /V "Name">!_TmpFile! && SET /P _OSName=<!_TmpFile!
FOR /F "tokens=1 delims=|" %%a IN ("!_OSName!") DO (SET _OSName=%%a)
IF NOT DEFINED _OSName (SET /A _ErrorNum=1& GOTO:ERROR)
CALL:PL OS: [ !_OSName! ]
REM ----------------------------------------------------------------------------------
SET _DebugStep=OS VERSION& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
WMIC OS GET VERSION|FIND /I /V "Version">!_TmpFile! && SET /P _OSVersion=<!_TmpFile!
FOR /F %%E IN ("!_OSVersion!") DO (SET _OSVersion=%%E)
IF NOT DEFINED _OSVersion (SET /A _ErrorNum=2& GOTO:ERROR)
CALL:PL OS Version: [ !_OSVersion! ]
REM ----------------------------------------------------------------------------------
SET _DebugStep=OS ARCH& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
WMIC OS GET OSARCHITECTURE|FIND /I /V "OSArchitecture">!_TmpFile! && SET /P _OSArchitecture=<!_TmpFile!
FOR /F %%E IN ("!_OSArchitecture!") DO (SET _OSArchitecture=%%E)
IF NOT DEFINED _OSArchitecture (SET /A _ErrorNum=3& GOTO:ERROR)
CALL:PL OS Architecture: [ x!_OSArchitecture! ]
REM ------------------------------------------------------------------------------------------------
SET _DebugStep=OS LANGUAGE& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
WMIC OS GET OSLANGUAGE|FIND /I /V "OSLanguage">!_TmpFile! && SET /P _OSLangDec=<!_TmpFile!
FOR /F %%E IN ("!_OSLangDec!") DO (SET _OSLangDec=%%E)
IF NOT DEFINED _OSLangDec (SET _ErrorNum=4& GOTO:ERROR) ELSE (
	IF !_OSLangDec! EQU 1033 (SET _OSLang=ENG)& REM <US English>
	IF !_OSLangDec! EQU 4105 (SET _OSLang=ENG)& REM <Canada English>
	IF !_OSLangDec! EQU 2058 (SET _OSLang=SPA)& REM <Mexico Spanish>
	IF NOT DEFINED _OSLang (SET /A _ErrorNum=5& GOTO:ERROR)
)
CALL:PL OS Language: [ !_OSLang! ]
REM ----------------------------------------------------------------------------------
SET _DebugStep=OS LOCALE& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
WMIC OS GET LOCALE|FIND /I /V "Locale">!_TmpFile! && SET /P _OSLocaleHex=<!_TmpFile!
FOR /F %%E IN ("!_OSLocaleHex!") DO (SET _OSLocaleHex=%%E)
IF NOT DEFINED _OSLocaleHex (SET ErrorNum=6& GOTO:ERROR) ELSE (
	IF !_OSLocaleHex! EQU 0409 (SET _OSLocaleLang=ENG)& REM <US English>
	IF !_OSLocaleHex! EQU 1009 (SET _OSLocaleLang=ENG)& REM <Canada English>
	IF  !_OSLocaleHex! EQU 080a (SET _OSLocaleLang=SPA)& REM <Mexico Spanish>
	IF NOT DEFINED _OSLocaleLang (SET _ErrorNum=7& GOTO:ERROR)
)
CALL:PL OS Locale language: [ !_OSLocaleLang! ]

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=CONDITIONALS& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
IF !_GotoHelp! EQU TRUE (SET _NoLog=TRUE& GOTO:HELP)& REM <Display help if flag is set>
REM <Abort if program needs Admin Rights and we don't have them>
IF !_ProgNeedsAdmin! EQU TRUE (IF !_RanAsAdmin! EQU FALSE (SET /A _ErrorNum=8& GOTO:ERROR ))
REM <Abort if running on an unsupported OS version, bypass this at your own risk>
IF %_OSVersion:~0,1% NEQ 6 (SET /A _ErrorNum=9& GOTO:ERROR)

REM ----------------------------------------------------------------------------------
SET _DebugStep=FILE CHECK& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
CALL:PL Checking required files...
IF NOT EXIST "!_BinFolder!\Ncftpls.exe" (SET /A _ErrorNum=21& GOTO:ERROR ) ELSE (CALL:PL .\bin\NcFTPLs.exe found.)
IF NOT EXIST "!_BinFolder!\Ncftpget.exe" (SET /A _ErrorNum=22& GOTO:ERROR ) ELSE (CALL:PL .\bin\NcFTPGet.exe found.)
IF NOt DEFINED _DevDataFile (SET /A _ErrorNum=23& GOTO:ERROR )
IF NOT EXIST "!_DevDataFile!" (SET /A _ErrorNum=24& GOTO:ERROR ) ELSE (CALL:PL Device data found.)
CALL:PL

::----------------------------------------------------------------------------------
SET _DebugStep=CONFIG FILE READ& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
::----------------------------------------------------------------------------------
CALL:P Reading device data from file...
FOR /F "usebackq tokens=1,* delims==" %%A IN ("!_DevDataFile!") DO (
	IF "%%A" EQU "BackupDir" (SET "_BkpDir=%%B"& CALL:P -Read BackupDir: [ !_BkpDir! ])
	IF "%%A" EQU "DeviceDir" (SET "_DeviceDir=%%B"& CALL:P -Read DeviceDir: [ !_DeviceDir! ])
	IF "%%A" EQU "DeviceName" (SET "_DeviceName=%%B"& CALL:P -Read DeviceName: [ !_DeviceName! ])
	IF "%%A" EQU "DeviceIpAddress" (SET "_DeviceIpAddress=%%B"& CALL:P -Read DeviceIpAddress: [ !_DeviceIpAddress! ])
	IF "%%A" EQU "DeviceUsername" (SET "_DeviceUsername=%%B"& CALL:P -Read DeviceUsername: [ !_DeviceUsername! ])
	IF "%%A" EQU "DevicePwd" (SET "_DevicePwd=%%B"& CALL:P -Read DevicePwd: [ !_DevicePwd! ])
	IF "%%A" EQU "ResultFile" (SET "_ResultFile=%%B"& CALL:P -Read ResultFile: [ !_ResultFile! ])
)
CALL:P

REM ----------------------------------------------------------------------------------
SET _DebugStep=VARIABLES1& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
IF NOT DEFINED _DeviceIpAddress ( SET /A _ErrorNum=11& GOTO:ERROR )
IF NOT DEFINED _BkpDir ( SET /A _ErrorNum=12& GOTO:ERROR )
IF NOT DEFINED _DevicePingTriesPreset ( CALL:P Ping retries not set, defaulting to [ 3 ].& SET /A _DevicePingTriesPreset=3 )
IF NOT DEFINED _DeviceName  ( CALL:P Device name not set, defaulting to [ Device ].& SET _DeviceName=Device)
IF NOT DEFINED _DeviceDir ( CALL:P Device backup folder not set, defaulting to [ .\!_DeviceName! ].& SET _DeviceDir=!_DeviceName!)
IF NOT DEFINED _ResultFile ( CALL:P Device results file not set, defaulting to [ !_BkpDir!\.!_DeviceName!-result.txt ].& SET _ResultFile=!_BkpDir!\.!_DeviceName!-result.txt)
SET _FileList=!_BkpDir!\.!_DeviceName!-filelist.txt

REM ----------------------------------------------------------------------------------
SET _DebugStep=LOG2& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
CALL:PL DATA LOG:
CALL:PL Device Name: [ !_DeviceName! ]
CALL:PL Device Backup Folder: [ "!_DeviceDir!" ]
CALL:PL This Backup Folder: [ !_BkpDir! ]
CALL:PL Device Ping Max Tries: [ !_DevicePingTriesPreset! ]
CALL:PL Device IP Address: [ !_DeviceIpAddress! ]
CALL:PL File list will output to: [ !_FileList! ]
CALL:PL Results will output to: [ !_ResultFile! ]
CALL:PL

REM ----------------------------------------------------------------------------------
SET _DebugStep=VARIABLES& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
REM <Local variables start here>
SET /A _DownloadedFiles=0
SET /A _FilesInDevice=0
SET /A _PingTriesCount=0
SET _FailReason=Unknown

REM ----------------------------------------------------------------------------------
SET _DebugStep=MAIN& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO Off)
REM ----------------------------------------------------------------------------------
CALL:P
CALL:P ----------------STARTING MAIN------------------
CALL:P 

REM --------MAIN PROGRAM STARTS HERE--------------------------------

CALL:P !_ProgName! will try to ping [ !_DeviceName! ] 
CALL:P [ !_DevicePingTriesPreset! ] times before aborting the 
CALL:P download process.
CALL:P

:PINGLOOP
REM ----------------------------------------------------------------------------------
SET _DebugStep=PINGLOOP& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
CALL:P Trying to ping device [ !_DeviceName! ] @ [ !_DeviceIpAddress! ]
SET _PingOK=FALSE
CALL:TRY_PING !_DeviceIpAddress!
SET /A _PingTriesCount=!_PingTriesCount!+1
IF !_PingOK! EQU TRUE (
	REM ----------------------------------------------------------------------------------
	SET _DebugStep=FTP LIST& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
	REM ----------------------------------------------------------------------------------
	CALL:P ---[ !_DeviceName! ] @ [ !_DeviceIpAddress! ] found!
	CALL:P
	CALL:P Trying to get file list from [ !_DeviceName! ]...
	CALL:P ---Running NcFTPLs.exe
	IF NOT DEFINED _DeviceUsername SET _DeviceUsername=anonymous
	IF NOT DEFINED _DevicePwd SET _DevicePwd=""
	"!_BinFolder!\ncftpls.exe" -d "!_LogFile!" -u !_DeviceUsername! -p !_DevicePwd! -x "a" ftp://!_DeviceIpAddress! > "!_FileList!"
	CALL:P ---NcFTPLs Done.
	CALL:P Counting files in list...
	IF NOT EXIST "!_FileList!" (
		CALL:P ---File list not found. Aborting...
		SET _FailReason=File list not found
		GOTO:RESULT
	)
	FOR /F "usebackq" %%q IN ("!_FileList!") DO (SET /A _FilesInDevice+=1)
	CALL:P 
	CALL:P ---[ !_FilesInDevice! ] Files detected on Device.
	IF !_FilesInDevice! LEQ 0 (CALL:P ---No Files Detected. Aborting...&SET _FailReason=NcFTPLs did not return data& GOTO:RESULT )
	CALL:P Looking for folder [ "!_DeviceDir!" ] in backup folder...
	IF NOT EXIST "!_BkpDir!/!_DeviceDir!" (
		CALL:P ---[ "!_DeviceDir!" ] not found.
		CALL:P --Creating folder [ "!_DeviceDir!" ] in backup folder...
		CALL:PL --Creating folder [ "!_BkpDir!/!_DeviceDir!" ] in backup folder...
		MKDIR "!_BkpDir!/!_DeviceDir!"
		IF EXIST "!_BkpDir!/!_DeviceDir!" (
			CALL:P ---[ "!_DeviceDir!" ] folder created.
		) ELSE ( SET /A _ErrorNum=15& GOTO:ERROR)
	) ELSE ( CALL:P ---[ "!_DeviceDir!" ] found. )
	REM ----------------------------------------------------------------------------------
	SET _DebugStep=FTP GET& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
	REM ----------------------------------------------------------------------------------
	CALL:P
	CALL:P Starting download for [ !_DeviceName! ]
	CALL:P ---Running NcFTPGet.exe
	CALL:P
	PUSHD "!_BkpDir!/!_DeviceDir!"
	"!_BinFolder!\ncftpget.exe" -R -T -u !_DeviceUsername! -p !_DevicePwd! -d "!_LogFile!" !_DeviceIpAddress! "!_BkpDir!/!_DeviceDir!" *.*
	FOR %%H IN (*) DO (SET /A _DownloadedFiles+=1)
	POPD
	CALL:P [ !_DeviceName! ] finished Downloading.
	CALL:P ---[ !_DownloadedFiles!/!_FilesInDevice! ] Files downloaded.
	
	REM CHECKS IF DOWNLOADED FILES MATCH THE ONES ON THE DEVICE.
	IF !_DownloadedFiles! EQU 0 (
		SET _FailReason=No files downloaded
	) ELSE (
		IF !_DownloadedFiles! EQU !_FilesInDevice! (
			SET _FailReason=
		) ELSE (
			IF !_DownloadedFiles! LSS !_FilesInDevice! (
				SET _FailReason=Incomplete download
			) ELSE (
				SET _FailReason=Extra files in Download
			)
		)
	)
	GOTO:RESULT 

) ELSE (
	CALL:P ---Failed to ping [ !_DeviceName! ] [ !_PingTriesCount! ] times.
	IF !_PingTriesCount! GEQ !_DevicePingTriesPreset! (
		CALL:P
		CALL:P Failed to ping [ !_DeviceName! ].
		CALL:P ---Download aborted.
		SET _FailReason=Failed to ping device
		GOTO:RESULT
	)
	GOTO:PINGLOOP
)

:RESULT
REM ----------------------------------------------------------------------------------
SET _DebugStep=RESULT & IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
CALL:P
IF NOT DEFINED _FailReason ( CALL:P Backup Complete. Congrats Mate! ) ELSE ( CALL:P Backup failed. )
IF NOT DEFINED _FailReason (SET /A _FailReason=0)
IF NOT DEFINED _DownloadedFiles (SET /A _DownloadedFiles=0)
IF NOT DEFINED _FilesInDevice (SET /A _FilesInDevice=0)

CALL:P Output to result file:
CALL:P [ !_FailReason!;!_DownloadedFiles!;!_FilesInDevice! ]
ECHO.!_FailReason!;!_DownloadedFiles!;!_FilesInDevice!>"!_ResultFile!"
GOTO:FIN

:FIN
REM ----------------------------------------------------------------------------------
SET _DebugStep=EXIT SEQ& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
CALL:P 
CALL:P ---------------PROGRAM FINISHED----------------
CALL:P
CALL:P Starting cleanup...

SET _OKToDelete=FALSE
IF !_Debug! EQU FALSE (IF !_ErrorNum! EQU 0 ( SET _OKToDelete=TRUE))
CALL:P --Deleting temp file:
IF EXIST !_TmpFile! (
	IF !_OKToDelete! EQU TRUE (
		CALL:P --[ !_TmpFileName! ]
		CALL:PL --[ !_TmpFile! ]
		ERASE /Q !_TmpFile!
		IF NOT EXIST !_TmpFile! ( CALL:P ---Temp file succesfully deleted.) ELSE ( SET _ShowProg=TRUE& CALL:P ---Failed to delete temp file. )
	) ELSE (CALL:P ---Not clear to delete temp file.)
) ELSE (CALL:P ---Temporary file not found.)

IF !_NoLog! EQU FALSE (
	SET "_LogName=!_BkpDir!\.!_DeviceName!-!_ProgName!Log.txt"
	CALL:P Saving log as:
	CALL:P -[ .!_DeviceName!-!_ProgName!-log.txt ]
	CALL:PL -[ !_LogName! ]
	IF EXIST "!_BkpDir!" (COPY /Y "!_LogFile!" "!_LogName!">NUL )
	IF EXIST "!_LogName!" ( CALL:P ---Log save successful.) ELSE ( SET _ShowProg=TRUE& CALL:P ---Failed to save log. )
)

:OUT
REM ----------------------------------------------------------------------------------
SET _DebugStep=OUT& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
TITLE=!_ProgName! v!_ProgVersion! FINISHED.
CALL:PL
CALL:PL Real program end. BYE
IF !_ShowProg! EQU TRUE ( PAUSE )
IF !_Quit! EQU TRUE ( 
	ENDLOCAL
	EXIT
) ELSE (
	ENDLOCAL
	GOTO:EOF
)

:TRY_PING
REM ----------------------------------------------------------------------------------
SET _DebugStep=TRY PING & IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
REM Argument 1 should be the IP Address to try to ping.
SET _PingOK=TRUE
IF "%~1" EQU "" (CALL:P No IP Address& SET _PingOK=FALSE&& GOTO:EOF)
PING -n 2 -w 30 "%~1" |FIND /I "TTL=">NUL
IF ERRORLEVEL 1 SET _PingOK=FALSE
GOTO:EOF

REM PRINTOUT ROUTINE---------------------------------------------------------
:P
SET "_Out=%*"
ECHO.!_Out!
:PL
SET "_Out=%*"
IF NOT DEFINED _LogStarted ( ECHO.!_ProgRunTimeRead!	!_ProgRunDateRead! LOG START>"!_LogFile!" & ECHO.>>"!_LogFile!" & SET _LogStarted=TRUE)
IF "!_Out!" EQU "" ( ECHO.>>"!_LogFile!" ) ELSE ( ECHO.%TIME%	!_Out!>>"!_LogFile!" )
GOTO:EOF

:HELP
REM ----------------------------------------------------------------------------------
SET _DebugStep=HELP& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ----------------------------------------------------------------------------------
CALL:P
CALL:P Opened help display.
ECHO.
ECHO.-Based off template v.!_TemplateVersion!
ECHO. 
ECHO.!_ProgDesc1!
ECHO.!_ProgDesc2!
ECHO.!_ProgDesc3!
ECHO.
ECHO.Available arguments:
ECHO.[ /devicedata ] REQ file to read device data from.
ECHO.[ /show ] to pause at the end of program.
ECHO.[ /nolog ] to not include a log in backups.
ECHO.[ /debug ] to display debug steps.
ECHO.
ECHO.[ /quit ] to exit cmd at the end of program.
ECHO.
ECHO.Dates are in mm/dd/yyyy format.
ECHO.
ECHO.Execution time: [ !_ProgRunTimeRead! ] on [ !_ProgRunDateRead! ]
ECHO.
ECHO.Current directory: [ !_ProgRunDir! ]
ECHO.Log files created on: [ !_LogFolder! ]
ECHO.
ECHO.Written by G.G - Last Edit !_ProgLastModDate!
ECHO.
GOTO:FIN

:ERROR
REM ------------------------------------------------------------------------------------------------
SET _DebugStep=ERROR REPORTER& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
TITLE=!_ProgName! v!_ProgVersion! [ ERROR ]
SET _BackupResult=ERROR
CALL:P Opened error display.
CALL:P
CALL:P ERROR #!_ErrorNum!

REM Error number lookup.
IF NOT DEFINED _ErrorEnabled (SET _ErrorEnabled=FALSE)
IF !_ErrorEnabled! EQU TRUE (
	IF DEFINED _ErrorFile (
		IF EXIST !_ErrorFile! (
			SET _ErrorFound=FALSE
			FOR /F "tokens=2 delims=;" %%E IN ('FIND /I "!_ErrorNum!" "!_ErrorFile!"') DO (
				IF "%%E" NEQ "" (CALL:P ---%%E& SET _ErrorFound=TRUE)
			)
		IF !_ErrorFound! EQU FALSE (CALL:P ---Error code not found in file.)
		)ELSE (CALL:P ---Error file not found.)
	) ELSE (CALL:P ---Error file is not defined.)
) ELSE (CALL:P ---Error lookup is not enabled.)
CALL:P
SET _ShowProg=TRUE& GOTO:FIN
