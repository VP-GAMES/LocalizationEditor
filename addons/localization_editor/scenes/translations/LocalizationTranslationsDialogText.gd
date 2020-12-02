tool
extends WindowDialog

onready var text_edit_ui = $VBox/TextEdit

func set_data(data: LocalizationData) -> void:
	var editor_theme = data.editor().get_editor_interface().get_base_control().theme
	var font = editor_theme.get_font("main", "EditorFonts")
	text_edit_ui.set("custom_fonts/font", font)
