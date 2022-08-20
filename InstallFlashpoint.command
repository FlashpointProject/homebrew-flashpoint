#!/bin/bash

quitIfFailed() {
	status=$?
	if [ $status -gt 0 ]; then
		echo "Failed to install $1. The Flashpoint installer will now exit."
		echo "To try again, simply re-run the installer."
		exit
	fi
}

# Copied from the Homebrew source code: 
# https://github.com/Homebrew/install/blob/master/install.sh
getShell() {
	case "${SHELL}" in
		*/bash*)
			if [[ -r "${HOME}/.bash_profile" ]]; then
				shell_profile="${HOME}/.bash_profile"
			else
				shell_profile="${HOME}/.profile"
			fi
			;;
		*/zsh*)
			shell_profile="${HOME}/.zprofile"
			;;
		*)
			shell_profile="${HOME}/.profile"
			;;
	esac
}

# For some reason the Homebrew installer prompts the user to add it to the PATH 
# instead of doing it automatically. So we have to do that ourselves.
addBrewToPATH() {
	arch_name="$(uname -m)"
	if [ $arch_name == "arm64" ]; then
		homebrew_path="/opt/homebrew/bin"
	else
		homebrew_path="/usr/local/bin"
	fi
	# Set the required environment variables in this shell
	eval "$($homebrew_path/brew shellenv)"
	# Find the shell profile file for this shell
	getShell
	# Add those env variables to the shell profile so they'll be set automatically from now on
	echo eval "\$($homebrew_path/brew shellenv)" >> ${shell_profile}
}

clear
echo "Welcome to the Flashpoint installer!"
echo "Press Enter to begin, or press Control-C to cancel the installation."
read

# Check disk space
space_required_gb=7
free_space=$(df -Pk . | sed 1d | grep -v used | awk '{ print $4 "\t" }')
free_space_mb=$((free_space/1024))
if [ $free_space_mb -lt ${space_required_gb}000 ]; then
	echo "Warning: you need at least $space_required_gb gigabytes of free disk space to install Flashpoint."
	echo "Please clear out some disk space before you continue."
	echo "Press Enter to continue, or press Control-C to cancel the installation."
	read
fi

if test ! $(which brew); then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	quitIfFailed "Homebrew"
	if test ! $(which brew); then
		addBrewToPATH
	fi
else
	brew update
	quitIfFailed "an update for Homebrew"
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
	quitIfFailed "Flashpoint"
else
	if [ "$(brew outdated FlashpointProject/flashpoint/flashpoint-infinity)" == "flashpoint-infinity" ]; then
		echo "A Flashpoint update is available! Do you want to install it now?"
		echo "Don't forget to back up your custom playlists before you continue!"
		echo "Press Enter to install the update, or press Control-C to cancel."
		read
		brew upgrade --no-quarantine FlashpointProject/flashpoint/flashpoint-infinity
		quitIfFailed "Flashpoint"
	else
		echo "The latest version of Flashpoint is already installed."
		exit
	fi
fi

echo "Flashpoint has been installed to your Applications folder."
echo "If you want to open Flashpoint now, press Enter. Otherwise, press Control-C."
read
open /Applications/Flashpoint/Flashpoint.app
