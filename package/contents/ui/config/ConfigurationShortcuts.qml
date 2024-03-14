import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kquickcontrols as KQuickControls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.kcmutils as KCM

// Based on:
// https://invent.kde.org/plasma/plasma-desktop/blob/master/desktoppackage/contents/configuration/ConfigurationShortcuts.qml
KCM.SimpleKCM {
	id: page

	title: i18nd("plasma_shell_org.kde.plasma.desktop", "Shortcuts")

	signal configurationChanged()
	function saveConfig() {
		Plasmoid.globalShortcut = keySequenceItem.keySequence
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
			keySequence: Plasmoid.globalShortcut
			modifierOnlyAllowed: true
			onCaptureFinished: {
				if (keySequence !== Plasmoid.globalShortcut) {
					page.configurationChanged()
				}
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
