class_name TransitionPanel
extends Polygon2D

enum pos { hidden, docked, full_right } # can have 3 positions (anims between)

@export var dock_width:= 450.0
@export var slant := 0.15
@export var menu_alpha := 0.65 # default

var state: pos = pos.hidden
var smoother: ShaderMaterial

func _ready() -> void:
	smoother = ShaderMaterial.new()
	smoother.shader = load("res://scenes/ui/slant_smoother.gdshader") # smooooooooooooth
	material = smoother
	set_state(pos.hidden) # pos.docked
	
	# press ctrl+k with selected comments to uncomment:
	# test of tween animations
	
	#var tween := create_tween()
	#tween.tween_interval(2.0)
	#tween.tween_method(_set_right, _right_for(pos.docked), _right_for(pos.full_right), 2.5)\
		#.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	#tween.tween_method(_set_right, _right_for(pos.full_right), _right_for(pos.docked), 2.0)\
		#.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _set_right(right: float) -> void:
	smoother.set_shader_parameter("right_edge", right)
	var h := get_viewport().get_visible_rect().size.y
	polygon = PackedVector2Array([
		Vector2(0,0),
		Vector2(right,0),
		Vector2(right - slant * h, h),
		Vector2(0, h),
	])
	
func _right_for(p: pos) -> float:
	match p:
		pos.hidden:
			return -dock_width
		pos.full_right:
			return 5000.0
		_:
			return dock_width
	
func set_state(p: pos) -> void:
	state = p
	_set_right(_right_for(p))
	
func animate_to(p: pos, duration: float = 0.6) -> void:
	var start := state
	state = p
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(_set_right, _right_for(start), _right_for(p), duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func sweep_then_black(dur: float = 0.8) -> void:
	state = pos.full_right
	var tween := create_tween()
	tween.tween_method(_set_right, _right_for(pos.docked), _right_for(pos.full_right), dur)
	tween.parallel().tween_property(self, "color", Color.BLACK, dur)
