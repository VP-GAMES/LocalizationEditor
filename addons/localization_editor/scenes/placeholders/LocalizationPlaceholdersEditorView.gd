# Placeholders view for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends VBoxContainer

var _data: LocalizationData
var _split_viewport_size = 0
var _scroll_position = 0

onready var _split_ui = $Split
onready var _keys_ui = $Split/Keys
onready var _placeholders_ui = $Split/Placeholders
onready var _placeholders_list_ui = $Split/Placeholders/Scroll/Placeholders

func set_data(data: LocalizationData) -> void:
	_data = data
	_keys_ui.set_data(data)
	_placeholders_ui.set_data(data)
	_init_connections()

func _init_connections() -> void:
	if not _split_ui.is_connected("dragged", self, "_on_split_dragged"):
		_split_ui.connect("dragged", self, "_on_split_dragged")

func _process(delta):
	if _split_viewport_size != rect_size.x:
		_split_viewport_size = rect_size.x
		_init_split_offset()
	_update_scrolls()

func _init_split_offset() -> void:
	var offset = 350
	if _data:
		offset = _data.setting_placeholders_split_offset()
	_split_ui.set_split_offset(-rect_size.x / 2 + offset)

func _on_split_dragged(offset: int) -> void:
	if _data != null:
		var value = -(-rect_size.x / 2 - offset)
		_data.setting_placeholders_split_offset_put(value)

# Workaround for https://github.com/godotengine/godot/issues/22936
func _update_scrolls() -> void:
	var sc = _new_scrolls_position()
	if _scroll_position != sc:
		_scroll_position = sc
		_keys_ui.set_v_scroll(_scroll_position)
		for child in _placeholders_list_ui.get_children():
			if child.has_method("set_v_scroll"):
				child.set_v_scroll(_scroll_position)

func _new_scrolls_position() -> int:
	if _keys_ui == null:
		return 0
	var v_1 = [_keys_ui.get_v_scroll()] 
	var v_2 = []
	for child in _placeholders_list_ui.get_children():
		if child.has_method("get_v_scroll"):
			var v_child = child.get_v_scroll()
			if v_1[0] == v_child:
				v_1.append(v_child)
			else:
				v_2.append(v_child)
	if v_2.size() == 0:
		return v_1[0]
	if v_1.size() == 1:
		return v_1[0]
	return v_2[0]
