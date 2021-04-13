// Version 4

import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2

QQC2.CheckBox {
	id: configCheckBox

	property string configKey: ''
	checked: plasmoid.configuration[configKey]
	onClicked: plasmoid.configuration[configKey] = !plasmoid.configuration[configKey]
}
