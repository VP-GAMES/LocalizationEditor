# Drag and drop UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
# This is a workaround for https://github.com/godotengine/godot/issues/30480
tool
extends TextureRect

var _key
var _remap
var _data: LocalizationData

func set_data(key, remap, data: LocalizationData) -> void:
	_key = key
	_remap = remap
	_data = data

func can_drop_data(position, data) -> bool:
	var remap_value = data["files"][0]
	var remap_extension = _data.file_extension(remap_value)
	for extension in _data.supported_file_extensions():
		if remap_extension == extension:
			return true
	return false

func drop_data(position, data) -> void:
	var remap_value = data["files"][0]
	_remap_value_changed(remap_value)

func _remap_value_changed(remap_value) -> void:
	_data.remapkey_value_change(_remap, remap_value)
