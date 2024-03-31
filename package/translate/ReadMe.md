# Translate

## Status

|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |     117 |       |
| de       | 110/117 |   94% |
| es       | 113/117 |   96% |
| fa       | 117/117 |  100% |
| fi       | 113/117 |   96% |
| fr       | 116/117 |   99% |
| he       | 116/117 |   99% |
| hr       |  91/117 |   77% |
| id       |  99/117 |   84% |
| ja       | 117/117 |  100% |
| ko       | 114/117 |   97% |
| nl       | 117/117 |  100% |
| pl       | 101/117 |   86% |
| pt       |  96/117 |   82% |
| pt_BR    | 112/117 |   95% |
| ro       | 101/117 |   86% |
| ru       | 113/117 |   96% |
| sl       | 112/117 |   95% |
| tr       | 112/117 |   95% |
| zh_CN    |  88/117 |   75% |
| zh_TW    | 117/117 |  100% |


## New Translations

* Fill out [`template.pot`](template.pot) with your translations then open a [new issue](https://github.com/Zren/plasma-applet-tiledmenu/issues/new), name the file `spanish.txt`, attach the txt file to the issue (drag and drop).

Or if you know how to make a pull request

* Copy the `template.pot` file and name it your locale's code (Eg: `en`/`de`/`fr`) with the extension `.po`. Then fill out all the `msgstr ""`.
* Your region's locale code can be found at: https://stackoverflow.com/questions/3191664/list-of-all-locales-and-their-short-codes/28357857#28357857

## Scripts

Zren's `kpac` script can easily run the `gettext` commands for you, parsing the `metadata.json` and filling out any placeholders for you. `kpac` can be [downloaded here](https://github.com/Zren/plasma-applet-lib/blob/master/kpac) and should be placed at `~/Code/plasmoid-widgetname/kpac` to edit translations at `~/Code/plasmoid-widgetname/package/translate/`.


* `python3 ./kpac i18n` will parse the `i18n()` calls in the `*.qml` files and write it to the `template.pot` file. Then it will merge any changes into the `*.po` language files. Then it converts the `*.po` files to it's binary `*.mo` version and move it to `contents/locale/...` which will bundle the translations in the `*.plasmoid` without needing the user to manually install them.
* `python3 ./kpac localetest` will convert the `.po` to the `*.mo` files then run `plasmoidviewer` (part of `plasma-sdk`).

## How it works

Since KDE Frameworks v5.37, translations can be bundled with the zipped `*.plasmoid` file downloaded from the store.

* `xgettext` extracts the messages from the source code into a `template.pot`.
* Translators copy the `template.pot` to `fr.po` to translate the French language.
* When the source code is updated, we use `msgmerge` to update the `fr.po` based on the updated `template.pot`.
* When testing or releasing the widget, we convert the `.po` files to their binary `.mo` form with `msgfmt`.

The binary `.mo` translation files are placed in `package/contents/locale/` so you may want to add `*.mo` to your `.gitignore`.

```
package/contents/locale/fr/LC_MESSAGES/plasma_applet_com.github.zren.tiledmenu.mo
```

## Links

* https://develop.kde.org/docs/plasma/widget/translations-i18n/
* https://l10n.kde.org/stats/gui/trunk-kf5/team/fr/plasma-desktop/
* https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems
* https://api.kde.org/frameworks/ki18n/html/prg_guide.html

> Version 8 of [Zren's i18n scripts](https://github.com/Zren/plasma-applet-lib).
