#!/usr/bin/env bash

if ! type pacman &> /dev/null; then
	echo -e "\x1B[1;31mFailed to find pacman. Aborting...\x1B[0m"
	exit 1
fi

cd "$( dirname "$0" )"



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

hyprclean-help() {
	cat <<-EOF
		Usage:
		  $0 <OPTION>

		Options:
		  -i, --install     Install Hyprclean, requires sudo
		  -u, --uninstall   Uninstall Hyprclean, requires sudo
	EOF
}

hyprclean-install() {
	echo -en "\x1B[1;33mInstall dependencies (uses sudo)? [y/N]\x1B[0m "
	read reply
	if [[ "$reply" =~ ^[Yy](es)?$ ]]; then
		sudo pacman -Sv --needed "${deps[@]}"
	fi

	echo ""

	echo -en "\x1B[1;33mLink Hyprclean global configs (uses sudo)? [y/N]\x1B[0m "
	read reply
	if [[ "$reply" =~ ^[Yy](es)?$ ]]; then
		sudo stow --verbose -d @ -t / .
	fi

	echo ""

	echo -en "\x1B[1;33mLink Hyprclean user configs? [y/N]\x1B[0m "
	read reply
	if [[ "$reply" =~ ^[Yy](es)?$ ]]; then
		stow --verbose -d etc -t "${XDG_CONFIG_HOME}" .
		stow --verbose -d usr -t "${XDG_DATA_HOME%/*}" .
	fi
}

hyprclean-uninstall() {
	echo -en "\x1B[1;33mUninstall dependencies (uses sudo)? [y/N]\x1B[0m "
	read reply
	if [[ "$reply" =~ ^[Yy](es)?$ ]]; then
		sudo pacman -Rnsv --needed "${deps[@]}"
		echo -e "\x1B[1;32mDone.\x1B[0m"
	fi

	echo ""

	echo -en "\x1B[1;33mUnlink Hyprclean global configs (uses sudo)? [y/N]\x1B[0m "
	read reply
	if [[ "$reply" =~ ^[Yy](es)?$ ]]; then
		sudo stow --delete --verbose -d @ -t / .
	fi

	echo ""

	echo -en "\x1B[1;33mUnlink Hyprclean user configs? [y/N]\x1B[0m "
	read reply
	if [[ "$reply" =~ ^[Yy](es)?$ ]]; then
		stow --delete --verbose -d etc -t "${XDG_CONFIG_HOME}" .
		stow --delete --verbose -d usr -t "${XDG_DATA_HOME%/*}" .
	fi
}

case $1 in
	-i | --install) hyprclean-install ;;
	-u | --uninstall) hyprclean-uninstall ;;
	*) hyprclean-help ;;
esac
