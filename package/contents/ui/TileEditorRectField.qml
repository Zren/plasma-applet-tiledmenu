import QtQuick 2.2
import QtQuick.Layouts 1.0
import org.kde.plasma.components 3.0 as PlasmaComponents3

TileEditorGroupBox {
	id: tileEditorRectField
	title: "Label"
	implicitWidth: parent.implicitWidth
	Layout.fillWidth: true

	// readonly property int xLeft: tileGrid.columns - (appObj.tileX + appObj.tileW)

	RowLayout {
		anchors.fill: parent

		GridLayout {
			columns: 2
			Layout.fillWidth: true

			PlasmaComponents3.Label { text: "x:" }
			TileEditorSpinBox {
				key: 'x'
				from: 0
				// to: tileGrid.columns - (appObj.tile && appObj.tile.w-1 || 0)
				// to: appObj.tileX + tileEditorRectField.xLeft
			}
			PlasmaComponents3.Label { text: "y:" }
			TileEditorSpinBox {
				key: 'y'
				from: 0
			}
			PlasmaComponents3.Label { text: "w:" }
			TileEditorSpinBox {
				key: 'w'
				from: 1
				// to: tileGrid.columns - (appObj.tile && appObj.tile.x || 0)
				// to: appObj.tileW + tileEditorRectField.xLeft
			}
			PlasmaComponents3.Label { text: "h:" }
			TileEditorSpinBox {
				key: 'h'
				from: 1
			}
		}

		GridLayout {
			id: resizeGrid
			Layout.fillWidth: true
			rows: 4
			columns: 4

			Repeater {
				model: resizeGrid.rows * resizeGrid.columns

				PlasmaComponents3.Button {
					Layout.fillWidth: true
					implicitWidth: 20
					property int w: (modelData % resizeGrid.columns) + 1
					property int h: Math.floor(modelData / resizeGrid.columns) + 1
					text: '' + w + 'x' + h
					checked: w <= appObj.tileW && h <= appObj.tileH
					// enabled: w - appObj.tileW <= tileEditorRectField.xLeft
					onClicked: {
						appObj.tile.w = w
						appObj.tile.h = h
						appObj.tileChanged()
						tileGrid.tileModelChanged()
					}
				}
			}
		}
	}
}
