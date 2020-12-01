# Remap UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _key
var _remap
var _data: LocalizationData

onready var _put_ui = $HBox/Put
onready var _remap_ui = $HBox/Remap
onready var _audio_ui = $HBox/Audio
onready var _video_ui = $HBox/Video
onready var _image_ui = $HBox/Image

const LocalizationRemapDialogVideo = preload("res://addons/localization_editor/scenes/remaps/LocalizationRemapDialogVideo.tscn")
const LocalizationRemapDialogImage = preload("res://addons/localization_editor/scenes/remaps/LocalizationRemapDialogImage.tscn")

func set_data(key, remap, data: LocalizationData) -> void:
	_key = key
	_remap = remap
	_data = data
	_put_ui.set_data(key, remap, data)
	_remap_ui.set_data(key, remap, data)
	_init_connections()
	_draw_view()

func _init_connections() -> void:
	if not _data.is_connected("data_remapkey_value_changed", self, "_draw_view"):
		_data.connect("data_remapkey_value_changed", self, "_draw_view")
	if not _audio_ui.is_connected("pressed", self, "_on_audio_pressed"):
		_audio_ui.connect("pressed", self, "_on_audio_pressed")
	if not _video_ui.is_connected("pressed", self, "_on_video_pressed"):
		_video_ui.connect("pressed", self, "_on_video_pressed")
	if not _image_ui.is_connected("pressed", self, "_on_image_pressed"):
		_image_ui.connect("pressed", self, "_on_image_pressed")

func _draw_view() -> void:
	_check_buttons()

func _check_buttons() -> void:
	_hide_buttons()
	var type = _data.remap_type(_remap)
	match type:
		"audio":
			_audio_ui.show()
		"image":
			_image_ui.show()
		"video":
			_video_ui.show()

func _hide_buttons() -> void:
	_audio_ui.hide()
	_video_ui.hide()
	_image_ui.hide()

func _on_audio_pressed() -> void:
	var audio_player
	if get_tree().get_root().has_node("AudioPlayer"):
		audio_player = get_tree().get_root().get_node("AudioPlayer") as AudioStreamPlayer
	else:
		audio_player = AudioStreamPlayer.new()
		get_tree().get_root().add_child(audio_player)
	var audio = load(_remap.value)
	audio.set_loop(false)
	audio_player.stream = audio
	audio_player.play()

func _on_video_pressed() -> void:
	var video_dialog  = LocalizationRemapDialogVideo.instance()
	var root = get_tree().get_root()
	root.add_child(video_dialog)
	video_dialog.window_title = _data.filename(_remap.value)
	video_dialog.get_close_button().hide()
	video_dialog.connect("popup_hide", self, "_on_popup_hide", [root, video_dialog])
	var video_player = video_dialog.get_node("VideoPlayer") as VideoPlayer
	var video = load(_remap.value)
	video_player.stream = video
	video_dialog.popup_centered()
	video_player.play()

func _on_image_pressed() -> void:
	var image_dialog  = LocalizationRemapDialogImage.instance()
	var root = get_tree().get_root()
	root.add_child(image_dialog)
	image_dialog.window_title = _data.filename(_remap.value)
	image_dialog.get_close_button().hide()
	image_dialog.connect("popup_hide", self, "_on_popup_hide", [root, image_dialog])
	var texture = image_dialog.get_node("Texture") as TextureRect
	var image = load(_remap.value)
	texture.texture = image
	image_dialog.popup_centered()

func _on_popup_hide(root, dialog) -> void:
	root.remove_child(dialog)
	dialog.queue_free()
