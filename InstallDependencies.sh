#!/bin/bash
export SUDO_ASKPASS=1

quitIfFailed() {
	if [ $? -gt 0 ]; then
		echo "Failed to install $1. See the Flashpoint Wiki for guidance."
		exit 1
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

installBrew() {
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	quitIfFailed "Homebrew"
	if test ! $(which brew); then
		addBrewToPATH
	fi
}

installPHP() {
	brew install --no-quarantine php
	quitIfFailed "PHP"
}

installWine() {
	echo "Installing Wine..."
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
		echo "Wine cannot be installed automatically on this MacOS version (10.${os_ver[1]})"
		echo "See the Flashpoint Wiki for guidance."
	fi
	quitIfFailed "Wine"
}

echo "Installing Flashpoint dependencies..."
if test ! $(which brew); then
	installBrew
else
	brew update
	quitIfFailed "an update for Homebrew"
fi
if test ! $(which php); then
	installPHP
fi
if test ! $(which wine); then
	installWine
fi
echo "Finished installing dependencies!"