import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import ".."

RowLayout {
	id: configJsonString
	Layout.fillWidth: true

	property var base64JsonString: Base64JsonString {
		id: base64JsonString
	}

	property alias configKey: base64JsonString.configKey
	property alias defaultValue: base64JsonString.defaultValue

	property alias enabled: textArea.enabled

	readonly property var configValue: configKey ? plasmoid.configuration[configKey] : ""
	onConfigValueChanged: deserialize()
	readonly property var value: base64JsonString.value

	property alias textArea: textArea
	property alias textAreaText: textArea.text

	property string indent: '  '

	function parseValue(value) {
		return JSON.stringify(value, null, indent)
	}
	function parseText(text) {
		return JSON.parse(text)
	}

	function setValue(val) {
		var newText = parseValue(val)
		if (textArea.text != newText) {
			textArea.text = newText
		}
	}

	function deserialize() {
		if (!textArea.focus) {
			setValue(value)
		}
	}
	function serialize() {
		var newValue = parseText(textArea.text)
		base64JsonString.set(newValue)
	}

	property alias before: labelBefore.text
	property alias after: labelAfter.text

	Label {
		id: labelBefore
		text: ""
		visible: text
	}
	
	TextArea {
		id: textArea
		Layout.fillWidth: true
		Layout.fillHeight: configJsonString.Layout.fillHeight

		onTextChanged: serializeTimer.restart()
	}

	Label {
		id: labelAfter
		text: ""
		visible: text
	}

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: serialize()
	}
}
