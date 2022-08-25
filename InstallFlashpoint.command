#!/bin/bash

mirror_url="http://archive.org/download/flashpoint-11-infinity-mac/Flashpoint11InfinityMac.7z"
repo_path="FlashpointProject/flashpoint/flashpoint-infinity"

checkDiskSpace() {
	space_required_gb=$1
	free_space=$(df -Pk . | sed 1d | grep -v used | awk '{ print $4 "\t" }')
	free_space_mb=$((free_space/1024))
	if [ $free_space_mb -lt ${space_required_gb}000 ]; then
		echo "Warning: you need at least $space_required_gb gigabytes of free disk space to install Flashpoint."
		echo "Please clear out some disk space before you continue."
		echo "Press Return to continue, or press Control-C to cancel the installation."
		read
	fi
}

quitIfFailed() {
	if [ $? -gt 0 ]; then
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
	if [ $arch_name = "arm64" ]; then
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

installWine() {
	# Thanks to https://scriptingosx.com/2017/11/on-the-macos-version/
	os_ver=$(sw_vers -productVersion)
	IFS='.' read -r -a os_ver <<< "$os_ver"
	if [[ "${os_ver[0]}" -ge 11 ]] || [[ "${os_ver[1]}" -ge 15 ]]; then
		# Catalina or later
		brew install --no-quarantine gcenx/wine/wine-crossover
	elif [[ "${os_ver[1]}" -ge 13 ]]; then
		# High Sierra or Mojave
		brew tap homebrew/cask-versions
		brew install --cask --no-quarantine wine-staging
	elif [[ "${os_ver[1]}" -le 12 ]]; then
		# Sierra or below
		echo "Warning: Wine cannot be installed automatically on this MacOS version (10.${os_ver[1]})"
	fi
	quitIfFailed "Wine"
}

# Download from the Archive.org mirror if the main download failed
checkDownload() {
	cache_path="$(brew --cache -s $repo_path)"
	if ! [ -e "$cache_path" ]; then
		curl --progress-bar -o "$cache_path" "$mirror_url"
		quitIfFailed "Flashpoint"
	fi
}

clear
echo "Welcome to the Flashpoint installer!"
echo "Press Return to begin, or press Control-C to cancel the installation."
read
checkDiskSpace 7

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
if test ! $(which wine); then
	installWine
fi

if ! [ -e /Applications/Flashpoint/Flashpoint.app ]; then
	install_cmd="brew install --no-quarantine $repo_path"
	echo "Installing Flashpoint..."
	eval $install_cmd
	if [ $? -gt 0 ]; then
		checkDownload
		eval $install_cmd
		quitIfFailed "Flashpoint"
	fi
else
	if [ "$(brew outdated $repo_path)" = "flashpoint-infinity" ]; then
		upgrade_cmd="brew upgrade --no-quarantine $repo_path"
		echo "A Flashpoint update is available! Do you want to install it now?"
		echo "Don't forget to back up your custom playlists before you continue!"
		echo "Press Return to install the update, or press Control-C to cancel."
		read
		eval $upgrade_cmd
		if [ $? -gt 0 ]; then
			checkDownload
			eval $upgrade_cmd
			quitIfFailed "Flashpoint"
		fi
	else
		echo "The latest version of Flashpoint is already installed."
		exit
	fi
fi

echo "Flashpoint has been installed to your Applications folder."
echo "If you want to open Flashpoint now, press Return. Otherwise, press Control-C."
read
open /Applications/Flashpoint/Flashpoint.app
