# Remaps key UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _key
var _data: LocalizationData

onready var _add_ui = $HBoxContainer/Add
onready var _del_ui = $HBoxContainer/Del

func set_data(key, data: LocalizationData):
	_key = key
	_data = data
	_draw_view()

func _ready() -> void:
	_init_connections()

func _init_connections() -> void:
	if not _add_ui.is_connected("pressed", self, "_on_add_pressed"):
		_add_ui.connect("pressed", self, "_on_add_pressed")
	if not _del_ui.is_connected("pressed", self, "_on_del_pressed"):
		_del_ui.connect("pressed", self, "_on_del_pressed")

func _draw_view() -> void:
	_del_ui.disabled = _data.remaps().size() == 1

func _on_add_pressed() -> void:
	_data._add_remapkey_new_after_uuid_remap(_key.uuid)

func _on_del_pressed() -> void:
	_data.del_remapkey(_key.uuid)
