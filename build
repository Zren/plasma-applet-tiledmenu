#!/bin/bash
# Version 22

packageDir="package"
i18nDir="package/translate"
qtMinVer="6.6"
kfMinVer="6.0"
plasmaMinVer="6.0"
filenameTag="plasma${plasmaMinVer}"
filenameTag=`echo "$filenameTag" | sed 's/\./\-/'`

function printHelp() {
	echo "sh ./build                For building a .zip for KDE Store"
	echo "sh ./build --i18n-only    To package for distros like Arch we only need to convert"
	echo "                          translation files .po => .mo with gettext's msgfmt."
}

# Builds .zip or .plasmoid for uploading to https://store.kde.org
function buildZip() {
	python3 ./kpac --dir "$packageDir" --i18ndir "$i18nDir" \
		build --tag "$filenameTag"
}

# For distributing with distro packaging (like AUR) we only need to convert
# the translation *.po files to *.mo files with gettext's msgfmt command.
# Eg: "package/translate/fr.po" => "package/contents/locale/fr/LC_MESSAGES/plasma_applet_com.github.zren.widgetname.mo"
function buildI18nOnly() {
	python3 ./kpac --dir "$packageDir" --i18ndir "$i18nDir" \
		i18n --no-merge
}

showHelp=false
i18nOnly=false
for arg in "$@"; do
	case "$arg" in
		--i18n-only) i18nOnly=true;;
		-h|--help) showHelp=true;;
		*) ;;
	esac
done

if $showHelp; then
	# sh ./build --help
	printHelp
elif $i18nOnly; then
	# sh ./build --i18n-only
	buildI18nOnly
else
	# sh ./build
	buildZip
fi
