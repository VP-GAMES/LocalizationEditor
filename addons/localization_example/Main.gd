extends CanvasLayer

onready var _locales = TranslationServer.get_loaded_locales()

func _ready() -> void:
	init_scene()
	init_connections()
	init_languages()

func init_scene() -> void:
	$Main.visible = true
	$Languages.visible = false

func init_connections() -> void:
	var resultLanguages = $Main/ButtonLanguages.connect("pressed", self, "_on_languages_pressed")
	if resultLanguages != OK:
		push_error("Can't connect languages button")
	var resultQuit = $Main/ButtonQuit.connect("pressed", self, "_on_quit_pressed")
	if resultQuit != OK:
		push_error("Can't connect quit button")
	var resultLang = $Languages/OptionButtonLang.connect("item_selected", self, "_on_language_item_selected")
	var resultPlayAudio = $Main/ButtonPlaySound.connect("pressed", self, "_on_play_audio_pressed")
	if resultPlayAudio != OK:
		push_error("Can't connect play audio button")
	var resultPlayVideo = $Main/ButtonPlayVideo.connect("pressed", self, "_on_play_video_pressed")
	if resultPlayAudio != OK:
		push_error("Can't connect play audio button")
	if resultLang != OK:
		push_error("Can't connect lang option button")
	var resultBack = $Languages/ButtonBack.connect("pressed", self, "_on_back_pressed")
	if resultBack != OK:
		push_error("Can't connect back button")
	
func _on_languages_pressed() -> void:
	$Main.visible = false
	$Languages.visible = true

func _on_play_audio_pressed() -> void:
	$Main/Audio.play()

func _on_play_video_pressed() -> void:
	$Main/Video.play()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_language_item_selected(id: int) -> void:
	TranslationServer.set_locale(_locales[id])

func _on_back_pressed() -> void:
	$Main.visible = true
	$Languages.visible = false

func init_languages() -> void:
	var index: = -1
	for i in range(_locales.size()):
		$Languages/OptionButtonLang.add_item(TranslationServer.get_locale_name(_locales[i]))
		if _locales[i] == TranslationServer.get_locale():
			index = i
	$Languages/OptionButtonLang.select(index)
