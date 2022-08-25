#!/bin/bash
dl_url="https://bluemaxima.org/flashpoint/Flashpoint%2011%20Infinity%20Mac.7z"
dl_filename="Flashpoint 11.0.1 Infinity.7z"
install_url="https://raw.githubusercontent.com/FlashpointProject/homebrew-flashpoint/main/InstallDependencies.sh"

checkDiskSpace() {
	space_required_gb=$1
	free_space=$(df -Pk . | sed 1d | grep -v used | awk '{ print $4 "\t" }')
	free_space_mb=$((free_space/1024))
	if [ $free_space_mb -lt ${space_required_gb}000 ]; then
		echo "Warning: you need at least $space_required_gb gigabytes of free disk space to use Flashpoint."
		echo "Please clear out some disk space before you continue."
		echo "Press Return to continue, or press Control-C to cancel the download."
		read
	fi
}

checkDiskSpace
if test ! $(which php); then
	/bin/bash -c "$(curl -fsSL $install_url)"
fi

cd "$HOME"
mkdir -p Flashpoint && cd Flashpoint
echo "Downloading Flashpoint..."
curl -o "$dl_filename" -k --progress-bar $dl_url
if [ $? -gt 0 ]; then
	echo "Failed to download Flashpoint. See the Flashpoint Wiki for guidance."
else
	echo "Finished downloading Flashpoint!"
	echo "Double-click the downloaded file to expand it."
	echo "If that doesn't work, try installing The Unarchiver: https://theunarchiver.com/"
	open ./
fi
