# RemapsList UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _locale: String
var _data: LocalizationData

onready var _separator_ui = $Separator
onready var _head_ui = $VBox/Head
onready var _scroll_ui = $VBox/Scroll
onready var _remaps_ui = $VBox/Scroll/RemapsList

const Locales = preload("res://addons/localization_editor/model/LocalizationLocalesList.gd")
const LocalizationRemap = preload("res://addons/localization_editor/scenes/remaps/LocalizationRemap.tscn")

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
	_add_remaps()

func _add_remaps() -> void:
	_clear_remaps()
	for key in _data.remapkeys_filtered():
		for remap in key.remaps:
			if remap.locale == _locale:
				_add_remap(key, remap)

func _clear_remaps() -> void:
	for remap_ui in _remaps_ui.get_children():
		_remaps_ui.remove_child(remap_ui)
		remap_ui.queue_free()

func _add_remap(key, remap) -> void:
	var remap_ui = LocalizationRemap.instance()
	_remaps_ui.add_child(remap_ui)
	remap_ui.set_data(key, remap, _data)
