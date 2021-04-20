import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.0
import org.kde.kquickcontrols 2.0 as KQuickControls
import org.kde.kirigami 2.0 as Kirigami

// Based on:
// https://invent.kde.org/plasma/plasma-desktop/blob/master/desktoppackage/contents/configuration/ConfigurationShortcuts.qml
Kirigami.ScrollablePage {
	id: page

	title: i18nd("plasma_shell_org.kde.plasma.desktop", "Shortcuts")

	signal configurationChanged()
	function saveConfig() {
		plasmoid.globalShortcut = keySequenceItem.keySequence
	}

	ColumnLayout {
		QQC2.Label {
			Layout.fillWidth: true
			text: i18nd("plasma_shell_org.kde.plasma.desktop", "This shortcut will activate the applet as though it had been clicked.")
			wrapMode: Text.WordWrap
		}

		// https://github.com/KDE/kdeclarative/blob/master/src/qmlcontrols/kquickcontrols/KeySequenceItem.qml
		// https://github.com/KDE/kdeclarative/blob/master/src/qmlcontrols/kquickcontrols/private/keysequencehelper.h
		KQuickControls.KeySequenceItem {
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

		Item {
			implicitHeight: Kirigami.Units.largeSpacing
		}

		QQC2.Label {
			Layout.fillWidth: true
			text: i18n("When this widget has a global shortcut set, like 'Alt+F1', Plasma will open this menu with just the ⊞ Windows / Meta key.")
			wrapMode: Text.WordWrap
		}
	}
}
