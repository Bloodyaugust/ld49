#!/bin/sh

# set -e

which butler

echo "Checking application versions..."
echo "-----------------------------"
cat ~/.local/share/godot/templates/3.3.stable/version.txt
godot --version
butler -V
echo "-----------------------------"

mkdir build/
mkdir build/linux/
mkdir build/osx/
mkdir build/win/

echo "EXPORTING FOR LINUX"
echo "-----------------------------"
godot --export "Linux/X11" build/linux/ld49.x86_64 -v
# echo "EXPORTING FOR OSX"
# echo "-----------------------------"
# godot --export "Mac OSX" build/osx/ld49.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --export "Windows Desktop" build/win/ld49.exe -v
echo "-----------------------------"

# echo "CHANGING FILETYPE AND CHMOD EXECUTABLE FOR OSX"
# echo "-----------------------------"
# cd build/osx/
# mv ld49.dmg ld49-osx-alpha.zip
# unzip ld49-osx-alpha.zip
# rm ld49-osx-alpha.zip
# chmod +x ld49.app/Contents/MacOS/ld49
# zip -r ld49-osx-alpha.zip ld49.app
# rm -rf ld49.app
# cd ../../

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "ZIPPING FOR WINDOZE"
echo "-----------------------------"
cd build/win/
zip -r ld49-win-alpha.zip ld49.exe ld49.pck
rm -r ld49.exe ld49.pck
cd ../../

echo "ZIPPING FOR LINUX"
echo "-----------------------------"
cd build/linux/
zip -r ld49-linux-alpha.zip ld49.x86_64 ld49.pck
rm -r ld49.x86_64 ld49.pck
cd ../../

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/ld49:linux-alpha
# butler push build/osx/ synsugarstudio/ld49:osx-alpha
butler push build/win/ synsugarstudio/ld49:win-alpha
