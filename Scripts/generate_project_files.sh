#!/bin/bash

# Deduce OS we are running on
is_windows=false
if [ "$1" != "gmake2" ]; then
    is_windows=true
fi

# Delete any files which are not needed for a CI artifact to be created
echo "1. Deleting uncessery files from the binary directory..."
./Scripts/clean.sh $2

# Extract third-party libraries (that the project will link to)
echo
echo "= 2. Extracting third-party dependencies... ==========================================="
if [ "$is_windows" = false ]; then
	./Scripts/7za e ThirdParty/libraries/libraries.7z -oThirdParty/libraries/ -aoa
else
	./Scripts/7z.exe e ThirdParty/libraries/libraries.7z -oThirdParty/libraries/ -aoa
fi
echo "======================================================================================="

# Copy engine data to the binary directory
echo
echo "3. Copying required data to the binary directory..."
mkdir -p "Binaries/$2"
cp -r Data "Binaries/$2"

# Copy engine DLLs to the binary directory
echo
echo "4. Copying required DLLs to the binary directory..."
cp ThirdParty/libraries/dxcompiler.dll "Binaries/$2"
cp ThirdParty/libraries/fmod64.dll "Binaries/$2"
cp ThirdParty/libraries/fmodL64.dll	"Binaries/$2"

# Generate project files
echo
if [ "$is_windows" = false ]; then
	echo "5. Generating MakeFiles..."
else
	echo "5. Generating Visual Studio solution..."
fi
echo
./Scripts/premake5 --file=Scripts/premake.lua $@