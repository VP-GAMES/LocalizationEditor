# Localization data for LocalizationEditor : MIT License
# @author Vladimir Petrenko
extends Resource
class_name LocalizationData

signal data_changed

var _editor: EditorPlugin
var _undo_redo: UndoRedo

export(Dictionary) var data = {"locales": [], "keys": []}
var data_filter: Dictionary = {}

var _locales_filter: String setget  locales_filter_put, locales_filter
var _locales_selected: bool setget  locales_selected_put, locales_selected

var data_remaps: Dictionary = {"remapkeys": []}
var data_filter_remaps: Dictionary = {}

const uuid_gen = preload("res://addons/localization_editor/uuid/uuid.gd")

const default_path_to_file = "res://localization/localizations.csv"
const SETTINGS_PATH_TO_FILE = "localization_editor/locales_path_to_file"
const SETTINGS_LOCALES_VISIBILITY = "localization_editor/locales_visibility"
const SETTINGS_TRANSLATIONS_SPLIT_OFFSET = "localization_editor/translations_split_offset"

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	if _editor:
		_undo_redo = _editor.get_undo_redo()

func editor() -> EditorPlugin:
	return _editor

func undo_redo() -> UndoRedo:
	return _undo_redo

func init_data_translations() -> void:
	_init_data_translations_csv()

func _init_data_translations_csv() -> void:
	var file = File.new()
	var path = setting_path_to_file()
	if file.file_exists(path):
		file.open(path, file.READ)
		var locales_line = file.get_csv_line()
		for index in range(1, locales_line.size()):
			add_locale(locales_line[index])
		data.keys.clear()
		while !file.eof_reached():
			var values_line = file.get_csv_line()
			if values_line.size() > 1:
				var key = {"uuid": uuid(), "value": values_line[0], "translations": []}
				for index in range(1, values_line.size()):
					var translation = {"locale": locales_line[index], "value": values_line[index]}
					key.translations.append(translation)
				data.keys.append(key)
		file.close()

func save_data_translations() -> void:
	_save_data_translations_csv()
	_save_data_translations_to_project_settings()

func _save_data_translations_csv() -> void:
	var file = File.new()
	file.open(setting_path_to_file(), File.WRITE)
	var locales_line: PoolStringArray = ["keys"]
	locales_line.append_array(data.locales)
	file.store_csv_line(locales_line)
	for key in data.keys:
		var values_line: PoolStringArray = [key.value]
		for translation in key.translations:
			values_line.append(translation.value)
		file.store_csv_line(values_line)
	file.close()

func _save_data_translations_to_project_settings() -> void:
	var file = setting_path_to_file()
	file = file_path_without_extension(file)
	var translations: PoolStringArray = []
	for locale in data.locales:
		var entry = file + "." + locale + ".translation"
		translations.append(entry)
	ProjectSettings.set_setting("translations", translations)

# ***** UUID ****
static func uuid() -> String:
	return uuid_gen.v4()

# ***** LOCALES *****
func locales_filter_put(text: String) -> void:
	_locales_filter = text
	emit_signal("data_changed")

func locales_filter() -> String:
	return _locales_filter

func locales_selected_put(value: bool) -> void:
	_locales_selected = value
	emit_signal("data_changed")

func locales_selected() -> bool:
	return _locales_selected

func locales() -> Array:
	return data.locales

func check_locale(locale: String) -> void:
	if not find_locale(locale):
		add_locale(locale)

func find_locale(code: String):
	if data.has("locales"):
		for locale in data.locales:
			if locale == code:
				return locale
	return null

func add_locale(locale: String) -> void:
	if not data.locales.has(locale):
		if _undo_redo != null:
			_undo_redo.create_action("Add locale " + locale)
			_undo_redo.add_do_method(self, "_add_locale", locale)
			_undo_redo.add_undo_method(self, "_del_locale", locale)
			_undo_redo.commit_action()
		else:
			_add_locale(locale)

func _add_locale(locale) -> void:
	data.locales.append(locale)
	if data.keys.empty():
		_add_key(uuid())
	for key in data.keys:
		if not key_has_locale(locale):
			key.translations.append({"locale": locale, "value": ""})
	if data_remaps.remapkeys.empty():
		_add_remapkey(uuid())
	emit_signal("data_changed")

func del_locale(locale: String) -> void:
	if data.locales.has(locale):
		if _undo_redo != null:
			_undo_redo.create_action("Del locale " + locale)
			_undo_redo.add_do_method(self, "_del_locale", locale)
			_undo_redo.add_undo_method(self, "_add_locale", locale)
			_undo_redo.commit_action()
		else:
			_del_locale(locale)

func _del_locale(locale: String) -> void:
	data.locales.erase(locale)
	setting_locales_visibility_del(locale)
	for key in data.keys:
		for translation in key.translations:
			if translation.locale == locale:
				var t = key.translations.find(translation)
				key.translations.remove(t)
				break
	for remapkey in data_remaps.remapkeys:
		for remap in remapkey.remaps:
			if remap.locale == locale:
				var r = remapkey.remaps.find(remap)
				remapkey.remaps.remove(r)
				break
	emit_signal("data_changed")

# ***** KEYS *****
signal data_key_value_changed

func emit_data_key_value_changed() -> void:
	emit_signal("data_key_value_changed")

func keys() -> Array:
	return data.keys

func keys_filtered() -> Array:
	var keys = _filter_by_keys()
	for filter_key in data_filter.keys():
		if filter_key != "keys":
			keys = _key_filter_by_translations(keys, filter_key)
	return keys

func _filter_by_keys() -> Array:
	var keys = []
	for key in data.keys:
		if not data_filter.has("keys") or data_filter["keys"] == "" or key.value == null or key.value == "" or data_filter["keys"] in key.value:
			keys.append(key)
	return keys

func _key_filter_by_translations(keys, locale) -> Array:
	var new_keys = []
	for key in keys:
		var value = _translation_value_by_locale(key, locale)
		if data_filter[locale] == "" or value == null or value == ""  or data_filter[locale] in value:
			new_keys.append(key)
	return new_keys

func _translation_value_by_locale(key, locale):
	for translation in key.translations:
		if translation.locale == locale:
			if translation.value != null:
				return translation.value 
	return ""

func add_key_object(key) -> void:
	data.keys.append(key)

func _add_key(uuid: String, emitSignal = true) -> void:
	data.keys.append(_create_key(uuid))
	if emitSignal:
		emit_signal("data_changed")

func add_key_new_after_uuid(after_uuid: String, uuid = uuid()) -> void:
	if _undo_redo != null:
		_undo_redo.create_action("Add new key " + uuid + " after " + after_uuid)
		_undo_redo.add_do_method(self, "_add_key_new_after_uuid", after_uuid, uuid)
		_undo_redo.add_undo_method(self, "_del_key", uuid)
		_undo_redo.commit_action()
	else:
		_add_key_new_after_uuid(after_uuid, uuid)

func _add_key_after_uuid(after_uuid: String, key) -> void:
	var position = _key_position(after_uuid)
	if position != -1 and position < data.keys.size():
		data.keys.insert(position + 1, key)
		emit_signal("data_changed")
	else:
		data.keys.append(key)

func _add_key_new_after_uuid(after_uuid: String, uuid = uuid()) -> void:
	var position = _key_position(after_uuid)
	if position != -1 and position < data.keys.size():
		var key = _create_key(uuid)
		data.keys.insert(position + 1, key)
		emit_signal("data_changed")
	else:
		_add_key(uuid)

func _create_key(uuid: String):
	var key = {"uuid": uuid, "value": "", "translations": []}
	for locale in data.locales:
		var translation = {"locale": locale, "value": ""}
		key.translations.append(translation)
	return key

func del_key(uuid: String, emitSignal = true) -> void:
	if _undo_redo != null:
		var before_uuid = before_uuid(uuid)
		var key = key(uuid)
		_undo_redo.create_action("Del key " + uuid)
		_undo_redo.add_do_method(self, "_del_key", uuid)
		_undo_redo.add_undo_method(self, "_add_key_after_uuid", before_uuid, key)
		_undo_redo.commit_action()
	else:
		_del_key(uuid)

func _del_key(uuid: String, emitSignal = true) -> void:
	data.keys.remove(_key_position(uuid))
	if emitSignal:
		emit_signal("data_changed")

func after_uuid(uuid: String):
	var position = _key_position(uuid)
	if position != -1 and position < data.keys.size():
		return data.keys[position + 1].uuid
	else:
		return null

func before_uuid(uuid: String):
	var position = _key_position(uuid)
	if position > 0:
		return data.keys[position - 1].uuid
	else:
		return null

func _key_position(uuid: String) -> int:
	for index in range(data.keys.size()):
		if data.keys[index].uuid == uuid:
			return index
	return -1

func key_has_locale(locale: String) -> bool:
	for key in data.keys:
		for translation in key.translations:
			if translation.locale == locale:
				return true
	return false

func key_value(uuid: String):
	var key = key(uuid)
	if key != FAILED:
		return key.value
	else:
		return "" 

func key_value_change(key, key_value: String):
	if _undo_redo != null:
		_undo_redo.create_action("Change key value ")
		_undo_redo.add_do_method(self, "_key_value_change", key, key_value)
		_undo_redo.add_undo_method(self, "_key_value_change", key, "" + key.value)
		_undo_redo.commit_action()
	else:
		_key_value_change(key, key_value)

func _key_value_change(key, key_value: String):
	key.value = key_value
	emit_data_key_value_changed()

func key(uuid: String):
	for key in data.keys:
		if key.uuid == uuid:
			return key
	return FAILED

func is_key_value_double(value: String) -> bool:
	var count = 0
	for key in data.keys:
		if key.value != null and !key.value.empty()  and key.value == value:
			count = count + 1
		if count > 1:
			return true
	return false

# ***** TRANSLATIONS *****
func get_translations_by_locale(locale: String) -> Array:
	var translations = []
	for key in data.keys:
		for translation in key.translations:
			if translation.locale == locale:
				translations.append(translation)
				break
	return translations

func key_by_translation(translation):
	for key in data.keys:
		for translation_obj in key.translations:
			if translation == translation_obj:
				return key
	return null

func get_translations() -> Array:
	var translations = {}
	for locale in data.locales:
		var translation_for_server = Translation.new()
		translation_for_server.set_locale(locale)
		translations[locale] = translation_for_server
	for key in data.keys:
		for translation in key.translations:
			translations[translation.locale].add_message(key.value, str(translation.value))
	return translations.values()

# ***** FILTER *****
func data_filter_by_type(type: String) -> String:
	return data_filter[type] if data_filter.has(type) else ""

func data_filter_put(type: String, filter: String) -> void:
	data_filter[type] = filter
	emit_signal("data_changed")

func data_filter_remaps_by_type(type: String) -> String:
	return data_filter_remaps[type] if data_filter_remaps.has(type) else ""

func data_filter_remaps_put(type: String, filter: String) -> void:
	data_filter_remaps[type] = filter
	emit_signal("data_changed")

# ***** REMAPS *****
func remaps_keys_filtered() -> Array:
	return data_remaps.remapkeys

func init_data_remaps() -> void:
	data_remaps.remapkeys = []
	var settings_remaps = ProjectSettings.get_setting("locale/translation_remaps")
	var keys = settings_remaps.keys();
	for key in keys:
		var remaps = []
		var first_locale = data.locales[0] if data.locales.size() > 0 else "en"
		check_locale(first_locale)
		remaps.append({"locale": first_locale , "value": key })
		for remap in settings_remaps[key]:
			var index = remap.find_last(":")
			var locale  = remap.substr(index + 1)
			check_locale(locale)
			var value = remap.substr(0, index)
			var remap_new = {"locale": locale, "value": value }
			remaps.append(remap_new)
		data_remaps.remapkeys.append({"uuid": uuid(), "remaps": remaps})

func save_data_remaps() -> void:
	var remaps = {}
	for remapkey in  data_remaps.remapkeys:
		if remapkey.remaps.size() > 0:
			var key = remapkey.remaps[0].value
			remaps[key] = []
			for index in range(1, remapkey.remaps.size()):
				var remap = remapkey.remaps[index]
				var value = remap.value + ":" + remap.locale
				remaps[key].append(value)
	ProjectSettings.set_setting("locale/translation_remaps", remaps)

signal data_remapkey_value_changed

func emit_data_remapkey_value_changed() -> void:
	emit_signal("data_remapkey_value_changed")

func remapkeys_filtered() -> Array:
	var remapkeys = _filter_by_remapkeys()
	for filter_remapkey in data_filter_remaps.keys():
		if filter_remapkey != "remapkeys":
			remapkeys = _remapkey_filter_by_remaps(remapkeys, filter_remapkey)
	return remapkeys

func _filter_by_remapkeys() -> Array:
	var remapkeys = []
	for remapkey in data_remaps.remapkeys:
		if _remapkey_allow_by_filter(remapkey):
			remapkeys.append(remapkey)
	return remapkeys

func _remapkey_allow_by_filter(remapkey) -> bool:
	if data_filter_remaps.has("remapkeys"):
		if data_filter_remaps.remapkeys.empty():
			return true
		else:
			for remap in remapkey.remaps:
				if remap_type(remap) in data_filter_remaps.remapkeys:
					return true
			return false
	else:
		return true

func _remapkey_filter_by_remaps(remapkeys, locale) -> Array:
	var new_remapkeys = []
	for remapkey in remapkeys:
		var value = _remap_value_by_locale(remapkey, locale)
		if data_filter_remaps[locale] == "" or value == null or value == ""  or data_filter_remaps[locale] in value:
			new_remapkeys.append(remapkey)
	return new_remapkeys

func _remap_value_by_locale(remapkey, locale):
	for remap in remapkey.remaps:
		if remap.locale == locale:
			if remap.value != null:
				return remap.value 
	return ""

func add_remapkey_object(remapkey) -> void:
	data_remaps.remapkeys.append(remapkey)

func _add_remapkey(uuid: String, emitSignal = true) -> void:
	data_remaps.remapkeys.append(_create_remapkey(uuid))
	if emitSignal:
		emit_signal("data_changed")

func add_remapkey_new_after_uuid_remap(after_uuid_remap: String, uuid = uuid()) -> void:
	if _undo_redo != null:
		_undo_redo.create_action("Add new remapkey " + uuid + " after " + after_uuid_remap)
		_undo_redo.add_do_method(self, "_add_remapkey_new_after_uuid_remap", after_uuid_remap, uuid)
		_undo_redo.add_undo_method(self, "_del_remapkey", uuid)
		_undo_redo.commit_action()
	else:
		_add_remapkey_new_after_uuid_remap(after_uuid_remap, uuid)

func _add_remapkey_after_uuid_remap(after_uuid_remap: String, remapkey) -> void:
	var position = _remapkey_position(after_uuid_remap)
	if position != -1 and position < data_remaps.remapkeys.size():
		data_remaps.remapkeys.insert(position + 1, remapkey)
		emit_signal("data_changed")
	else:
		data_remaps.remapkeys.append(remapkey)

func _add_remapkey_new_after_uuid_remap(after_uuid_remap: String, uuid = uuid()) -> void:
	var position = _remapkey_position(after_uuid_remap)
	if position != -1 and position < data_remaps.remapkeys.size():
		var remapkey = _create_remapkey(uuid)
		data_remaps.remapkeys.insert(position + 1, remapkey)
		emit_signal("data_changed")
	else:
		_add_remapkey(uuid)

func _create_remapkey(uuid: String):
	var remapkey = {"uuid": uuid, "remaps": []}
	for locale in data.locales:
		var remap = {"locale": locale, "value": ""}
		remapkey.remaps.append(remap)
	return remapkey

func del_remapkey(uuid: String, emitSignal = true) -> void:
	if _undo_redo != null:
		var before_uuid_remap = before_uuid_remap(uuid)
		var remapkey = remapkey(uuid)
		_undo_redo.create_action("Del remapkey " + uuid)
		_undo_redo.add_do_method(self, "_del_remapkey", uuid)
		_undo_redo.add_undo_method(self, "_add_remapkey_after_uuid_remap", before_uuid_remap, remapkey)
		_undo_redo.commit_action()
	else:
		_del_remapkey(uuid)

func _del_remapkey(uuid: String, emitSignal = true) -> void:
	data_remaps.remapkeys.remove(_remapkey_position(uuid))
	if emitSignal:
		emit_signal("data_changed")

func after_uuid_remap(uuid: String):
	var position = _remapkey_position(uuid)
	if position != -1 and position < data_remaps.remapkeys.size():
		return data_remaps.remapkeys[position + 1].uuid
	else:
		return null

func before_uuid_remap(uuid: String):
	var position = _remapkey_position(uuid)
	if position > 0:
		return data_remaps.remapkeys[position - 1].uuid
	else:
		return null

func _remapkey_position(uuid: String) -> int:
	for index in range(data_remaps.remapkeys.size()):
		if data_remaps.remapkeys[index].uuid == uuid:
			return index
	return -1

func remapkey_value(uuid: String):
	var remapkey = remapkey(uuid)
	if remapkey != FAILED:
		return remapkey.value
	else:
		return "" 

func remapkey_value_change(remapkey, remapkey_value: String):
	if _undo_redo != null:
		_undo_redo.create_action("Change remapkey value ")
		_undo_redo.add_do_method(self, "_remapkey_value_change", remapkey, remapkey_value)
		_undo_redo.add_undo_method(self, "_remapkey_value_change", remapkey, "" + remapkey.value)
		_undo_redo.commit_action()
	else:
		_remapkey_value_change(remapkey, remapkey_value)

func _remapkey_value_change(remapkey, remapkey_value: String):
	remapkey.value = remapkey_value
	emit_data_remapkey_value_changed()

func remapkey(uuid: String):
	for remapkey in data_remaps.remapkeys:
		if remapkey.uuid == uuid:
			return remapkey
	return FAILED

func remap_type(remap) -> String:
	match file_extension(remap.value):
		"ogg", "wav":
			return "audio"
		"bmp", "dds", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "svgz", "webp":
			return "image"
		"webm", "o":
			return "video"
		_:
			return "undefined"

func supported_file_extensions() -> Array:
	return ["ogg", "wav", "bmp", "dds", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "svgz", "webp", "webm", "o"]

# ***** EDITOR SETTINGS *****
signal settings_changed

func setting_path_to_file() -> String:
	var path = default_path_to_file
	if ProjectSettings.has_setting(SETTINGS_PATH_TO_FILE):
		path = ProjectSettings.get_setting(SETTINGS_PATH_TO_FILE)
	return path
	
func setting_path_to_file_put(path: String) -> void:
	ProjectSettings.set_setting(SETTINGS_PATH_TO_FILE, path)
	emit_signal("settings_changed")

func is_locale_visible(locale: String) -> bool:
	if not ProjectSettings.has_setting(SETTINGS_LOCALES_VISIBILITY):
		return true
	var locales = ProjectSettings.get_setting(SETTINGS_LOCALES_VISIBILITY)
	return not locales.has(locale)

func setting_locales_visibility_put(locale: String) -> void:
	var locales = []
	if ProjectSettings.has_setting(SETTINGS_LOCALES_VISIBILITY):
		locales = ProjectSettings.get_setting(SETTINGS_LOCALES_VISIBILITY)
	if not locales.has(locale):
		locales.append(locale)
		ProjectSettings.set_setting(SETTINGS_LOCALES_VISIBILITY, locales)
		emit_signal("data_changed")

func setting_locales_visibility_del(locale: String, emitSignal = true) -> void:
	if ProjectSettings.has_setting(SETTINGS_LOCALES_VISIBILITY):
		var locales = ProjectSettings.get_setting(SETTINGS_LOCALES_VISIBILITY)
		if locales.has(locale):
			locales.erase(locale)
			ProjectSettings.set_setting(SETTINGS_LOCALES_VISIBILITY, locales)
			if emitSignal:
				emit_signal("data_changed")

func setting_translations_split_offset() -> int:
	var offset = 350
	if ProjectSettings.has_setting(SETTINGS_TRANSLATIONS_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_TRANSLATIONS_SPLIT_OFFSET)
	return offset

func setting_translations_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_TRANSLATIONS_SPLIT_OFFSET, offset)

# ***** UTILS *****
func filename(value: String) -> String:
	var index = value.find_last("/")
	return value.substr(index + 1)

func file_path_without_extension(value: String) -> String:
	var index = value.find_last(".")
	return value.substr(0, index)

func file_path(value: String) -> String:
	var index = value.find_last("/")
	return value.substr(0, index)

func file_extension(value: String):
	var index = value.find_last(".")
	if index == -1:
		return null
	return value.substr(index + 1)