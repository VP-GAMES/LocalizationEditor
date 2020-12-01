# Remaps UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends Panel

var _data: LocalizationData

onready var _remaps_ui = $Scroll/Remaps

const LocalizationRemapsList = preload("res://addons/localization_editor/scenes/remaps/LocalizationRemapsList.tscn")

func set_data(data: LocalizationData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("data_changed", self, "_update_view"):
		_data.connect("data_changed", self, "_update_view")

func _update_view() -> void:
	_clear_ui_remaps()
	_add_ui_remaps()
	_view_ui_remaps()
	_update_ui_remaps()

func _clear_ui_remaps() -> void:
	var remaps_ui = _remaps_ui.get_children()
	for remap_ui in remaps_ui:
		if remap_ui.has_method("get_locale"):
			var locale = remap_ui.get_locale()
			if not _data.find_locale(locale):
				remaps_ui.erase(remap_ui)
				remap_ui.queue_free()

func _add_ui_remaps() -> void:
	var locales = _data.locales()
	for locale in locales:
		if not _ui_remap_exists(locale):
			_add_ui_remap(locale)

func _ui_remap_exists(locale) -> bool:
	for remap_ui in _remaps_ui.get_children():
		if remap_ui.has_method("get_locale"):
			if remap_ui.get_locale() == locale:
				return true
	return false

func _add_ui_remap(locale: String) -> void:
	var ui_remap = LocalizationRemapsList.instance()
	_remaps_ui.add_child(ui_remap)
	ui_remap.set_data(locale, _data)

func _view_ui_remaps() -> void:
	for remap_ui in _remaps_ui.get_children():
		if remap_ui.has_method("get_locale"):
			var locale = remap_ui.get_locale()
			var serarator_ui = _separator_after_remap_ui(remap_ui)
			if _data.is_locale_visible(locale):
				remap_ui.show()
				if serarator_ui != null:
					serarator_ui.show()
			else:
				remap_ui.hide()
				if serarator_ui != null:
					serarator_ui.hide()

func _separator_after_remap_ui(remap_ui: Node) -> Node:
	var index = remap_ui.get_index()
	var count = _remaps_ui.get_child_count()
	if index + 1 < count:
		return _remaps_ui.get_child(index + 1)
	return null

func _update_ui_remaps() -> void:
	for remap_ui in _remaps_ui.get_children():
		if remap_ui.has_method("update_view"):
			remap_ui.update_view()
