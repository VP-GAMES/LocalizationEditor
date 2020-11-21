# Locales filter for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _data: LocalizationData

onready var _filter_ui = $HBox/Filter as LineEdit
onready var _selected_ui = $HBox/Selected as CheckBox

func set_data(data: LocalizationData) -> void:
	_data = data
	_init_connections()

func _init_connections() -> void:
	_filter_ui.connect("text_changed", self, "_on_filter_changed")
	_selected_ui.connect("toggled", self, "_on_selected_changed")

func _on_filter_changed(text: String) -> void:
	_data.locales_filter_put(text)

func _on_selected_changed(value) -> void:
	_data.locales_selected_put(value)
