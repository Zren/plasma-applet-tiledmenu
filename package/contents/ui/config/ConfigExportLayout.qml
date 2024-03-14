import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore

import ".." as TiledMenu

ColumnLayout {
	id: page

	TextAreaBase64JsonString {
		id: exportData
		Layout.fillHeight: true

		TiledMenu.Base64JsonString {
			id: configTileModel
			configKey: 'tileModel'
			writing: exportData.base64JsonString.writing
			defaultValue: []
		}

		property var ignoredKeys: [
			'tileScale',
			'searchResultsReversed',
			'searchResultsCustomSort',
		]
		
		defaultValue: {
			var data = {}
			var configKeyList = plasmoid.configuration.keys()
			for (var i = 0; i < configKeyList.length; i++) {
				var configKey = configKeyList[i]
				var configValue = plasmoid.configuration[configKey]
				if (typeof configValue === "undefined") {
					continue
				}
				if (ignoredKeys.indexOf(configKey) >= 0) {
					continue
				}
				// Filter KF5 5.78 default keys https://invent.kde.org/frameworks/kdeclarative/-/merge_requests/38
				if (configKey.endsWith('Default')) {
					var key2 = configKey.substr(0, configKey.length - 'Default'.length)
					if (typeof plasmoid.configuration[key2] !== 'undefined') {
						continue
					}
				}
				if (configKey == 'tileModel') {
					data.tileModel = configTileModel.value
				} else {
					data[configKey] = configValue
				}
			}
			return data
		}

		function serialize() {
			var newValue = parseText(textArea.text)
			var configKeyList = plasmoid.configuration.keys()
			for (var i = 0; i < configKeyList.length; i++) {
				var configKey = configKeyList[i]
				var propValue = newValue[configKey]
				if (typeof propValue === "undefined") {
					continue
				}
				if (ignoredKeys.indexOf(configKey) >= 0) {
					continue
				}
				if (configKey == 'tileModel') {
					configTileModel.set(propValue)
				} else {
					if (plasmoid.configuration[configKey] != propValue) {
						plasmoid.configuration[configKey] = propValue
					}
				}
			}
		}
	}

}
