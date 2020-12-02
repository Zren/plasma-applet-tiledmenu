import QtQuick 2.0

Repeater {
	id: repeater
	property int maxHeight: 1000000
	property int numAvailable: maxHeight / config.flatButtonSize
	property int minVisibleIndex: count - numAvailable // Hide items with an index smaller than this

	delegate: SidebarItem {
		icon: symbolicIconName || model.iconName || model.decoration
		text: xdgDisplayName || model.name || model.display
		sidebarMenu: repeater.parent.parent // SidebarContextMenu { Column { Repeater{} } }
		onClicked: {
			repeater.parent.parent.open = false // SidebarContextMenu { Column { Repeater{} } }
			var xdgFolder = isLocalizedFolder()
			if (xdgFolder === 'DOCUMENTS') {
				executable.exec('xdg-open $(xdg-user-dir DOCUMENTS)')
			} else if (xdgFolder === 'DOWNLOAD') {
				executable.exec('xdg-open $(xdg-user-dir DOWNLOAD)')
			} else if (xdgFolder === 'MUSIC') {
				executable.exec('xdg-open $(xdg-user-dir MUSIC)')
			} else if (xdgFolder === 'PICTURES') {
				executable.exec('xdg-open $(xdg-user-dir PICTURES)')
			} else if (xdgFolder === 'VIDEOS') {
				executable.exec('xdg-open $(xdg-user-dir VIDEOS)')
			} else {
				repeater.model.triggerIndex(index)
			}
		}
		visible: index >= minVisibleIndex

		// These files are localize, so open them via commandline
		// since Qt 5.7 doesn't expose the localized paths anywhere.
		function isLocalizedFolder() {
			var s = model.url.toString()
			if (startsWith(s, 'xdg:')) {
				s = s.substring('xdg:'.length, s.length)
				if (s == 'DOCUMENTS'
				 || s == 'DOWNLOAD'
				 || s == 'MUSIC'
				 || s == 'PICTURES'
				 || s == 'VIDEOS'
				) {
					return s
				}
			}
			return ''
		}

		function startsWith(s, sub) {
			return s.indexOf(sub) === 0
		}
		function endsWith(s, sub) {
			return s.indexOf(sub) === s.length - sub.length
		}

		property string xdgDisplayName: {
			var xdgFolder = isLocalizedFolder()
			if (xdgFolder) {
				// https://translationproject.org/domain/xdg-user-dirs.html
				// https://translationproject.org/PO-files/fr/xdg-user-dirs-0.17.fr.po
				if (xdgFolder === 'DOCUMENTS') {
					return i18nd("xdg-user-dirs", "Documents")
				} else if (xdgFolder === 'DOWNLOAD') {
					return i18nd("xdg-user-dirs", "Download")
				} else if (xdgFolder === 'MUSIC') {
					return i18nd("xdg-user-dirs", "Music")
				} else if (xdgFolder === 'PICTURES') {
					return i18nd("xdg-user-dirs", "Pictures")
				} else if (xdgFolder === 'VIDEOS') {
					return i18nd("xdg-user-dirs", "Videos")
				} else {
					return ''
				}
			} else {
				return ''
			}
		}
		property string symbolicIconName: {
			if (model.url) {
				var s = model.url.toString()
				if (endsWith(s, '.desktop')) {
					if (endsWith(s, '/org.kde.dolphin.desktop')) {
						return 'folder-open-symbolic'
					} else if (endsWith(s, '/systemsettings.desktop')) {
						return 'configure'
					}
				} else if (startsWith(s, 'file:///home/')) {
					s = s.substring('file:///home/'.length, s.length)
					// console.log(model.url, s)

					var trimIndex = s.indexOf('/')
					if (trimIndex == -1) { // file:///home/username
						s = ''
					} else {
						s = s.substring(trimIndex, s.length)
					}
					// console.log(model.url, s)

					if (s === '') { // Home Directory
						return 'user-home-symbolic'
					}
				} else if (startsWith(s, 'xdg:')) {
					s = s.substring('xdg:'.length, s.length)
					if (s === 'DOCUMENTS') {
						return 'folder-documents-symbolic'
					} else if (s === 'DOWNLOAD') {
						return 'folder-download-symbolic'
					} else if (s === 'MUSIC') {
						return 'folder-music-symbolic'
					} else if (s === 'PICTURES') {
						return 'folder-pictures-symbolic'
					} else if (s === 'VIDEOS') {
						return 'folder-videos-symbolic'
					}
				}
			}
			return ""
		}
	}
}
