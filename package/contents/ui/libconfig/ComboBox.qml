// Version 8

import QtQuick
import QtQuick.Controls as QQC2

/*
** Example:
**
import './libconfig' as LibConfig
LibConfig.ComboBox {
	configKey: "appDescription"
	model: [
		{ value: "a", text: i18n("A") },
		{ value: "b", text: i18n("B") },
		{ value: "c", text: i18n("C") },
	]
}
LibConfig.ComboBox {
	configKey: "appDescription"
	populated: false
	onPopulate: {
		model = [
			{ value: "a", text: i18n("A") },
			{ value: "b", text: i18n("B") },
			{ value: "c", text: i18n("C") },
		]
		populated = true
	}
}
*/
QQC2.ComboBox {
	id: configComboBox

	property string configKey: ''
	readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ""
	onConfigValueChanged: {
		if (!focus && value != configValue) {
			selectValue(configValue)
		}
	}

	readonly property var currentItem: currentIndex >= 0 ? model[currentIndex] : null

	textRole: "text" // Doesn't autodeduce from model if we manually populate it

	// Note that ComboBox.valueRole and ComboBox.currentValue was introduced in Qt 5.14.
	// Ubuntu 20.04 only has Qt 5.12. We cannot define a currentValue property or it will
	// break when users upgrade to Qt 5.14.
	property string _valueRole: "value"
	readonly property var _currentValue: _valueRole && currentIndex >= 0 ? model[currentIndex][_valueRole] : null
	readonly property alias value: configComboBox._currentValue

	model: []

	signal populate()
	property bool populated: true

	Component.onCompleted: {
		populate()
		selectValue(configValue)
	}

	onCurrentIndexChanged: {
		if (typeof model !== 'number' && 0 <= currentIndex && currentIndex < count) {
			var item = model[currentIndex]
			if (typeof item !== "undefined") {
				var val = item[_valueRole]
				if (configKey && (typeof val !== "undefined") && populated) {
					plasmoid.configuration[configKey] = val
				}
			}
		}
	}

	function size() {
		if (typeof model === "number") {
			return model
		} else if (typeof model.count === "number") {
			return model.count
		} else if (typeof model.length === "number") {
			return model.length
		} else {
			return 0
		}
	}

	function findValue(val) {
		for (var i = 0; i < size(); i++) {
			if (model[i][_valueRole] == val) {
				return i
			}
		}
		return -1
	}

	function selectValue(val) {
		var index = findValue(val)
		if (index >= 0) {
			currentIndex = index
		}
	}
}
