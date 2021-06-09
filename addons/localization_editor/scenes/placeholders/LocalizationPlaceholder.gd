# Placeholder UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _key
var _locale
var _data: LocalizationData

onready var _placeholder_ui = $HBox/Placeholder

const Locales = preload("res://addons/localization_editor/model/LocalizationLocalesList.gd")

func set_data(key, locale, data: LocalizationData) -> void:
	_key = key
	_locale = locale
	_data = data
	_draw_view()

func _ready() -> void:
	_init_connections()

func _init_connections() -> void:
	if not _placeholder_ui.is_connected("text_changed", self, "_on_text_changed"):
		_placeholder_ui.connect("text_changed", self, "_on_text_changed")

func _draw_view() -> void:
	_placeholder_ui.text = _data.data_placeholders[_key][_locale]
	
func _on_text_changed(new_text) -> void:
	_data.data_placeholders[_key][_locale] = new_text
