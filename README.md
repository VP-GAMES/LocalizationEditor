# LocalizationEditor

This is a Godot Editor plugin to manage localization data. The plugin allows you to quickly and easily edit translations in csv format. You can also auto translate your text (build in Google Translator) Remaps are also supported. Resources are assigned very easily using drag and drop. The assigned resources can be viewed in preview window, to check them. Inputs are also checked for errors. The wrong entries are highlighted in color.

Version: 1.1.2
* Add Filter Dropdown for Auto Translation

Version: 1.1.1
* Editor auto refresh created files

Version: 1.1.0
* Add support for Auto Translation(Google Translator)

The following validations are supported:
* Empty entries
* Missing resources in the specified path
* Incorrect resource type assignments
* Same resources in different languages

The following screenshots show the working areas of the plugin:

Select locales
![locales selection](https://raw.githubusercontent.com/VP-GAMES/LocalizationEditor/main/.github/images/locales.png)

Edit translations
![Translations editor](https://raw.githubusercontent.com/VP-GAMES/LocalizationEditor/main/.github/images/translations.png)

Edit remaps
![Remaps editor](https://raw.githubusercontent.com/VP-GAMES/LocalizationEditor/main/.github/images/remaps.png)

Auto translation(Google Translator)
![Remaps editor](https://raw.githubusercontent.com/VP-GAMES/LocalizationEditor/main/.github/images/autotranslate.png)

How to install
-----------------

This is a regular editor plugin. Copy the contents of addons/localization_editor into the same folder in your project, and activate it in your project settings.
This plugin also contain example implementation. You find it in addons/localization_example folder.
