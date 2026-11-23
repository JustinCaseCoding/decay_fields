extends Control

@onready var panel: TransitionPanel = $TransitionPanel
@onready var title: Label = $MenuContent/title
@onready var items: Array[Label] = [
	$MenuContent/continue,
	$MenuContent/load,
	$MenuContent/settings,
	$MenuContent/save,
	$MenuContent/quit
]
@onready var quit_confirm: Control = $MenuContent/quit_confirm

var is_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.set_state(TransitionPanel.pos.hidden)
	quit_confirm.visible = false
	_show_items(false)
	
	$MenuContent/quit_confirm/yes.gui_input.connect(_on_quit_yes)
	$MenuContent/quit_confirm/no.gui_input.connect(_on_quit_no)
	$MenuContent/continue.gui_input.connect(_on_continue)
	$MenuContent/quit.gui_input.connect(_on_quit)
	$MenuContent/save.gui_input.connect(_on_save)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_open:
			close()
		else:
			open()
			
func open() -> void:
	is_open = true
	get_tree().paused = true
	quit_confirm.visible = false
	await panel.animate_to(TransitionPanel.pos.docked)
	_show_items(true)
	
func close() -> void:
	is_open = false
	_show_items(false)
	await panel.animate_to(TransitionPanel.pos.hidden)
	get_tree().paused = false
	
func _show_items(on: bool) -> void:
	title.visible = on
	for i in items:
		i.visible = on
		
func _on_continue(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
		
func _on_quit(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_show_items(false)
		quit_confirm.visible = false
		await panel.animate_to(TransitionPanel.pos.full_right)
		
func _on_quit_yes(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_tree().paused = false
		TransitionScreen.start_loading("res://scenes/ui/start.tscn")
		
func _on_quit_no(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		quit_confirm.visible = false
		_show_items(true)
		await panel.animate_to(TransitionPanel.pos.docked)
		
func _on_save(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		pass
