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

	readonly property string plasmaStyleLabelText: {
		var plasmaStyleText = i18nd("kcm_desktoptheme", "Plasma Style")
		return plasmaStyleText + ' (' + theme.themeName + ')'
	}

	function getTopItem(item) {
		var curItem = item
		while (curItem.parent) {
			curItem = curItem.parent
		}
		return curItem
	}
	function hideKeyboardShortcutTab() {
		// console.log('root', root)
		// console.log('root.parent', root.parent)
		// console.log('getTopItem(root)', getTopItem(root))
		
		// https://github.com/KDE/plasma-desktop/blob/master/desktoppackage/contents/configuration/AppletConfiguration.qml
		// The "root" id can't always be referenced here, so use one of the child id's and get it's parent.
		var appletConfiguration
		if (typeof mainColumn !== "undefined") { // Plasma 5.14 and below
			appletConfiguration = mainColumn.parent
		} else if (typeof root !== "undefined") { // Plasma 5.15 and above
			// root is the StackView { id: pageStack } in plasmoidviewer
			// walk up to the top node of the "DOM" for AppletConfiguration
			// However root in plasmashell is AppletConfiguration for some reason...
			appletConfiguration = getTopItem(root)
		}
		if (typeof appletConfiguration !== "undefined" && typeof appletConfiguration.globalConfigModel !== "undefined") {
			// Remove default Global Keyboard Shortcut config tab.
			var keyboardShortcuts = appletConfiguration.globalConfigModel.get(0)
			appletConfiguration.globalConfigModel.removeCategoryAt(0)
		}
	}

	Component.onCompleted: {
		hideKeyboardShortcutTab()
	}

	AppletConfig {
		id: config
	}

	ConfigSection {
		label: i18n("Popup")

		ConfigCheckBox {
			text: i18n("Fullscreen")
			configKey: 'fullscreen'
		}

		RowLayout {
			spacing: 0
			visible: !plasmoid.configuration.fullscreen

			ConfigSpinBox {
				configKey: 'favGridCols'
				before: i18n("Grid Columns")
			}

			Label {
				text: " x "
			}

			ConfigSpinBox {
				configKey: 'popupHeight'
				suffix: i18n("px")
			}
		}
	}

	ConfigSection {
		label: i18n("Panel Icon")

		ConfigIcon {
			configKey: 'icon'
			defaultValue: 'start-here-kde'
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
				suffix: 'x'
				minimumValue: 0.1
				maximumValue: 4
				decimals: 1
			}
			Label {
				text: '' + config.cellBoxSize + i18n("px")
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
			visible: false
			text: plasmaStyleLabelText
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
			ConfigCheckBox {
				text: i18n("Gradient")
				configKey: 'defaultTileGradient'
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
	}

	ExclusiveGroup { id: sidebarThemeGroup }
	ConfigSection {
		label: i18n("Sidebar")
		
		ConfigSpinBox {
			id: sidebarButtonSize
			configKey: 'sidebarButtonSize'
			before: i18n("Width")
			suffix: i18n("px")
			minimumValue: 24
			stepSize: 2
		}

		ConfigSpinBox {
			id: sidebarIconSize
			configKey: 'sidebarIconSize'
			before: i18n("Icon Size")
			suffix: i18n("px")
			minimumValue: 16
			maximumValue: sidebarButtonSize.configValue
			stepSize: 2
		}
		
		ConfigSpinBox {
			id: sidebarPopupButtonSize
			configKey: 'sidebarPopupButtonSize'
			before: i18n("Popup Button Height")
			suffix: i18n("px")
			minimumValue: 24
			stepSize: 2
		}

		RadioButton {
			text: plasmaStyleLabelText
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
					text: i18nd("xdg-user-dirs", "Documents")
					onClicked: sidebarShortcuts.addUrl('xdg:DOCUMENTS')
				}
				ConfigIconButton {
					iconName: "folder-download-symbolic"
					// Component.onCompleted: contentItem.alignment = Qt.AlignLeft
					text: i18nd("xdg-user-dirs", "Download")
					onClicked: sidebarShortcuts.addUrl('xdg:DOWNLOAD')
				}
				ConfigIconButton {
					iconName: "folder-music-symbolic"
					text: i18nd("xdg-user-dirs", "Music")
					onClicked: sidebarShortcuts.addUrl('xdg:MUSIC')
				}
				ConfigIconButton {
					iconName: "folder-pictures-symbolic"
					text: i18nd("xdg-user-dirs", "Pictures")
					onClicked: sidebarShortcuts.addUrl('xdg:PICTURES')
				}
				ConfigIconButton {
					iconName: "folder-videos-symbolic"
					text: i18nd("xdg-user-dirs", "Videos")
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

		ConfigCheckBox {
			configKey: 'hideSearchField'
			text: i18n("Hide Search Field")
		}

		ConfigSpinBox {
			configKey: 'searchFieldHeight'
			before: i18n("Search Field Height")
			suffix: i18n("px")
			minimumValue: 0
		}
		
		RadioButton {
			text: plasmaStyleLabelText
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

		// For debugging purposes.
		// User can configures the Filters in the SearchView
		// ConfigStringList {
		// 	configKey: 'searchDefaultFilters'
		// 	textArea.readOnly: true
		// 	function serialize() {
		// 		// Do nothing
		// 	}
		// }
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
			id: defaultAppListViewControl
			configKey: "defaultAppListView"
			label: i18n("Default View")
			model: [
				{ value: "Alphabetical", text: i18n("Alphabetical") },
				{ value: "Categories", text: i18n("Categories") },
				{ value: "JumpToLetter", text: i18n("Jump To Letter") },
				{ value: "JumpToCategory", text: i18n("Jump To Category") },
				{ value: "TilesOnly", text: i18n("Tiles Only") },
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

		RowLayout {
			ConfigCheckBox {
				id: showRecentAppsCheckBox
				text: i18n("Show:")
				configKey: 'showRecentApps'
			}
			ConfigSpinBox {
				configKey: 'numRecentApps'
				enabled: showRecentAppsCheckBox.checked
				// Kicker's RecentUsageModel limits to 15 apps.
				// https://github.com/KDE/plasma-desktop/blob/master/applets/kicker/plugin/recentusagemodel.cpp#L449
				minimumValue: 1
				maximumValue: 15
			}

			ConfigComboBox {
				configKey: 'recentOrdering'
				label: ""
				model: [
					// TODO: Use plasma_applet_org.kde.plasma.kicker domain after depending on Plasma 5.18
					{ value: 0, text: i18n("Recent applications") }, 
					{ value: 1, text: i18n("Often used applications") },
				]
			}
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
