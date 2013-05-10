@echo off

:: ----------------------
:: KUDU Deployment Script
:: ----------------------

:: Prerequisites
:: -------------

:: Verify node.js installed
where node 2>nul >nul
IF %ERRORLEVEL% NEQ 0 (
  echo Missing node.js executable, please install node.js, if already installed make sure it can be reached from current environment.
  goto error
)

:: Setup
:: -----

setlocal enabledelayedexpansion

SET ARTIFACTS=%~dp0%artifacts

IF NOT DEFINED DEPLOYMENT_SOURCE (
  SET DEPLOYMENT_SOURCE=%~dp0%.
)

IF NOT DEFINED DEPLOYMENT_TARGET (
  SET DEPLOYMENT_TARGET=%ARTIFACTS%\wwwroot
)

IF NOT DEFINED NEXT_MANIFEST_PATH (
  SET NEXT_MANIFEST_PATH=%ARTIFACTS%\manifest

  IF NOT DEFINED PREVIOUS_MANIFEST_PATH (
    SET PREVIOUS_MANIFEST_PATH=%ARTIFACTS%\manifest
  )
)

IF NOT DEFINED KUDU_SYNC_COMMAND (
  :: Install kudu sync
  echo Installing Kudu Sync
  call npm install kudusync -g --silent
  IF !ERRORLEVEL! NEQ 0 goto error

  :: Locally just running "kuduSync" would also work
  SET KUDU_SYNC_COMMAND=node "%appdata%\npm\node_modules\kuduSync\bin\kuduSync"
)

IF NOT DEFINED GALLIO_COMMAND (
  IF NOT EXIST "%appdata%\Gallio\bin\Gallio.Echo.exe" (
    :: Downloading unzip
    echo Downloading unzip
    curl -O http://stahlforce.com/dev/unzip.exe
    IF !ERRORLEVEL! NEQ 0 goto error

    :: Downloading Gallio
    echo Downloading Gallio
    curl -O http://mb-unit.googlecode.com/files/GallioBundle-3.4.14.0.zip
    IF !ERRORLEVEL! NEQ 0 goto error

    :: Extracting Gallio
    echo Extracting Gallio
    unzip -q -n GallioBundle-3.4.14.0.zip -d %appdata%\Gallio
    IF !ERRORLEVEL! NEQ 0 goto error
  )

  :: Set Gallio runner path
  SET GALLIO_COMMAND=%appdata%\Gallio\bin\Gallio.Echo.exe
)

IF NOT DEFINED GALLIO_ARGS (
  SET GALLIO_ARGS=/no-logo
)

IF NOT DEFINED NUNIT_COMMAND (
  SET NUNIT_COMMAND=%DEPLOYMENT_SOURCE%\packages\NUnit.Runners.2.6.2\tools\nunit-console.exe
)

IF NOT DEFINED NUNIT_ARGS (
  SET NUNIT_ARGS=/nologo
)

IF NOT DEFINED DEPLOYMENT_TEST_PROJECT (
  SET DEPLOYMENT_TEST_PROJECT=convene.Tests
)

IF NOT DEFINED DEPLOYMENT_TEST_DIR (
  SET DEPLOYMENT_TEST_DIR=%DEPLOYMENT_SOURCE%\%DEPLOYMENT_TEST_PROJECT%\
)

IF NOT DEFINED DEPLOYMENT_TEST_PROJECT_PATH (
  SET DEPLOYMENT_TEST_PROJECT_PATH=%DEPLOYMENT_TEST_DIR%%DEPLOYMENT_TEST_PROJECT%.csproj
)

IF NOT DEFINED DEPLOYMENT_TEMP (
  SET DEPLOYMENT_TEMP=%temp%\___deployTemp%random%
  SET CLEAN_LOCAL_DEPLOYMENT_TEMP=true
)

IF DEFINED CLEAN_LOCAL_DEPLOYMENT_TEMP (
  IF EXIST "%DEPLOYMENT_TEMP%" rd /s /q "%DEPLOYMENT_TEMP%"
  mkdir "%DEPLOYMENT_TEMP%"
)

IF NOT DEFINED MSBUILD_PATH (
  SET MSBUILD_PATH=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\msbuild.exe
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Deployment
:: ----------

echo Handling .NET Web Application deployment.

:: 1. Build to the temporary path
%MSBUILD_PATH% "%DEPLOYMENT_SOURCE%\convene\convene.csproj" /nologo /verbosity:m /t:Build /t:pipelinePreDeployCopyAllFilesToOneFolder /p:_PackageTempDir="%DEPLOYMENT_TEMP%";AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release %build_args% /p:SolutionDir="%DEPLOYMENT_SOURCE%\.\\"  %build_args%
IF !ERRORLEVEL! NEQ 0 goto error

:: 2. Build tests
echo Attempting to build the test project %DEPLOYMENT_TEST_PROJECT_PATH%
%MSBUILD_PATH% "%DEPLOYMENT_TEST_PROJECT_PATH%" /nologo /verbosity:m /t:Build /p:Configuration=Release %build_args% /p:SolutionDir="%DEPLOYMENT_SOURCE%\.\\" %build_args%
IF !ERRORLEVEL! NEQ 0 goto error

:: 3. Run nunit tests
echo Running unit tests against "%DEPLOYMENT_TEST_DIR%\bin\Release\%DEPLOYMENT_TEST_PROJECT%.dll"
call %GALLIO_COMMAND% %GALLIO_ARGS% "%DEPLOYMENT_TEST_DIR%\bin\Release\%DEPLOYMENT_TEST_PROJECT%.dll"
IF !ERRORLEVEL! NEQ 0 goto error

:: 2. KuduSync
echo Kudu Sync from "%DEPLOYMENT_TEMP%" to "%DEPLOYMENT_TARGET%"
call %KUDU_SYNC_COMMAND% -v 50 -f "%DEPLOYMENT_TEMP%" -t "%DEPLOYMENT_TARGET%" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd" 2>nul
IF !ERRORLEVEL! NEQ 0 goto error

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

goto end

:error
echo An error has occurred during web site deployment.
exit /b 1

:end
echo Finished successfully.
