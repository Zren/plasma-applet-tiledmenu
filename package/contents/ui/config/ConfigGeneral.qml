import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.0

import org.kde.kirigami 2.5 as Kirigami
import org.kde.kcoreaddons 1.0 as KCoreAddons

import ".."
import "../lib"
import "../libconfig" as LibConfig


Kirigami.FormLayout {
	id: formLayout

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

	property var config: AppletConfig {
		id: config
	}



		//-------------------------------------------------------
		LibConfig.Heading {
			text: i18n("Popup")
		}

		LibConfig.CheckBox {
			text: i18n("Fullscreen")
			configKey: 'fullscreen'
		}


		RowLayout {
			Kirigami.FormData.label: i18n("Grid Columns")
			spacing: 0
			visible: !plasmoid.configuration.fullscreen

			LibConfig.SpinBox {
				configKey: 'favGridCols'
			}

			QQC2.Label {
				text: " x "
			}

			LibConfig.SpinBox {
				configKey: 'popupHeight'
				suffix: i18n("px")
			}
		}



		//-------------------------------------------------------
		LibConfig.Heading {
			text: i18n("Panel Icon")
		}

		LibConfig.IconField {
			Layout.fillWidth: true
			configKey: 'icon'
			defaultValue: 'start-here-kde'
			previewIconSize: Kirigami.Units.iconSizes.large

			LibConfig.CheckBox {
				text: i18n("Fixed Size")
				configKey: 'fixedPanelIcon'
			}
		}



		//-------------------------------------------------------
		LibConfig.Heading {
			text: i18n("Tiles")
		}

		RowLayout {
			Kirigami.FormData.label: i18n("Tile Size")
			LibConfig.SpinBox {
				configKey: 'tileScale'
				suffix: 'x'
				minimumValue: 0.1
				maximumValue: 4
				decimals: 1
			}
			QQC2.Label {
				text: '' + config.cellBoxSize + i18n("px")
			}
		}
		LibConfig.SpinBox {
			configKey: 'tileMargin'
			Kirigami.FormData.label: i18n("Tile Margin")
			suffix: i18n("px")
			minimumValue: 0
			maximumValue: config.cellBoxUnits/2
		}

		LibConfig.RadioButtonGroup {
			id: tilesThemeGroup
			Kirigami.FormData.label: i18n("Background Color")
			spacing: 0 // "Custom Color" has lots of spacings already
			RowLayout {
				QQC2.RadioButton {
					id: defaultTileColorRadioButton
					text: i18n("Custom Color")
					QQC2.ButtonGroup.group: tilesThemeGroup.group
					checked: true
				}
				LibConfig.ColorField {
					id: defaultTileColorColor
					configKey: 'defaultTileColor'
				}
				LibConfig.CheckBox {
					text: i18n("Gradient")
					configKey: 'defaultTileGradient'
				}
			}
			QQC2.RadioButton {
				text: i18n("Transparent")
				QQC2.ButtonGroup.group: tilesThemeGroup.group
				onClicked: {
					defaultTileColorColor.text = "#00000000"
					defaultTileColorRadioButton.checked = true
				}
			}
		}
		LibConfig.ComboBox {
			configKey: "tileLabelAlignment"
			Kirigami.FormData.label: i18n("Text Alignment")
			model: [
				{ value: "left", text: i18n("Left") },
				{ value: "center", text: i18n("Center") },
				{ value: "right", text: i18n("Right") },
			]
		}




		//-------------------------------------------------------
		LibConfig.Heading {
			text: i18n("Sidebar")
		}

		LibConfig.SpinBox {
			id: sidebarButtonSize
			configKey: 'sidebarButtonSize'
			Kirigami.FormData.label: i18n("Width")
			suffix: i18n("px")
			minimumValue: 24
			stepSize: 2
		}

		LibConfig.SpinBox {
			id: sidebarIconSize
			configKey: 'sidebarIconSize'
			Kirigami.FormData.label: i18n("Icon Size")
			suffix: i18n("px")
			minimumValue: 16
			maximumValue: sidebarButtonSize.configValue
			stepSize: 2
		}
		
		LibConfig.SpinBox {
			id: sidebarPopupButtonSize
			Kirigami.FormData.label: i18n("Popup Button Height")
			configKey: 'sidebarPopupButtonSize'
			suffix: i18n("px")
			minimumValue: 24
			stepSize: 2
		}

		LibConfig.RadioButtonGroup {
			id: sidebarThemeGroup
			spacing: 0
			Kirigami.FormData.label: i18n("Theme")

			QQC2.RadioButton {
				text: plasmaStyleLabelText
				QQC2.ButtonGroup.group: sidebarThemeGroup.group
				checked: plasmoid.configuration.sidebarFollowsTheme
				onClicked: plasmoid.configuration.sidebarFollowsTheme = true
			}
			RowLayout {
				QQC2.RadioButton {
					text: i18n("Custom Color")
					QQC2.ButtonGroup.group: sidebarThemeGroup.group
					checked: !plasmoid.configuration.sidebarFollowsTheme
					onClicked: plasmoid.configuration.sidebarFollowsTheme = false
				}
				LibConfig.ColorField {
					configKey: 'sidebarBackgroundColor'
				}
			}
		}



		//-------------------------------------------------------
		LibConfig.Heading {
			text: i18n("Sidebar Shortcuts")
		}

		RowLayout {
			LibConfig.TextAreaStringList {
				id: sidebarShortcuts
				configKey: 'sidebarShortcuts'
				Layout.fillHeight: true
				implicitWidth: 12 * Kirigami.Units.gridUnit

				KCoreAddons.KUser {
					id: kuser
				}

				function startsWith(a, b) {
					return a.substr(0, b.length) === b
				}

				function textToValue(text) {
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

				QQC2.Label {
					text: i18n("Add Default")
				}

				QQC2.ToolButton {
					icon.name: "folder-documents-symbolic"
					text: i18nd("xdg-user-dirs", "Documents")
					onClicked: sidebarShortcuts.addUrl('xdg:DOCUMENTS')
				}
				QQC2.ToolButton {
					icon.name: "folder-download-symbolic"
					text: i18nd("xdg-user-dirs", "Download")
					onClicked: sidebarShortcuts.addUrl('xdg:DOWNLOAD')
				}
				QQC2.ToolButton {
					icon.name: "folder-music-symbolic"
					text: i18nd("xdg-user-dirs", "Music")
					onClicked: sidebarShortcuts.addUrl('xdg:MUSIC')
				}
				QQC2.ToolButton {
					icon.name: "folder-pictures-symbolic"
					text: i18nd("xdg-user-dirs", "Pictures")
					onClicked: sidebarShortcuts.addUrl('xdg:PICTURES')
				}
				QQC2.ToolButton {
					icon.name: "folder-videos-symbolic"
					text: i18nd("xdg-user-dirs", "Videos")
					onClicked: sidebarShortcuts.addUrl('xdg:VIDEOS')
				}
				QQC2.ToolButton {
					icon.name: "folder-open-symbolic"
					text: i18nd("dolphin", "Dolphin")
					onClicked: sidebarShortcuts.addUrl('org.kde.dolphin.desktop')
				}
				QQC2.ToolButton {
					icon.name: "configure"
					text: i18nd("systemsettings", "System Settings")
					onClicked: sidebarShortcuts.addUrl('systemsettings.desktop')
				}
				Item { Layout.fillHeight: true }
			}
		}



		//-------------------------------------------------------
		LibConfig.Heading {
			text: i18n("Search Box")
		}

		LibConfig.CheckBox {
			configKey: 'hideSearchField'
			text: i18n("Hide Search Field")
		}

		LibConfig.SpinBox {
			configKey: 'searchFieldHeight'
			Kirigami.FormData.label: i18n("Search Field Height")
			suffix: i18n("px")
			minimumValue: 0
		}

		LibConfig.RadioButtonGroup {
			Kirigami.FormData.label: i18n("Search Box Theme")
			QQC2.RadioButton {
				text: plasmaStyleLabelText
				checked: plasmoid.configuration.searchFieldFollowsTheme
				onClicked: plasmoid.configuration.searchFieldFollowsTheme = true
			}
			QQC2.RadioButton {
				text: i18n("Windows (White)")
				checked: !plasmoid.configuration.searchFieldFollowsTheme
				onClicked: plasmoid.configuration.searchFieldFollowsTheme = false
			}
		}

		// For debugging purposes.
		// User can configures the Filters in the SearchView
		// LibConfig.TextAreaStringList {
		// 	Kirigami.FormData.label: i18n("Search Plugins")
		// 	configKey: 'searchDefaultFilters'
		// 	readOnly: true
		// 	function serialize() {
		// 		// Do nothing
		// 	}
		// }



		//-------------------------------------------------------
		LibConfig.Heading {
			text: i18n("App List")
		}

		LibConfig.SpinBox {
			id: appListWidthControl
			configKey: 'appListWidth'
			Kirigami.FormData.label: i18n("App List Area Width")
			suffix: i18n("px")
			minimumValue: 0
		}

		LibConfig.ComboBox {
			id: defaultAppListViewControl
			configKey: "defaultAppListView"
			Kirigami.FormData.label: i18n("Default View")
			model: [
				{ value: "Alphabetical", text: i18n("Alphabetical") },
				{ value: "Categories", text: i18n("Categories") },
				{ value: "JumpToLetter", text: i18n("Jump To Letter") },
				{ value: "JumpToCategory", text: i18n("Jump To Category") },
				{ value: "TilesOnly", text: i18n("Tiles Only") },
			]
		}

		LibConfig.ComboBox {
			id: appDescriptionControl
			configKey: "appDescription"
			Kirigami.FormData.label: i18n("App Description")
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
			Kirigami.FormData.label: i18n("App History")
			LibConfig.CheckBox {
				id: showRecentAppsCheckBox
				text: i18n("Show:")
				configKey: 'showRecentApps'
			}
			LibConfig.SpinBox {
				configKey: 'numRecentApps'
				enabled: showRecentAppsCheckBox.checked
				// Kicker's RecentUsageModel limits to 15 apps.
				// https://github.com/KDE/plasma-desktop/blob/master/applets/kicker/plugin/recentusagemodel.cpp#L449
				minimumValue: 1
				maximumValue: 15
			}

			LibConfig.ComboBox {
				configKey: 'recentOrdering'
				model: [
					// TODO: Use plasma_applet_org.kde.plasma.kicker domain after depending on Plasma 5.18
					{ value: 0, text: i18n("Recent applications") }, 
					{ value: 1, text: i18n("Often used applications") },
				]
			}
		}

		LibConfig.SpinBox {
			id: menuItemHeightControl
			configKey: 'menuItemHeight'
			Kirigami.FormData.label: i18n("Icon Size")
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



		//-------------------------------------------------------
		LibConfig.Heading {
			text: i18n("Search Results")
		}

		LibConfig.RadioButtonGroup {
			QQC2.RadioButton {
				text: i18n("Merged (Application Launcher)")
				checked: plasmoid.configuration.searchResultsMerged
				onClicked: {
					plasmoid.configuration.searchResultsMerged = true
					plasmoid.configuration.searchResultsCustomSort = false
				}
			}
			QQC2.RadioButton {
				text: i18n("Split into Categories (Application Menu / Dashboard)")
				checked: !plasmoid.configuration.searchResultsMerged
				onClicked: plasmoid.configuration.searchResultsMerged = false
			}
		}

		// LibConfig.CheckBox {
		// 	enabled: !plasmoid.configuration.searchResultsMerged
		// 	text: i18n("Custom Sort (Prefer partial matches)")
		// 	configKey: 'searchResultsCustomSort'
		// }

}
