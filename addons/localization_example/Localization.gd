# LocalizationEditor example of Translations usage: MIT License
# @author Vladimir Petrenko
extends CanvasLayer

onready var _main_ui = $Main
onready var _languages_ui = $Languages
onready var _button_languages_ui = $Main/ButtonLanguages
onready var _button_quit_ui = $Main/ButtonQuit
onready var _button_optins_lang_ui = $Languages/OptionButtonLang
onready var _button_play_sound_ui = $Main/ButtonPlaySound
onready var _button_play_video_ui = $Main/ButtonPlayVideo
onready var _button_back_ui = $Languages/ButtonBack
onready var _audio_ui = $Main/Audio
onready var _video_ui = $Main/Video

onready var _locales = TranslationServer.get_loaded_locales()

func _ready() -> void:
	init_scene()
	init_connections()
	init_languages()

func init_scene() -> void:
	_main_ui.visible = true
	_languages_ui.visible = false

func init_connections() -> void:
	var resultLanguages = _button_languages_ui.connect("pressed", self, "_on_languages_pressed")
	if resultLanguages != OK:
		push_error("Can't connect languages button")
	var resultQuit = _button_quit_ui.connect("pressed", self, "_on_quit_pressed")
	if resultQuit != OK:
		push_error("Can't connect quit button")
	var resultLang = _button_optins_lang_ui.connect("item_selected", self, "_on_language_item_selected")
	if resultLang != OK:
		push_error("Can't connect lang option button")
	var resultPlayAudio = _button_play_sound_ui.connect("pressed", self, "_on_play_audio_pressed")
	if resultPlayAudio != OK:
		push_error("Can't connect play audio button")
	var resultPlayVideo = _button_play_video_ui.connect("pressed", self, "_on_play_video_pressed")
	if resultPlayVideo != OK:
		push_error("Can't connect play audio button")
	var resultBack = _button_back_ui.connect("pressed", self, "_on_back_pressed")
	if resultBack != OK:
		push_error("Can't connect back button")

func _on_languages_pressed() -> void:
	_main_ui.visible = false
	_languages_ui.visible = true

func _on_play_audio_pressed() -> void:
	_audio_ui.play()

func _on_play_video_pressed() -> void:
	_video_ui.play()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_language_item_selected(id: int) -> void:
	TranslationServer.set_locale(_locales[id])

func _on_back_pressed() -> void:
	_main_ui.visible = true
	_languages_ui.visible = false

func init_languages() -> void:
	var index: = -1
	for i in range(_locales.size()):
		_button_optins_lang_ui.add_item(TranslationServer.get_locale_name(_locales[i]))
		if _locales[i] in TranslationServer.get_locale():
			index = i
	_button_optins_lang_ui.select(index)
