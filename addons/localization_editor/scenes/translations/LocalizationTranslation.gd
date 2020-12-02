# Translation UI for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _key
var _locale
var _translation
var _data: LocalizationData

var _translation_ui_style_empty: StyleBoxFlat

onready var _translation_ui = $HBox/Translation

const Locales = preload("res://addons/localization_editor/model/LocalizationLocalesList.gd")
const LocalizationTranslationsDialogText = preload("res://addons/localization_editor/scenes/translations/LocalizationTranslationsDialogText.tscn")

func set_data(key, translation, locale, data: LocalizationData) -> void:
	_key = key
	_translation = translation
	_locale = locale
	_data = data
	_draw_view()

func _ready() -> void:
	_init_styles()
	_init_connections()

func _init_styles() -> void:
	var style_box = _translation_ui.get_stylebox("normal", "LineEdit")
	_translation_ui_style_empty = style_box.duplicate()
	_translation_ui_style_empty.set_bg_color(Color("#661c1c"))

func _init_connections() -> void:
	if not _translation_ui.is_connected("text_changed", self, "_on_text_changed"):
		_translation_ui.connect("text_changed", self, "_on_text_changed")
	if not _translation_ui.is_connected("gui_input", self, "_on_gui_input"):
		_translation_ui.connect("gui_input", self, "_on_gui_input")

func _draw_view() -> void:
	_translation_ui.text = _translation.value
	_check_translation_ui()

func _on_text_changed(new_text) -> void:
	_translation.value = new_text
	_check_translation_ui()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE:
			if event.pressed:
				var text_dialog  = LocalizationTranslationsDialogText.instance()
				var root = get_tree().get_root()
				var key = _data.key_by_translation(_translation).value
				var label = Locales.label_by_code(_locale)
				text_dialog.window_title = key + " (" + label + ")"
				text_dialog.get_close_button().hide()
				text_dialog.connect("popup_hide", self, "_on_popup_hide", [root, text_dialog])
				var text_edit = text_dialog.get_node("VBox/TextEdit")
				text_edit.text = _translation.value
				text_edit.connect("text_changed", self, "_on_text_changed_text_edit", [text_edit, _translation, _translation_ui])
				root.add_child(text_dialog)
				text_dialog.popup_centered()
				text_dialog.set_data(_data)

func _on_popup_hide(root, text_dialog) -> void:
	root.remove_child(text_dialog)
	text_dialog.queue_free()

func _on_text_changed_text_edit(text_edit, translation, translation_ui) -> void:
	translation.value = text_edit.text
	translation_ui.text = text_edit.text

func _check_translation_ui() -> void:
	if _translation_ui.text.empty():
		_translation_ui.set("custom_styles/normal", _translation_ui_style_empty)
		_translation_ui.hint_tooltip =  "Please enter value for your translation"
	else:
		_translation_ui.set("custom_styles/normal", null)
		_translation_ui.hint_tooltip =  ""
