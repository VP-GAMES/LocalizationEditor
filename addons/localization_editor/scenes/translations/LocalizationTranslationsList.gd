# Translations list UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _locale: String
var _data: LocalizationData

onready var _separator_ui = $Separator
onready var _head_ui = $VBox/Head
onready var _scroll_ui = $VBox/Scroll
onready var _translations_ui = $VBox/Scroll/TranslationsList

const Locales = preload("res://addons/localization_editor/model/LocalizationLocalesList.gd")
const LocalizationTranslation = preload("res://addons/localization_editor/scenes/translations/LocalizationTranslation.tscn")
const LocalizationTranslationsDialogText = preload("res://addons/localization_editor/scenes/translations/LocalizationTranslationsDialogText.tscn")

func set_data(locale: String, data: LocalizationData) -> void:
	_locale = locale
	_data = data
	_head_ui.set_data(_locale, _data)
	update_view()

func get_locale() -> String:
	return _locale

func get_v_scroll() -> int:
	if _scroll_ui == null:
		return 0
	return _scroll_ui.get_v_scroll()

func set_v_scroll(value: int) -> void:
	_scroll_ui.set_v_scroll(value)

func update_view() -> void:
	if get_index() == 0:
		_separator_ui.hide()
	_head_ui.set_title(Locales.label_by_code(_locale))
	_add_translations()

func _add_translations() -> void:
	_clear_translations()
	for key in _data.keys_filtered():
		for translation in key.translations:
			if translation.locale == _locale:
				_add_translation(key, translation)

func _clear_translations() -> void:
	for translation_ui in _translations_ui.get_children():
		_translations_ui.remove_child(translation_ui)
		translation_ui.queue_free()

func _add_translation(key, translation) -> void:
	var translation_ui = LocalizationTranslation.instance()
	_translations_ui.add_child(translation_ui)
	translation_ui.set_data(key, translation, _locale, _data)


