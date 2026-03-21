import QtQuick 6.5
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents4

PlasmaComponents4.TextField {
    id: searchField

    placeholderText: {
        if (search.isDefaultFilter) {
            return i18n("Search")
        } else if (search.isAppsFilter) {
            return i18n("Search Apps")
        } else if (search.isFileFilter) {
            return i18n("Search Files")
        } else if (search.isBookmarksFilter) {
            return i18n("Search Bookmarks")
        } else {
            // I think this line looks horrendous, so I'll just write a non-specific "Search"
            //return i18nc("Search [krunnerName, krunnerName, ...], ", "Search %1", search.filters.toString())
            return i18n("Search")
        }
    }

    // Layout and font handling
    property int topMargin: Kirigami.Units.smallSpacing
    property int bottomMargin: Kirigami.Units.smallSpacing
    property int defaultFontSize: 16 * config.scaleFactor
    property int styleMaxFontSize: height - topMargin - bottomMargin
    font.pixelSize: Math.min(defaultFontSize, styleMaxFontSize)

    // Plasma 6 automatically adapts to theme, no manual style needed
    // but you can still tint or theme dynamically if you want
    background: Rectangle {
        color: plasmoid.configuration.searchFieldFollowsTheme
        ? Kirigami.Theme.backgroundColor
        : "#ffffff"
        radius: Kirigami.Units.smallSpacing
        border.color: color   // same as background
        border.width: 1       // optional
        opacity: 0.9
    }

    color: plasmoid.configuration.searchFieldFollowsTheme
        ? Kirigami.Theme.textColor
        : "#111111"
    placeholderTextColor: plasmoid.configuration.searchFieldFollowsTheme
        ? Kirigami.Theme.disabledTextColor
        : "#777777"

    // Sync query text
    onTextChanged: search.query = text

    Connections {
        target: search
        function onQueryChanged() {
            searchField.text = search.query
        }
    }

    property var listView: searchResultsView.listView

    Keys.onPressed: (event) => {
        switch (event.key) {
        case Qt.Key_Up:
            event.accepted = true; listView.goUp(); break;
        case Qt.Key_Down:
            event.accepted = true; listView.goDown(); break;
        case Qt.Key_PageUp:
            event.accepted = true; listView.pageUp(); break;
        case Qt.Key_PageDown:
            event.accepted = true; listView.pageDown(); break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            event.accepted = true; listView.currentItem.trigger(); break;
        case Qt.Key_R:
            if (event.modifiers & Qt.MetaModifier) {
                event.accepted = true; search.filters = ['shell'];
            }
            break;
        case Qt.Key_Escape:
            plasmoid.expanded = false;
            break;
        }
    }

    Component.onCompleted: forceActiveFocus()
}
