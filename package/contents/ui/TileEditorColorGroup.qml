import QtQuick
import QtQuick.Layouts

TileEditorGroupBox {
	id: tileEditorColorField
	title: "Label"
	implicitWidth: parent.implicitWidth
	Layout.fillWidth: true
	property alias placeholderText: colorField.placeholderText
	property alias enabled: colorField.enabled
	property string key: ''

	TileEditorColorField {
		id: colorField
		showPreviewBg: false
		anchors.left: parent.left
		anchors.right: parent.right
		text: key && appObj.tile && appObj.tile[key] ? appObj.tile[key] : ''
		property bool updateOnChange: false
		onTextChanged: {
			if (key && updateOnChange) {
				if (text) {
					appObj.tile[key] = text
				} else {
					delete appObj.tile[key]
				}
				appObj.tileChanged()
				tileGrid.tileModelChanged()
			}
		}
	}

	Connections {
		target: appObj

		function onTileChanged() {
			if (key && tile) {
				colorField.updateOnChange = false
				colorField.text = appObj.tile[key] || ''
				colorField.updateOnChange = true
			}
		}
	}
}
