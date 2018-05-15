import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kcoreaddons 1.0 as KCoreAddons

import ".."
import "../lib"

ConfigPage {
	id: page
	showAppletVersion: true

	AppletConfig {
		id: config
	}

	XdgPathsLoader { id: xdgPathsLoader }

	ConfigSection {
		label: i18n("Popup")

		ConfigCheckBox {
			text: i18n("Fullscreen")
			configKey: 'fullscreen'
		}
	}

	ConfigSection {
		label: i18n("Panel Icon")

		ConfigIcon {
			configKey: 'icon'
			previewIconSize: units.iconSizes.large

			ConfigCheckBox {
				text: i18n("Fixed Size")
				configKey: 'fixedPanelIcon'
			}
		}
	}

	ExclusiveGroup { id: tilesThemeGroup }
	ConfigSection {
		label: i18n("Tiles")

		RowLayout {
			visible: false
			ConfigSpinBox {
				configKey: 'tileScale'
				before: i18n("Tile Size")
				suffix: i18n("x")
				minimumValue: 0.1
				maximumValue: 4
				decimals: 1
			}
			Label {
				text: i18n("%1 px", config.cellBoxSize)
			}
		}
		ConfigSpinBox {
			configKey: 'tileMargin'
			before: i18n("Tile Margin")
			suffix: i18n("px")
			minimumValue: 0
			maximumValue: config.cellBoxUnits/2
		}
		RadioButton {
			text: i18n("Desktop Theme (%1)", theme.themeName)
			exclusiveGroup: tilesThemeGroup
			checked: false
			enabled: false
		}
		RowLayout {
			RadioButton {
				id: defaultTileColorRadioButton
				text: i18n("Custom Color")
				exclusiveGroup: tilesThemeGroup
				checked: true
			}
			ConfigColor {
				id: defaultTileColorColor
				label: ""
				configKey: 'defaultTileColor'
			}
		}
		RadioButton {
			text: i18n("Transparent")
			exclusiveGroup: tilesThemeGroup
			onClicked: {
				defaultTileColorColor.setValue("#00000000")
				defaultTileColorRadioButton.checked = true
			}
		}
		ConfigComboBox {
			configKey: "tileLabelAlignment"
			label: i18n("Text Alignment")
			model: [
				{ value: "left", text: i18n("Left") },
				{ value: "center", text: i18n("Center") },
				{ value: "right", text: i18n("Right") },
			]
		}

		// ConfigStringList {
		// 	configKey: 'favoriteApps'
		// 	enabled: false
		// }
	}

	ExclusiveGroup { id: sidebarThemeGroup }
	ConfigSection {
		label: i18n("Sidebar")

		RadioButton {
			text: i18n("Desktop Theme (%1)", theme.themeName)
			exclusiveGroup: sidebarThemeGroup
			checked: plasmoid.configuration.sidebarFollowsTheme
			onClicked: plasmoid.configuration.sidebarFollowsTheme = true
		}
		RowLayout {
			RadioButton {
				text: i18n("Custom Color")
				exclusiveGroup: sidebarThemeGroup
				checked: !plasmoid.configuration.sidebarFollowsTheme
				onClicked: plasmoid.configuration.sidebarFollowsTheme = false
			}
			ConfigColor {
				label: ""
				configKey: 'sidebarBackgroundColor'
			}
		}
		
	}

	ConfigSection {
		label: i18n("Sidebar Shortcuts")

		RowLayout {
			ConfigStringList {
				id: sidebarShortcuts
				configKey: 'sidebarShortcuts'
				Layout.fillHeight: true

				KCoreAddons.KUser {
					id: kuser
				}

				function startsWith(a, b) {
					return a.substr(0, b.length) === b
				}

				function parseText(text) {
					var urls = text.split("\n")
					for (var i = 0; i < urls.length; i++) {
						if (startsWith(urls[i], '~/')) { // Starts with '~/' (home dir)
							if (kuser.loginName) {
								urls[i] = '/home/' + kuser.loginName + urls[i].substr(1)
							}
						}
						if (startsWith(urls[i], '/')) { // Starts with '/' (root)
							urls[i] = 'file://' + urls[i] // Prefix URL file scheme when serializing.
						}
					}
					return urls
				}

				function addUrl(str) {
					if (hasItem(str)) {
						// Skip. Kicker.FavoritesModel will remove it anyways,
						// and can cause a serialize + deserialize loop.
					} else {
						prepend(str)
					}
					selectItem(str) // Select the existing text to highlight it's existence.
				}
			}

			ColumnLayout {
				id: sidebarDefaultsColumn

				Label {
					text: i18n("Add Default")
				}

				ConfigIconButton {
					iconName: "folder-documents-symbolic"
					text: xdgPathsLoader.displayName('DOCUMENTS')
					onClicked: sidebarShortcuts.addUrl('xdg:DOCUMENTS')
				}
				ConfigIconButton {
					iconName: "folder-download-symbolic"
					// Component.onCompleted: contentItem.alignment = Qt.AlignLeft
					text: xdgPathsLoader.displayName('DOWNLOAD')
					onClicked: sidebarShortcuts.addUrl('xdg:DOWNLOAD')
				}
				ConfigIconButton {
					iconName: "folder-music-symbolic"
					text: xdgPathsLoader.displayName('MUSIC')
					onClicked: sidebarShortcuts.addUrl('xdg:MUSIC')
				}
				ConfigIconButton {
					iconName: "folder-pictures-symbolic"
					text: xdgPathsLoader.displayName('PICTURES')
					onClicked: sidebarShortcuts.addUrl('xdg:PICTURES')
				}
				ConfigIconButton {
					iconName: "folder-videos-symbolic"
					text: xdgPathsLoader.displayName('VIDEOS') // Uhg, it's displayed 'Movies' instead of 'Videos'...
					onClicked: sidebarShortcuts.addUrl('xdg:VIDEOS')
				}
				ConfigIconButton {
					iconName: "folder-open-symbolic"
					text: i18nd("dolphin", "Dolphin")
					onClicked: sidebarShortcuts.addUrl('org.kde.dolphin.desktop')
				}
				ConfigIconButton {
					iconName: "configure"
					text: i18nd("systemsettings", "System Settings")
					onClicked: sidebarShortcuts.addUrl('systemsettings.desktop')
				}
				Item { Layout.fillHeight: true }
			}
		}
	}


	ExclusiveGroup { id: searchBoxThemeGroup }
	ConfigSection {
		label: i18n("Search Box")

		ConfigSpinBox {
			configKey: 'searchFieldHeight'
			before: i18n("Search Field Height")
			suffix: i18n("px")
			minimumValue: 0
		}
		
		RadioButton {
			text: i18n("Desktop Theme (%1)", theme.themeName)
			exclusiveGroup: searchBoxThemeGroup
			checked: plasmoid.configuration.searchFieldFollowsTheme
			onClicked: plasmoid.configuration.searchFieldFollowsTheme = true
		}
		RadioButton {
			text: i18n("Windows (White)")
			exclusiveGroup: searchBoxThemeGroup
			checked: !plasmoid.configuration.searchFieldFollowsTheme
			onClicked: plasmoid.configuration.searchFieldFollowsTheme = false
		}
	}

	ConfigSection {
		label: i18n("App List")

		ConfigSpinBox {
			id: appListWidthControl
			configKey: 'appListWidth'
			before: i18n("App List Area Width")
			suffix: i18n("px")
			minimumValue: 0
		}

		ConfigComboBox {
			id: defaultAppListOrderControl
			configKey: "defaultAppListOrder"
			label: i18n("Default Order")
			model: [
				{ value: "alphabetical", text: i18n("Alphabetical") },
				{ value: "categories", text: i18n("Categories") },
			]
		}

		ConfigComboBox {
			id: appDescriptionControl
			configKey: "appDescription"
			label: i18n("App Description")
			model: [
				{ value: "hidden", text: i18n("Hidden") },
				{ value: "after", text: i18n("After") },
				{ value: "below", text: i18n("Below") },
			]
			onValueChanged: {
				if (value == "below") {
					if (menuItemHeightControl.value <= 36) { // Smaller than 2 lines of text
						menuItemHeightControl.value = 36
					}
				}
			}
		}

		ConfigCheckBox {
			text: i18n("Show recent applications")
			configKey: 'showRecentApps'
		}

		ConfigSpinBox {
			id: menuItemHeightControl
			configKey: 'menuItemHeight'
			before: i18n("Icon Size")
			suffix: i18n("px")
			minimumValue: 18 // 1 line of text
			maximumValue: 128
			onValueChanged: {
				if (value < 36) { // Smaller than 2 lines of text
					if (appDescriptionControl.value == "below") {
						appDescriptionControl.setValue("after")
					}
				}
			}
		}
	}

	ExclusiveGroup { id: searchResultsMergedGroup }
	ConfigSection {
		label: i18n("Search Results")

		RadioButton {
			exclusiveGroup: searchResultsMergedGroup
			text: i18n("Merged (Application Launcher)")
			checked: plasmoid.configuration.searchResultsMerged
			onClicked: {
				plasmoid.configuration.searchResultsMerged = true
				plasmoid.configuration.searchResultsCustomSort = false
			}
		}
		RadioButton {
			exclusiveGroup: searchResultsMergedGroup
			text: i18n("Split into Categories (Application Menu / Dashboard)")
			checked: !plasmoid.configuration.searchResultsMerged
			onClicked: plasmoid.configuration.searchResultsMerged = false
		}
		// ConfigCheckBox {
		// 	enabled: !plasmoid.configuration.searchResultsMerged
		// 	text: i18n("Custom Sort (Prefer partial matches)")
		// 	configKey: 'searchResultsCustomSort'
		// }
	}

}
