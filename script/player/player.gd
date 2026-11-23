extends CharacterBody2D
class_name Player
const speed := 130.0 # px/s
const acceleration := 600.0
const friction := 5000.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tap: AudioStreamPlayer2D = $tap
@onready var tap_timer: Timer = $tap_timer

func _ready() -> void:
	if Global.has_position:
		global_position = Global.loaded_position
		Global.has_position = false
		
func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() == 0:
		animated_sprite.play("idle")
		tap_timer.stop()
	else:
		if abs(direction.y) > abs(direction.x):
			animated_sprite.play("run_f") if direction.y > 0 else animated_sprite.play("run_b")
		else:
			animated_sprite.play("run")
		if direction.x < 0:
			animated_sprite.flip_h = true
		elif direction.x > 0:
			animated_sprite.flip_h = false
		if tap_timer.is_stopped():
			tap_timer.start()
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	move_and_slide()
	
func _on_tap_timer_timeout() -> void:
	tap.play()
