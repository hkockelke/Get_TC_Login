@echo off
REM ------------------------------
REM  Putzmeister 2021
REM  Create ELCAD necessary Dirs
REM ------------------------------

SETLOCAL EnableDelayedExpansion

set FileName=%~n0
set ProgPath=%~dp0


SET ELCAD_Base_dir=%SPLM_TMP_DIR%\ELCAD\
if not exist %ELCAD_Base_dir% mkdir %ELCAD_Base_dir%

SET "LogBaseDIR=%ELCAD_Base_dir%Logs"
if not exist %LogBaseDIR% mkdir %LogBaseDIR%

SET "QueryBaseDIR=%ELCAD_Base_dir%QueryResults"
if not exist %QueryBaseDIR% mkdir %QueryBaseDIR%

SET "ExportBaseDir=%SPLM_TMP_DIR%\ELCAD"
if not exist %ExportBaseDir% mkdir %ExportBaseDir%

SET "ExportBaseDIR_ELCAD=%ExportBaseDir%\export"
SET "LocalBaseDIR_ELCAD=%ExportBaseDir%\local"
SET "ServerBaseDIR_ELCAD=%ExportBaseDir%\server"
SET "importBaseDIR_ELCAD=%ExportBaseDir%\import"
if not exist %ExportBaseDIR_ELCAD% mkdir %ExportBaseDIR_ELCAD%
if not exist %LocalBaseDIR_ELCAD% mkdir %LocalBaseDIR_ELCAD%
if not exist %importBaseDIR_ELCAD% mkdir %importBaseDIR_ELCAD%
if not exist %ServerBaseDIR_ELCAD% mkdir %ServerBaseDIR_ELCAD%


ECHO SPLM_TMP_DIR:        %SPLM_TMP_DIR%
ECHO ELCAD_Base_dir:      %ELCAD_Base_dir%
ECHO LogBaseDIR:          %LogBaseDIR%
ECHO ServerBaseDIR_ELCAD: %ServerBaseDIR_ELCAD%
ECHO LocalBaseDIR_ELCAD:  %LocalBaseDIR_ELCAD%
ECHO ImportBaseDIR_ELCAD: %importBaseDIR_ELCAD%
ECHO ExportBaseDIR_ELCAD: %ExportBaseDIR_ELCAD%
ECHO QueryBaseDIR:        %QueryBaseDIR%

pause
