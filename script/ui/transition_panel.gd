extends Polygon2D

enum pos { hidden, docked, full_right } # can have 3 positions (anims between)

@export var dock_width:= 450.0
@export var slant := 0.15

var state: pos = pos.hidden

func _ready() -> void:
	set_state(pos.hidden) # pos.docked
	
	# press ctrl+k with selected comments to uncomment:
	
	#var tween := create_tween()
	#tween.tween_interval(2.0)
	#tween.tween_method(_set_right, _right_for(pos.docked), _right_for(pos.full_right), 2.5)\
		#.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	#tween.tween_method(_set_right, _right_for(pos.full_right), _right_for(pos.docked), 2.0)\
		#.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _set_right(right: float) -> void:
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
	state = p
	var tween := create_tween()
	tween.tween_method(_set_right, _right_for(state), _right_for(p), duration)
