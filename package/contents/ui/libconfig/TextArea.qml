// Version 5

import QtQuick 2.0
import QtQuick.Controls 2.1 as QQC2
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.0 as Kirigami

QQC2.TextArea {
	id: textArea
	property string configKey: ''
	readonly property var configValue: configKey ? plasmoid.configuration[configKey] : ""
	onConfigValueChanged: deserialize()

	onTextChanged: serializeTimer.restart()

	wrapMode: TextArea.Wrap

	// An empty TextArea adjust to it's empty contents.
	// So we need the TextArea to be wide enough.
	Layout.fillWidth: true

	// Since QQC2 defaults to implicitWidth=contentWidth, a really long
	// line in TextArea will cause a binding loop on FormLayout.width
	// when we only set fillWidth=true.
	// Setting an implicitWidth fixes this and allows the text to wrap.
	implicitWidth: Kirigami.Units.gridUnit * 20

	// Load
	function deserialize() {
		if (configKey) {
			var newText = valueToText(configValue)
			setText(newText)
		}
	}
	function valueToText(value) {
		return value
	}
	function setText(newText) {
		if (textArea.text != newText) {
			if (textArea.focus) {
				// TODO: Find cursor in newText and replace text before + after cursor.
			} else {
				textArea.text = newText
			}
		}
	}

	// Save
	function serialize() {
		var newValue = textToValue(textArea.text)
		setConfigValue(newValue)
	}
	function textToValue(text) {
		return text
	}
	function setConfigValue(newValue) {
		if (configKey) {
			var oldValue = plasmoid.configuration[configKey]
			if (oldValue != newValue) {
				plasmoid.configuration[configKey] = newValue
			}
		}
	}

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: serialize()
	}
}
