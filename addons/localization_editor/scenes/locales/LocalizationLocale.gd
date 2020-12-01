# Locale UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _locale
var _data: LocalizationData

onready var _selection_ui = $HBox/Selection as CheckBox
onready var _locale_ui = $HBox/Locale as Label
onready var _eye_ui = $HBox/Eye as TextureButton

const IconOpen = preload("res://addons/localization_editor/icons/Open.png")
const IconClose = preload("res://addons/localization_editor/icons/Close.png")

func locale():
	return _locale

func set_data(locale, data: LocalizationData) -> void:
	_locale = locale
	_data = data
	_draw_view()
	_init_connections()

func _draw_view() -> void:
	_selection_ui.text = _locale.code
	_locale_ui.text = _locale.name
	_selection_ui_state()
	_eye_ui_state()

func _selection_ui_state() -> void:
	_selection_ui.set_pressed(_data.find_locale(_locale.code) != null)

func _eye_ui_state() -> void:
	_eye_ui.set_pressed(not _data.is_locale_visible(_locale.code))
	_update_view_eye(_selection_ui.is_pressed())

func _init_connections() -> void:
	if not _selection_ui.is_connected("toggled", self, "_on_selection_changed"):
		_selection_ui.connect("toggled", self, "_on_selection_changed")
	if not _eye_ui.is_connected("toggled", self, "_on_eye_changed"):
		_eye_ui.connect("toggled", self, "_on_eye_changed")

func _on_selection_changed(value) -> void:
	if value == true:
		_data.add_locale(_locale.code)
		_update_view_eye(value)
	else:
		_show_confirm_dialog()

func _show_confirm_dialog() -> void:
		var confirm_dialog  = ConfirmationDialog.new()
		confirm_dialog.window_title = "Confirm"
		confirm_dialog.dialog_text = "Are you sure to delete locale with all translations and remaps?"
		confirm_dialog.get_ok().connect("pressed", self, "_on_confirm_dialog_ok")
		confirm_dialog.get_cancel().connect("pressed", self, "_on_confirm_dialog_cancelled")
		var root = get_tree().get_root()
		confirm_dialog.connect("popup_hide", self, "_on_confirm_dialog_hide", [root, confirm_dialog])
		root.add_child(confirm_dialog)
		confirm_dialog.popup_centered()

func _on_confirm_dialog_ok() -> void:
	_data.del_locale(_locale.code)
	_update_view_eye(false)

func _on_confirm_dialog_cancelled() -> void:
	_selection_ui.set_pressed(true)

func _on_confirm_dialog_hide(root, confirm_dialog) -> void:
	root.remove_child(confirm_dialog)
	confirm_dialog.queue_free()

func _update_view_eye(value: bool) -> void:
	if value:
		_eye_ui.show()
		_update_visible_icon_from_data()
	else:
		_eye_ui.hide()

func _update_visible_icon_from_data() -> void:
	_update_visible_icon(_data.is_locale_visible(_locale.code))

func _on_eye_changed(value) -> void:
	if value:
		_data.setting_locales_visibility_put(_locale.code)
	else:
		_data.setting_locales_visibility_del(_locale.code)
	_update_visible_icon(!value)

func _update_visible_icon(value: bool) -> void:
	_eye_ui.texture_normal = IconOpen if value else IconClose
