@REM ----------------------------------------------------------------------------
@REM Maven Wrapper for Windows (HFCMS Backend)
@REM ----------------------------------------------------------------------------
@echo off
setlocal

set "DIR=%~dp0"
set "MAVEN_PROJECTBASEDIR=%DIR%"
set "WRAPPER_DIR=%DIR%.mvn\wrapper"
set "WRAPPER_PROPERTIES=%WRAPPER_DIR%\maven-wrapper.properties"

if not exist "%WRAPPER_PROPERTIES%" (
    echo Error: Missing %WRAPPER_PROPERTIES%
    exit /b 1
)

for /f "tokens=1,* delims==" %%A in ('type "%WRAPPER_PROPERTIES%"') do (
    if "%%A"=="distributionUrl" set "DIST_URL=%%B"
)

set "MAVEN_HOME=%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.9"
set "MAVEN_BIN=%MAVEN_HOME%\bin\mvn.cmd"

if not exist "%MAVEN_BIN%" (
    echo Downloading Maven distribution from %DIST_URL% ...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; New-Item -ItemType Directory -Force -Path '%USERPROFILE%\.m2\wrapper\dists' | Out-Null; $zip = '%TEMP%\maven.zip'; Invoke-WebRequest -Uri '%DIST_URL%' -OutFile $zip; Expand-Archive -Path $zip -DestinationPath '%USERPROFILE%\.m2\wrapper\dists' -Force; Remove-Item $zip -Force; Rename-Item '%USERPROFILE%\.m2\wrapper\dists\apache-maven-*' '%MAVEN_HOME%' -ErrorAction SilentlyContinue"
)

if exist "%MAVEN_BIN%" (
    "%MAVEN_BIN%" %*
) else (
    echo Failed to find or download Maven. Please ensure internet access or install Maven.
    exit /b 1
)
