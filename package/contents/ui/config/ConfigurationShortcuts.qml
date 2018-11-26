import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.kquickcontrols 2.0

import ".."
import "../lib"

// Based on:
// https://github.com/KDE/plasma-desktop/blob/master/desktoppackage/contents/configuration/ConfigurationShortcuts.qml
ConfigPage {
	id: page

	signal configurationChanged()
	function saveConfig() {
		plasmoid.globalShortcut = keySequenceItem.keySequence
	}

	Label {
		Layout.fillWidth: true
		text: i18nd("plasma_shell_org.kde.plasma.desktop", "This shortcut will activate the applet: it will give the keyboard focus to it, and if the applet has a popup (such as the start menu), the popup will be open.")
		wrapMode: Text.WordWrap
	}

	// https://github.com/KDE/kdeclarative/blob/master/src/qmlcontrols/kquickcontrols/KeySequenceItem.qml
	// https://github.com/KDE/kdeclarative/blob/master/src/qmlcontrols/kquickcontrols/private/keysequencehelper.h
	KeySequenceItem {
		id: keySequenceItem
		keySequence: plasmoid.globalShortcut
		onKeySequenceChanged: {
			page.configurationChanged()
		}

		// Unfortunately, keySequence does not exposed the isEmpty function to QML.
		// There's no way to detect if the shortcut is not set.
		// readonly property bool isEmpty: keySequence.isEmpty()

		// Luckily, the PlasmaQuick::ConfigView exposes the global shortcut as a String.
		// Unfortunately, appletGlobalShortcut only updates when the config tab is loaded.
		// It does not even change when we hit apply. It's limited use makes it useless
		// for notifying the user when the Meta shortcut is active.
		// https://github.com/KDE/plasma-framework/blob/master/src/plasmaquick/configview.cpp#L174
		// https://github.com/KDE/plasma-framework/blob/master/src/plasmaquick/configview.h
		// readonly property bool isEmpty: configDialog.appletGlobalShortcut == ""
	}

	Connections {
		target: configDialog
		onAppletGlobalShortcutChanged: console.log('appletGlobalShortcut', configDialog.appletGlobalShortcut)
	}

	Item {
		Layout.preferredHeight: units.largeSpacing
	}

	Label {
		Layout.fillWidth: true
		text: i18n("When this widget has a global shortcut set, like 'Alt+F1', Plasma will open this menu with just the ⊞ Windows / Meta key.")
		wrapMode: Text.WordWrap
	}
	// CheckBox {
	// 	text: i18n("Open %1 with the ⊞ Windows / Meta key", plasmoid.title)
	// 	checked: !keySequenceItem.isEmpty
	// 	enabled: false
	// }
}
