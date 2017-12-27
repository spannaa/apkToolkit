@echo off
setlocal enabledelayedexpansion
COLOR 1E
if (%1)==(0) goto SkipMe
echo ------------------------------------------------------------------------------------ >> log.txt
echo ^|%date% -- %time%^| >> log.txt
echo ------------------------------------------------------------------------------------ >> log.txt
apkToolkit 0 2>> log.txt

:SkipMe
mode con:cols=100 lines=72
set compression=9
set currentApp=None
set apktool=apktool_2.3.1.jar
set heapy=512
set projectFolder=None
java -version 
if errorlevel 1 goto JavaError
REM Check if there is only one project folder - if there is, set it as 'projectFolder'
set /A projectcount=0
for /D %%D in (*) do if /I not "%%~nxD"=="tools" (
set /A projectcount+=1
set project=%%~nD%%~xD
)
if %projectcount%==1 set projectFolder=%project%
REM Check if there is only one apk/jar in the projectFolder\files_in folder - if there is, set it as 'currentApp'
set /A filecount=0
for %%F in (%projectFolder%/files_in/*.apk, %projectFolder%/files_in/*.jar) do (
set /A filecount+=1
set file=%%~nF%%~xF
)
if %filecount%==1 set currentApp=%file%

:ReStart
cd "%~dp0"
set menunr=GARBAGE
cls
echo.
echo   APK TOOLKIT
echo.   
echo   Spannaa @ XDA
echo.
echo  --------------------------------------------------------------------------------------------------
echo   Compression Level: %compression%   ^|  Java Heap Size: %heapy%mb
echo  --------------------------------------------------------------------------------------------------
echo   Current apktool version:  %apktool%
echo  --------------------------------------------------------------------------------------------------
echo   Current Project: %projectFolder%  ^|  Current App: %currentApp% 
echo  --------------------------------------------------------------------------------------------------
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
echo    8.  Batch compile all apks ^& jars in a project folder
echo.
echo    9.  Sign an apk with test keys
echo.
echo   10.  Sign an apk with release keys
echo.
echo   11.  Zipalign an apk (after apk is compiled ^& signed)
echo.
echo   12.  Select version of apktool to work with
echo.
echo   13.  Select compression level for apks ^& jars
echo.
echo   14.  Set Max Memory Size (Only use if getting stuck at decompiling/compiling)
echo.
echo   15.  Setup, notes ^& credits
echo.
echo   16.  Quit
echo.
echo  --------------------------------------------------------------------------------------------------
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
if %menunr%==12 goto ApktoolSelect
if %menunr%==13 goto SetCompression
if %menunr%==14 goto MaxMemorySize
if %menunr%==15 goto Help
if %menunr%==16 goto Quit
REM If an out of range number is entered, redirect to OutOfRangeError
if %menunr%==0 goto OutOfRangeError
if %menunr% GTR 16 goto OutOfRangeError

:ProjectFolderSelect
set projectFolder=None
set currentApp=None
echo.
REM Check if there are any existing project folders and redirect to CreateProjectFolder if not
set /A projectcount=0
for /D %%D in (*) do if /I not "%%~nxD"=="tools" (
set /A projectcount+=1
)
if %projectcount%==0 (
echo   There are no existing project folders...
goto CreateProjectFolder
)
echo   Select a project folder to work in...
echo.
set /A projectcount=0
for /D %%D in (*) do if /I not "%%~nxD"=="tools" (
set /A projectcount+=1
set a!projectcount!=%%D
if /I !projectcount! LEQ 9 echo    !projectcount!.  %%D
if /I !projectcount! GTR 9 echo   !projectcount!.  %%D
)
echo.
set /P INPUT=- Enter its number: %=%
if /I %INPUT% GTR !projectcount! goto ProjectSelectError
if /I %INPUT% LSS 1 goto ProjectSelectError
set projectFolder=!a%INPUT%!
REM Count the number of apps in projectFolder and, if there is only one, set it as currentApp
set /A filecount=0
for %%F in (!a%INPUT%!/files_in/*.apk, !a%INPUT%!/files_in/*.jar) do (
set /A filecount+=1
set a!filecount!=%%F
set file=%%~nF%%~xF
)
if %filecount%==1 set currentApp=%file%
goto ReStart

:CreateProjectFolder
echo.
echo   Create a new project folder to work in...
echo.
set /P INPUT=- Enter the folders name : %=%
set projectFolder= %INPUT: =_%
REM Create projectFolder and sub folders
if not exist "%INPUT%" mkdir "%INPUT: =_%", "%INPUT: =_%\frameworks", "%INPUT: =_%\files_in", "%INPUT: =_%\files_out", "%INPUT: =_%\working"
echo.
echo   Project folder: %projectFolder% has been created
echo.
echo - Press any key to continue...
pause > nul
goto SkipMe

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
echo   Decompiling %currentApp%...
java -Xmx%heapy%m -jar %apktool% d "..\%projectFolder%\files_in\%currentApp%" -b -o "..\%projectFolder%\working\%currentApp%" > nul
if errorlevel 1 goto Level1Error
)
echo.
echo   The decompiled %currentApp% 
echo   can be found in your %projectFolder%\working folder
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
REM Delete any installed frameworks and install new one(s)
rmdir /S /Q %userprofile%\AppData\Local\apktool > nul
rmdir /S /Q %userprofile%\apktool > nul
REM set /A count=0
for %%F in (../%projectFolder%/frameworks/*.apk) do (
echo   Installing framework: %%F...
java -jar %apktool% if ..\%projectFolder%\frameworks\%%F > nul
if errorlevel 1 goto Level1Error
)
echo.
if exist "%~dp0%projectFolder%\working\%currentApp%" rmdir /S /Q "%~dp0%projectFolder%\working\%currentApp%"
echo   Decompiling %currentApp%...
java -Xmx%heapy%m -jar %apktool% d "..\%projectFolder%\files_in\%currentApp%" -b -o "..\%projectFolder%\working\%currentApp%" > nul
if errorlevel 1 goto Level1Error
)
echo.
echo   The decompiled %currentApp% 
echo   can be found in your %projectFolder%\working folder
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
REM Delete any installed frameworks and install new one(s)
rmdir /S /Q %userprofile%\AppData\Local\apktool > nul
rmdir /S /Q %userprofile%\apktool > nul
REM set /A count=0
for %%F in (../%projectFolder%/frameworks/*.apk) do (
echo   Installing framework: %%F...
java -jar %apktool% if ..\%projectFolder%\frameworks\%%F > nul
if errorlevel 1 goto Level1Error
)
echo.
REM use counter to check if there are any apps to decompile and redirect to error if not
set /A count=0
for %%F in (../%projectFolder%/files_in/*.apk ../%projectFolder%/files_in/*.jar) do (
set /A count+=1
if exist "%~dp0%projectFolder%\working\%%F" rmdir /S /Q "%~dp0%projectFolder%\working\%%F"
echo   Decompiling %%F...
java -Xmx%heapy%m -jar %apktool% d "..\%projectFolder%\files_in\%%F" -b -o "..\%projectFolder%\working\%%F" > nul
if errorlevel 1 (echo   There was an error decompiling %%D - please check your log.txt
echo.
echo - Press any key to continue...
pause > nul
)
)
if %count%==0 goto NoAppsError
echo.
echo   All decompiled apks ^& jars 
echo   can be found in your %projectFolder%\working folder
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
echo   Compiling %currentApp%...
if exist "%~dp0%projectFolder%\files_out\unsigned_%currentApp%" del /Q "%~dp0%projectFolder%\files_out\unsigned_%currentApp%"
java -Xmx%heapy%m -jar %apktool% b "..\%projectFolder%\working\%currentApp%" -o "%~dp0%projectFolder%\files_out\unsigned_%currentApp%" > nul
if errorlevel 1 goto Level1Error
echo.
echo   Is this a system apk ^(y/n^)
echo.
set /P INPUT=- Type input: %=%
if %INPUT%==n (goto NoSignatures)

REM Signatures function
:Signatures
echo.
echo   Apart from the signatures, would you like to copy over any additional files that you
echo   didn't modify from the original apk in order to ensure least number of errors ^(y/n^)
echo.
set /P INPUT=- Type input: %=%
if %INPUT%==y (goto SignaturesPlus)
echo.
REM Copy the original META-INF folder to the compiled apk/jar...
echo   Copying original META-INF folder to %currentApp%...
7za x -o"..\%projectFolder%\working\temp" "..\%projectFolder%\files_in\%currentApp%" META-INF -r  > nul
REM If it exists, copy the original SEC-INF folder to the compiled apk
if exist "%~dp0%projectFolder%\working\%currentApp%\SEC-INF" (
echo   Copying original SEC-INF folder to %currentApp%...
7za x -o"..\%projectFolder%\working\temp" "..\%projectFolder%\files_in\%currentApp%" SEC-INF -r  > nul
)
REM If AndroidManifest.xml exists in the working folder, it's an apk not a jar
if exist "%~dp0%projectFolder%\working\%currentApp%\AndroidManifest.xml" (
REM Copy the original AndroidManifest.xml to the compiled apk
echo   Copying original AndroidManifest.xml to %currentApp%...
7za x -o"..\%projectFolder%\working\temp" "..\%projectFolder%\files_in\%currentApp%" AndroidManifest.xml -r > nul
)
7za a -tzip "..\%projectFolder%\files_out\unsigned_%currentApp%" "..\%projectFolder%\working\temp\*" -mx%compression% -r  > nul
REM Delete projectFolder\working\temp
rmdir /S /Q "%~dp0%projectFolder%\working\temp"
REM Delete existing file before renaming unsigned_file
if exist "%~dp0%projectFolder%\files_out\%currentApp%" del /Q "%~dp0%projectFolder%\files_out\%currentApp%"
ren "%~dp0%projectFolder%\files_out\unsigned_%currentApp%" "%currentApp%"
echo.
echo   The compiled %currentApp% with its original META-INF folder ^& AndroidManifest.xml
echo   can be found in your %projectFolder%\files_out folder
goto Pause

REM NoSignatures function
:NoSignatures
echo.
echo   The compiled, unsigned_%currentApp% 
echo   can be found in your %projectFolder%\files_out folder
goto Pause

REM SignaturesPlus function
:SignaturesPlus
echo.
rmdir /S /Q "%~dp0%projectFolder%\keep"
echo   Extracting original %currentApp%...
echo.
7za x -o"..\%projectFolder%\keep" "..\%projectFolder%\files_in\%currentApp%"  > nul
echo   In the %projectFolder% folder you'll find a keep folder. Delete everything inside it
echo   that you have modified and leave files that you haven't. If you have modified any 
echo   xml files in the res/values folder, then delete resources.arsc from the keep folder too. 
echo   Once done then press enter on this window.
echo.
echo - Press any key to continue...
pause > nul
echo.
echo   Copying unmodified files from keep folder to unsigned_%currentApp%
7za a -tzip "..\%projectFolder%\files_out\unsigned_%currentApp%" "..\%projectFolder%\keep\*" -mx%compression% -r  > nul
rmdir /S /Q "%~dp0%projectFolder%\keep"
echo.
echo   The compiled, unsigned_%currentApp% 
echo   can be found in your %projectFolder%\files_out folder
goto Pause

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
echo   Compiling %%D...
if exist "%~dp0%projectFolder%\files_out\unsigned_%%D" del /Q "%~dp0%projectFolder%\files_out\unsigned_%%D"
java -Xmx%heapy%m -jar %apktool% b "..\%projectFolder%\working\%%D" -o "%~dp0%projectFolder%\files_out\unsigned_%%D" > nul
REM If errorlevel 1 occurs, show an error message and pause
if errorlevel 1 (echo   There was an error compiling %%D - please check your log.txt
echo.
echo - Press any key to continue...
pause > nul
) else (
REM Copy the original META-INF folders to the compiled apks & jars...
echo   Copying original META-INF folder to %%D...
7za x -o"..\%projectFolder%\working\temp" "..\%projectFolder%\files_in\%%D" META-INF -r > nul
REM If it exists, copy the original SEC-INF folder to the compiled apks
if exist "%~dp0%projectFolder%\working\%%D\SEC-INF" (
echo   Copying original SEC-INF folder to %%D...
7za x -o"..\%projectFolder%\working\temp" "..\%projectFolder%\files_in\%%D" SEC-INF -r  > nul
)
REM If AndroidManifest.xml exists in the working folder, it's an apk not a jar
if exist "%~dp0%projectFolder%\working\%%D\AndroidManifest.xml" (
REM Copy the original AndroidManifest.xmls to the compiled apks
echo   Copying original AndroidManifest.xml to %%D...
7za x -o"..\%projectFolder%\working\temp" "..\%projectFolder%\files_in\%%D" AndroidManifest.xml -r > nul
)
7za a -tzip "..\%projectFolder%\files_out\unsigned_%%D" "..\%projectFolder%\working\temp\*" -mx%compression% -r > nul
REM Delete projectFolder\working\temp
rmdir /S /Q "%~dp0%projectFolder%\working\temp"
REM Delete existing file before renaming unsigned_file
if exist "%~dp0%projectFolder%\files_out\%%D" del /Q "%~dp0%projectFolder%\files_out\%%D"
ren "%~dp0%projectFolder%\files_out\unsigned_%%D" "%%D"
)
)
if %count%==0 goto NoneDecompiledError
echo.
echo   All compiled apks ^& jars with their original META-INF folders ^& AndroidManifest.xml
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
echo   The test_signed_%currentApp% 
echo   can be found in your %projectFolder%\files_out folder
goto Pause

:SignApkRelease
cd tools
REM Check that there is an unsigned currentApp avaialable to sign and redirect to error if not
if not exist "%~dp0%projectFolder%\files_out\unsigned_%currentApp%" goto SigningError
REM Delete any existing unsigned currentApp before proceeding
if exist "%~dp0%projectFolder%\files_out\release_signed_%currentApp%" del /Q "%~dp0%projectFolder%\files_out\release_signed_%currentApp%"
echo.
echo   Signing %currentApp% with release keys
REM rename cert.x509.pem and private.pk8 to reflect the filenames of your own public & private release keys in the tools folder
java -Xmx%heapy%m -jar signapk.jar -w cert.x509.pem private.pk8 ..\%projectFolder%\files_out\unsigned_%currentApp% ..\%projectFolder%\files_out\release_signed_%currentApp%
if errorlevel 1 goto Level1Error
)
del /Q "%~dp0%projectFolder%\files_out\files_out\unsigned_%currentApp%"
echo.
echo   The release_signed_%currentApp% 
echo   can be found in your %projectFolder%\files_out folder
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
echo   The aligned %currentApp% 
echo   can be found in your %projectFolder%\files_out folder
goto Pause

:ApktoolSelect
cls
echo.
echo   Select an apktool to work with...
echo.
set /A count=0
for %%F in (tools/apktool_*.jar) do (
set /A count+=1
set a!count!=%%F
if /I !count! LEQ 9 echo    !count!.  %%F 
if /I !count! GTR 9 echo   !count!.  %%F 
)
echo.
set /P INPUT=- Enter its number: %=%
if /I %INPUT% GTR !count! goto ApktoolSelectError
if /I %INPUT% LSS 1 goto ApktoolSelectError
set apktool=!a%INPUT%!
goto ReStart

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
echo  APK TOOLKIT
echo  --------------------------------------------------------------------------------------------------
echo.
echo  SETUP
echo.
echo  1. Java MUST be installed for this tool to work.
echo.
echo  2. Create a project folder to work in - this could be named after the rom you're working
echo     with or you could just use a generic folder name if you're only working with user apps.
echo.
echo  3. Copy ALL of the framework apks from the rom you're working with into the 'frameworks'
echo     folder of the project folder.
echo.
echo  4. Copy the apks ^& jars you want to decompile from the rom you're working with into the 
echo     'files_in' folder of the project folder.
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
echo  When you compile a single apk or jar, you are asked if it is a system app or not.
echo   - If you select 'y', you can choose to either just copy its original META-INF folder 
echo     (^& AndroidManifest.xml if its an apk) to the compiled apk or to choose which files
echo     to copy over from a 'keep' folder.
echo   - If you select 'n', nothing is copied to the compiled apk and it remains unsigned.
echo.
echo  When batch compiling all apks ^& jars in a project folder, their original META-INF folders  
echo  (^& AndroidManifest.xmls for apks) are copied to the compiled apks.
echo.
echo  To sign apks with your own release keys, replace the dummy cert.x509.pem and private.pk8 
echo  keys in the 'tools' folder  with your own public & private release keys and then edit 
echo  line 468 in apkToolkit.bat accordingly to reflect the filenames of your keys.
echo.
echo  New releases of apktool can be found at: https://ibotpeaches.github.io/Apktool/
echo  To update apkToolkit, download the new apktool_x.x.x.jar, add it to the 'tools' folder 
echo  and select it via option #12 in the apkToolkit menu.
echo.
echo  To build and add the latest snapshot version of apktool to apkToolkit (Git MUST be installed) 
echo  run build_apktool_snapshot.bat, wait for the build to complete and then select the newly built
echo  snapshot via option #12 in the apkToolkit menu.
echo.
echo  The default compression level is '9'.
echo  The default maximum memory (heap) size is '512'mb 
echo  These should not need to be changed unless there is aproblem with decompiling/compiling.
echo.
echo  Running cleanup.bat after quitting will delete all installed frameworks and log.txt
echo.
echo  CREDITS
echo.
echo  apkToolkit is based on Apk Manager: Daneshm90 @ XDA
echo  apktool: iBotPeaches @ XDA ^& Brut.all @ XDA
echo  7za standalone command line version of 7-Zip: Igor Pavlov
echo.
echo  --------------------------------------------------------------------------------------------------
goto Pause

REM Error messages
:OutOfRangeError
echo.
echo   You selected a number that wasn't one of the options^^!
goto Pause

:NotDecompiledError
echo.
echo   %currentApp% has not been decompiled. 
echo   Please do so before doing attempting to compile it
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

:ApktoolSelectError
set apktool=apktool_2.2.4.jar
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
echo   An error occurred - please check your log.txt
goto Pause

:Pause
echo.
echo - Press any key to continue...
pause > nul
goto Restart

:Quit
