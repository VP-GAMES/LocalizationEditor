# Translations UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends Panel

var _data: LocalizationData

onready var _translations_ui = $Scroll/Translations

const LocalizationTranslationsList = preload("res://addons/localization_editor/scenes/translations/LocalizationTranslationsList.tscn")

func set_data(data: LocalizationData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("data_changed", self, "_update_view"):
		_data.connect("data_changed", self, "_update_view")

func _update_view() -> void:
	_clear_ui_translations()
	_add_ui_translations()
	_view_ui_translations()
	_update_ui_translations()

func _clear_ui_translations() -> void:
	var translations_ui = _translations_ui.get_children()
	for translation_ui in translations_ui:
		if translation_ui.has_method("get_locale"):
			var locale = translation_ui.get_locale()
			if not _data.find_locale(locale):
				translations_ui.erase(translation_ui)
				translation_ui.queue_free()

func _add_ui_translations() -> void:
	var locales = _data.locales()
	for locale in locales:
		if not _ui_translation_exists(locale):
			_add_ui_translation(locale)

func _ui_translation_exists(locale) -> bool:
	for translation_ui in _translations_ui.get_children():
		if translation_ui.has_method("get_locale"):
			if translation_ui.get_locale() == locale:
				return true
	return false

func _add_ui_translation(locale: String) -> void:
	var ui_translation = LocalizationTranslationsList.instance()
	_translations_ui.add_child(ui_translation)
	ui_translation.set_data(locale, _data)

func _view_ui_translations() -> void:
	for translation_ui in _translations_ui.get_children():
		if translation_ui.has_method("get_locale"):
			var locale = translation_ui.get_locale()
			var serarator_ui = _separator_after_translation_ui(translation_ui)
			if _data.is_locale_visible(locale):
				translation_ui.show()
				if serarator_ui != null:
					serarator_ui.show()
			else:
				translation_ui.hide()
				if serarator_ui != null:
					serarator_ui.hide()

func _separator_after_translation_ui(translation_ui: Node) -> Node:
	var index = translation_ui.get_index()
	var count = _translations_ui.get_child_count()
	if index + 1 < count:
		return _translations_ui.get_child(index + 1)
	return null

func _update_ui_translations() -> void:
	for translation_ui in _translations_ui.get_children():
		if translation_ui.has_method("update_view"):
			translation_ui.update_view()
