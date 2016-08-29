@echo off
rem ******************************************************************
rem *                       ��Դ�ļ�ͬ��ϵͳ                         *
rem *                       �汾��    2.0                            *
rem *                       ���ߣ�    �α���                         *
rem *                       ����ʱ�䣺2016/08/18                     *
rem ******************************************************************

setlocal EnableDelayedExpansion
rem ------------------���û���������ʼ--------------------------------
rem ģ��
set MODULE=CUV
rem ҵ�����
set COMPONENT=visitindex,visitcardmag,visittask,workplan,cuvpub
rem ����Ŀ¼
set PROJECT=D:\WORKSPACE\customvisit\CRM_CUV
rem NC HOME
set NC_HOME=D:\NC_HOME\ehp2_427_visitindex

rem ------------------�����û���������--------------------------------
rem ------------------�������л�����ʼ--------------------------------
rem �������(��)
set INTERVAL=2
rem Debug��������ʾ��������ϸ��Ϣ(Y/N)
set DEBUG=N
rem ͬ��Log������ͬ�����ļ���¼����־(Y/N)
set SYNCLOG=Y
rem ��־�ļ�
set LOGFILE=log.txt
rem ��Դ·��
set TARG_SOURCE_PATH=hotwebs\portal\sync
set SRC_HTML_PATH=web\html

rem ------------------�������л�������--------------------------------
rem ����ǰ�Թ���Ŀ¼��HOMEĿ¼���м��
call :RunCheck

rem ��ʼ���ӹ������ļ��ĸĶ�
:start
cls
rem ��ӡ������Ϣ
call :PrintSysInfo
echo �ļ�������.
echo �����ʱ��:%time:~0,-3%
for %%i in (%COMPONENT%) do (
	call :SyncSource %%i
)
call :Delay %INTERVAL%
goto :start

:SyncSource
rem ҵ�����
call :Info ��ʼͬ��ҵ�����[%1]
set src=%PROJECT%\%1\%SRC_HTML_PATH%
set targ=%NC_HOME%\%TARG_SOURCE_PATH%\%MODULE%\%1\html
call :ListenFolder "%src%" "%targ%" "^>ͬ��web��Դ.."

call :Info ^>ͬ��META-INF��Դ..
set src=%PROJECT%\%1\META-INF
set targ=%NC_HOME%\modules\%MODULE%\META-INF
call :ListenFolder "%src%" "%targ%" "ͬ����modules\%MODULE%\META-INF.."

goto :eof

rem ���Ŀ¼���ļ��汾������ļ��汾��HOME���ļ��汾��һ�������
:ListenFolder
set src=%~1
set targ=%~2
set "folder=!src:%PROJECT%=Project!"
call :Info %3
call :Info ���ڼ��Ŀ¼��%folder%
for /r %1 %%i in (*.*) do (
	set srcfile=%%i
	set "targFile=!srcfile:%src%=%targ%!"
	call :CompareAndCopyFile "!srcfile!" "!targFile!" %4
)
goto :eof

rem ����ļ��汾������ļ��汾��HOME���ļ��汾��һ�������
:CompareAndCopyFile
set file=%1
set file=!file:%PROJECT%=Project!
if "%~t1" neq "%~t2" (
	echo A|xcopy /s /i "%src%" "%targ%" > nul
	call :ShowWithColor a ��ʾ���Ѹ����ļ���!file!.
	call :Log %1
) else (
	call :Info �Ѽ���ļ���!file!.
)
goto :eof

rem ��ʱָ����ʱ��
:Delay
choice /t %1 /d y /n >nul
goto :eof

rem �����ϸ��Ϣ
:Info
if "%DEBUG%"=="Y" echo ��Ϣ��%1%2
goto :eof

rem ���ͬ����־
:Log
if "%SYNCLOG%"=="Y" echo [%date:~0,10% %time:~0,8%] ͬ���ļ�:%1 >> %LOGFILE%
goto :eof

rem �������ɫ����(a:��ɫ��c:��ɫ)
:ShowWithColor
echo %2
rem echo. >%2&findstr /a:%1 . %2*&del %2
goto :eof

rem ����ǰ���
:RunCheck
if not exist "%PROJECT%" echo ����Ŀ¼[%PROJECT%]�����ڣ����������ù���Ŀ¼. & pause & exit
if not exist "%NC_HOME%" echo NC HOMTEĿ¼[%NC_HOME%]�����ڣ�����������NC HOMTEĿ¼. & pause & exit
type "%PROJECT%\META-INF\module.xml" | find /i "%MODULE%" > nul || ( echo ģ����[%MODULE%]�빤�̲�ƥ�䣬��������ȷ��ģ����. & pause & exit )
for %%i in (%COMPONENT%) do (
	if not exist "%PROJECT%\%%i" echo ����Ŀ¼[%PROJECT%]��ҵ�����[%%i]�����ڣ���ȷ������. & pause & exit
)
goto :eof

rem ��ʾ������Ϣ
:PrintSysInfo
echo ************************������Ϣ************************
echo * ����Ŀ¼:%PROJECT%
echo * NC HOME :%NC_HOME%
echo * ģ��    :%MODULE%
echo * ҵ�����:%COMPONENT%
echo * ����ʱ����:%INTERVAL%��
if "%DEBUG%" == "Y" (
	echo * ��ӡ��ϸ��Ϣ:����
) else (
	echo * ��ӡ��ϸ��Ϣ:�ر�
)
if "%SYNCLOG%" == "Y" (
	echo * ����ͬ����־:����
) else (
	echo * ����ͬ����־:�ر�
)
echo * ��־�ļ�:%LOGFILE%
echo ************************������Ϣ************************
goto :eof