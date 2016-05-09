@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

:: Setup
:: -----

setlocal enabledelayedexpansion

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Deployment
:: ----------

echo Handling .NET Web Application deployment.

:: We don't need the XML docs
::set NUGET_XMLDOC_MODE=skip

:: Make the NuGet packages go in a persisted folder instead of %USERPROFILE%, which on Azure goes in Temp space
::set NUGET_PACKAGES=%HOME%\.nuget

:: For now, we need a myget feed since RC2 packages are not yet released
:: call :ExecuteCmd .nuget\nuget.exe restore -source https://myget.org/f/aspnetrelease/api/v3/index.json -source https://api.nuget.org/v3/index.json -packagesavemode nuspec

call :ExecuteCmd %HOME%\dotnet\dotnet.exe restore -s https://myget.org/f/aspnetrelease/api/v3/index.json -s https://api.nuget.org/v3/index.json
call :ExecuteCmd %HOME%\dotnet\dotnet.exe publish
IF !ERRORLEVEL! NEQ 0 goto error

::call :ExecuteCmd dotnet publish --output "%DEPLOYMENT_TEMP%"
IF !ERRORLEVEL! NEQ 0 goto error

::call :ExecuteCmd "%KUDU_SYNC_CMD%" -v 50 -f "%DEPLOYMENT_TEMP%" -t "%DEPLOYMENT_TARGET%" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd"
IF !ERRORLEVEL! NEQ 0 goto error

goto end

:: Execute command routine that will echo out when error
:ExecuteCmd
setlocal
set _CMD_=%*
call %_CMD_%
if "%ERRORLEVEL%" NEQ "0" echo Failed exitCode=%ERRORLEVEL%, command=%_CMD_%
exit /b %ERRORLEVEL%

:error
endlocal
echo An error has occurred during web site deployment.
call :exitSetErrorLevel
call :exitFromFunction 2>nul

:exitSetErrorLevel
exit /b 1

:exitFromFunction
()

:end
endlocal
echo Finished successfully.