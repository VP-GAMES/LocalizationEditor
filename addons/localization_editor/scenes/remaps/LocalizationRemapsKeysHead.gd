# Remaps head keys UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _type: String = "remapkeys"
var _filter: String = ""
var _data: LocalizationData

onready var _music_ui = $VBox/HBoxTop/Music
onready var _image_ui = $VBox/HBoxTop/Image
onready var _video_ui = $VBox/HBoxBottom/Video
onready var _reset_ui = $VBox/HBoxBottom/Reset

func set_data(data: LocalizationData):
	_data = data
	_filter = _data.data_filter_remaps_by_type(_type)
	_init_connections()

func _init_connections() -> void:
	if not _music_ui.is_connected("button_up", self, "_filter_changed_action"):
		_music_ui.connect("button_up", self, "_filter_changed_action")
	if not _image_ui.is_connected("button_up", self, "_filter_changed_action"):
		_image_ui.connect("button_up", self, "_filter_changed_action")
	if not _video_ui.is_connected("button_up", self, "_filter_changed_action"):
		_video_ui.connect("button_up", self, "_filter_changed_action")
	if not _reset_ui.is_connected("button_up", self, "_filter_reset_action"):
		_reset_ui.connect("button_up", self, "_filter_reset_action")

func _filter_changed_action() -> void:
	var new_filter = ""
	if _music_ui.is_pressed():
		new_filter = new_filter + "audio"
	if _image_ui.is_pressed():
		new_filter = new_filter + ",image"
	if _video_ui.is_pressed():
		new_filter = new_filter + ",video"
	_filter = new_filter
	_data.data_filter_remaps_put(_type, _filter)

func _filter_reset_action() -> void:
	_music_ui.set_pressed(false)
	_image_ui.set_pressed(false)
	_video_ui.set_pressed(false)
	_filter = ""
	_data.data_filter_remaps_put(_type, _filter)
