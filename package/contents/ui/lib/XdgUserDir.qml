// Version 1

import QtQml
import QtCore as QtCore

QtObject {
	id: xdgUserDir
	readonly property url home: QtCore.StandardPaths.writableLocation(QtCore.StandardPaths.HomeLocation)
	readonly property url desktop: QtCore.StandardPaths.writableLocation(QtCore.StandardPaths.DesktopLocation)
	readonly property url documents: QtCore.StandardPaths.writableLocation(QtCore.StandardPaths.DocumentsLocation)
	readonly property url download: QtCore.StandardPaths.writableLocation(QtCore.StandardPaths.DownloadLocation)
	readonly property url music: QtCore.StandardPaths.writableLocation(QtCore.StandardPaths.MusicLocation)
	readonly property url pictures: QtCore.StandardPaths.writableLocation(QtCore.StandardPaths.PicturesLocation)
	readonly property url videos: QtCore.StandardPaths.writableLocation(QtCore.StandardPaths.MoviesLocation)
}
