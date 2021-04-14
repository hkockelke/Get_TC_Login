@echo off
REM ---------------------------------
REM  Putzmeister 2021
REM  Export ELCAD Data to Teamcenter
REM ---------------------------------

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
SET "ImportLog=%LogBaseDIR%\%DateFormated%_%TimeFormated%_%RevisionID%_Import.log"
SET "CMDLog=%LogBaseDIR%\%DateFormated%_%TimeFormated%_%RevisionID%_CMD.log"
echo Start of Import Commands>%CMDLog%

ECHO.
ECHO Input Parameters>>%CMDLog%
SET "InputDir=%1"
ECHO InputDir: %InputDir%>>%CMDLog%
ECHO 1: %1>>%CMDLog%

for /f "tokens=1,2 delims=_" %%a in ("%InputDir%") do (
SET "SAP_MATNO=%%a" 
SET "RevisionID=%%b" )

ECHO SAP_MATNO: %SAP_MATNO%>>%CMDLog%
ECHO RevisionID: %RevisionID%>>%CMDLog%
ECHO.

SET "QueryBaseDIR=%ELCAD_Base_dir%QueryResults"
if not exist %QueryBaseDIR% mkdir %QueryBaseDIR%
SET "QueryResult=%QueryBaseDIR%\%SAP_MATNO%_%RevisionID%.csv"
SET "CleanQueryResult=%QueryBaseDIR%\%SAP_MATNO%_%RevisionID%_clean.txt"

REM SPLM_TMP_DIR=c:\plmtemp
REM SPLM_SHR_DIR=\\azrweupdm23.jumbo.net\plmshare
REM SET "ImportBaseDir=%SPLM_SHR_DIR%\simulation"
SET "ImportBaseDir=%SPLM_TMP_DIR%\ELCAD"
if not exist %ImportBaseDir% mkdir %ImportBaseDir%
SET "ImportDIR=%ImportBaseDir%\%SAP_MATNO%_%RevisionID%"
SET "ImportFile=%ImportDIR%\importList.txt"
REM clean-up
IF EXIST %ImportFile% (
    del %ImportFile%
)

ECHO QueryBaseDIR: %QueryBaseDIR%>>%CMDLog%
ECHO QueryResult: %QueryResult%>>%CMDLog%
ECHO CleanQueryResult: %CleanQueryResult%>>%CMDLog%
ECHO ImportBaseDir: %ImportBaseDir%>>%CMDLog%
ECHO ImportDIR: %ImportDIR%>>%CMDLog%
ECHO ImportFile: %ImportFile%>>%CMDLog%

REM if not exist %TC_TMP_DIR% mkdir %TC_TMP_DIR%

REM set "ORACLE_SID=pmprod"
REM set "SPLM_SHR_DIR=C:\plm\plmshare"

set "ORACLE_SID=pmprod"

echo %ORACLE_SID%>>%CMDLog%

REM Login to TC
REM set "UPG=-u=%importuser% -p=%importpassw% -g=%importgrp%"
REM %ProgPath%Get_TC_Login.exe

if exist "C:\plmtemp\ELCAD\TC_Login.cmd" (
   call C:\plmtemp\ELCAD\TC_Login.cmd
) else (
   goto :errorExit
)


REM set TC_TMP_DIR=%SPLM_TMP_DIR%
REM set TC_DATA=%SPLM_SHR_DIR%\%ORACLE_SID%data
REM if exist %SPLM_SHR_DIR%\%ORACLE_SID%data\win64 set TC_DATA=%SPLM_SHR_DIR%\%ORACLE_SID%data\win64
REM call %TC_DATA%\tc_profilevars

call %SPLM_SHR_DIR%\start_apps\windows\start_nx120.bat en tc_prompt %ORACLE_SID% tc116>>%CMDLog%

set TC_BIN=%TC_ROOT%\bin

set PATH=%TC_BIN%;%PATH%



ECHO _________________________________________________________________________________________________________________>>%CMDLog%
ECHO.>>%CMDLog%
ECHO Create Loader File>>%CMDLog%
ECHO _________________________________________________________________________________________________________________>>%CMDLog%
SETLOCAL EnableDelayedExpansion

ECHO Query ItemId from SAP Mat Number
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

echo Found %ItemID%
echo %ItemID%>>%CMDLog%


IF EXIST %ImportDIR%\%SAP_MATNO%_%RevisionID%.zip (
    ren %ImportDIR%\%SAP_MATNO%_%RevisionID%.zip %ItemID%_%RevisionID%_ELCAD.zip
	echo %ImportDIR%\%SAP_MATNO%_%RevisionID%.zip >>%CMDLog%
) else (
   echo Missing File:>>%CMDLog%
   echo %ImportDIR%\%SAP_MATNO%_%RevisionID%.zip>>%CMDLog%
   goto :errorExit
)


ECHO Create Import File
REM echo -f=%ImportDIR%\%ItemID%_%RevisionID%.pdf -d=%ItemID%_%RevisionID%_%NewSequence%.pdf -type=PM5_PDF_Analysis_Result -ref=PM5_PDF_Reference -item=%ItemID% -rev=%RevisionID% -rel=PM5_SIM_Relation -owner=IREV -group=IREV -status=SIM -de=c>>%CMDLog%
REM echo -f=%ImportDIR%\%ItemID%_%RevisionID%.pdf -d=%ItemID%_%RevisionID%_%NewSequence%.pdf -type=PM5_PDF_Analysis_Result -ref=PM5_PDF_Reference -item=%ItemID% -rev=%RevisionID% -rel=PM5_SIM_Relation -owner=IREV -group=IREV -status=SIM -de=c>%ImportFile%
REM echo -f=%ImportDIR%\%ItemID%_%RevisionID%.pptx -d=%ItemID%_%RevisionID%_%NewSequence%.pptx -type=PM5_PDF_Analysis_Result -ref=PM5_PPTX_Reference -item=%ItemID% -rev=%RevisionID% -rel=PM5_SIM_Relation -owner=IREV -group=IREV -status=SIM -de=c>>%CMDLog%
REM echo -f=%ImportDIR%\%ItemID%_%RevisionID%.pptx -d=%ItemID%_%RevisionID%_%NewSequence%.pptx -type=PM5_PDF_Analysis_Result -ref=PM5_PPTX_Reference -item=%ItemID% -rev=%RevisionID% -rel=PM5_SIM_Relation -owner=IREV -group=IREV -status=SIM -de=c>>%ImportFile%
echo -f=%ImportDIR%\%ItemID%_%RevisionID%_ELCAD.zip -d=%ItemID%_%RevisionID%_ELDAD -type=Zip -ref=ZIPFILE -item=%ItemID% -rev=%RevisionID% -rel=IMAN_specification -owner=IREV -group=IREV  -de=r>>%CMDLog%
echo -f=%ImportDIR%\%ItemID%_%RevisionID%_ELCAD.zip -d=%ItemID%_%RevisionID%_ELCAD -type=Zip -ref=ZIPFILE -item=%ItemID% -rev=%RevisionID% -rel=IMAN_specification -owner=IREV -group=IREV  -de=r>>%ImportFile%


ECHO _________________________________________________________________________________________________________________>>%CMDLog%
ECHO.>>%CMDLog%
ECHO Import>>%CMDLog%
ECHO _________________________________________________________________________________________________________________>>%CMDLog%
ECHO.
REM SET NLS_LANG=GERMAN_GERMANY.WE8ISO8859P1

REM tcpb_import_file [-u= -p=|-pf= -g=] [-volume=] -i=|-f= -d= -type= -ref= [-ds_desc=] -revuid=|-item= [-rev=] [-item_type=] [-mfk=y] [-name=] [-desc=] [-rel=] [-ref_item=] [-de=] [-owner=] [-group=] [-status=] –nobypass –h
REM tcpb_import_file [-volume=] -i=|-f= -d= -type= -ref= [-ds_desc=] -revuid=|-item= [-rev=] [-item_type=] [-mfk=y] [-name=] [-desc=] [-rel=] [-ref_item=] [-de=] [-owner=] [-group=] [-status=] –nobypass –h

ECHO Import in TC
call %SPLM_SHR_DIR%\%ORACLE_SID%local\bin\tcpb_import_file.exe %UPG% -logfile=%ImportLog% -i=%ImportFile%>>%CMDLog%

if ERRORLEVEL 1 goto :errorExit

:gracefullExit
del %QueryLog%
del %CMDLog%
del %ImportLog%
del %ImportFile%
del %QueryResult%

goto :EOF


:errorExit
pause
goto :EOF 1
