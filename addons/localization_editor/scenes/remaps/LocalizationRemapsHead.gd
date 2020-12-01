# Head UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends VBoxContainer

var _type: String
var _filter: String = ""
var _data: LocalizationData

onready var _title_ui = $TitleMargin/HBox/Title
onready var _filter_ui = $FilterMargin/HBox/Filter

func set_data(type: String, data: LocalizationData):
	_type = type
	_data = data
	_filter = _data.data_filter_remaps_by_type(_type)
	_init_connections()
	_draw_view()

func _init_connections() -> void:
	if not _filter_ui.is_connected("text_changed", self, "_filter_changed_action"):
		_filter_ui.connect("text_changed", self, "_filter_changed_action")

func _draw_view() -> void:
	_filter_ui.text = _filter

func _filter_changed_action(filter) -> void:
	_filter = filter
	_data.data_filter_remaps_put(_type, _filter)

func set_title(text: String) -> void:
	_title_ui.text = text
