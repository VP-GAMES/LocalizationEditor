# Locales view for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends VBoxContainer

onready var _filter_ui = $Filter
onready var _locales_ui = $Locales

func set_data(data: LocalizationData) -> void:
	_filter_ui.set_data(data)
	_locales_ui.set_data(data)
