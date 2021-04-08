# LocalizationManager for usege with placeholders: MIT License
# @author Vladimir Petrenko
extends Node

signal translation_changed

var _keys_with_placeholder: Dictionary = {}
var _placeholders: Dictionary = {}

func _ready() -> void:
	_load_localization_keys()

func _load_localization_keys() -> void:
	var regex = RegEx.new()
	regex.compile("{{(.+?)}}")
	for _localization_key in LocalizationKeys.KEYS:
		var results = regex.search_all(tr(_localization_key))
		for result in results:
			_add_placeholder(_localization_key, result.get_string())

func _add_placeholder(key: String, placeholder: String) -> void:
	if not _keys_with_placeholder.has(key):
		_keys_with_placeholder[key] = []
	var placeholders = _keys_with_placeholder[key] as Array
	if not placeholders.has(placeholder):
		placeholders.append(placeholder)

func set_placeholder(name: String, value: String) -> void:
	_placeholders[name] = value
	emit_signal("translation_changed")

func tr(name: String) -> String:
	var tr_text = .tr(name)
	if _keys_with_placeholder.has(name):
		for placeholder in _keys_with_placeholder[name]:
			if _placeholders.has(placeholder):
				tr_text = tr_text.replace(placeholder, _placeholders[placeholder])
	return tr_text

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_TRANSLATION_CHANGED:
			emit_signal("translation_changed")


