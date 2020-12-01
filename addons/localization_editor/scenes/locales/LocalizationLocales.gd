# Locales UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _data: LocalizationData

onready var _locales_ui = $Panel/Scroll/VBox as VBoxContainer

const Locales = preload("res://addons/localization_editor/model/LocalizationLocalesList.gd")
const LocalizationLocale = preload("res://addons/localization_editor/scenes/locales/LocalizationLocale.tscn")

func set_data(data: LocalizationData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("data_changed", self, "_update_view"):
		_data.connect("data_changed", self, "_update_view")

func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for child in _locales_ui.get_children():
		_locales_ui.remove_child(child)
		child.queue_free()

func _draw_view() -> void:
	for locale in Locales.LOCALES:
		if _is_locale_to_show(locale):
			var locale_ui = LocalizationLocale.instance()
			_locales_ui.add_child(locale_ui)
			locale_ui.set_data(locale, _data)

func _is_locale_to_show(locale) -> bool:
	if not _is_locale_to_show_by_selection(locale):
		return false
	return _is_locale_to_show_by_filter(locale)
	
func _is_locale_to_show_by_selection(locale) -> bool:
	return !_data.locales_selected() or _data.find_locale(locale.code) != null
		
func  _is_locale_to_show_by_filter(locale) -> bool:
	var filter = _data.locales_filter()
	return filter == "" or filter in locale.code or filter in locale.name
