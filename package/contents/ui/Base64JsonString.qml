// Version 3

import QtQuick 2.0

QtObject {
	property string configKey
	readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ""
	property variant value: { return {} }
	property variant defaultValue: { return {} }
	property bool writing: false
	property bool loadOnConfigChange: true
	signal loaded()

	Component.onCompleted: {
		load()
	}

	onConfigValueChanged: {
		if (loadOnConfigChange && !writing) {
			load()
		}
	}

	onDefaultValueChanged: {
		if (configValue === '') { // Optimization
			load()
		}
	}

	function getBase64Json(key, defaultValue) {
		if (configValue === '') {
			return defaultValue
		}
		var val = Qt.atob(configValue) // decode base64
		val = JSON.parse(val)
		return val
	}

	function setBase64Json(key, data) {
		var val = JSON.stringify(data)
		val = Qt.btoa(val)
		writing = true
		plasmoid.configuration[key] = val
		writing = false
	}

	function set(obj) {
		setBase64Json(configKey, obj)
	}

	function setItemProperty(key1, key2, val) {
		var item = value[key1] || {}
		item[key2] = val
		value[key1] = item
		set(value)
		valueChanged()
	}

	function getItemProperty(key1, key2, def) {
		var item = value[key1] || {}
		return typeof item[key2] !== "undefined" ? item[key2] : def
	}

	function load() {
		// console.log('load')
		// console.log('configKey', configKey)
		// console.log('plasmoid.configuration[key]', plasmoid.configuration[configKey])
		value = getBase64Json(configKey, defaultValue)
		loaded()
	}

	function save() {
		// console.log('save')
		// console.log('configKey', configKey)
		// console.log('plasmoid.configuration[key]', plasmoid.configuration[configKey])
		setBase64Json(configKey, value || defaultValue)
	}

	onValueChanged: {
		// console.log('onValueChanged', configKey, value)
	}
}
