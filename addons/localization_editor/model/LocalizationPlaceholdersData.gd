# Localization placeholders data for LocalizationEditor : MIT License
# @author Vladimir Petrenko
extends Resource
class_name LocalizationPlaceholdersData

export(Dictionary) var placeholders = {}

#func update_placeholders(loc_data: LocalizationData) -> void:
#	var regex = RegEx.new()
#	regex.compile("{{(.+?)}}")
#	for key in loc_data.keys:
#		for index in  range(key.translations.size()):
#			var results = regex.search_all(key.translations[index].value)
#			for result in results:
#				var name = result.get_string()
#				var clean_name = name.replace("{{", "");
#				clean_name = clean_name.replace("}}", "");
#				if not placeholders.has(clean_name):
#					placeholders[clean_name] = name
