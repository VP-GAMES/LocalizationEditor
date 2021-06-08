# Translations key UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _key
var _data: LocalizationData

onready var _key_ui = $HBoxContainer/Key as LineEdit

func key():
	return _key

func set_data(key, data: LocalizationData):
	_key = key
	_data = data
	_draw_view()

func _draw_view() -> void:
	_key_ui.text = _key
