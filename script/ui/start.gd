extends Control

@onready var panel: Polygon2D = $TransitionPanel
@onready var continue_label: Label = $TransitionPanel/continue
@onready var load_label: Label = $TransitionPanel/load
@onready var settings_label: Label = $TransitionPanel/settings
@onready var credits_label: Label = $TransitionPanel/credits
@onready var quit_label: Label = $TransitionPanel/quit
@onready var new_game_label: Label = $TransitionPanel/new_game
@onready var quit_question_label: Label = $quit_confirm/question
@onready var quit_yes_label: Label = $quit_confirm/yes
@onready var quit_no_label: Label = $quit_confirm/no
@onready var df_label: Label = $TransitionPanel/title

@export_file("*.res", "*.tscn") var house_path: String

@onready var main_labels := [
	$TransitionPanel/continue, 
	$TransitionPanel/load, 
	$TransitionPanel/settings, 
	$TransitionPanel/credits, 
	$TransitionPanel/quit,
	$TransitionPanel/new_game
]

@onready var quit_labels := [
	$quit_confirm/question,
	$quit_confirm/yes,
	$quit_confirm/no,
	$quit_confirm
]

@onready var title_labels := [
	$TransitionPanel/title
]

func _ready() -> void:
	panel.set_state(TransitionPanel.pos.docked)
	continue_label.visible = SaveSystem.has_saves()
	
	var labels := [continue_label, load_label, settings_label, credits_label, quit_label, new_game_label]
	var questions := [quit_no_label, quit_yes_label]
	
	for l in labels:
		l.mouse_filter = Control.MOUSE_FILTER_STOP
		l.mouse_entered.connect(_on_hover.bind(l))
		l.mouse_exited.connect(_on_unhover.bind(l))
		#print("_ready(): OK")
		
	for q in questions:
		q.mouse_filter = Control.MOUSE_FILTER_STOP
		q.mouse_entered.connect(_on_hover_question.bind(q))
		q.mouse_exited.connect(_on_unhover_question.bind(q))
		
func _on_new_game_clicked(event: InputEvent) -> void:
	#print("_on_new_game_clicked: OK")
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	Global.current_map = house_path
	Global.has_position = false
	panel.sweep_then_black()
	await get_tree().create_timer(0.8).timeout
	TransitionScreen.start_loading("res://scenes/main.tscn")
		
func _on_hover(item: Label) -> void:
	#print("_on_hover: ", item.name)
	item.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	item.add_theme_color_override("font_color", Color(0.167, 0.167, 0.167, 1.0))

func _on_unhover(item: Label) -> void:
	item.mouse_default_cursor_shape = Control.CURSOR_ARROW
	item.add_theme_color_override("font_color", Color(0, 0, 0))

func _on_continue_clicked(event: InputEvent) -> void:
	#print("_on_continue_clicked: OK")
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	var save := SaveSystem.latest_save()
	if save.is_empty():
		return
	Global.current_map = save["current_scene"]
	Global.loaded_position = save["player_position"]
	Global.has_position = true
	panel.sweep_then_black()
	await get_tree().create_timer(0.8).timeout
	TransitionScreen.start_loading("res://scenes/main.tscn")
	
func _on_quit_clicked(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	for l in main_labels:
		l.visible = false
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for t in title_labels:
		t.visible = false
	for l in quit_labels:
		l.visible = true
		l.mouse_filter = Control.MOUSE_FILTER_STOP
	
	panel.animate_to(TransitionPanel.pos.full_right)
		
func _on_quit_confirmed(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	get_tree().quit()
	
func _on_quit_denied(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	panel.animate_to(TransitionPanel.pos.docked)
	await get_tree().create_timer(0.7).timeout
	for l in main_labels:
		l.visible = true
		continue_label.visible = SaveSystem.has_saves()
		l.mouse_filter = Control.MOUSE_FILTER_STOP
	for t in title_labels:
		t.visible = true
	for l in quit_labels:
		l.visible = false
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_hover_question(item: Label) -> void:
	#print("_on_hover: ", item.name)
	item.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	item.add_theme_color_override("font_color", Color(1.0, 0.33, 0.315, 1.0))

func _on_unhover_question(item: Label) -> void:
	item.mouse_default_cursor_shape = Control.CURSOR_ARROW	
	item.add_theme_color_override("font_color", Color(1, 0, 0))
