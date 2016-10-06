# apkToolkit
Toolkit for working with apks &amp; jars within multiple projects


APK TOOLKIT HELP


SETUP

1. Java MUST be installed for this tool to work. Java 7 (JRE 1.7) is recommended.

2. Create a project folder to work in - this could be named after the rom you're working
   with or you could just use a generic folder name if you're only working with user apps.

3. Copy ALL of the framework apks from the rom you're working with into the 'frameworks'
   folder of the project folder for the rom.

4. Copy all of the apks & jars from the rom you're working with into the 'files_in' folder 
   of the project folder for the rom.

5. Use the menu to select APK & JAR Tasks and execute them.


NOTES

When decompiling or batch decompiling apks & jars, any previously installed frameworks 
are deleted and the frameworks for the project you're working in are installed automatically.
This enables different roms to be worked on without their frameworks getting mixed up.

Any number of self-contained project folders can be created and worked with and each 
project folder can contain any number of apks & jars.

To sign apks with your own release keys, replace the dummy cert.x509.pem and 
private.pk8 keys in the 'tools' folder  with your own and then edit line 392 in 
Apk_Jar_Manager.bat accordingly to reflect the filenames of your keys.

The toolkit currently uses apktool_2.2.0.jar. To switch to a different apktool_2.0.X.jar
version, just copy it into the 'tools' folder and rename it 'apktool.jar'

The default compression level is '9', The default maximum memory (heap) size is '512mb 
These should not need to be changed unless there is aproblem with decompiling/compiling.
