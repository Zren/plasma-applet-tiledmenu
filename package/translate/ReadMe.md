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
| Template |     121 |       |
| de       | 112/121 |   92% |
| es       | 113/121 |   93% |
| fi       | 113/121 |   93% |
| fr       | 118/121 |   97% |
| he       | 116/121 |   95% |
| hr       |  91/121 |   75% |
| id       |  99/121 |   81% |
| ja       | 117/121 |   96% |
| ko       | 114/121 |   94% |
| nl       | 117/121 |   96% |
| pl       | 101/121 |   83% |
| pt_BR    | 112/121 |   92% |
| pt       |  96/121 |   79% |
| ro       | 101/121 |   83% |
| ru       | 113/121 |   93% |
| sl       | 112/121 |   92% |
| tr       | 112/121 |   92% |
| zh_CN    |  88/121 |   72% |
| zh_TW    | 117/121 |   96% |
