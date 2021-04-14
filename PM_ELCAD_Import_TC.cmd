@echo off
REM -------------------------
REM  Putzmeister 2021
REM  Import TC Data to ELCAD
REM --------------------------

SETLOCAL EnableDelayedExpansion

set FileName=%~n0
set ProgPath=%~dp0

set DateFormated=%date:~-4%%date:~-8,-4%%date:~-10,-8%
set DateFormated=%DateFormated:.=-%
set DateFormated=%DateFormated:/=-%

set TimeFormated=%time:~0,5%
set TimeFormated=%TimeFormated: =0%
set TimeFormated=%TimeFormated:.=%
set TimeFormated=%TimeFormated:/=%
set TimeFormated=%TimeFormated::=%

REM turns off BCT Exits output
set BCT_DEBUG_TC_EXITS_STDOUT=0

SET ELCAD_Base_dir=%SPLM_TMP_DIR%\ELCAD\
if not exist %ELCAD_Base_dir% mkdir %ELCAD_Base_dir%

SET "LogBaseDIR=%ELCAD_Base_dir%Logs"
if not exist %LogBaseDIR% mkdir %LogBaseDIR%
SET "QueryLog=%LogBaseDIR%\%DateFormated%_%TimeFormated%_%RevisionID%_Query.log"
SET "ExportLog=%LogBaseDIR%\%DateFormated%_%TimeFormated%_%RevisionID%_Export.log"
SET "CMDLog=%LogBaseDIR%\%DateFormated%_%TimeFormated%_%RevisionID%_CMD.log"
echo Start of Export Commands>%CMDLog%

ECHO.
ECHO Input Parameters>>%CMDLog%
ECHO 1: %1>>%CMDLog%
ECHO 2: %2>>%CMDLog%
SET "InputDir=%1"
ECHO InputDir: %InputDir%>>%CMDLog%
SET "Checkout=%2"
ECHO Checkout: %Checkout%>>%CMDLog%

set TC_DATASET_CHECKOUT=Y
if /i "%Checkout%" == "false"  set TC_DATASET_CHECKOUT=N


for /f "tokens=1,2 delims=_" %%a in ("%InputDir%") do (
SET "SAP_MATNO=%%a" 
SET "RevisionID=%%b" )

ECHO SAP_MATNO: %SAP_MATNO%>>%CMDLog%
ECHO RevisionID: %RevisionID%>>%CMDLog%
ECHO.

SET "QueryBaseDIR=%ELCAD_Base_dir%QueryResults"
if not exist %QueryBaseDIR% mkdir %QueryBaseDIR%
SET "QueryResult=%QueryBaseDIR%\%SAP_MATNO%_%RevisionID%.csv"

REM SPLM_TMP_DIR=c:\plmtemp
REM SPLM_SHR_DIR=\\azrweupdm23.jumbo.net\plmshare

SET "ExportBaseDir=%SPLM_TMP_DIR%\ELCAD"
if not exist %ExportBaseDir% mkdir %ExportBaseDir%
SET "ExportDIR=%ExportBaseDir%\%SAP_MATNO%_%RevisionID%"
if not exist %ExportDIR% mkdir %ExportDIR%
SET "ExportFile=%ExportDIR%\exportList.txt"

SET "ExportBaseDIR_ELCAD=%ExportBaseDir%\export"
SET "LocalBaseDIR_ELCAD=%ExportBaseDir%\local"
SET "ServerBaseDIR_ELCAD=%ExportBaseDir%\server"
if not exist %ExportBaseDIR_ELCAD% mkdir %ExportBaseDIR_ELCAD%
if not exist %LocalBaseDIR_ELCAD% mkdir %LocalBaseDIR_ELCAD%
if not exist %ServerBaseDIR_ELCAD% mkdir %ServerBaseDIR_ELCAD%


REM clean-up first
IF EXIST %ExportFile% (
    del %ExportFile%
)

ECHO QueryBaseDIR: %QueryBaseDIR%>>%CMDLog%
ECHO QueryResult: %QueryResult%>>%CMDLog%
ECHO ExportBaseDir: %ExportBaseDir%>>%CMDLog%
ECHO ExportDIR: %ExportDIR%>>%CMDLog%
ECHO ExportFile: %ExportFile%>>%CMDLog%
ECHO.>>%CMDLog%
ECHO ExportBaseDIR_ELCAD: %ExportBaseDIR_ELCAD%>>%CMDLog%
ECHO LocalBaseDIR_ELCAD: %LocalBaseDIR_ELCAD%>>%CMDLog%
ECHO ServerBaseDIR_ELCAD: %ServerBaseDIR_ELCAD%>>%CMDLog%


REM if not exist %TC_TMP_DIR% mkdir %TC_TMP_DIR%

set "ORACLE_SID=pmprod"

echo %ORACLE_SID%>>%CMDLog%

REM -- Login to TC --
REM %ProgPath%Get_TC_Login.exe

if exist "C:\plmtemp\ELCAD\TC_Login.cmd" (
   call C:\plmtemp\ELCAD\TC_Login.cmd
) else (
   goto :errorExit
)

REM -- Set Environment for TC Utils --
REM set TC_TMP_DIR=%SPLM_TMP_DIR%
REM set TC_DATA=%SPLM_SHR_DIR%\%ORACLE_SID%data
REM if exist %SPLM_SHR_DIR%\%ORACLE_SID%data\win64 set TC_DATA=%SPLM_SHR_DIR%\%ORACLE_SID%data\win64
REM call %TC_DATA%\tc_profilevars

call %SPLM_SHR_DIR%\start_apps\windows\start_nx120.bat en tc_prompt %ORACLE_SID% tc116>>%CMDLog%

set TC_BIN=%TC_ROOT%\bin

set PATH=%TC_BIN%;%PATH%;C:\Windows\System32\WindowsPowerShell\v1.0\;


ECHO ___________________________________________________________________________________________>>%CMDLog%
ECHO.>>%CMDLog%
ECHO Create Loader File>>%CMDLog%
ECHO ___________________________________________________________________________________________>>%CMDLog%
SETLOCAL EnableDelayedExpansion

ECHO Get ItemId from SAP Mat Number
ECHO Get ItemId from SAP Mat Number>>%CMDLog%
%ProgPath%PM_Query_SAPMatNo.exe %UPG% -SAPMatNo=%SAP_MATNO% -rev=%RevisionID% -output=%QueryResult% -log=%QueryLog%>>%CMDLog%

if errorlevel 1 (
   echo Failure PM_Query_SAPMatNo %errorlevel%
   goto :errorExit
)

If EXIST %QueryResult% (
   FOR /f "tokens=1,2,3 delims=;" %%a IN (%QueryResult%) DO (
      SET "ItemID=%%a"
   )
) else (
   echo "Error Query">>%CMDLog%
   goto :errorExit
)

ECHO __________________________________________________________________________________________>>%CMDLog%
echo Found %ItemID%
echo Found Item-Id %ItemID%>>%CMDLog%
ECHO __________________________________________________________________________________________>>%CMDLog%

IF "%ItemID%" == "" (
   echo "Error ItemId">>%CMDLog%
   goto :errorExit
)


ECHO Create Export File
REM echo -f=%ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip -replace -d=%ItemID%_%RevisionID%_ELCAD -type=Zip -ref=ZIPFILE -item=%ItemID% -rev=%RevisionID% -rel=IMAN_specification -export=y>>%CMDLog%
echo -f=%ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip -replace -d=%ItemID%_%RevisionID%_ELCAD -type=Zip -ref=ZIPFILE -item=%ItemID% -rev=%RevisionID% -rel=IMAN_specification -export=y>>%ExportFile%


ECHO __________________________________________________________________________________________>>%CMDLog%
ECHO.>>%CMDLog%
ECHO Export>>%CMDLog%
ECHO __________________________________________________________________________________________>>%CMDLog%
ECHO.

IF EXIST %ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip (
   echo delete existing ELCAD.zip
   del %ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip
)

REM Export does not create a Log file
ECHO Execute the TC Export
REM call %SPLM_SHR_DIR%\%ORACLE_SID%local\bin\tcpb_export_file.exe %UPG% -logfile=%ExportLog% -i=%ExportFile%>>%CMDLog%
call %ProgPath%PM_ELCAD_Download_File.exe %UPG% -item=%ItemID% -rev=%RevisionID% -outputDir=%ExportDIR% -checkout=%TC_DATASET_CHECKOUT% -log=%ExportLog%>>%CMDLog%

REM -- Rename --
ECHO Rename>>%CMDLog%
If EXIST %ExportDIR%\%SAP_MATNO%_%RevisionID%.zip  (
   echo delete existing %ExportDIR%\%SAP_MATNO%_%RevisionID%.zip >>%CMDLog%
   del %ExportDIR%\%SAP_MATNO%_%RevisionID%.zip
)
IF EXIST %ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip (
    ren %ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip %SAP_MATNO%_%RevisionID%.zip 
	echo %ExportDIR%\%SAP_MATNO%_%RevisionID%.zip >>%CMDLog%
) else (
   echo %ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip>>%CMDLog%
   echo "Error tcpb_export_file" >>%CMDLog%
   goto :errorExit
)


REM -- Extract with powershell cmd
echo File found, extract to: %ServerBaseDIR_ELCAD%
echo "Extract ZIP file">>%CMDLog%
ECHO %PATH%>>%CMDLog%
powershell.exe -command "Expand-Archive -Force '%ExportDIR%\%SAP_MATNO%_%RevisionID%.zip' '%ServerBaseDIR_ELCAD%'"

if ERRORLEVEL 1 goto :errorExit

:gracefullExit
del %QueryLog%
del %CMDLog%
REM del %ExportLog%
del %ExportFile%
del %QueryResult%

goto :EOF


:errorExit
pause
goto :EOF 1
