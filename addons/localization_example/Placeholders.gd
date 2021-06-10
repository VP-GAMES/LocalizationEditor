# LocalizationEditor example of Placeholdes usage: MIT License
# @author Vladimir Petrenko
extends Control

onready var _locales = TranslationServer.get_loaded_locales()
var _localization_manager
var _placeholders: Array

onready var _content_ui = $Content
onready var _label_error_ui = $LabelError
onready var _placeholder_ui = $Content/VBox/HBox/Placeholder as OptionButton
onready var _value_ui = $Content/VBox/HBox/Value
onready var _apply_ui = $Content/VBox/HBox/Apply
onready var _label_top_ui =$Content/VBox/LabelTop
onready var _label_middle_ui =$Content/VBox/LabelMiddle
onready var _label_bottom_ui =$Content/VBox/LabelBottom
onready var _languages_ui = $Content/VBox/Languages

func _ready() -> void:
	_content_ui.hide()
	_label_error_ui.hide()
	if _is_localization_manager_loaded():
		_content_ui.show()
	else:
		_label_error_ui.show()
		return
	_init_placeholders()
	_init_connections()
	_update_translation_from_manager()
	_init_languages()

func _is_localization_manager_loaded() -> bool:
	_localization_manager = get_tree().get_root().get_node("LocalizationManager")
	return is_instance_valid(_localization_manager)

func _init_placeholders() -> void:
	_placeholder_ui.clear()
	_placeholders = []
	for placeholder in LocalizationPlaceholders.PLACEHOLDERS:
		_placeholders.append(placeholder)
		_placeholder_ui.add_item(placeholder)

func _init_connections() -> void:
	var resultManager = _localization_manager.connect("translation_changed", self, "_update_translation_from_manager")
	if resultManager != OK:
		push_error("Can't connect manager translation_changed")
	var resultApply = _apply_ui.connect("pressed", self, "_on_apply_pressed")
	if resultApply != OK:
		push_error("Can't connect apply button")
	var resultLanguages = _languages_ui.connect("item_selected", self, "_on_language_item_selected")
	if resultLanguages != OK:
		push_error("Can't connect languages option button")

func _update_translation_from_manager() -> void:
	_label_top_ui.text = _localization_manager.tr(LocalizationKeys.KEY_PLACEHOLDER_AGE)
	_label_middle_ui.text = _localization_manager.tr(LocalizationKeys.KEY_PLACEHOLDER_NAME)
	_label_bottom_ui.text = _localization_manager.tr(LocalizationKeys.KEY_PLACEHOLDER_NAME_AGE)

func _on_apply_pressed() -> void:
	var index = _placeholder_ui.get_selected_id()
	var placeholder = _placeholders[index]
	var value = _value_ui.text
	_localization_manager.set_placeholder(placeholder, value)

func _init_languages() -> void:
	var index: = -1
	for i in range(_locales.size()):
		_languages_ui.add_item(TranslationServer.get_locale_name(_locales[i]))
		if _locales[i] in TranslationServer.get_locale():
			index = i
	_languages_ui.select(index)

func _on_language_item_selected(id: int) -> void:
	TranslationServer.set_locale(_locales[id])
