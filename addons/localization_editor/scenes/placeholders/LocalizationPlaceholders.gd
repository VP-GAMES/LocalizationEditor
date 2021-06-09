# Placeholders UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends Panel

var _data: LocalizationData

onready var _placeholders_ui = $Scroll/Placeholders

const LocalizationTranslationsList = preload("res://addons/localization_editor/scenes/placeholders/LocalizationPlaceholdersList.tscn")

func set_data(data: LocalizationData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("data_changed", self, "_update_view"):
		_data.connect("data_changed", self, "_update_view")

func _update_view() -> void:
	_clear_ui_placeholders()
	_add_ui_placeholders()
	_view_ui_placeholders()
	_update_ui_placeholders()

func _clear_ui_placeholders() -> void:
	var placeholders_ui = _placeholders_ui.get_children()
	for placeholder_ui in placeholders_ui:
		if placeholder_ui.has_method("get_locale"):
			var locale = placeholder_ui.get_locale()
			if not _data.find_locale(locale):
				placeholders_ui.erase(placeholder_ui)
				placeholder_ui.queue_free()

func _add_ui_placeholders() -> void:
	var locales = _data.locales()
	for locale in locales:
		if not _ui_placeholder_exists(locale):
			_add_ui_placeholder(locale)

func _ui_placeholder_exists(locale) -> bool:
	for placeholder_ui in _placeholders_ui.get_children():
		if placeholder_ui.has_method("get_locale"):
			if placeholder_ui.get_locale() == locale:
				return true
	return false

func _add_ui_placeholder(locale: String) -> void:
	var ui_placeholder = LocalizationTranslationsList.instance()
	_placeholders_ui.add_child(ui_placeholder)
	ui_placeholder.set_data(locale, _data)

func _view_ui_placeholders() -> void:
	for placeholder_ui in _placeholders_ui.get_children():
		if placeholder_ui.has_method("get_locale"):
			var locale = placeholder_ui.get_locale()
			var serarator_ui = _separator_after_placeholder_ui(placeholder_ui)
			if _data.is_locale_visible(locale):
				placeholder_ui.show()
				if serarator_ui != null:
					serarator_ui.show()
			else:
				placeholder_ui.hide()
				if serarator_ui != null:
					serarator_ui.hide()

func _separator_after_placeholder_ui(placeholder_ui: Node) -> Node:
	var index = placeholder_ui.get_index()
	var count = _placeholders_ui.get_child_count()
	if index + 1 < count:
		return _placeholders_ui.get_child(index + 1)
	return null

func _update_ui_placeholders() -> void:
	for placeholder_ui in _placeholders_ui.get_children():
		if placeholder_ui.has_method("update_view"):
			placeholder_ui.update_view()
