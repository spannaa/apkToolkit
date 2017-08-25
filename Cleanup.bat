del /s /q "%userprofile%\apktool\framework\*.*"
rd /s /q "%userprofile%\apktool\"
del /s /q "%userprofile%\AppData\Local\apktool\framework\*.*"
rd /s /q "%userprofile%\AppData\Local\apktool\"
if exist "%~dp0log.txt" (del /s /q "%~dp0log.txt")
exit