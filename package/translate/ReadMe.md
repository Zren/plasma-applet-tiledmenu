> Version 7 of Zren's i18n scripts.

With KDE Frameworks v5.37 and above, translations are bundled with the `*.plasmoid` file downloaded from the store.

## Install Translations

Go to `~/.local/share/plasma/plasmoids/com.github.zren.tiledmenu/translate/` and run `sh ./build --restartplasma`.

## New Translations

1. Fill out [`template.pot`](template.pot) with your translations then open a [new issue](https://github.com/Zren/plasma-applet-tiledmenu/issues/new), name the file `spanish.txt`, attach the txt file to the issue (drag and drop).

Or if you know how to make a pull request

1. Copy the `template.pot` file and name it your locale's code (Eg: `en`/`de`/`fr`) with the extension `.po`. Then fill out all the `msgstr ""`.

## Scripts

* `sh ./merge` will parse the `i18n()` calls in the `*.qml` files and write it to the `template.pot` file. Then it will merge any changes into the `*.po` language files.
* `sh ./build` will convert the `*.po` files to it's binary `*.mo` version and move it to `contents/locale/...` which will bundle the translations in the `*.plasmoid` without needing the user to manually install them.
* `sh ./plasmoidlocaletest` will run `./build` then `plasmoidviewer` (part of `plasma-sdk`).

## Links

* https://zren.github.io/kde/docs/widget/#translations-i18n
* https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems
* https://api.kde.org/frameworks/ki18n/html/prg_guide.html

## Examples

* https://l10n.kde.org/stats/gui/trunk-kf5/team/fr/plasma-desktop/
* https://github.com/psifidotos/nowdock-plasmoid/tree/master/po
* https://github.com/kotelnik/plasma-applet-redshift-control/tree/master/translations

## Status
|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |     117 |       |
| de       | 110/117 |   94% |
| es       | 113/117 |   96% |
| fi       | 113/117 |   96% |
| fr       | 116/117 |   99% |
| he       | 116/117 |   99% |
| hr       |  91/117 |   77% |
| id       |  99/117 |   84% |
| ja       | 104/117 |   88% |
| ko       | 114/117 |   97% |
| nl       | 117/117 |  100% |
| pl       | 101/117 |   86% |
| pt_BR    | 112/117 |   95% |
| pt       |  96/117 |   82% |
| ro       | 101/117 |   86% |
| ru       | 113/117 |   96% |
| sl       | 112/117 |   95% |
| tr       | 112/117 |   95% |
| zh_CN    |  88/117 |   75% |
