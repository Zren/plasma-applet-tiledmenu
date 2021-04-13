// Version 5

import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.5 as Kirigami

/*
** Example:
**
import './libconfig' as LibConfig
LibConfig.RadioButtonGroup {
	configKey: "priority"
	model: [
		{ value: "a", text: i18n("A") },
		{ value: "b", text: i18n("B") },
		{ value: "c", text: i18n("C") },
	]
}
*/
ColumnLayout {
	id: radioButtonGroup

	property string configKey: ''
	readonly property var configValue: configKey ? plasmoid.configuration[configKey] : ""

	property alias group: group
	QQC2.ButtonGroup {
		id: group
	}

	property alias model: buttonRepeater.model

	// The main reason we put all the RadioButtons in
	// a ColumnLayout is to shrink the spacing between the buttons.
	spacing: Kirigami.Units.smallSpacing

	// Assign buddyFor to the first RadioButton so that the Kirigami label aligns with it.
	// Repeater is also a visibleChild, so avoid it.
	Kirigami.FormData.buddyFor: {
		for (var i = 0; i < visibleChildren.length; i++) {
			if (!(visibleChildren[i] instanceof Repeater)) {
				return visibleChildren[i]
			}
		}
		return null
	}

	Repeater {
		id: buttonRepeater
		QQC2.RadioButton {
			visible: typeof modelData.visible !== "undefined" ? modelData.visible : true
			enabled: typeof modelData.enabled !== "undefined" ? modelData.enabled : true
			text: modelData.text
			checked: modelData.value === configValue
			QQC2.ButtonGroup.group: radioButtonGroup.group
			onClicked: {
				focus = true
				if (configKey) {
					plasmoid.configuration[configKey] = modelData.value
				}
			}
		}
	}
}
