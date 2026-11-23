extends Node

@onready var map_root: Node2D = $Map

func _ready() -> void:
	var packed: PackedScene = load(Global.current_map)
	map_root.add_child(packed.instantiate())
