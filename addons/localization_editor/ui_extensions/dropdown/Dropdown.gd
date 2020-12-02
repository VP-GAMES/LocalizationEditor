# UI Extension Filter Dropdown : MIT License
# @author Vladimir Petrenko
tool
extends LineEdit

signal selection_changed

var selected = -1
export var popup_maxheight = 0

var _group = ButtonGroup.new()
var _filter: String = ""
var _items = []

onready var _popup_panel: PopupPanel= $PopupPanel
onready var _popup_panel_vbox: VBoxContainer= $PopupPanel/Scroll/VBox

const DropdownCheckBox = preload("DropdownCheckBox.tscn")

func clear() -> void:
	_items.clear()

func items() -> PoolStringArray:
	return _items

func add_item(value: String) -> void:
	_items.append(value)

func get_selected() -> int:
	return selected

func _ready() -> void:
	_group.resource_local_to_scene = false
	_init_connections()

func _init_connections() -> void:
	if connect("gui_input", self, "_line_edit_gui_input") != OK:
		push_warning("_popup_panel gui_input not connected")
	if connect("text_changed", self, "_on_text_changed") != OK:
		push_warning("_popup_panel text_changed not connected")
 
func _popup_panel_focus_entered() -> void:
	grab_focus()

func _popup_panel_index_pressed(index: int) -> void:
	var text = _popup_panel.get_item_text(index)
	text = text
	_filter = text
	selected = _items.find(text)

func _line_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_MASK_LEFT and not event.pressed:
			_update_popup_view()

func _on_text_changed(filter: String) -> void:
	_filter = filter
	_update_popup_view(_filter)

func _update_popup_view(filter = "") -> void:
	_update_items_view(filter)
	var rect = get_global_rect()
	var position =  Vector2(rect.position.x, rect.position.y + rect.size.y)
	var size = Vector2(rect.size.x, popup_maxheight)
	_popup_panel.popup(Rect2(position, size))
	grab_focus()

func _update_items_view(filter = "") -> void:
	for child in _popup_panel_vbox.get_children():
		_popup_panel_vbox.remove_child(child)
		child.queue_free()
	for index in range(_items.size()):
		if filter.empty():
			_popup_panel_vbox.add_child(_init_check_box(index))
		else:
			if filter in _items[index]:
				_popup_panel_vbox.add_child(_init_check_box(index))

func _init_check_box(index: int) -> CheckBox:
	var check_box = DropdownCheckBox.instance()
	check_box.set_button_group(_group)
	check_box.text = _items[index]
	if index == selected:
		check_box.set_pressed(true)
	check_box.connect("pressed", self, "_on_selection_changed", [index])
	return check_box

func _on_selection_changed(index: int) -> void:
	if selected != index:
		selected = index
		_filter = _items[selected]
		text = _filter
		emit_signal("selection_changed")
	_popup_panel.hide()
