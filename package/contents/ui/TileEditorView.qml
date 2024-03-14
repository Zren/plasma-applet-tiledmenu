import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs as QtDialogs
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.iconthemes as KIconThemes // IconDialog

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

		PlasmaComponents3.Button {
			text: i18n("Reset Tile")
			onClicked: resetTile()
		}

		PlasmaComponents3.Button {
			text: i18n("Close")
			onClicked: {
				tileEditorView.close()
			}
		}
	}


	PlasmaComponents3.ScrollView {
		id: scrollView
		Layout.fillHeight: true
		Layout.fillWidth: true

		ColumnLayout {
			id: scrollContent
			Layout.fillWidth: true
			width: scrollView.availableWidth

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

				PlasmaComponents3.Button {
					icon.name: "document-open"
					onClicked: iconDialog.open()

					KIconThemes.IconDialog {
						id: iconDialog
						onIconNameChanged: iconField.text = iconName
					}
				}
			}

			TileEditorField {
				id: backgroundImageField
				title: i18n("Background Image")
				key: 'backgroundImage'

				PlasmaComponents3.Button {
					icon.name: 'document-open'
					onClicked: imagePicker.open()

					QtDialogs.FileDialog {
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

			TileEditorColorGroup {
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

		function onCurrentItemChanged() {
			if (stackView.currentItem != tileEditorView) {
				tileEditorView.resetView()
			}
		}
	}


	Connections {
		target: config.tileModel

		function onLoaded() {
			// Base64JsonString.save() will create a new JavaScript array [],
			// and our current tile {} reference will be incorrect, which breaks the tile editor.
			// We could keep a reference to the tile's index in the array, and make sure
			// the tile's url did not change, but there's no guarantee we won't overwrite data
			// during an Import, so just close the view.
			tileEditorView.close()
		}
	}

}
