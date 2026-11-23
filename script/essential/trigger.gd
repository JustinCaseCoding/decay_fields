extends Node2D

@export var dfintro: PackedScene

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		$Area2D.set_deferred("monitoring", false)
		var intro := dfintro.instantiate()
		add_child(intro)
