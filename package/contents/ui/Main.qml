import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kcoreaddons 1.0 as KCoreAddons
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons

import "lib"

Item {
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
		KCoreAddons.KUser {
			id: kuser
		}
		
		Kicker.SystemSettings {
			id: systemSettings
		}

		Kicker.DragHelper {
			id: dragHelper

			dragIconSize: units.iconSizes.medium

			// Used when we only have a string and don't have a QIcon.
			// DragHelper.startDrag(...) requires a QIcon. See Issue #75.
			property var defaultIconItem: KQuickControlsAddons.QIconItem {
				id: defaultIconItem
			}
			property alias defaultIcon: defaultIconItem.icon
		}

		Kicker.ProcessRunner {
			id: processRunner
			// .runMenuEditor() to run kmenuedit
		}

		Kicker.WindowSystem {
			id: windowSystem
		}

		PlasmaCore.DataSource {
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

	Plasmoid.toolTipMainText: ""
	Plasmoid.toolTipSubText: ""

	Plasmoid.compactRepresentation: LauncherIcon {
		id: panelItem
		iconSource: plasmoid.configuration.icon || "start-here-kde"
	}

	Plasmoid.hideOnWindowDeactivate: !plasmoid.userConfiguring
	property bool expanded: plasmoid.expanded
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
	Popup {
		id: popup
		anchors.fill: parent
	}
	Layout.minimumWidth: config.leftSectionWidth
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

	Timer {
		id: resizeHeight
		interval: 200
		onTriggered: {
			if (!plasmoid.configuration.fullscreen) {
				// Need to Math.ceil when writing to fix (Issue #71)
				var dPR = units.devicePixelRatio
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
				// Force a reflow since Alt+RightClick+Drag resizing doesn't really play nice with PlasmaCore.Dialog.
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

	function action_kinfocenter() { appsModel.launch('org.kde.kinfocenter') }
	function action_konsole() { appsModel.launch('org.kde.konsole') }
	function action_ksysguard() { appsModel.launch('org.kde.ksysguard') }
	function action_systemsettings() { appsModel.launch('systemsettings') }
	function action_filemanager() { appsModel.launch('org.kde.dolphin') }
	function action_menuedit() { processRunner.runMenuEditor(); }

	Component.onCompleted: {
		if (plasmoid.hasOwnProperty("activationTogglesExpanded")) {
			plasmoid.activationTogglesExpanded = true
		}
		plasmoid.setAction("kinfocenter", i18n("System Info"), "hwinfo");
		plasmoid.setAction("konsole", i18n("Terminal"), "utilities-terminal");
		plasmoid.setActionSeparator("systemAppsSection")
		plasmoid.setAction("ksysguard", i18n("Task Manager"), "ksysguardd");
		plasmoid.setAction("systemsettings", i18n("System Settings"), "systemsettings");
		plasmoid.setAction("filemanager", i18n("File Manager"), "folder");
		plasmoid.setActionSeparator("configSection")
		plasmoid.setAction("menuedit", i18n("Edit Applications..."), "kmenuedit");

		// plasmoid.action('configure').trigger() // Uncomment to open the config window on load.
	}
}
