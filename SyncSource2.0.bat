@echo off
rem ******************************************************************
rem *                       资源文件同步系统                         *
rem *                       版本：    2.0                            *
rem *                       作者：    任宝玉                         *
rem *                       更新时间：2016/08/18                     *
rem ******************************************************************

setlocal EnableDelayedExpansion
rem ------------------设置环境变量开始--------------------------------
rem 模块
set MODULE=CUV
rem 业务组件
set COMPONENT=visitindex,visitcardmag,visittask,workplan,cuvpub
rem 工程目录
set PROJECT=D:\WORKSPACE\customvisit\CRM_CUV
rem NC HOME
set NC_HOME=D:\NC_HOME\ehp2_427_visitindex

rem ------------------设置用户环境结束--------------------------------
rem ------------------设置运行环境开始--------------------------------
rem 监听间隔(秒)
set INTERVAL=2
rem Debug开启后显示监听的详细信息(Y/N)
set DEBUG=N
rem 同步Log开启后将同步的文件记录到日志(Y/N)
set SYNCLOG=Y
rem 日志文件
set LOGFILE=log.txt
rem 资源路径
set TARG_SOURCE_PATH=hotwebs\portal\sync
set SRC_HTML_PATH=web\html

rem ------------------设置运行环境结束--------------------------------
rem 运行前对工程目录和HOME目录进行检查
call :RunCheck

rem 开始监视工程中文件的改动
:start
cls
rem 打印环境信息
call :PrintSysInfo
echo 文件监视中.
echo 最后检查时间:%time:~0,-3%
for %%i in (%COMPONENT%) do (
	call :SyncSource %%i
)
call :Delay %INTERVAL%
goto :start

:SyncSource
rem 业务组件
call :Info 开始同步业务组件[%1]
set src=%PROJECT%\%1\%SRC_HTML_PATH%
set targ=%NC_HOME%\%TARG_SOURCE_PATH%\%MODULE%\%1\html
call :ListenFolder "%src%" "%targ%" "^>同步web资源.."

call :Info ^>同步META-INF资源..
set src=%PROJECT%\%1\META-INF
set targ=%NC_HOME%\modules\%MODULE%\META-INF
call :ListenFolder "%src%" "%targ%" "同步到modules\%MODULE%\META-INF.."

goto :eof

rem 检查目录中文件版本，如果文件版本与HOME中文件版本不一致则更新
:ListenFolder
set src=%~1
set targ=%~2
set "folder=!src:%PROJECT%=Project!"
call :Info %3
call :Info 正在检查目录：%folder%
for /r %1 %%i in (*.*) do (
	set srcfile=%%i
	set "targFile=!srcfile:%src%=%targ%!"
	call :CompareAndCopyFile "!srcfile!" "!targFile!" %4
)
goto :eof

rem 检查文件版本，如果文件版本与HOME中文件版本不一致则更新
:CompareAndCopyFile
set file=%1
set file=!file:%PROJECT%=Project!
if "%~t1" neq "%~t2" (
	echo A|xcopy /s /i "%src%" "%targ%" > nul
	call :ShowWithColor a 提示：已更新文件：!file!.
	call :Log %1
) else (
	call :Info 已检查文件：!file!.
)
goto :eof

rem 延时指定的时间
:Delay
choice /t %1 /d y /n >nul
goto :eof

rem 输出详细消息
:Info
if "%DEBUG%"=="Y" echo 信息：%1%2
goto :eof

rem 输出同步日志
:Log
if "%SYNCLOG%"=="Y" echo [%date:~0,10% %time:~0,8%] 同步文件:%1 >> %LOGFILE%
goto :eof

rem 输出有颜色的行(a:绿色，c:红色)
:ShowWithColor
echo %2
rem echo. >%2&findstr /a:%1 . %2*&del %2
goto :eof

rem 运行前检查
:RunCheck
if not exist "%PROJECT%" echo 工程目录[%PROJECT%]不存在，请重新配置工程目录. & pause & exit
if not exist "%NC_HOME%" echo NC HOMTE目录[%NC_HOME%]不存在，请重新配置NC HOMTE目录. & pause & exit
type "%PROJECT%\META-INF\module.xml" | find /i "%MODULE%" > nul || ( echo 模块名[%MODULE%]与工程不匹配，请配置正确的模块名. & pause & exit )
for %%i in (%COMPONENT%) do (
	if not exist "%PROJECT%\%%i" echo 工程目录[%PROJECT%]中业务组件[%%i]不存在，请确认配置. & pause & exit
)
goto :eof

rem 显示环境信息
:PrintSysInfo
echo ************************环境信息************************
echo * 工程目录:%PROJECT%
echo * NC HOME :%NC_HOME%
echo * 模块    :%MODULE%
echo * 业务组件:%COMPONENT%
echo * 监听时间间隔:%INTERVAL%秒
if "%DEBUG%" == "Y" (
	echo * 打印详细信息:开启
) else (
	echo * 打印详细信息:关闭
)
if "%SYNCLOG%" == "Y" (
	echo * 生成同步日志:开启
) else (
	echo * 生成同步日志:关闭
)
echo * 日志文件:%LOGFILE%
echo ************************环境信息************************
goto :eof