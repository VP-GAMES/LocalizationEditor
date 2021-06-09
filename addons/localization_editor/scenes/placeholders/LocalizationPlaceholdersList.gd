# Placeholders list UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _locale: String
var _data: LocalizationData

onready var _separator_ui = $Separator
onready var _head_ui = $VBox/Head
onready var _scroll_ui = $VBox/Scroll
onready var _placeholders_ui = $VBox/Scroll/PlaceholdersList

const Locales = preload("res://addons/localization_editor/model/LocalizationLocalesList.gd")
const LocalizationPlaceholder = preload("res://addons/localization_editor/scenes/placeholders/LocalizationPlaceholder.tscn")

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
	_add_placeholders()

func _add_placeholders() -> void:
	_clear_placeholders()
	var placeholders_filtered = _data.placeholders_filtered()
	for key in placeholders_filtered.keys():
		var placeholder = placeholders_filtered[key]
		if placeholder.has(_locale):
			_add_placeholder(key)

func _clear_placeholders() -> void:
	for placeholder_ui in _placeholders_ui.get_children():
		_placeholders_ui.remove_child(placeholder_ui)
		placeholder_ui.queue_free()

func _add_placeholder(key) -> void:
	var placeholder_ui = LocalizationPlaceholder.instance()
	_placeholders_ui.add_child(placeholder_ui)
	placeholder_ui.set_data(key, _locale, _data)


