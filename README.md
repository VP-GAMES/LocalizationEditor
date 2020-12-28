# LocalizationEditor

This is a Godot Editor plugin to manage localization data. The plugin allows you to quickly and easily edit translations in csv format. You can also auto translate your text (build in Google Translator) Remaps are also supported. Resources are assigned very easily using drag and drop. The assigned resources can be viewed in preview window, to check them. Inputs are also checked for errors. The wrong entries are highlighted in color.

Version: 1.2.1
 - Add mp3 as supported audio format(Godot 3.2.4 release) 

The following validations are supported:
* Empty entries
* Missing resources in the specified path
* Incorrect resource type assignments
* Same resources in different languages

The following screenshots show the working areas of the plugin:

### Videos
EN Localization Editor
[![EN Localization Editor](https://raw.githubusercontent.com/VP-GAMES/LocalizationEditor/main/.github/images/translations.png)](https://www.youtube.com/watch?v=ZrxLvK2Dy3g&list=PL41Y0dlU24xct5rE9Be4kchW1vbWM4M4y)

RU Localization Editor
[![RU Localization Editor](https://raw.githubusercontent.com/VP-GAMES/LocalizationEditor/main/.github/images/translations.png)](https://www.youtube.com/watch?v=DI1fUMuEBfA&list=PL41Y0dlU24xfhXFpZ7WW054A12HWsDwq_)

DE Localization Editor
[![DE Localization Editor](https://raw.githubusercontent.com/VP-GAMES/LocalizationEditor/main/.github/images/translations.png)](https://www.youtube.com/watch?v=rmIwVXbXGMM&list=PL41Y0dlU24xfvGHwOUErtHCHMUHzChFOQ)

### Images
Select locales
![Locales editor](https://raw.githubusercontent.com/VP-GAMES/LocalizationEditor/main/.github/images/locales.png)

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
