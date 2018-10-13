import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kcoreaddons 1.0 as KCoreAddons

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
		XdgPathsLoader { id: xdgPathsLoader }

		KCoreAddons.KUser {
			id: kuser
		}
		
		Kicker.SystemSettings {
			id: systemSettings
		}

		Kicker.DragHelper {
			id: dragHelper

			dragIconSize: units.iconSizes.medium

			onDropped: widget.draggedFavoriteId = ""
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

	// Workaround for passing the favoriteId to the drop handler.
	// Use until event.mimeData.mimeData is exposed.
	// https://github.com/KDE/kdeclarative/blob/0e47f91b3a2c93655f25f85150faadad0d65d2c1/src/qmlcontrols/draganddrop/DeclarativeDragDropEvent.cpp#L66
	property string draggedFavoriteId: ""
	// onDraggedFavoriteIdChanged: console.log('onDraggedFavoriteIdChanged', draggedFavoriteId)


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
				plasmoid.configuration.popupHeight = height / units.devicePixelRatio
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
