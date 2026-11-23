extends CanvasLayer

@onready var fade: ColorRect = $dfintro_fade

func _ready() -> void:
	fade.visible = false
	fade.color.a = 0.0
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.5)
	await tween.finished
	queue_free() 
