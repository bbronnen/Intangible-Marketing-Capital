REM ****************************************************
REM * make.bat: double-click to run all scripts
REM ****************************************************

SET LOG= ..\output\make.log

REM DELETE OUTPUT & TEMP FILES
RMDIR  ..\output /S /Q
MKDIR  ..\output
MKDIR  ..\output\tables
MKDIR  ..\output\figures
RMDIR  ..\temp /S /Q
MKDIR  ..\temp


REM LOG START
ECHO make.bat started	>%LOG%
ECHO %DATE%		>>%LOG%
ECHO %TIME%		>>%LOG%


REM ANALYSIS.DO
%STATAEXE% /e do figures

COPY %LOG%+figures.log %LOG%

DEL figures.log

REM CLOSE LOG
ECHO make.bat completed	>>%LOG%
ECHO %DATE%		>>%LOG%
ECHO %TIME%		>>%LOG%

PAUSE