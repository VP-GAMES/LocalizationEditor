# Autotranslate Yandex (https://translate.yandex.com/) for LocalizationEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _data: LocalizationData
var _locales_google: Array = []


onready var _from_language_ui = $Panel/VBox/HBox/FromLanguage
onready var _to_language_ui = $Panel/VBox/HBox/ToLanguage
onready var _translate_ui = $Panel/VBox/HBox/Translate
onready var _progress_ui = $Panel/VBox/Progress

const Locales = preload("res://addons/localization_editor/model/LocalizationLocalesList.gd")
const GoogleLocales = preload("res://addons/localization_editor/scenes/auto_translate/google/LocalizationAutoTranslateGoogleLocalesList.gd")

func set_data(data: LocalizationData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("data_changed", self, "_update_view"):
		_data.connect("data_changed", self, "_update_view")
	if not _translate_ui.is_connected("pressed", self, "_on_translate_pressed"):
		_translate_ui.connect("pressed", self, "_on_translate_pressed")

func _update_view() -> void:
	_init_from_language_ui()
	_init_to_language_ui()

func _init_from_language_ui() -> void:
	_from_language_ui.clear()
	if not _from_language_ui.is_connected("selection_changed", self, "_check_translate_ui"):
		_from_language_ui.connect("selection_changed", self, "_check_translate_ui")
	for locale in _data.locales():
		var from_language_label = Locales.label_by_code(locale)
		_from_language_ui.add_item(from_language_label)

func _init_to_language_ui() -> void:
	_to_language_ui.clear()
	if not _to_language_ui.is_connected("selection_changed", self, "_check_translate_ui"):
		_to_language_ui.connect("selection_changed", self, "_check_translate_ui")
	_locales_google.clear()
	for locale in GoogleLocales.LOCALES:
		if Locales.has_code(locale.code):
			_locales_google.append(locale.code)
			var to_language_label = GoogleLocales.label_by_code(locale.code)
			_to_language_ui.add_item(to_language_label)

func _check_translate_ui() -> void:
	_translate_ui.set_disabled(_from_language_ui.selected == -1 or _to_language_ui.selected == -1)

func _on_translate_pressed() -> void:
	var from_language_code = _data.locales()[_from_language_ui.selected]
	var to_language_code = _locales_google[_to_language_ui.selected]
	_translate(from_language_code, to_language_code)

func _translate(from_code: String, to_code: String) -> void:
	_translate_ui.disabled = true
	_progress_ui.max_value = _data.keys().size()
	if not _data.locales().has(to_code):
		_data.add_locale(to_code, false)
	for key in _data.keys():
		var from_translation = _data.translation_by_locale(key, from_code)
		var to_translation = _data.translation_by_locale(key, to_code)
		if from_translation != null and not from_translation.value.empty() and (to_translation.value == null or to_translation.value.empty()):
			_create_request(from_translation, to_translation)
		else:
			_add_progress()

func _create_request(from_translation, to_translation) -> void:
	var url = _create_url(from_translation, to_translation)
	var http_request = HTTPRequest.new()
	http_request.timeout = 5
	add_child(http_request)
	http_request.connect("request_completed", self, "http_request_completed", [http_request, to_translation])
	http_request.request(url, [], false, HTTPClient.METHOD_GET)

func _create_url(from_translation, to_translation) -> String:
	var url = "https://translate.googleapis.com/translate_a/single?client=gtx"
	url += "&sl=" + from_translation.locale
	url += "&tl=" + to_translation.locale
	url += "&dt=t"
	url += "&q=" + from_translation.value.http_escape()
	return url

func http_request_completed(result, response_code, headers, body, http_request, to_translation):
	var result_body := JSON.parse(body.get_string_from_utf8())
	to_translation.value = result_body.result[0][0][0]
	_add_progress()
	remove_child(http_request)

func _add_progress() -> void:
	_progress_ui.value = _progress_ui.value + 1
	_check_progress()

func _check_progress() -> void:
	if _progress_ui.value == _data.keys().size():
		_data.emit_signal_data_changed()
		_translate_ui.disabled = false
		_progress_ui.value = 0

