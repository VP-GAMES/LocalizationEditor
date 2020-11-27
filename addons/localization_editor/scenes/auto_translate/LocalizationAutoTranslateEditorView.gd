# Auto Translate view for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends VBoxContainer

onready var _google_ui = $Google

func set_data(data: LocalizationData) -> void:
	_google_ui.set_data(data)
