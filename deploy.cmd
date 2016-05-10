echo Handling .NET Web Application deployment.
 
:: We don't need the XML docs
set NUGET_XMLDOC_MODE=skip
 
:: Make the NuGet packages go in a persisted folder instead of %USERPROFILE%, which on Azure goes in Temp space
set NUGET_PACKAGES=%HOME%\nuget
 
call :ExecuteCmd %HOME%\dotnet\dotnet.exe restore -s https://myget.org/f/aspnetrelease/api/v3/index.json -s https://api.nuget.org/v3/index.json -s https://dotnet.myget.org/F/cli-deps/api/v3/index.json

IF !ERRORLEVEL! NEQ 0 goto error

echo publishing
 
call :ExecuteCmd %HOME%\dotnet\dotnet.exe publish
:: --output "%DEPLOYMENT_TEMP%"

::call :ExecuteCmd "%KUDU_SYNC_CMD%" -v 50 -f "%DEPLOYMENT_TEMP%" -t "%DEPLOYMENT_TARGET%" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd"
 
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

