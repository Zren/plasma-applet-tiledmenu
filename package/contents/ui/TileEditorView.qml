import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

import "./config"

ColumnLayout {
	id: tileEditorView
	Layout.alignment: Qt.AlignTop

	AppObject {
		id: appObj
	}
	property alias tile: appObj.tile

	function resetView() {
		tile = null
	}

	function resetTile() {
		delete appObj.tile.showIcon
		delete appObj.tile.showLabel
		delete appObj.tile.label
		delete appObj.tile.icon
		delete appObj.tile.backgroundColor
		delete appObj.tile.backgroundImage
		appObj.tileChanged()
		tileGrid.tileModelChanged()
	}


	RowLayout {
		PlasmaExtras.Heading {
			Layout.fillWidth: true
			level: 2
			text: i18n("Edit Tile")
		}

		PlasmaComponents.Button {
			text: i18n("Reset Tile")
			onClicked: resetTile()
		}

		PlasmaComponents.Button {
			text: i18n("Close")
			onClicked: {
				tileEditorView.close()
			}
		}
	}


	ScrollView {
		id: scrollView
		Layout.fillHeight: true
		Layout.fillWidth: true

		readonly property int viewportWidth: viewport ? viewport.width : 0

		ColumnLayout {
			id: scrollContent
			width: scrollView.viewportWidth

			TileEditorField {
				// visible: appObj.isLauncher
				title: i18n("Url")
				key: 'url'
			}

			TileEditorField {
				id: labelField
				title: i18n("Label")
				placeholderText: appObj.appLabel
				key: 'label'
				checkedKey: 'showLabel'
			}

			TileEditorField {
				id: iconField
				title: i18n("Icon")
				// placeholderText: appObj.appIcon ? appObj.appIcon.toString() : ''
				key: 'icon'
				checkedKey: 'showIcon'
				checkedDefault: appObj.defaultShowIcon

				PlasmaComponents.Button {
					iconName: "document-open"
					onClicked: iconDialog.open()

					KQuickAddons.IconDialog {
						id: iconDialog
						onIconNameChanged: iconField.text = iconName
					}
				}
			}

			TileEditorField {
				id: backgroundImageField
				title: i18n("Background Image")
				key: 'backgroundImage'

				PlasmaComponents.Button {
					iconName: 'document-open'
					onClicked: imagePicker.open()

					FileDialog {
						id: imagePicker

						title: i18n("Choose an image")

						selectFolder: false
						selectMultiple: false

						nameFilters: [ i18n("Image Files (*.png *.jpg *.jpeg *.bmp *.svg *.svgz)") ]

						onFileUrlChanged: {
							backgroundImageField.text = fileUrl
							if (fileUrl) {
								labelField.checked = false
								iconField.checked = false
							}
						}
					}
				}
			}

			TileEditorPresetTiles {
				title: i18n("Preset Tiles")
			}

			TileEditorColorField {
				title: i18n("Background Color")
				placeholderText: config.defaultTileColor
				key: 'backgroundColor'
			}

			TileEditorRectField {
				title: i18n("Position / Size")
			}

			Item { // Consume the extra space below
				Layout.fillHeight: true
			}
		}
	}

	function show() {
		if (stackView.currentItem != tileEditorView) {
			stackView.push(tileEditorView, true)
		}
	}

	function open(tile) {
		resetView()
		tileEditorView.tile = tile
		show()
	}

	function close() {
		searchView.showDefaultView()
	}


	Connections {
		target: stackView

		onCurrentItemChanged: {
			if (stackView.currentItem != tileEditorView) {
				tileEditorView.resetView()
			}
		}
	}


	Connections {
		target: config.tileModel

		onLoaded: {
			// Base64JsonString.save() will create a new JavaScript array [],
			// and our current tile {} reference will be incorrect, which breaks the tile editor.
			// We could keep a reference to the tile's index in the array, and make sure
			// the tile's url did not change, but there's no guarantee we won't overwrite data
			// during an Import, so just close the view.
			tileEditorView.close()
		}
	}

}
