#!/bin/bash

quitIfFailed() {
	status=$?
	if [ $? -gt 0 ]; then
		echo "Failed to install $1. The Flashpoint installer will now exit."
		echo "To try again, simply re-run the installer."
		exit
	fi
}

clear
echo "Welcome to the Flashpoint installer!"
echo "Press Enter to begin, or press Ctrl-C to cancel the installation."
read

if test ! $(which brew); then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    quitIfFailed "Homebrew"
fi

if ! [ -e /Applications/Flashpoint/Flashpoint.app ]; then
	echo "Installing Flashpoint..."
	brew install --no-quarantine FlashpointProject/flashpoint/flashpoint-infinity
else
	echo "Flashpoint is installed. Do you want to update Flashpoint now?"
	echo "Don't forget to back up your custom playlists first!"
	echo "For more info, copy and paste this link into your browser:"
	echo "https://bluemaxima.org/flashpoint/datahub/Mac_Support#Updating_Flashpoint"
	echo "Type y or n:"
	read choice
	if [ $choice == "y" ]; then
		brew upgrade --no-quarantine flashpoint-infinity
	else
		echo "Exiting the Flashpoint installer."
		exit
	fi
fi
quitIfFailed "Flashpoint"

clear
echo "Flashpoint has been installed to your Applications folder."
echo "If you want to open Flashpoint now, press Enter. Otherwise, press Ctrl-C."
read
open /Applications/Flashpoint/Flashpoint.app
