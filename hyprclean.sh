#!/usr/bin/env bash

if ! type pacman &> /dev/null; then
	echo -e "\x1B[1;31mFailed to find pacman. Aborting...\x1B[0m"
	exit 1
fi

declare -a deps=(
	fastfetch
	git
	hypridle
	hyprland
	hyprlock
	hyprpaper
	stow
	tmux
	wmenu
)

cd "$( dirname "$0" )"

hyprclean-help() {
	cat <<-EOF
		Usage:
		  $0 <OPTION>

		Options:
		  -i, --install     Install Hyprclean
		  -u, --uninstall   Uninstall Hyprclean
	EOF
}

hyprclean-install() {
	echo -e "\x1B[1;32mInstalling packages...\x1B[0m"
	sudo pacman -Sv --needed "${deps[@]}"
	echo -e "\x1B[1;32mDone.\x1B[0m"

	echo ""

	echo -e "\x1B[1;32mBacking up old configs...\x1B[0m"
	for file in etc/*; do
		if [[ -e "$XDG_CONFIG_HOME/${file##*/}" ]]; then
			echo "$XDG_CONFIG_HOME/${file##*/}" "->" ".backup/etc/${file##*/}"
		fi
	done
	for file in usr/share/*; do
		if [[ -e "$XDG_DATA_HOME/${file##*/}" ]]; then
			echo "$XDG_DATA_HOME/${file##*/}" "->" ".backup/usr/share/${file##*/}"
		fi
	done
	echo -e "\x1B[1;32mDone. Old configs moved to $( dirname "$0" )/.backup\x1B[0m"

	echo ""

	echo -e "\x1B[1;32mLinking hyprclean configs...\x1B[0m"
	stow --verbose -d etc -t "${XDG_CONFIG_HOME}" .
	stow --verbose -d usr -t "${XDG_DATA_HOME%/*}" .
	echo -e "\x1B[1;32mDone.\x1B[0m"
}

hyprclean-uninstall() {
	echo -e "\x1B[1;32mUnlinking hyprclean configs...\x1B[0m"
	stow --delete --verbose -d etc -t "${XDG_CONFIG_HOME}" .
	stow --delete --verbose -d usr -t "${XDG_DATA_HOME%/*}" .
	echo -e "\x1B[1;32mDone.\x1B[0m"

	echo ""

	echo -e "\x1B[1;32mRestoring backed up configs...\x1B[0m"
	for file in etc/*; do
		if [[ -e ".backup/etc/${file##*/}" ]]; then
			echo ".backup/etc/${file##*/}" "->" "$XDG_CONFIG_HOME/${file##*/}"
		fi
	done
	for file in usr/share/*; do
		if [[ -e ".backup/usr/share/${file##*/}" ]]; then
			echo ".backup/usr/share/${file##*/}" "->" "$XDG_DATA_HOME/${file##*/}"
		fi
	done
	echo -e "\x1B[1;32mDone.\x1B[0m"

	echo ""

	echo -e "\x1B[1;32mUninstalling packages...\x1B[0m"
	sudo pacman -Rnsv "${deps[@]}"
	echo -e "\x1B[1;32mDone.\x1B[0m"
}

case $1 in
	-i | --install) hyprclean-install ;;
	-u | --uninstall) hyprclean-uninstall ;;
	*) hyprclean-help ;;
esac
