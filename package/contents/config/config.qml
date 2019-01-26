import QtQuick 2.0

import org.kde.plasma.configuration 2.0

ConfigModel {
	ConfigCategory {
		name: i18n("General")
		icon: "configure"
		source: "config/ConfigGeneral.qml"
	}
	ConfigCategory {
		name: i18n("Import/Export Layout")
		icon: "grid-rectangular"
		source: "config/ConfigExportLayout.qml"
	}
	ConfigCategory {
		name: i18n("Advanced")
		icon: "applications-development"
		source: "lib/ConfigAdvanced.qml"
		visible: false
	}
	ConfigCategory {
		name: i18nd("plasma_shell_org.kde.plasma.desktop", "Keyboard shortcuts")
		icon: "preferences-desktop-keyboard"
		source: "config/ConfigurationShortcuts.qml"
	}
}
