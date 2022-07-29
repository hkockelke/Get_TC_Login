@echo off
REM ------------------------------
REM  Putzmeister 2021
REM  Import from TC Data to ELCAD
REM ------------------------------
REM  change: July 29, 2022 | Helmut | add new Parameter Unzip=true|false

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
SET "QueryLog=%LogBaseDIR%\%DateFormated%_%TimeFormated%_Query.log"
SET "ExportLog=%LogBaseDIR%\%DateFormated%_%TimeFormated%_Export.log"
SET "CMDLog=%LogBaseDIR%\%DateFormated%_%TimeFormated%_CMD.log"

ECHO Start of Teamcenter Export Commands>%CMDLog%
ECHO ___________________________________>>%CMDLog%

ECHO SPLM_SHR_DIR : %SPLM_SHR_DIR%>>%CMDLog%

ECHO.
ECHO Input Parameters>>%CMDLog%
ECHO 1: %1>>%CMDLog%
ECHO 2: %2>>%CMDLog%
ECHO 3: %3>>%CMDLog%
ECHO 4: %4>>%CMDLog%
SET "SAP_MATNO=%1"
ECHO SAP_MATNO: %SAP_MATNO%>>%CMDLog%
SET "RevisionID=%2"
ECHO RevisionID: %RevisionID%>>%CMDLog%
SET "Checkout=%3"
ECHO Checkout: %Checkout%>>%CMDLog%
SET "Unzip=%4"
ECHO Unzip: %Unzip%>>%CMDLog%

set TC_DATASET_CHECKOUT=Y
if /i "%Checkout%" == "false"  set TC_DATASET_CHECKOUT=N


REM for /f "tokens=1,2 delims=_" %%a in ("%InputDir%") do (
REM    SET "SAP_MATNO=%%a" 
REM    SET "RevisionID=%%b" 
REM )

ECHO SAP_MATNO:  %SAP_MATNO%
ECHO RevisionID: %RevisionID%
ECHO Checkout:   %Checkout%
ECHO Unzip:      %Unzip%
ECHO.

REM Contains the output dir 
set "ELCAD_TC_DIR_CMD=%ELCAD_Base_dir%\TC_SAP_MN.cmd"

if exist %ELCAD_TC_DIR_CMD% (
   call %ELCAD_TC_DIR_CMD%
) else (
   goto :errorExit
)
ECHO ELCAD_IMP_TC_DIR: %ELCAD_IMP_TC_DIR%>>%CMDLog%

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
SET "importBaseDIR_ELCAD=%ExportBaseDir%\import"
if not exist %ExportBaseDIR_ELCAD% mkdir %ExportBaseDIR_ELCAD%
if not exist %LocalBaseDIR_ELCAD% mkdir %LocalBaseDIR_ELCAD%
if not exist %importBaseDIR_ELCAD% mkdir %importBaseDIR_ELCAD%


REM clean-up first
IF EXIST %ExportFile% (
    del %ExportFile%
)

ECHO ELCAD_Base_dir: %ELCAD_Base_dir%>>%CMDLog%
ECHO QueryBaseDIR: %QueryBaseDIR%>>%CMDLog%
ECHO QueryResult: %QueryResult%>>%CMDLog%
ECHO ExportDIR: %ExportDIR%>>%CMDLog%
ECHO ExportFile: %ExportFile%>>%CMDLog%
ECHO.>>%CMDLog%
ECHO ExportBaseDIR_ELCAD: %ExportBaseDIR_ELCAD%>>%CMDLog%
ECHO LocalBaseDIR_ELCAD:  %LocalBaseDIR_ELCAD%>>%CMDLog%
ECHO ImportBaseDIR_ELCAD: %importBaseDIR_ELCAD%>>%CMDLog%

REM if not exist %TC_TMP_DIR% mkdir %TC_TMP_DIR%

set "ORACLE_SID=pmprod"

echo %ORACLE_SID%>>%CMDLog%

REM -- Login to TC --

set "ELCAD_TC_CMD=%USERPROFILE%\TC_Login.cmd"

if exist %ELCAD_TC_CMD% (
   call %ELCAD_TC_CMD%
) else (
   ECHO Error TC Login File missing
   ECHO TC_Login File missing >>%CMDLog%
   goto :errorExit
)


REM -- Set Environment for TC Utils --
REM set TC_TMP_DIR=%SPLM_TMP_DIR%
REM set TC_DATA=%SPLM_SHR_DIR%\%ORACLE_SID%data
REM if exist %SPLM_SHR_DIR%\%ORACLE_SID%data\win64 set TC_DATA=%SPLM_SHR_DIR%\%ORACLE_SID%data\win64
REM call %TC_DATA%\tc_profilevars

REM only TC13 is supported (April 20, 2022)
set VERSION=tc13
set Language=en
set CONFIG=tc_prompt
REM echo %SPLM_SHR_DIR% | findstr /l "azrweupdm33" >nul && set VERSION=tc13

IF "%VERSION%" == "tc13" (
   ECHO.>>%CMDLog%
   ECHO "Teamcenter 13">>%CMDLog%
   ECHO.>>%CMDLog%
   
   set ORACLE_SID=pmprod13
   set NX_INST_DIR=nx1953
   REM --------------
   REM Therefore the delayedExpansion syntax exists, it uses ! instead of % and it is evaluated at execution time, not parse time.
   REM Please note that in order to use !, the additional statement setlocal EnableDelayedExpansion is needed.
   REM --------------
   call %SPLM_SHR_DIR%\start_apps\!NX_INST_DIR!\start_nx.bat %Language% %CONFIG% !ORACLE_SID! %VERSION%>>%CMDLog%

) else (
   ECHO "Teamcenter version not supported">>%CMDLog%
   REM call %SPLM_SHR_DIR%\start_apps\windows\start_nx120.bat %Language% %CONFIG% %ORACLE_SID% %VERSION%>>%CMDLog%
   goto :errorExit
)

set TC_BIN=%TC_ROOT%\bin

set PATH=%TC_BIN%;%PATH%;C:\Windows\System32\WindowsPowerShell\v1.0\;


ECHO ___________________________________________________________________________________>>%CMDLog%
ECHO.>>%CMDLog%
ECHO Query SAP Mat No>>%CMDLog%
ECHO ___________________________________________________________________________________>>%CMDLog%
SETLOCAL EnableDelayedExpansion

ECHO Get ItemId from SAP Mat Number
ECHO Get ItemId from SAP Mat Number>>%CMDLog%
%ProgPath%PM_Query_SAPMatNo.exe %UPG% -SAPMatNo=%SAP_MATNO% -rev=%RevisionID% -output=%QueryResult% -log=%QueryLog%>>%CMDLog%

if errorlevel 1 (
   echo Failure PM_Query_SAPMatNo %errorlevel%
   goto :errorExit
)

If EXIST %QueryResult% (
   FOR /f "tokens=1,2,3,4,5,6 delims=;" %%a IN (%QueryResult%) DO (
      SET "ItemID=%%a"
      SET "ItemRev=%%b"
      SET "CADSystem=%%d"
      SET "CADSource=%%e"
      SET "RelStatus=%%f"
      IF "%%d" == "E-CAD" goto :END_FOR_LOOP
   )
) else (
   echo "Error Query">>%CMDLog%
   goto :errorExit
)

:END_FOR_LOOP

ECHO ___________________________________________________________________________________>>%CMDLog%
echo Found %ItemID% - %ItemRev%
echo CAD-System %CADSystem% - %CADSource%
echo Status %RelStatus%
echo Found Item-Id %ItemID%>>%CMDLog%
ECHO ___________________________________________________________________________________>>%CMDLog%

IF "%ItemID%" == "" (
   echo Error   
   echo "Error ItemId">>%CMDLog%
   goto :errorExit
)


ECHO Create Export File
REM echo -f=%ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip -replace -d=%ItemID%_%RevisionID%_ELCAD -type=Zip -ref=ZIPFILE -item=%ItemID% -rev=%RevisionID% -rel=IMAN_specification -export=y>>%CMDLog%
echo -f=%ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip -replace -d=%ItemID%_%RevisionID%_ELCAD -rel=PM5_ELCAD_Relation -type=PM5_Data_ELCAD -ref=PM5_Zip_Reference -item=%ItemID% -rev=%RevisionID% -export=y>>%ExportFile%


ECHO ____________________________________________________________________________________>>%CMDLog%
ECHO.>>%CMDLog%
ECHO Export>>%CMDLog%
ECHO ____________________________________________________________________________________>>%CMDLog%
ECHO.

IF EXIST %ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip (
   echo delete existing ELCAD.zip
   del %ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip
)

REM Export does not create a Log file
ECHO Execute the TC Export
REM call %SPLM_SHR_DIR%\%ORACLE_SID%local\bin\tcpb_export_file.exe %UPG% -logfile=%ExportLog% -i=%ExportFile%>>%CMDLog%
call %ProgPath%PM_ELCAD_Download_File.exe %UPG% -item=%ItemID% -rev=%RevisionID% -outputDir=%ExportDIR% -checkout=%TC_DATASET_CHECKOUT% -log=%ExportLog%>>%CMDLog%

if ERRORLEVEL 1 goto :errorExit

ECHO Export finished

REM -- Rename --
ECHO Rename>>%CMDLog%
If EXIST %ExportDIR%\%SAP_MATNO%%RevisionID%.zip  (
   echo delete existing %ExportDIR%\%SAP_MATNO%%RevisionID%.zip >>%CMDLog%
   del %ExportDIR%\%SAP_MATNO%%RevisionID%.zip
)
IF EXIST %ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip (
   ren %ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip %SAP_MATNO%%RevisionID%.zip 
   echo %ExportDIR%\%SAP_MATNO%%RevisionID%.zip >>%CMDLog%
) else (
   echo %ExportDIR%\%ItemID%_%RevisionID%_ELCAD.zip>>%CMDLog%
   echo Error tcpb_export_file
   echo "Error tcpb_export_file" >>%CMDLog%
   goto :errorExit
)


REM -- Extract with powershell cmd
echo Teamcenter Export File found

if /i "%Unzip%" == "true" (
   echo "Extract ZIP file">>%CMDLog%
   REM ECHO %PATH%>>%CMDLog%
   powershell.exe -command "Expand-Archive -Force '%ExportDIR%\%SAP_MATNO%%RevisionID%.zip' '%LocalBaseDIR_ELCAD%'"
)

echo "Move ZIP file to %ELCAD_IMP_TC_DIR%">>%CMDLog%
move %ExportDIR%\%SAP_MATNO%%RevisionID%.zip %ELCAD_IMP_TC_DIR%

echo %SAP_MATNO%%RevisionID%.zip > %ELCAD_IMP_TC_DIR%\ImportFromTC.txt

if ERRORLEVEL 1 goto :errorExit

:gracefullExit

REM Pause
del %QueryLog%
del %CMDLog%
REM del %ExportLog%
del %ExportFile%
del %QueryResult%
if EXIST %ExportDIR%\ (
   rmdir /S /Q %ExportDIR%
)
REM goto :EOF
exit /B 0

:errorExit
echo Error Import from TC >>%CMDLog%
REM pause
REM goto :EOF 1
exit /B 1
