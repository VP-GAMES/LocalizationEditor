# Remaps view for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _data: LocalizationData
var _split_viewport_size = 0

onready var _split_ui = $Split
onready var _keys_ui = $Split/Keys
onready var _remaps_ui = $Split/Remaps

const LocalizationRemaps = preload("res://addons/localization_editor/scenes/remaps/LocalizationRemaps.tscn")

func set_data(data: LocalizationData):
	_data = data
	_keys_ui.set_data(data)
	_remaps_ui.set_data(data)

func _process(delta):
	if _split_viewport_size != rect_size.x:
		_split_viewport_size = rect_size.x
		_init_split_offset()

func _init_split_offset() -> void:
	var offset = 70
	_split_ui.set_split_offset(-rect_size.x / 2 + offset)
