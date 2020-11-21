extends Node

var _path = "res://localizations.tres"

func _ready() -> void:
	var data = _load_data()
	for translation in data.get_translations():
		TranslationServer.add_translation(translation)
		TranslationServer.set_locale("en")

func _load_data() -> LocalizationData:
	var data = LocalizationData.new()
	var file = File.new()
	if file.file_exists(_path):
		var res = load(_path)
		if res != null:
			data.data = res.data
	return data 
