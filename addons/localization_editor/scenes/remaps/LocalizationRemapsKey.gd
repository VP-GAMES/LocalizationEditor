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

func _ready() -> void:
	_init_connections()

func _init_connections() -> void:
	_add_ui.connect("pressed", self, "_on_add_pressed")
	_del_ui.connect("pressed", self, "_on_del_pressed")

func _on_add_pressed() -> void:
	_data._add_remapkey_new_after_uuid_remap(_key.uuid)

func _on_del_pressed() -> void:
	_data.del_remapkey(_key.uuid)
