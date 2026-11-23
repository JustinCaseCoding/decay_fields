extends CanvasLayer

var _black: ColorRect
var _bar: ProgressBar
var _path := ""
var _progress := []
var _elapsed := 0.0
const min_time := 1.0

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_black = ColorRect.new()
	_black.color = Color.BLACK
	_black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_black.mouse_filter = Control.MOUSE_FILTER_STOP
	_black.visible = false
	add_child(_black)
	
	_bar = ProgressBar.new()
	_bar.show_percentage = false
	_bar.max_value = 100.0
	_bar.anchor_left = 0.5
	_bar.anchor_right = 0.5
	_bar.anchor_top = 0.5
	_bar.anchor_bottom = 0.5
	_bar.offset_left = -160.0
	_bar.offset_right = 160.0
	_bar.offset_top = -6.0
	_bar.offset_bottom = 6.0
	_black.add_child(_bar)
	_bar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color.BLACK
	bg.border_color = Color.WHITE
	bg.set_border_width_all(2)
	bg.set_corner_radius_all(0)
	bg.anti_aliasing = false
	_bar.add_theme_stylebox_override("background", bg)
	
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color.WHITE
	fill.set_corner_radius_all(0)
	fill.anti_aliasing = false
	_bar.add_theme_stylebox_override("fill", fill)
	
	set_process(false)
	
func start_loading(path: String) -> void:
	_path = path
	_black.visible = true
	_black.color.a = 1.0
	_bar.value = 0.0
	_elapsed = 0.0
	
	var err := ResourceLoader.load_threaded_request(path, "", true)
	if err != OK:
		push_error("load request failed: %s" % err)
		_black.visible = false
		return
	set_process(true)
	
func _process(delta: float) -> void:
	_elapsed += delta
	var status := ResourceLoader.load_threaded_get_status(_path, _progress)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		_bar.value = min(_progress[0], _elapsed / min_time) * 100
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		if _elapsed < min_time:
			var tween = create_tween()
			tween.tween_property(_bar, "value", 100.0, min_time - _elapsed)
			await tween.finished
			_bar.value = 100.0
		var packed: PackedScene = ResourceLoader.load_threaded_get(_path)
		get_tree().change_scene_to_packed(packed)
		await get_tree().process_frame
		await get_tree().process_frame
		await _fade_out()
		
func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(_black, "color:a", 0.0, 0.5)
	await tween.finished
	_black.visible = false
	_black.color.a = 1.0
	
