# LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends Control

var _editor: EditorPlugin
var _data:= LocalizationData.new()

onready var _save_ui = $VBox/Margin/HBox/Save
onready var _open_ui = $VBox/Margin/HBox/Open
onready var _file_ui = $VBox/Margin/HBox/File
onready var _locales_ui = $VBox/Tabs/Locales
onready var _remaps_ui = $VBox/Tabs/Remaps
onready var _translations_ui = $VBox/Tabs/Translations

const LocalizationEditorDialogFile = preload("res://addons/localization_editor/LocalizationEditorDialogFile.tscn")

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()
	_load_data()
	_data.set_editor(editor)
	_data_to_childs()
	_update_view()

func _init_connections() -> void:
	_data.connect("settings_changed", self, "_update_view")
	_save_ui.connect("pressed", self, "save_data")
	_open_ui.connect("pressed", self, "_open_file")

func _load_data() -> void:
	_data.init_data_translations()
	_data.init_data_remaps()

func _data_to_childs() -> void:
	_translations_ui.set_data(_data)
	_remaps_ui.set_data(_data)
	_locales_ui.set_data(_data)

func _update_view() -> void:
	_file_ui.text = _data.setting_path_to_file()

func save_data() -> void:
	_data.save_data_translations()
	_data.save_data_remaps()

func _open_file() -> void:
	var file_dialog = LocalizationEditorDialogFile.instance()
	var root = get_tree().get_root()
	root.add_child(file_dialog)
	file_dialog.connect("file_selected", self, "_path_to_file_changed")
	file_dialog.connect("popup_hide", self, "_on_popup_hide", [root, file_dialog])
	file_dialog.popup_centered()

func _on_popup_hide(root, dialog) -> void:
	root.remove_child(dialog)
	dialog.queue_free()

func _path_to_file_changed(new_path) -> void:
	_data.setting_path_to_file_put(new_path)
	var file = File.new()
	if file.file_exists(new_path):
		_load_data()
		_data_to_childs()
		_update_view()
