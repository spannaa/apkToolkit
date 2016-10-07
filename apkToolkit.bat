@echo off
setlocal enabledelayedexpansion
COLOR 1E
if (%1)==(0) goto SkipMe
echo ------------------------------------------------------------------------------ >> log.txt
echo ^|%date% -- %time%^| >> log.txt
echo ------------------------------------------------------------------------------ >> log.txt
apkToolkit 0 2>> log.txt

:SkipMe
mode con:cols=94 lines=64
set compression=9
set currentApp=None
set heapy=512
set projectFolder=None
java -version 
if errorlevel 1 goto JavaError
REM Check if there is only one project folder - if there is, set it as 'projectFolder'
set /A projectcount=0
for /D %%D in (*) do if /I not "%%~nxD"=="tools" (
set /A projectcount+=1
set tmpstore1=%%~nD%%~xD
)
if %projectcount%==1 set projectFolder=%tmpstore1%
REM Check if there is only one apk/jar in the projectFolder\files_in folder - if there is, set it as 'currentApp'
set /A filecount=0
for %%F in (%projectFolder%/files_in/*.apk, %projectFolder%/files_in/*.jar) do (
set /A filecount+=1
set tmpstore2=%%~nF%%~xF
)
if %filecount%==1 set currentApp=%tmpstore2%

:ReStart
cd "%~dp0"
set menunr=GARBAGE
cls
echo.
echo   APK TOOLKIT
echo.   
echo   Spannaa @ XDA (Based on Apk Manager by Daneshm90 @ XDA)
echo.
echo  --------------------------------------------------------------------------------------------
echo   Compression Level: %compression%   ^|  Java Heap Size: %heapy%mb
echo.
echo.
echo   Current Project: %projectFolder%  ^|  Current App: %currentApp% 
echo  --------------------------------------------------------------------------------------------
echo.
REM Check if there are any existing project folders and redirect to CreateProjectFolder if not
set /A count=0
for /D %%D in (*) do if /I not "%%~nxD"=="tools" (
set /A count+=1
)
if %count%==0 (
echo   There are no existing project folders...
goto CreateProjectFolder
)
REM Main menu
echo   MENU
echo.
echo    1.  Select a project folder to work in
echo.
echo    2.  Create a new project folder to work in
echo.
echo    3.  Select an apk or jar to work on
echo.
echo    4.  Decompile a user apk
echo.
echo    5.  Decompile a system apk or jar
echo.
echo    6.  Batch decompile all apks ^& jars in a project folder
echo.
echo    7.  Compile an apk or jar
echo.
echo    8.  Batch compile all apks ^& jars in a project folder (keep original signatures)
echo.
echo    9.  Sign an apk with test keys
echo.
echo   10.  Sign an apk with release keys
echo.
echo   11.  Zipalign an apk (do after apk is compiled ^& signed)
echo.
echo   12.  Select compression level for apks ^& jars
echo.
echo   13.  Set Max Memory Size (Only use if getting stuck at decompiling/compiling)
echo.
echo   14.  Help
echo.
echo   15.  Quit
echo.
echo  --------------------------------------------------------------------------------------------
echo.
set /P menunr=- Please select your option: 
if %menunr%==1 goto ProjectFolderSelect
if %menunr%==2 goto CreateProjectFolder
if %menunr%==3 goto FileSelect
if %menunr%==4 goto DecompileUserApk
if %menunr%==5 goto DecompileSystemApk
if %menunr%==6 goto DecompileAll
if %menunr%==7 goto CompileApkOrJar
if %menunr%==8 goto CompileAll
if %menunr%==9 goto SignApkTest
if %menunr%==10 goto SignApkRelease
if %menunr%==11 goto ZipAlignApk
if %menunr%==12 goto SetCompression
if %menunr%==13 goto MaxMemorySize
if %menunr%==14 goto Help
if %menunr%==15 goto Quit
REM If an out of range number is entered, redirect to OutOfRangeError
if %menunr%==0 goto OutOfRangeError
if %menunr% GTR 15 goto OutOfRangeError

:ProjectFolderSelect
echo.
REM Check if there are any existing project folders and redirect to CreateProjectFolder if not
set /A count=0
for /D %%D in (*) do if /I not "%%~nxD"=="tools" (
set /A count+=1
)
if %count%==0 (
echo   There are no existing project folders...
goto CreateProjectFolder
)
echo   Select a project folder to work in...
echo.
set /A count=0
for /D %%D in (*) do if /I not "%%~nxD"=="tools" (
set /A count+=1
set a!count!=%%D
if /I !count! LEQ 9 echo    !count!.  %%D
if /I !count! GTR 9 echo   !count!.  %%D
)
echo.
set /P INPUT=- Enter its number: %=%
if /I %INPUT% GTR !count! goto ProjectSelectError
if /I %INPUT% LSS 1 goto ProjectSelectError
set projectFolder=!a%INPUT%!
goto ReStart

:CreateProjectFolder
echo.
echo   Create a new project folder to work in...
echo.
set /P INPUT=- Enter the folders name : %=%
set projectFolder= %INPUT: =_%
REM Create projectFolder and sub folders
if not exist "%INPUT%" mkdir "%INPUT: =_%", "%INPUT: =_%\frameworks", "%INPUT: =_%\files_in", "%INPUT: =_%\files_out", "%INPUT: =_%\working"
goto ReStart

:FileSelect
echo.
REM Check if a project folder has been selected and Restart if not
if %projectFolder% ==None (
echo   You need to select a project folder to work in first^^!
goto Pause
)
cls
echo.
echo   Select an apk or jar to work on...
echo.
REM use counter to check if there are any apps and redirect to error if not
set /A count=0
for %%F in (%projectFolder%/files_in/*.apk, %projectFolder%/files_in/*.jar) do (
set /A count+=1
set a!count!=%%F
if /I !count! LEQ 9 echo    !count!.  %%F 
if /I !count! GTR 9 echo   !count!.  %%F 
)
if %count%==0 goto NoAppsError
echo.
set /P INPUT=- Enter its number: %=%
if /I %INPUT% GTR !count! goto FileSelectError
if /I %INPUT% LSS 1 goto FileSelectError
set currentApp=!a%INPUT%!
goto ReStart

:DecompileUserApk
cd tools
REM Check if a project folder has been selected and Restart if not
if %projectFolder%==None (
echo.
echo   You need to select a project folder to work in first^^!
goto Pause
)
REM Check if a apk or jar has been selected and Restart if not
if %currentApp%==None (
echo.
echo   You need to select an apk or jar to work on first^^!
goto Pause
)
if exist "%~dp0%projectFolder%\working\%currentApp%" rmdir /S /Q "%~dp0%projectFolder%\working\%currentApp%"
echo.
echo   Decompiling %currentApp% ...
java -Xmx%heapy%m -jar apktool.jar d "..\%projectFolder%\files_in\%currentApp%" -b -o "..\%projectFolder%\working\%currentApp%" > nul
if errorlevel 1 goto Level1Error
)
echo.
echo   The decompiled %currentApp% can be found in your %projectFolder%\working folder
goto Pause

:DecompileSystemApk
cd tools
REM Check if a project folder has been selected and Restart if not
if %projectFolder%==None (
echo.
echo   You need to select a project folder to work in first^^!
goto Pause
)
REM Check if a apk or jar has been selected and Restart if not
if %currentApp%==None (
echo.
echo   You need to select an apk or jar to work on first^^!
goto Pause
)
echo.
rmdir /S /Q %userprofile%\apktool > nul
REM set /A count=0
for %%F in (../%projectFolder%/frameworks/*.apk) do (
echo   Installing framework: %%F ...
java -jar apktool.jar if ..\%projectFolder%\frameworks\%%F > nul
if errorlevel 1 goto Level1Error
)
echo.
if exist "%~dp0%projectFolder%\working\%currentApp%" rmdir /S /Q "%~dp0%projectFolder%\working\%currentApp%"
echo   Decompiling %currentApp% ...
java -Xmx%heapy%m -jar apktool.jar d "..\%projectFolder%\files_in\%currentApp%" -b -o "..\%projectFolder%\working\%currentApp%" > nul
if errorlevel 1 goto Level1Error
)
echo.
echo   The decompiled %currentApp% can be found in your %projectFolder%\working folder
goto Pause

:DecompileAll
cd tools
REM Check if a project folder has been selected and Restart if not
if %projectFolder% ==None (
echo.
echo   You need to select a project folder to work in first^^!
goto Pause
)
echo.
rmdir /S /Q %userprofile%\apktool > nul
REM set /A count=0
for %%F in (../%projectFolder%/frameworks/*.apk) do (
echo   Installing framework: %%F ...
java -jar apktool.jar if ..\%projectFolder%\frameworks\%%F > nul
if errorlevel 1 goto Level1Error
)
echo.
REM use counter to check if there are any apps to decompile and redirect to error if not
set /A count=0
for %%F in (../%projectFolder%/files_in/*.apk ../%projectFolder%/files_in/*.jar) do (
set /A count+=1
if exist "%~dp0%projectFolder%\working\%%F" rmdir /S /Q "%~dp0%projectFolder%\working\%%F"
echo   Decompiling %%F ...
java -Xmx%heapy%m -jar apktool.jar d "..\%projectFolder%\files_in\%%F" -b -o "..\%projectFolder%\working\%%F" > nul
if errorlevel 1 goto Level1Error
)
if %count%==0 goto NoAppsError
echo.
echo   All decompiled apks ^& jars can be found in your %projectFolder%\working folder
goto Pause

:CompileApkOrJar
cd tools
REM Check if a project folder has been selected and Restart if not
if %projectFolder%==None (
echo.
echo   You need to select a project folder to work in first^^!
goto Pause
)
REM Check if a apk or jar has been selected and Restart if not
if %currentApp%==None (
echo.
echo   You need to select an apk or jar to work on first^^!
goto Pause
)
echo.
if not exist "%~dp0%projectFolder%\working\%currentApp%" goto NotDecompiledError
REM If currentApp's build folder exists, delete it before compiling
if exist "%~dp0%projectFolder%\working\%currentApp%\build" rmdir /S /Q "%~dp0%projectFolder%\working\%currentApp%\build"
echo   Compiling %currentApp% ...
if exist "%~dp0%projectFolder%\files_out\unsigned_%currentApp%" del /Q "%~dp0%projectFolder%\files_out\unsigned_%currentApp%"
java -Xmx%heapy%m -jar apktool.jar b "..\%projectFolder%\working\%currentApp%" -o "%~dp0%projectFolder%\files_out\unsigned_%currentApp%" > nul
if errorlevel 1 goto Level1Error
echo.
echo   Is this a system apk ^(y/n^)
echo.
set /P INPUT=- Type input: %=%
if %INPUT%==y (call :Signatures
) else (call :NoSignatures)
goto Pause

REM Signatures function
:Signatures
echo.
echo  --------------------------------------------------------------------------------------------
7za x -o"..\%projectFolder%\working\temp" "..\%projectFolder%\files_in\%currentApp%" META-INF -r
7za a -tzip "..\%projectFolder%\files_out\unsigned_%currentApp%" "..\%projectFolder%\working\temp\*" -mx%usrc% -r
echo.
echo  --------------------------------------------------------------------------------------------
rmdir /S /Q "%~dp0%projectFolder%\working\temp"
REM Delete existing file before renaming unsigned_file
if exist "%~dp0%projectFolder%\files_out\%currentApp%" del /Q "%~dp0%projectFolder%\files_out\%currentApp%"
ren "%~dp0%projectFolder%\files_out\unsigned_%currentApp%" "%currentApp%"
echo.
echo   The compiled %currentApp% with the original signatures 
echo   can be found in your %projectFolder%\files_out folder
goto:eof

REM NoSignatures function
:NoSignatures
echo.
echo   The compiled, unsigned_%currentApp% can be 
echo   found in your %projectFolder%\files_out folder
goto:eof

:CompileAll
cd tools
REM Check if a project folder has been selected and Restart if not
if %projectFolder%==None (
echo.
echo   You need to select a project folder to work in first^^!
goto Pause
)
cls
echo.
REM use counter to check if there are any decompiled apps to compile and redirect to error if not
set /A count=0
REM If decompiled apk's build folder exists, delete it before compiling
for /D %%D in (../%projectFolder%/working/*.apk ../%projectFolder%/working/*.jar) do (
set /A count+=1
if exist "%~dp0%projectFolder%\working\%%D\build" rmdir /S /Q "%~dp0%projectFolder%\working\%%D\build"
REM Compile the apks & jars...
echo.
echo   Compiling %%D ...
if exist "%~dp0%projectFolder%\files_out\unsigned_%%D" del /Q "%~dp0%projectFolder%\files_out\unsigned_%%D"
java -Xmx%heapy%m -jar apktool.jar b "..\%projectFolder%\working\%%D" -o "%~dp0%projectFolder%\files_out\unsigned_%%D" > nul
REM If errorlevel 1 occurs, show an error message and pause
if errorlevel 1 (echo   There was an error compiling %%D - please Check Your log.txt
echo.
echo - Press any key to continue...
pause > nul
) else (
REM Copy the original signatures to the compiled apks & jars...
echo   Copying original signatures to %%D ...
echo.
echo  --------------------------------------------------------------------------------------------
7za x -o"..\%projectFolder%\working\temp" "..\%projectFolder%\files_in\%%D" META-INF -r
7za a -tzip "..\%projectFolder%\files_out\unsigned_%%D" "..\%projectFolder%\working\temp\*" -mx%usrc% -r
echo.
echo  --------------------------------------------------------------------------------------------
rmdir /S /Q "%~dp0%projectFolder%\working\temp"
REM Delete existing file before renaming unsigned_file
if exist "%~dp0%projectFolder%\files_out\%%D" del /Q "%~dp0%projectFolder%\files_out\%%D"
ren "%~dp0%projectFolder%\files_out\unsigned_%%D" "%%D"
)
)
if %count%==0 goto NoneDecompiledError
echo.
echo   All compiled apks ^& jars with their original signatures 
echo   can be found in your %projectFolder%\files_out folder
goto Pause

:SignApkTest
cd tools
REM Check that there is an unsigned currentApp avaialable to sign and redirect to error if not
if not exist "%~dp0%projectFolder%\files_out\unsigned_%currentApp%" goto SigningError
REM Delete any existing unsigned currentApp before proceeding
if exist "%~dp0%projectFolder%\files_out\test_signed_%currentApp%" del /Q "%~dp0%projectFolder%\files_out\test_signed_%currentApp%"
echo.
echo   Signing %currentApp% with test keys
java -Xmx%heapy%m -jar signapk.jar -w testkey.x509.pem testkey.pk8 ..\%projectFolder%\files_out\unsigned_%currentApp% ..\%projectFolder%\files_out\test_signed_%currentApp%
if errorlevel 1 goto Level1Error
)
del /Q "%~dp0%projectFolder%\files_out\files_out\unsigned_%currentApp%"
echo.
echo   The test_signed_%currentApp% can be found in your %projectFolder%\files_out folder
goto Pause

:SignApkRelease
cd tools
REM Check that there is an unsigned currentApp avaialable to sign and redirect to error if not
if not exist "%~dp0%projectFolder%\files_out\unsigned_%currentApp%" goto SigningError
REM Delete any existing unsigned currentApp before proceeding
if exist "%~dp0%projectFolder%\files_out\release_signed_%currentApp%" del /Q "%~dp0%projectFolder%\files_out\release_signed_%currentApp%"
echo.
echo   Signing %currentApp% with release keys
REM rename cert.x509.pem and private.pk8 to reflect the filenames of your own release keys in the tools folder
java -Xmx%heapy%m -jar signapk.jar -w cert.x509.pem private.pk8 ..\%projectFolder%\files_out\unsigned_%currentApp% ..\%projectFolder%\files_out\release_signed_%currentApp%
if errorlevel 1 goto Level1Error
)
del /Q "%~dp0%projectFolder%\files_out\files_out\unsigned_%currentApp%"
echo.
echo   The release_signed_%currentApp% can be found in your %projectFolder%\files_out folder
goto Pause

:ZipAlignApk
cd tools
echo.
echo   Zipaligning %currentApp%
if exist "%~dp0%projectFolder%\files_out\test_signed_%currentApp%" zipalign -f 4 "%~dp0%projectFolder%\files_out\test_signed_%currentApp%" "%~dp0%projectFolder%\files_out\test_signed_aligned_%currentApp%"
if exist "%~dp0%projectFolder%\files_out\release_signed_%currentApp%" zipalign -f 4 "%~dp0%projectFolder%\files_out\release_signed_%currentApp%" "%~dp0%projectFolder%\files_out\release_signed_aligned_%currentApp%"
if exist "%~dp0%projectFolder%\files_out\unsigned_%currentApp%" zipalign -f 4 "%~dp0%projectFolder%\files_out\unsigned_%currentApp%" "%~dp0%projectFolder%\files_out\unsigned_aligned_%currentApp%"
if exist "%~dp0%projectFolder%\files_out\%currentApp%" zipalign -f 4 "%~dp0%projectFolder%\files_out\%currentApp%" "%~dp0%projectFolder%\files_out\aligned_%currentApp%"
if errorlevel 1 goto Level1Error
)
del /Q "%~dp0%projectFolder%\files_out\test_signed_%currentApp%"
del /Q "%~dp0%projectFolder%\files_out\release_signed_%currentApp%"
del /Q "%~dp0%projectFolder%\files_out\unsigned_%currentApp%"
del /Q "%~dp0%projectFolder%\files_out\%currentApp%"
echo.
echo   The aligned %currentApp% can be found in your %projectFolder%\files_out folder
goto Pause

:ClearFrameworks
echo   Clearing Frameworks...
rmdir /S /Q %userprofile%\apktool > nul
goto Pause

:SetCompression
set /P INPUT=- Enter Compression Level (0-9) : %=%
set compression=%INPUT%
cls
goto ReStart

:MaxMemorySize
set /P INPUT=- Enter max size for java heap space in megabytes (eg 512) : %=%
set heapy=%INPUT%
cls
goto ReStart

:Help
cls
echo.
echo  APK TOOLKIT HELP
echo  --------------------------------------------------------------------------------------------
echo.
echo  SETUP
echo.
echo  1. Java MUST be installed for this tool to work. Java 7 (JRE 1.7) is recommended.
echo.
echo  2. Create a project folder to work in - this could be named after the rom you're working
echo     with or you could just use a generic folder name if you're only working with user apps.
echo.
echo  3. Copy ALL of the framework apks from the rom you're working with into the 'frameworks'
echo     folder of the project folder for the rom.
echo.
echo  4. Copy all of the apks ^& jars from the rom you're working with into the 'files_in' folder 
echo     of the project folder for the rom.
echo.
echo  5. Use the menu to select tasks and execute them.
echo.
echo  NOTES
echo.
echo  When decompiling or batch decompiling apks ^& jars, any previously installed frameworks 
echo  are deleted and the frameworks for the project you're working in are installed automatically.
echo  This enables different roms to be worked on without their frameworks getting mixed up.
echo.
echo  Any number of self-contained project folders can be created and worked with and each 
echo  project folder can contain any number of apks ^& jars.
echo.
echo  To sign apks with your own release keys, replace the dummy cert.x509.pem and 
echo  private.pk8 keys in the 'tools' folder  with your own and then edit line 384 in 
echo  Apk_Jar_Manager.bat accordingly to reflect the filenames of your keys.
echo.
echo  The toolkit currently uses apktool_2.2.0.jar. To switch to a different version, just rename 
echo  one of the apktool_2.0.X.jar files in the 'tools' folder to 'apktool.jar'
echo.
echo  The default compression level is '9', The default maximum memory (heap) size is '512'mb 
echo  These should not need to be changed unless there is aproblem with decompiling/compiling.
echo.
echo  --------------------------------------------------------------------------------------------
goto Pause

REM Error messages
:OutOfRangeError
echo.
echo   You selected a number that wasn't one of the options^^!
goto Pause

:NotDecompiledError
echo.
echo   %currentApp% has not been decompiled, please do so before doing attempting this
goto Pause

:NoneDecompiledError
echo.
echo   There are no decompiled apps in the %projectFolder%\working folder^^!
goto Pause

:NoAppsError
echo.
echo   There are no apks or jars in the %projectFolder%\files_in folder^^!
goto Pause

:ProjectSelectError
set projectFolder=None
echo.
echo   You selected a number that wasn't one of the options^^!
goto Pause

:FileSelectError
set currentApp=None
echo.
echo   You selected a number that wasn't one of the options^^!
goto Pause

:JavaError
echo.
echo   Java was not found, you will not be able to sign apks or use apktool
goto Pause

:SigningError
echo.
echo   There is no unsigned_%currentApp% available to sign
goto Pause

:Level1Error
echo.
echo   An error Occured - please Check Your log.txt
goto Pause

:Pause
echo.
echo - Press any key to continue...
pause > nul
goto Restart

:Quit
