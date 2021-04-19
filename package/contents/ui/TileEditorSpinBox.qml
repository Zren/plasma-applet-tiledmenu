import QtQuick 2.2
import QtQuick.Layouts 1.0

import org.kde.plasma.components 3.0 as PlasmaComponents3

PlasmaComponents3.SpinBox {
	id: spinBox
	property string key: ''
	Layout.fillWidth: true
	implicitWidth: 20
	value: appObj.tile && appObj.tile[key] || 0
	property bool updateOnChange: false
	onValueChanged: {
		if (key && updateOnChange) {
			appObj.tile[key] = value
			appObj.tileChanged()
			tileGrid.tileModelChanged()
		}
	}

	Connections {
		target: appObj

		onTileChanged: {
			if (key && tile) {
				spinBox.updateOnChange = false
				spinBox.value = appObj.tile[key] || 0
				spinBox.updateOnChange = true
			}
		}
	}
}
