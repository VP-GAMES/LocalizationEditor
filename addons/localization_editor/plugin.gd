# Plugin LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends EditorPlugin

const IconResource = preload("res://addons/localization_editor/icons/Localization.png")
const LocalizationMain = preload("res://addons/localization_editor/LocalizationEditor.tscn")

var _localization_main

func _enter_tree():
	_localization_main = LocalizationMain.instance()
	_localization_main.name = "LocalizationEditor"
	get_editor_interface().get_editor_viewport().add_child(_localization_main)
	_localization_main.set_editor(self)
	make_visible(false)

func _exit_tree():
	if _localization_main:
		_localization_main.queue_free()

func has_main_screen():
	return true

func make_visible(visible):
	if _localization_main:
		_localization_main.visible = visible

func get_plugin_name():
	return "Localization"

func get_plugin_icon():
	return IconResource

func save_external_data():
	if _localization_main:
		_localization_main.save_data()
