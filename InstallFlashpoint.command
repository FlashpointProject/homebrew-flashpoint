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
echo "Press Enter to begin, or press Control-C to cancel the installation."
read

if test ! $(which brew); then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    quitIfFailed "Homebrew"
else
	brew update
fi

# Homebrew doesn't seem to honor --no-quarantine for cask dependencies,
# so install them manually first
if ! [ -e /Applications/Chromium.app ]; then
	brew install --no-quarantine eloston-chromium
	quitIfFailed "Chromium"
fi
if ! [ -e "/Applications/Waterfox Classic.app" ]; then
	brew install --no-quarantine waterfox-classic
	quitIfFailed "Waterfox Classic"
fi
if ! [ -e "/Applications/Wine Crossover.app" ]; then
	brew install --no-quarantine gcenx/wine/wine-crossover
	quitIfFailed "Wine"
fi

if ! [ -e /Applications/Flashpoint/Flashpoint.app ]; then
	echo "Installing Flashpoint..."
	brew install --no-quarantine FlashpointProject/flashpoint/flashpoint-infinity
else
	if [ "$(brew outdated FlashpointProject/flashpoint/flashpoint-infinity)" == "flashpoint-infinity" ]; then
		echo "A Flashpoint update is available! Do you want to install it now?"
		echo "Don't forget to back up your custom playlists before you continue!"
		echo "Press Enter to install the update, or press Control-C to cancel."
		read
		brew upgrade --no-quarantine FlashpointProject/flashpoint/flashpoint-infinity
	else
		echo "The latest version of Flashpoint is already installed."
		exit
	fi
fi
quitIfFailed "Flashpoint"

echo "Flashpoint has been installed to your Applications folder."
echo "If you want to open Flashpoint now, press Enter. Otherwise, press Control-C."
read
open /Applications/Flashpoint/Flashpoint.app
