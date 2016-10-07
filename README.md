# apkToolkit

A toolkit for working with apks &amp; jars within multiple projects.

Any number of self-contained project folders can be created and worked with and each 
project folder can contain any number of apks & jars.

When decompiling or batch decompiling apks & jars, any previously installed frameworks 
are deleted and the frameworks for the project you're working in are installed automatically.
This enables different roms to be worked on without their frameworks getting mixed up.

WHAT IT CAN DO

  - Decompile
  - Batch decompile
  - Compile 
  - Batch compile keeping the original signatures
  - Sign with test keys
  - Sign with release keys
  - Zipalign (after compiling & signing)

SETUP

1. Java MUST be installed for this tool to work. Java 7 (JRE 1.7) is recommended.

2. Create a project folder to work in - this could be named after the rom you're working
   with or you could just use a generic folder name if you're only working with user apps.

3. Copy ALL of the framework apks from the rom you're working with into the 'frameworks'
   folder of the project folder.

4. Copy all of the apks & jars from the rom you're working with into the 'files_in' folder 
   of the project folder.

5. Use the menu to select tasks and execute them.
