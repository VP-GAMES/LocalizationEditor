# Translations keys UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends Panel

var _data: LocalizationData

onready var _head_ui = $VBox/Head
onready var _scroll_ui = $VBox/Scroll
onready var _keys_ui = $VBox/Scroll/Keys

const LocalizationKey = preload("res://addons/localization_editor/scenes/translations/LocalizationTranslationsKey.tscn")

func get_v_scroll() -> int:
	return _scroll_ui.get_v_scroll()

func set_v_scroll(value: int) -> void:
	_scroll_ui.set_v_scroll(value)

func set_data(data: LocalizationData) -> void:
	_data = data
	_head_ui.set_data("keys", _data)
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("data_changed", self, "_update_view"):
		_data.connect("data_changed", self, "_update_view")

func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for key_ui in _keys_ui.get_children():
		_keys_ui.remove_child(key_ui)
		key_ui.queue_free()

func _draw_view() -> void:
	for key in _data.keys_filtered():
		_draw_key(key)

func _draw_key(key) -> void:
	var key_ui = LocalizationKey.instance()
	_keys_ui.add_child(key_ui)
	key_ui.set_data(key, _data)
