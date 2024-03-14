import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.private.kicker as Kicker
import org.kde.coreaddons as KCoreAddons
// import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons

import "lib"

PlasmoidItem {
	id: widget

	Logger {
		id: logger
		name: 'tiledmenu'
		// showDebug: true
	}

	SearchModel {
		id: search
		Component.onCompleted: {
			search.applyDefaultFilters()
		}
	}

	property alias rootModel: appsModel.rootModel
	AppsModel {
		id: appsModel
	}

	Item {
		// https://invent.kde.org/frameworks/kdeclarative/-/blob/master/src/qmlcontrols/kcoreaddons/kuserproxy.h
		// https://invent.kde.org/frameworks/kdeclarative/-/blob/master/src/qmlcontrols/kcoreaddons/kuserproxy.cpp
		KCoreAddons.KUser {
			id: kuser
			// faceIconUrl is an empty QUrl 'object' when ~/.face.icon doesn't exist.
			// Cast it to string first before checking if it's empty by casting to bool.
			readonly property bool hasFaceIcon: (''+faceIconUrl)
		}
		
		Kicker.SystemSettings {
			id: systemSettings
		}

		Kicker.DragHelper {
			id: dragHelper

			dragIconSize: Kirigami.Units.iconSizes.medium

			// Used when we only have a string and don't have a QIcon.
			// DragHelper.startDrag(...) requires a QIcon. See Issue #75.
			// property var defaultIconItem: KQuickControlsAddons.QIconItem {
			// 	id: defaultIconItem
			// }
			// property alias defaultIcon: defaultIconItem.icon
		}

		Kicker.ProcessRunner {
			id: processRunner
			// .runMenuEditor() to run kmenuedit
		}

		Kicker.WindowSystem {
			id: windowSystem
		}

		Plasma5Support.DataSource {
			id: executable
			engine: "executable"
			connectedSources: []
			onNewData: disconnectSource(sourceName) // cmd finished
			function exec(cmd) {
				connectSource(cmd)
			}
		}
	}

	AppletConfig {
		id: config
	}

	function logListModel(label, listModel) {
		console.log(label + '.count', listModel.count);
		// logObj(label, listModel);
		for (var i = 0; i < listModel.count; i++) {
			var item = listModel.modelForRow(i);
			var itemLabel = label + '[' + i + ']';
			console.log(itemLabel, item);
			logObj(itemLabel, item);
			if (('' + item).indexOf('Model') >= 0) {
				logListModel(itemLabel, item);
			}
		}
	}
	function logObj(label, obj) {
		// if (obj && typeof obj === 'object') {
		//  console.log(label, Object.keys(obj))
		// }
		
		for (var key in obj) {
			var val = obj[key];
			if (typeof val !== 'function') {
				var itemLabel = label + '.' + key;
				console.log(itemLabel, typeof val, val);
				if (('' + val).indexOf('Model') >= 0) {
					logListModel(itemLabel, val);
				}
			}
		}
	}

	toolTipMainText: ""
	toolTipSubText: ""

	// TODO Plasma6 update broke button so need to check default
	// compactRepresentation: LauncherIcon {
	// 	id: panelItem
	// 	iconSource: plasmoid.configuration.icon || "start-here-kde"
	// }

	hideOnWindowDeactivate: !widget.userConfiguring
	activationTogglesExpanded: true
	onExpandedChanged: {
		if (expanded) {
			search.query = ""
			search.applyDefaultFilters()
			config.showSearch = false
			popup.searchView.searchField.forceActiveFocus()
			popup.searchView.showDefaultView()
			// popup.searchView.tileEditorView.open('preferred://browser')
		}
	}

	// property alias searchResultsView: popup.searchView.searchResultsView
	// width: popup.width
	// height: popup.height

	fullRepresentation: Popup {
		id: popup

		Layout.minimumWidth: config.leftSectionWidth
		Layout.minimumHeight: config.minimumHeight
		Layout.preferredWidth: config.popupWidth
		Layout.preferredHeight: config.popupHeight

		// Layout.minimumHeight: 600 // For quickly testing as a desktop widget
		// Layout.minimumWidth: 800

		onWidthChanged: {
			// console.log('popup.size', width, height, 'width')
			resizeToFit.run()
		}
		onHeightChanged: {
			// console.log('popup.size', width, height, 'height')
			resizeHeight.restart()
		}

		// Make popup resizeable like default Kickoff widget.
		// The FullRepresentation must have an appletInterface property.
		// https://invent.kde.org/plasma/plasma-desktop/-/commit/23c4e82cdcb6c7f251c27c6eefa643415c8c5927
		// https://invent.kde.org/frameworks/plasma-framework/-/merge_requests/500/diffs
		readonly property var appletInterface: Plasmoid.self

		Timer {
			id: resizeHeight
			interval: 200
			onTriggered: {
				if (!plasmoid.configuration.fullscreen) {
					// Need to Math.ceil when writing to fix (Issue #71)
					var dPR = Screen.devicePixelRatio
					var pH2 = height / dPR
					var pH3 = Math.ceil(pH2)
					// console.log('pH.set', 'dPR='+dPR, 'pH1='+height, 'pH2='+pH2, 'pH3='+pH3)
					if (plasmoid.configuration.popupHeight != pH3) {
						plasmoid.configuration.popupHeight = pH3
					}
				}
			}
		}
		Timer {
			id: resizeToFit
			interval: attemptsLeft == attempts ? 200 : 100
			repeat: attemptsLeft > 0
			property int attempts: 10
			property int attemptsLeft: 10

			function run() {
				restart()
				attemptsLeft = attempts
			}

			onTriggered: {
				if (plasmoid.configuration.fullscreen) {
					attemptsLeft = 0
				} else {
					var favWidth = Math.max(0, widget.width - config.leftSectionWidth) // 398 // 888-60-430
					// console.log(favWidth, widget.width, config.leftSectionWidth)
					// console.log(favWidth / config.cellBoxSize)
					// var cols = Math.floor(favWidth / config.favColWidth) * 2
					var cols = Math.floor(favWidth / config.cellBoxSize)
					if (plasmoid.configuration.favGridCols != cols) {
						// console.log(plasmoid.configuration.favGridCols, cols)
						plasmoid.configuration.favGridCols = cols
					}
					// Force a reflow since Meta+RightClick+Drag resizing doesn't really play nice with PlasmaCore.Dialog.
					config.popupWidthChanged()
					widget.Layout.preferredWidthChanged()
					attemptsLeft -= 1
				}
			}
		}
		// Layout.onPreferredWidthChanged: console.log('popup.size', width, height)
		// Layout.onPreferredHeightChanged: console.log('popup.size', width, height)


		onFocusChanged: {
			if (focus) {
				popup.searchView.searchField.forceActiveFocus()
			}
		}
	}

	Plasmoid.contextualActions: [
		PlasmaCore.Action {
			text: i18n("System Info")
			icon.name: "hwinfo"
			onTriggered: appsModel.launch('org.kde.kinfocenter')
		},
		PlasmaCore.Action {
			text: i18n("Terminal")
			icon.name: "utilities-terminal"
			onTriggered: appsModel.launch('org.kde.konsole')
		},
		PlasmaCore.Action {
			isSeparator: true
		},
		PlasmaCore.Action {
			text: i18n("Task Manager")
			icon.name: "ksysguardd"
			onTriggered: appsModel.launch('org.kde.ksysguard')
		},
		PlasmaCore.Action {
			text: i18n("System Settings")
			icon.name: "systemsettings"
			onTriggered: appsModel.launch('systemsettings')
		},
		PlasmaCore.Action {
			text: i18n("File Manager")
			icon.name: "folder"
			onTriggered: appsModel.launch('org.kde.dolphin')
		},
		PlasmaCore.Action {
			isSeparator: true
		},
		PlasmaCore.Action {
			text: i18n("Edit Applications...")
			icon.name: "kmenuedit"
			onTriggered: processRunner.runMenuEditor()
		}
	]

	Component.onCompleted: {
		// Plasmoid.internalAction("configure").trigger() // Uncomment to open the config window on load.
	}
}
