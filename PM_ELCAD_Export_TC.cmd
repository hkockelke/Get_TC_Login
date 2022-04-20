@echo off
REM ---------------------------------
REM  Putzmeister 2021
REM  Export ELCAD Data to Teamcenter
REM ---------------------------------
REM  change: Sept 2, 2021 | Helmut | tcpb_import_file with option -de=c

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
SET "AttributeLog=%LogBaseDIR%\%DateFormated%_%TimeFormated%_Attr.log"
SET "ImportLog=%LogBaseDIR%\%DateFormated%_%TimeFormated%_Import.log"
SET "CMDLog=%LogBaseDIR%\%DateFormated%_%TimeFormated%_CMD.log"

ECHO Start of Import to Teamcenter Commands>%CMDLog%
ECHO ______________________________________>>%CMDLog%

ECHO SPLM_SHR_DIR : %SPLM_SHR_DIR%>>%CMDLog%

ECHO.
ECHO Input Parameters>>%CMDLog%
ECHO 1: %1>>%CMDLog%
ECHO 2: %2>>%CMDLog%
SET "SAP_MATNO=%1"
ECHO SAP_MATNO: %SAP_MATNO%>>%CMDLog%
SET "RevisionID=%2"
ECHO RevisionID: %RevisionID%>>%CMDLog%
SET "ELCAD_Type=%3"
ECHO ELCAD_Type: %ELCAD_Type%>>%CMDLog%


REM for /f "tokens=1,2 delims=_" %%a in ("%InputDir%") do (
REM    SET "SAP_MATNO=%%a" 
REM    SET "RevisionID=%%b" )


ECHO SAP_MATNO:  %SAP_MATNO%
ECHO RevisionID: %RevisionID%
ECHO ELCAD_Type: %ELCAD_Type%
ECHO.

SET "QueryBaseDIR=%ELCAD_Base_dir%QueryResults"
if not exist %QueryBaseDIR% mkdir %QueryBaseDIR%
SET "QueryResult=%QueryBaseDIR%\%SAP_MATNO%_%RevisionID%.csv"
SET "CleanQueryResult=%QueryBaseDIR%\%SAP_MATNO%_%RevisionID%_clean.txt"

REM SPLM_TMP_DIR=c:\plmtemp
REM SPLM_SHR_DIR=\\azrweupdm23.jumbo.net\plmshare

SET "ImportBaseDir=%SPLM_TMP_DIR%\ELCAD"
if not exist %ImportBaseDir% mkdir %ImportBaseDir%
REM SET "ImportDIR=%ImportBaseDir%\%SAP_MATNO%_%RevisionID%"
SET "ImportDIR=%ImportBaseDir%\export"
SET "ImportFile=%ImportDIR%\importList.txt"
SET "AttrTemplateFile=%ImportDIR%\attribute_template.txt"

REM clean-up
IF EXIST %ImportFile% (
    del %ImportFile%
)

ECHO ELCAD_Base_dir: %ELCAD_Base_dir%>>%CMDLog%
ECHO QueryBaseDIR: %QueryBaseDIR%>>%CMDLog%
ECHO QueryResult: %QueryResult%>>%CMDLog%
ECHO CleanQueryResult: %CleanQueryResult%>>%CMDLog%
ECHO ImportDIR: %ImportDIR%>>%CMDLog%
ECHO ImportFile: %ImportFile%>>%CMDLog%
ECHO USERPROFILE: %USERPROFILE%>>%CMDLog%

REM if not exist %TC_TMP_DIR% mkdir %TC_TMP_DIR%

REM set "ORACLE_SID=pmprod"
REM set "SPLM_SHR_DIR=\\azrweupdm23.jumbo.net\plmshare"

set "ORACLE_SID=pmprod"

echo %ORACLE_SID%>>%CMDLog%

REM Login to TC
REM set "UPG=-u=%importuser% -p=%importpassw% -g=%importgrp%"
REM %ProgPath%Get_TC_Login.exe

set "ELCAD_TC_CMD=%USERPROFILE%\TC_Login.cmd"

if exist %ELCAD_TC_CMD% (
   call %ELCAD_TC_CMD%
) else (
   goto :errorExit
)

REM set TC_TMP_DIR=%SPLM_TMP_DIR%
REM set TC_DATA=%SPLM_SHR_DIR%\%ORACLE_SID%data
REM if exist %SPLM_SHR_DIR%\%ORACLE_SID%data\win64 set TC_DATA=%SPLM_SHR_DIR%\%ORACLE_SID%data\win64
REM call %TC_DATA%\tc_profilevars

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
   call %SPLM_SHR_DIR%\start_apps\windows\start_nx120.bat %Language% %CONFIG% %ORACLE_SID% %VERSION%>>%CMDLog%

)

set TC_BIN=%TC_ROOT%\bin

set PATH=%TC_BIN%;%PATH%

ECHO _________________________________________________________________________________________>>%CMDLog%
ECHO.>>%CMDLog%
ECHO Query>>%CMDLog%
ECHO _________________________________________________________________________________________>>%CMDLog%
SETLOCAL EnableDelayedExpansion

ECHO Query ItemId from SAP Mat Number
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
	  REM IF X"%RelStatus:C2NX=" == X%RelStatus% goto :END_FOR_LOOP
   )
) else (
   echo "Error Query">>%CMDLog%
   goto :errorExit
)

:END_FOR_LOOP

ECHO ___________________________________________________________________________________>>%CMDLog%
echo Found %ItemID% - %ItemRev%
echo CAD-System [%CADSystem%] - [%CADSource%]
echo Status %RelStatus%
echo Found Item-Id %ItemID%>>%CMDLog%
ECHO ___________________________________________________________________________________>>%CMDLog%

IF "%ItemID%" == "" (
   echo "Error ItemId">>%CMDLog%
   goto :errorExit
)

IF EXIST %ImportDIR%\%ItemID%_%RevisionID%_ELCAD.zip (
   echo delete existing ELCAD.zip
   del %ImportDIR%\%ItemID%_%RevisionID%_ELCAD.zip
)

IF EXIST %ImportDIR%\%SAP_MATNO%%RevisionID%.zip (
    ren %ImportDIR%\%SAP_MATNO%%RevisionID%.zip %ItemID%_%RevisionID%_ELCAD.zip
	echo %ImportDIR%\%SAP_MATNO%_%RevisionID%.zip >>%CMDLog%
) else (
   echo Missing File:>>%CMDLog%
   echo %ImportDIR%\%SAP_MATNO%%RevisionID%.zip>>%CMDLog%
   goto :errorExit
)

set "AttributeFile=%ImportDIR%\attribute_%ItemID%_%RevisionID%.txt"
echo AttributeFile=%AttributeFile%>>%CMDLog%
if EXIST %AttrTemplateFile% (
	COPY %AttrTemplateFile% %AttributeFile% /y
	ECHO PM5_Eng_Design^|%ItemID%^|%RevisionID%^|E-CAD^|%ELCAD_Type%>>%AttributeFile%
)


ECHO Create Import File

ECHO Create Import File>>%CMDLog%
ECHO  %ImportDIR%\%SAP_MATNO%%RevisionID%.pro\Teamcenter>>%CMDLog%
if EXIST %ImportDIR%\%SAP_MATNO%%RevisionID%.pro\Teamcenter\ (
   REM ECHO For all Files do   >>%CMDLog%  
   for  %%f in ( %ImportDIR%\%SAP_MATNO%%RevisionID%.pro\Teamcenter\*.* ) DO (
       echo %%f >>%CMDLog%
       echo %%~xf >>%CMDLog%
	   if "%%~xf" == ".pdf" (
	      echo "PDF file">>%CMDLog%
		  echo -f=%%f -d=%ItemID%-%RevisionID% -rel=IMAN_specification -type=PM5_PDF_Drawing -ref=PM5_PDF_Reference -item=%ItemID% -rev=%RevisionID% -owner=IREV -group=IREV -status=IREV -de=r>>%CMDLog%
		  echo -f=%%f -d=%ItemID%-%RevisionID% -rel=IMAN_specification -type=PM5_PDF_Drawing -ref=PM5_PDF_Reference -item=%ItemID% -rev=%RevisionID% -owner=IREV -group=IREV -status=IREV -de=r>>%ImportFile%
	   )
	   if "%%~xf" == ".xls" (
	      echo "Excel file">>%CMDLog%
		  echo -f=%%f -d=%%~nxf -rel=IMAN_specification -type=PM5_Excel -ref=PM5_excel -item=%ItemID% -rev=%RevisionID% -owner=IREV -group=IREV -status=IREV -de=r>>%CMDLog%
		  echo -f=%%f -d=%%~nxf -rel=IMAN_specification -type=PM5_Excel -ref=PM5_excel -item=%ItemID% -rev=%RevisionID% -owner=IREV -group=IREV -status=IREV -de=r>>%ImportFile%
	   )
	   if "%%~xf" == ".xlsx" (
	      echo "ExcelX file">>%CMDLog%
		  REM PM_<...>_HD.xslx file must not uploaded
		  echo %%f | findstr /r /c:"^PM_.*_HD.xlsx" >nul && (
               echo "exclude of file: PM_<...>_HD">>%CMDLog%
             ) || (
		       echo -f=%%f -d=%%~nxf -rel=IMAN_specification -type=MSExcelX -ref=excel -item=%ItemID% -rev=%RevisionID% -owner=IREV -group=IREV -status=IREV -de=r>>%CMDLog%
		       REM todo: currently there is a BUG in the script, here exclude all xlsx files
			   REM echo -f=%%f -d=%%~nxf -rel=IMAN_specification -type=MSExcelX -ref=excel -item=%ItemID% -rev=%RevisionID% -owner=IREV -group=IREV -status=IREV -de=r>>%ImportFile%
	         )
		  )
    )
)
REM echo -f=%ImportDIR%\%ItemID%_%RevisionID%_ELCAD.zip -d=%ItemID%_%RevisionID%_ELDAD -type=Zip -ref=ZIPFILE -rel=IMAN_specification -item=%ItemID% -rev=%RevisionID% -owner=IREV -group=IREV  -de=r>>%CMDLog%
echo -f=%ImportDIR%\%ItemID%_%RevisionID%_ELCAD.zip -d=%ItemID%_%RevisionID%_ELCAD -type=PM5_Data_ELCAD -ref=PM5_Zip_Reference -rel=PM5_ELCAD_Relation -item=%ItemID% -rev=%RevisionID% -owner=IREV -group=IREV  -de=r>>%CMDLog%
echo -f=%ImportDIR%\%ItemID%_%RevisionID%_ELCAD.zip -d=%ItemID%_%RevisionID%_ELCAD -type=PM5_Data_ELCAD -ref=PM5_Zip_Reference -rel=PM5_ELCAD_Relation -item=%ItemID% -rev=%RevisionID% -owner=IREV -group=IREV  -de=r>>%ImportFile%


ECHO ____________________________________________________________________________________________>>%CMDLog%
ECHO.>>%CMDLog%
ECHO Import>>%CMDLog%
ECHO ____________________________________________________________________________________________>>%CMDLog%
ECHO.
REM SET NLS_LANG=GERMAN_GERMANY.WE8ISO8859P1

ECHO Import in TC>>%CMDLog%
ECHO Import Files in TC
call %SPLM_SHR_DIR%\%ORACLE_SID%local\bin\tcpb_import_file.exe %UPG% -logfile=%ImportLog% -i=%ImportFile%>>%CMDLog%

if ERRORLEVEL 1 goto :errorExit

REM IF CADSystem OR CADSource not set/blank do the attribute update
set B_Do_Attr=0
if "%CADSystem%" == "" set B_Do_Attr=1
if "%CADSystem%" == " " set B_Do_Attr=1
if "%CADSource%" == "" set B_Do_Attr=1
if "%CADSource%" == " " set B_Do_Attr=1
if %B_Do_Attr% == 1 (
   ECHO Attributes>>%CMDLog%
   ECHO Add ELCAD Source System Attributes
   call %SPLM_SHR_DIR%\%ORACLE_SID%local\bin\tcpb_data_import %UPG% -input=%AttributeFile% -update_mode=MatchOnly -nodryrun -simple_mfk -return_error -log=%AttributeLog%>>%CMDLog%
)

if ERRORLEVEL 1 goto :errorExit


:gracefullExit

REM pause

del %QueryLog%
del %CMDLog%
del %ImportLog%
del %AttributeLog%
del %ImportFile%
del %AttributeFile%
del %QueryResult%
if EXIST %ImportDIR%\%SAP_MATNO%%RevisionID%.pro\ (
   rmdir /S /Q %ImportDIR%\%SAP_MATNO%%RevisionID%.pro
)

goto :EOF


:errorExit

ECHO.>>%CMDLog%
echo Error >>%CMDLog%

REM Undo the renaming in case of Error
IF EXIST %ImportDIR%\%ItemID%_%RevisionID%_ELCAD.zip (
   echo DRename back >>%CMDLog%
   ren %ImportDIR%\%ItemID%_%RevisionID%_ELCAD.zip %SAP_MATNO%%RevisionID%.zip 
) 
pause
goto :EOF 1
