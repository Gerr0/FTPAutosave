REM STARTUP-----------------------------------------------------------------
@ECHO OFF & COLOR 0A & CLS
VERIFY OTHER 2>NUL
SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS
IF ERRORLEVEL 1 (ECHO.Could not set delayed expansion or enable extensions.& PAUSE & GOTO:EOF )
SET _LogStarted=& REM <Leave this blank to clear Log>
SET "_AllArgs=%*"
IF "%~1" EQU "/debug" (SHIFT /1 & SET _Debug=TRUE) ELSE (SET _Debug=FALSE)
SET _TemplateVersion=1.4

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=PROGRAM DATA& IF !_Debug! EQU TRUE (ECHO.#!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
SET _ProgOriginDate=20120615& REM <Project Start Date>
SET _ProgLastModDate=20160906_1240& REM <Last Modification Date>
SET _ProgName=FTPAutosave& REM <Program name>
SET _ProgVersion=!_ProgLastModDate!& REM <Program version or release>
SET _ProgDesc1=Program copies files in FTP servers
SET _ProgDesc2=such as Fanuc Robot controllers, and
SET _ProgDesc3=zips the copied files to a single file.
SET _ProgNeedsAdmin=FALSE& REM <Change as needed>
TITLE=!_ProgName! v!_ProgVersion!

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=CHECK DEFINED VARIABLES& IF !_Debug! EQU TRUE (ECHO.#!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
REM Check for required variables to be set.

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=ADMIN CHECK& IF !_Debug! EQU TRUE (ECHO.#!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
SET _RanAsAdmin=TRUE
NET FILE 1>NUL 2>NUL & IF ERRORLEVEL 1 (SET _RanAsAdmin=FALSE)
IF !_RanAsAdmin! EQU TRUE (CD /d %~dp0)

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=SETUP& IF !_Debug! EQU TRUE (ECHO.#!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
SET "_FileName=%~nx0"
SET _ProgRunTimeRead=%Time%
SET _ProgRunDir=%CD%& IF /I "%CD:~-1%" EQU "\" ( SET _ProgRunDir=%CD:~0,-1% )
SET _LogFileName=.!_ProgName!_LastRun.log
SET _LogFolder=!_ProgRunDir!\Logs
SET _LogFile=!_LogFolder!\!_LogFileName!
SET _TmpFileName=!_ProgName!.tmp
SET _TmpFile="!_ProgRunDir!\!_TmpFileName!"
SET _BinFolder=!_ProgRunDir!\bin

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=TIME AND DATE& IF !_Debug! EQU TRUE (ECHO.##!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
WMIC OS GET LOCALDATETIME|FIND /I /V "LocalDateTime">!_TmpFile! && SET /P _OSDate=<!_TmpFile!
SET _ProgRunDateTimeSerial=%_OSDate:~0,8%_%_OSDate:~8,4%
SET _ProgRunDateSerial=%_OSDate:~0,8%
SET _ProgRunDateRead=%_OSDate:~4,2%/%_OSDate:~6,2%/%_OSDate:~0,4%& REM < mm/dd/yyyy >
REM Do not try to use Print Subroutine before defining the date and the log filename!

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=ARGUMENT CHECK& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
SET _GotoHelp=FALSE& REM <Add flags to set with Arguments.>
SET _ShowProg=FALSE
SET _NoLog=FALSE
SET _NoDownload=FALSE

:ARGCHECKLOOP
IF "%~1" EQU "" GOTO:ARGEND& REM <Exit Loop if there are no more arguments.>
IF "%~1" EQU "/?" SET _GotoHelp=TRUE& GOTO:ARGNEXT& REM <Check if user needs help.>
IF "%~1" EQU "-?" SET _GotoHelp=TRUE& GOTO:ARGNEXT
IF "%~1" EQU "help" SET _GotoHelp=TRUE& GOTO:ARGNEXT
IF "%~1" EQU "/help" SET _GotoHelp=TRUE& GOTO:ARGNEXT
IF "%~1" EQU "/show" SET _ShowProg=TRUE& GOTO:ARGNEXT& REM <Set flags as needed.>
IF "%~1" EQU "/nolog" SET _NoLog=TRUE& GOTO:ARGNEXT
IF "%~1" EQU "/nodown" SET _NoDownload=TRUE& GOTO:ARGNEXT
IF "%~1" EQU "/csv" SET _CsvFileName=%~2&& SHIFT /1 && GOTO:ARGNEXT
IF "%~1" EQU "/debug" ( CALL:P /debug argument must be in first position.& PAUSE & GOTO:EOF )
CALL:P Unknown argument [ %~1 ] & PAUSE & GOTO:EOF
:ARGNEXT
SHIFT /1 & GOTO :ARGCHECKLOOP
:ARGEND

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=INITIATE DISPLAY& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
IF !_Debug! EQU FALSE (CLS)
CALL:P -----------------------------------------------
CALL:P -         !_ProgName! v!_ProgVersion!          -& REM <This will be offset if values are changed>
CALL:P -----------------------------------------------
CALL:P

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=LOG START& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
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
CALL:PL /help:   [ !_GotoHelp! ]
CALL:PL /show:   [ !_ShowProg! ]
CALL:PL /debug:  [ !_Debug! ]
CALL:PL /nolog:  [ !_NoLog! ]
CALL:PL /nodown: [ !_NoDownload! ]
CALL:PL

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=ERROR SETUP& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
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

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=OS NAME& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
WMIC OS GET NAME|FIND /I /V "Name">!_TmpFile! && SET /P _OSName=<!_TmpFile!
FOR /F "tokens=1 delims=|" %%a IN ("!_OSName!") DO (SET _OSName=%%a)
IF NOT DEFINED _OSName (SET /A _ErrorNum=1& GOTO:ERROR)
CALL:PL OS: [ !_OSName! ]
REM ------------------------------------------------------------------------------------------------
SET _DebugStep=OS VERSION& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
WMIC OS GET VERSION|FIND /I /V "Version">!_TmpFile! && SET /P _OSVersion=<!_TmpFile!
FOR /F %%E IN ("!_OSVersion!") DO (SET _OSVersion=%%E)
IF NOT DEFINED _OSVersion (SET /A _ErrorNum=2& GOTO:ERROR)
CALL:PL OS Version: [ !_OSVersion! ]
REM ------------------------------------------------------------------------------------------------
SET _DebugStep=OS ARCH& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
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

IF NOT DEFINED _CsvFileName CALL:P ---CSV file not defined in argument, using default.&& SET _CsvFileName=!_ProgName!
CALL:PL

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=FILE CHECK& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
CALL:PL Checking required files...
REM <Check files as needed>
IF NOT EXIST "!_BinFolder!" (SET /A _ErrorNum=20& GOTO:ERROR) ELSE (CALL:PL .\bin folder found.)
IF NOT EXIST "!_BinFolder!\Ncftpls.exe" (SET /A _ErrorNum=21& GOTO:ERROR) ELSE (CALL:PL .\bin\NcFTPLs.exe found.)
IF NOT EXIST "!_BinFolder!\Ncftpget.exe" (SET /A _ErrorNum=22& GOTO:ERROR) ELSE (CALL:PL .\bin\NcFTPGet.exe found.)
IF NOT EXIST "!_BinFolder!\FTPDownloader.bat" (SET /A _ErrorNum=23& GOTO:ERROR) ELSE (CALL:PL .\bin\FTPDownloader.bat found.)
IF NOT EXIST "!_BinFolder!\zip.exe" (SET /A _ErrorNum=24& GOTO:ERROR) ELSE (CALL:PL .\bin\zip.exe found.)
CALL:PL

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=VARIABLES1& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
SET _DeviceName=0
SET _DeviceIpAddress=0
SET /A _DownloadCount=0
SET /A _DeviceCount=0
SET /A _DeviceOKCount=0
SET /A _DeviceFailedCount=0
SET /A _DeviceIncompleteCount=0
SET /A _AllDevicesFiles=0
SET _CompleteBackup=FALSE
SET _ZipComplete=FALSE
SET _CsvFile=!_ProgRunDir!\!_CsvFileName!.csv& REM <This will rename the backups>
SET _BkpRoot=%UserProfile%\Desktop\BACKUPS& REM <Change _BkpRoot to change main Backup folder>

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=MAIN& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
CALL:P
CALL:P ----------------STARTING MAIN------------------
CALL:P 

REM --------MAIN PROGRAM STARTS HERE--------------------------------

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=IP ADDRESS FIND& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
CALL:P 1. Looking for IP address list.
CALL:P
:IPListFind
IF NOT EXIST "!_CsvFile!" (
	CALL:P ---CSV file not found.
	CALL:P ---[ !_CsvFile! ]
	CALL:P
	CALL:P --Use a different file?
	CHOICE
	IF !ERRORLEVEL! EQU 1 (
		CALL:P
		CALL:P --Please type the name of the file to be used:
		SET /P _CsvFileName=
		CALL:PL Entered: [ !_CsvFileName! ]
		SET _CsvFile=!_ProgRunDir!\!_CsvFileName!.csv
	)
	IF !ERRORLEVEL! EQU 2 (
		CALL:P ---Selected NO.
		CALL:P
		SET /A _ErrorNum=11& GOTO:ERROR	
	)
	CALL:P
	GOTO:IPListFind
)
CALL:P ---Found [ !_CsvFile! ].
CALL:P

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=VARIABLES2& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
SET _IpAddressFileName=!_CsvFileName!.csv
SET _IpAddressFile=!_ProgRunDir!\!_IpAddressFileName!
SET _BkpName=!_CsvFileName!-!_ProgRunDateTimeSerial!
SET _BkpDir=!_BkpRoot!\!_BkpName!

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=FIREWALL& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
CALL:P 2. Checking Firewall Rules.
:FirewallCheck
FOR %%x in (NcFtpLs NcFtpGet) DO (
	FOR %%i IN (in out) DO (
		CALL:PL --Looking for firewall rule [ %%x_%%i ]
		NETSH advfirewall firewall show rule name=%%x_%%i >NUL
		IF !ERRORLEVEL! == 1 (SET /A _ErrorNum=28& GOTO:ERROR) ELSE ( CALL:PL ---Found firewall rule [ %%x_%%i ].)
	)
)
CALL:P

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=BACKUP FOLDER& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
CALL:P 3. Backup folder verification.
CALL:P --Looking for folder[ BACKUPS ] in desktop...
IF NOT EXIST "!_BkpRoot!" (
	CALL:P ---[ BACKUPS ] not found.
	CALL:P --Creating folder [ BACKUPS ] in desktop...
	MKDIR "!_BkpRoot!"
	IF EXIST "!_BkpRoot!" (
		CALL:P ---[ BACKUPS ] folder created.
	) ELSE ( SET /A _ErrorNum=15& GOTO:ERROR )
) ELSE ( CALL:P ---[ BACKUPS ] found. )

CALL:P --Looking for folder[ !_BkpName! ] in backup folder...
IF NOT EXIST "!_BkpDir!" (
	CALL:P ---[ !_BkpName! ] not found.
	CALL:P --Creating folder [ !_BkpName! ] in backup folder...
	MKDIR "!_BkpDir!"
	IF EXIST "!_BkpDir!" (
		CALL:P ---Folder created [ !_BkpName! ].
		CALL:PL ---Folder created [ !_BkpDir! ].
	) ELSE ( SET /A _ErrorNum=15& GOTO:ERROR )
) ELSE ( CALL:P ---[ !_BkpName! ] found. )
CALL:P

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=IP ADDRESS COPY& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
CALL:P 4. Copying IP address list.
COPY /Y "!_IpAddressFile!" "!_BkpDir!\!_IpAddressFileName!" >NUL
IF NOT EXIST "!_BkpDir!\!_IpAddressFileName!" ( SET /A _ErrorNum=12& GOTO:ERROR )
CALL:P ---Copied [ !_IpAddressFileName! ] to folder
CALL:P ---[ !_BkpName! ].
CALL:P

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=IP ADDRESS READ& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
CALL:P 5. Loading [ !_IpAddressFileName! ] to start downloads.
PUSHD "!_BkpDir!"
FOR /F "usebackq eol=#" %%q IN ("!_BkpDir!\!_IpAddressFileName!") DO (SET /A _DeviceCount=!_DeviceCount!+1)
CALL:P ---[ !_DeviceCount! ] Devices found in list.
CALL:P

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=FTP DOWNLOAD LOOP& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
CALL:P --------------STARTING DOWNLOADS---------------
FOR /F "usebackq eol=# tokens=1,2,3,4 delims=," %%I IN ("!_IpAddressFileName!") DO (
	SET _DeviceName=%%I
	SET _DeviceIpAddress=%%J
	SET _DeviceUsername=%%K
	SET _DevicePwd=%%L
	IF NOT DEFINED _DeviceUsername SET _DeviceUsername=anonymous
	IF NOT DEFINED _DevicePwd SET _DevicePwd=""
	SET _PingTriesCount=0
	SET _DevicePingTriesPreset=3
	SET _DeviceDir=!_DeviceName!_(!_DeviceIpAddress!^)
	SET _DownloadedFiles=0
	SET _FilesInDevice=0
	SET _DownloadOK=FALSE
	SET _FailReason=Unknown
	SET _ResultFile=!_BkpDir!\.!_DeviceName!-result.txt
	SET /A _DownloadCount+=1
	
	REM ------------------------------------------------------------------------------------------------
	SET _DebugStep=PING LOOP& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
	REM ------------------------------------------------------------------------------------------------
	SET _PingOK=FALSE
	CALL:P
	CALL:P Trying to ping [ !_DeviceName! ] @ [ !_DeviceIpAddress! ]
	CALL:TRY_PING !_DeviceIpAddress!
	IF !_PingOK! EQU TRUE ( 
		CALL:P ---Ping OK.
	) ELSE ( 
		CALL:P ---Ping failed.
		CALL:P Will run Download routine to retry...
	)
	CALL:P
	IF EXIST "!_ResultFile!" (
		REM <Clear results file before starting>
		CALL:P Result file found before starting!
		CALL:P Erasing file...
		ERASE /Q "!_ResultFile!"
		IF EXIST "!_ResultFile!" ( SET /A _ErrorNum=16& GOTO:ERROR )
		CALL:P ---File deleted succesfully.
		CALL:P 
	)
	
	REM ------------------------------------------------------------------------------------------------
	SET _DebugStep=DEVICEDATA FILE WRITE& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
	REM ------------------------------------------------------------------------------------------------
	REM <Write device data to temp file to pass to downloader>
	CALL:P Writing device data to temp file...
	IF EXIST !_TmpFile! (ERASE /Q !_TmpFile!)
	ECHO.BackupDir=!_BkpDir!>!_TmpFile!
	ECHO.DeviceDir=!_DeviceDir!>>!_TmpFile!
	ECHO.DeviceName=!_DeviceName!>>!_TmpFile!
	ECHO.DeviceIpAddress=!_DeviceIpAddress!>>!_TmpFile!
	ECHO.DeviceUsername=!_DeviceUsername!>>!_TmpFile!
	ECHO.DevicePwd=!_DevicePwd!>>!_TmpFile!
	ECHO.ResultFile=!_ResultFile!>>!_TmpFile!
	IF NOT EXIST !_TmpFile! ( SET /A _ErrorNum=17& GOTO:ERROR )
	CALL:P ---Data written succesfully.
	CALL:P 
	
	REM ------------------------------------------------------------------------------------------------
	SET _DebugStep=DOWNLOAD CALL& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
	REM ------------------------------------------------------------------------------------------------
	CALL:P !TIME! - Calling download routine 
	CALL:P [ !_DownloadCount!/!_DeviceCount! ] - [ !_DeviceName! ] @ [ !_DeviceIpAddress! ].
	TITLE=!_ProgName! v!_ProgVersion! [ Downloading: !_DownloadCount!/!_DeviceCount! ]
	CALL:PL Results will be read from: [ !_ResultFile! ]
	CALL:P ===============================================
	IF !_NoDownload! EQU FALSE ( START "Download" /D "!_BinFolder!" /MAX /WAIT /SEPARATE FTPDownloader.bat !_AllArgs! /quit /devicedata !_TmpFile!)
	CALL:P ---Download routine finished.
	CALL:P Reading Results...
	IF EXIST "!_ResultFile!" (
		REM ------------------------------------------------------------------------------------------------
		SET _DebugStep=RESULT PARSE& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
		REM ------------------------------------------------------------------------------------------------
		FOR /F "usebackq delims=; tokens=1,2,3 eol= " %%W IN ("!_ResultFile!") DO (
			CALL:PL ---Results Read: [ %%W;%%X;%%Y ]
			SET _FailReason=%%W
			SET /A _DownloadedFiles=%%X
			SET /A _FilesInDevice=%%Y
			IF !_FailReason! EQU 0 ( IF NOT DEFINED _DownloadedFiles ( SET _FailReason=Results file is missing data 2) )
			IF !_FailReason! EQU 0 ( IF NOT DEFINED _FilesInDevice ( SET _FailReason=Results file is missing data 3) )
			IF !_FailReason! EQU 0 ( IF !_DownloadedFiles! LSS 0 ( SET _FailReason=Invalid value received) ) 
			IF !_FailReason! EQU 0 ( IF !_DownloadedFiles! EQU 0 ( SET _FailReason=No files downloaded) )
			IF !_FailReason! EQU 0 ( IF !_FilesInDevice! LSS 0 ( SET _FailReason=Invalid value received) )
			IF !_FailReason! EQU 0 ( IF !_FilesInDevice! EQU 0 ( SET _FailReason=No files to download) )
			IF !_FailReason! EQU 0 ( IF !_DownloadedFiles! LSS !_FilesInDevice! ( SET _FailReason=Incomplete download) )
			IF !_FailReason! EQU 0 ( IF !_DownloadedFiles! GTR !_FilesInDevice! ( SET _FailReason=Too many files downloaded) )
			IF !_FailReason! EQU 0 ( SET _FailReason=)
		)
	) ELSE (SET _FailReason=Can't find result file.)
	
	IF DEFINED _FailReason (
		REM ------------------------------------------------------------------------------------------------
		SET _DebugStep=DOWNLOAD FAULT HANDLER& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
		REM ------------------------------------------------------------------------------------------------
		SET _DownloadOK=FALSE
		CALL:P --Download Faulted.
		CALL:P ---Reason: [ !_FailReason! ].
		CALL:P Looking for leftover data...
		CALL:P --Looking for download folder...
		IF EXIST "!_BkpDir!/!_DeviceDir!" (
			CALL:P ---[ "!_DeviceDir!" ] found.		
			CALL:P --Trying to count downloaded files...
			PUSHD "!_BkpDir!/!_DeviceDir!"
			SET /A _DownloadedFiles=0
			FOR %%H IN (*) DO (SET /A _DownloadedFiles+=1)
			POPD
			CALL:P ---[ !_DownloadedFiles! ] files found.
			CALL:P --Looking for a file list...	
			SET /A _FilesInDevice=0
			IF EXIST "!_BkpDir!\.!_DeviceName!-filelist.txt" (
				CALL:P ---File list found.
				CALL:P --Counting files in list...
				FOR /F "usebackq" %%q IN ("!_BkpDir!\.!_DeviceName!-filelist.txt") DO (SET /A _FilesInDevice+=1)
				CALL:P ---[ !_FilesInDevice! ] files in list.
			) ELSE (
				CALL:P ---File list not found.
				IF !_PingOK! EQU TRUE (
					CALL:P Device responded to ping before.
					CALL:P --Trying to count files in [ !_DeviceName! ].
					CALL:P --Running NcFTPLs.exe...
					"!_BinFolder!\ncftpls.exe" -d "!_LogFile!" -u !_DeviceUsername! -p !_DevicePwd! -x "a" ftp://!_DeviceIpAddress! > "!_BkpDir!\.!_DeviceName!-filelist.txt"
					FOR /F "usebackq" %%q IN ("!_BkpDir!\.!_DeviceName!-filelist.txt") DO (SET /A _FilesInDevice+=1)
					IF !_FilesInDevice! LEQ 0 ( CALL:P ---NcFTPLs did not return data. ) ELSE ( CALL:P ---[ !_FilesInDevice! ] files in Device. )
				) ELSE (
					CALL:P Device [ !_DeviceName! ] didn't respond to ping before.
					CALL:P Download for Device [ !_DeviceName! ] failed.
				)
			)
		) ELSE (
			CALL:P ---[ "!_DeviceDir!" ] not found.
			CALL:P Download for Device [ !_DeviceName! ] failed.
			SET /A _DownloadedFiles=0
		)
	)
	IF !_DownloadedFiles! GTR 0 (IF !_DownloadedFiles! EQU !_FilesInDevice! (SET _DownloadOK=TRUE))

	REM ------------------------------------------------------------------------------------------------
	SET _DebugStep=DOWNLOAD OUTPUT& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
	REM ------------------------------------------------------------------------------------------------
	IF !_DownloadOK! EQU TRUE (
		CALL:P ===============================================
		CALL:P !TIME! - SUCCESFUL DOWNLOAD.
		CALL:P . Device [ !_DeviceName! ] @ [ !_DeviceIpAddress! ].
		CALL:P ---[ !_DownloadedFiles!/!_FilesInDevice! ] Files downloaded.
		CALL:P
		CALL:P Erasing results file...
		IF EXIST "!_ResultFile!" (
			ERASE /Q "!_ResultFile!"
			IF EXIST "!_ResultFile!" ( CALL:P ---Failed to delete file.) ELSE (CALL:P ---File deleted succesfully.)
			CALL:P 
		) ELSE ( CALL:P ---Results file not found. )
		SET /A _DeviceOKCount=!_DeviceOKCount!+1
	) ELSE (
		IF !_DownloadedFiles! GTR 0 (
			IF EXIST "!_BkpDir!/!_DeviceDir!" (
				CALL:P Marking folder as INCOMPLETE...
				PUSHD !_BkpDir!
				RENAME "!_DeviceDir!" "!_DeviceDir!-INCOMPLETE"
				IF EXIST "!_BkpDir!\!_DeviceDir!-INCOMPLETE" (
					CALL:P ---Folder renamed succesfully.
				) ELSE (CALL:P ---Folder rename failed.)
				POPD	
			)
			CALL:P ===============================================
			CALL:P !TIME! - INCOMPLETE DOWNLOAD.
			SET /A _DeviceIncompleteCount+=1
		) ELSE (
			CALL:P ===============================================
			CALL:P !TIME! - FAILED TO DOWNLOAD.
			SET /A _DeviceFailedCount+=1
		)
		CALL:P ---[ !_DownloadedFiles!/!_FilesInDevice! ] Files downloaded.
		CALL:P
	)
	SET /A _AllDevicesFiles+=!_DownloadedFiles!
)

REM ------------------------------------------------------------------------------------------------
SET _DebugStep=COMPLETION EVAL& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
CALL:P _______________________________________________
CALL:P [ !_DownloadCount!/!_DeviceCount! ] Downloads.
CALL:P [ !_DeviceOKCount! ] OK.
CALL:P [ !_DeviceIncompleteCount! ] Partial.
CALL:P [ !_DeviceFailedCount! ] Failed.

IF !_DeviceOKCount! GTR 0 (
	IF !_DeviceOKCount! EQU !_DeviceCount! (SET _CompleteBackup=TRUE)
)
IF !_CompleteBackup! EQU TRUE (
	SET _BackupResult=COMPLETE
) ELSE (
	SET _ShowProg=TRUE
	IF !_AllDevicesFiles! GTR 0 (
		SET _BackupResult=INCOMPLETE
	) ELSE (
		SET _BackupResult=FAILED
	)
)
CALL:P
CALL:P BACKUP STATUS:
CALL:P [ !_BackupResult! ]
CALL:P
REM ------------------------------------------------------------------------------------------------
SET _DebugStep=ZIP& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
IF !_AllDevicesFiles! GTR 0 (
	IF !_CompleteBackup! EQU TRUE (
		SET _ZipFileName=!_BkpName!.zip
	) ELSE (
		SET _ZipFileName=!_BkpName!-INCOMPLETE.zip
	)
	SET _ZipFile=!_BkpDir!\!_ZipFileName!
	PUSHD "!_BkpDir!"
		FOR /F %%a IN ('DIR /b /s') DO SET /A _TotalFiles+=1
	POPD
	CALL:P -------------STARTING COMPRESION---------------
	CALL:P
	CALL:P Compressing files...
	CALL:P --[ !_TotalFiles! ] Files to add to zip.
	CALL:P --Creating [ !_ZipFileName! ]
	CALL:PL --Creating [ !_ZipFile! ]
	START "" /WAIT "!_BinFolder!\zip.exe" -R "!_ZipFileName!" *	
	IF NOT ERRORLEVEL 0 ( SET /A _ErrorNum=13& GOTO:ERROR )
	SET _ZipComplete=TRUE
	CALL:P ---Files compressed succesfully.
	CALL:P 
	POPD & REM <This POPD matches a PUSHD from the IP Address read section>
	CALL:P --Trying to move zip file to backup folder...
	MOVE /Y "!_ZipFile!" "!_BkpRoot!"
	IF EXIST "!_BkpRoot!\!_ZipFileName!" (
		SET _ZipFile=!_BkpRoot!\!_ZipFileName!
		SET ZipInRoot=TRUE
		CALL:P ---[ !_ZipFileName! ] moved to backup folder.
		CALL:P
		CALL:P --Trying to delete non-zipped files in:
		CALL:P --[ !_BkpName! ]
		CALL:PL --[ !_BkpDir! ]
		IF EXIST "!_BkpDir!" RMDIR /Q /S "!_BkpDir!"
		IF NOT EXIST "!_BkpDir!" (
			CALL:P ---Non-zipped files succesfully deleted.
		) ELSE (
			CALL:P ---Failed to delete non-zipped files.
		)
	) ELSE ( CALL:P ---Failed to move zip file. )
)
GOTO:FIN

:FIN
REM ------------------------------------------------------------------------------------------------
SET _DebugStep=EXIT SEQ& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
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

IF DEFINED _BkpDir (
	IF DEFINED _AllDevicesFiles (
		IF !_AllDevicesFiles! EQU 0 (
		CALL:P --No files downloaded.
			IF EXIST "!_BkpDir!" (
				IF !_OKToDelete! EQU TRUE (
					CALL:P --Deleting backup folder:
					CALL:P --[ !_BkpName! ]
					CALL:PL --[ !_BkpDir! ]...
					CD "!_BkpRoot!"
					RMDIR /Q /S "!_BkpDir!" >>"!_LogFile!"
					IF NOT EXIST "!_BkpDir!" ( CALL:P ---[ !_BkpName! ] succesfully deleted. ) ELSE (SET _ShowProg=TRUE& CALL:P ---Failed to delete backup folder. )
				) ELSE ( CALL:P ---Not clear to delete folder. )
			) ELSE (CALL:P --No folder to delete.)
		)
	)
)

IF !_NoLog! EQU FALSE (
	SET _LogName=!_LogFolder!\.!_ProgName!-!_ProgRunDateTimeSerial!.txt
	IF !_ZipComplete! EQU TRUE (
		CALL:PL Will try to add the log to zip file.
		CALL:PL	If you see this file in the backup it means it worked.
		CALL:PL
		CALL:PL ......__________         __________     
		CALL:PL ...../ /        \       / /        \    
		CALL:PL ..../ /    ______\     / /    ______\   
		CALL:PL .../ /    / ______    / /    / ______   
		CALL:PL ../ /    / /      \  / /    / /      \  
		CALL:PL ./ /    / /___     \/ /    / /___     \ 
		CALL:PL .\ \    \____/     /\ \    \____/     / 
		CALL:PL ..\ \             /  \ \             /  
		CALL:PL ...\ \___________/    \ \___________/    
		CALL:PL ....\___________/OOD   \___________/AME...
		CALL:PL
		PUSHD "!_LogFolder!"
		START "" /WAIT "!_BinFolder!\zip.exe" -R "!_ZipFile!" "!_LogFileName!"
		REM STUFF BELOW THIS POINT WILL NOT SHOW IN THE LOG IN THE BACKUP---------------
		
		IF ERRORLEVEL 0 (
			CALL:PL ---Log added succesfully.
		) ELSE (
			CALL:PL ---Failed to add log.
		)
		POPD
	)
	CALL:P Saving log as:
	CALL:P [ .!_ProgName!-!_ProgRunDateTimeSerial!.txt ]
	COPY /Y "!_LogFile!" "!_LogName!">NUL
	IF EXIST "!_LogName!" ( CALL:P ---Log save successful.) ELSE ( SET _ShowProg=TRUE& CALL:P ---Failed to save log. )
)

:OUT
REM ------------------------------------------------------------------------------------------------
SET _DebugStep=OUT& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
SET /A _DeviceOKCount=!_DeviceOKCount!+!_DeviceIncompleteCount!
TITLE=!_ProgName! v!_ProgVersion! [ Downloaded: !_DeviceOKCount!/!_DeviceCount! ] - !_BackupResult!
CALL:PL
CALL:PL Real Program End. BYE
IF !_ShowProg! EQU TRUE ( PAUSE )
ENDLOCAL & GOTO:EOF

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
REM ------------------------------------------------------------------------------------------------
SET _DebugStep=HELP& IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
CALL:P
CALL:P Opened help display.
ECHO.
ECHO.-Based off template v.!_TemplateVersion!
ECHO. 
ECHO.!_ProgDesc1!
ECHO.!_ProgDesc2!
ECHO.!_ProgDesc3!
ECHO.
ECHO.Program requires a device list
ECHO.In the same folder as the program
ECHO.Default list name is: 
ECHO.[ !_ProgName!.csv ]
ECHO.Format for each device is:
ECHO.Device_Name,Device_IP,user,password,#
ECHO.E.G. Robot1,138.186.8.1,FtpUsername,FtpPassword,# 
ECHO.
ECHO.Available arguments:
ECHO.[ /show ] to pause at the end of program.
ECHO.[ /nolog ] to not include a log in backups.
ECHO.[ /debug ] to display debug steps.
ECHO.
ECHO.[ /nodown ] to skip download calls.
ECHO.[ /csv ] to use a diffent device list.
ECHO.E.G. !_ProgName!.bat /csv FileNameWithoutExtension
ECHO.
ECHO.Dates are in mm/dd/yyyy format.
ECHO.
ECHO.Execution time: [ !_ProgRunTimeRead! ] on [ !_ProgRunDateRead! ]
ECHO.
ECHO.Current directory:
ECHO.[ !_ProgRunDir! ]
ECHO.Log files created on:
ECHO.[ !_LogFolder! ]
ECHO.
ECHO.Written by G.G - Last Edit !_ProgLastModDate!
ECHO.
GOTO:FIN

:TRY_PING
REM ------------------------------------------------------------------------------------------------
SET _DebugStep=TRY PING & IF !_Debug! EQU TRUE (CALL:P #!_DebugStep!& @ECHO OFF)
REM ------------------------------------------------------------------------------------------------
REM Argument 1 should be the IP Address to try to ping.
SET _PingOK=TRUE
IF "%~1" EQU "" (CALL:P No IP Address& SET _PingOK=FALSE&& GOTO:EOF)
PING -n 2 -w 30 "%~1" |FIND /I "TTL=">NUL
IF ERRORLEVEL 1 SET _PingOK=FALSE
GOTO:EOF

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

