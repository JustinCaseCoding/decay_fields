extends Node

const saves_dir = "user://saves"
const slot_prefix := "slot_"
const slot_extension := ".cfg"

func save_game(scene_path: String, player_position: Vector2, slot: int = -1) -> int:
	if slot < 0:
		slot = next_slot()
	DirAccess.make_dir_recursive_absolute(saves_dir)
	var config := ConfigFile.new()
	config.set_value("World", "current_scene", scene_path)
	config.set_value("World", "player_position", player_position)
	config.set_value("Meta", "saved_at", Time.get_unix_time_from_system()) # best time with friends ❌️ | best time with unix ✅️
	var error := config.save(slot_path(slot))
	if error != OK:
		push_error("save failed: %s" % error)
		return -1
	return slot
	
func load_game(slot: int) -> Dictionary:
	var config := ConfigFile.new()
	if config.load(slot_path(slot)) != OK:
		return {}
	return {
		"current_scene": config.get_value("World", "current_scene", ""),
		"player_position": config.get_value("World", "player_position", Vector2.ZERO),
		"slot": slot,
	}
	
func latest_save() -> Dictionary:
	var slots := get_slots()
	if slots.is_empty():
		return {}
	var newest := slots[0]
	for s in slots:
		if FileAccess.get_modified_time(slot_path(s)) > FileAccess.get_modified_time(slot_path(newest)):
			newest = s
	return load_game(newest)
	
func has_saves() -> bool:
	return not get_slots().is_empty()
	
func get_slots() -> Array[int]:
	var slots: Array[int] = []
	var dir := DirAccess.open(saves_dir)
	if dir == null:
		return slots
	for file in dir.get_files():
		if file.begins_with(slot_prefix) and file.ends_with(slot_extension):
			slots.append(int(file.trim_prefix(slot_prefix).trim_suffix(slot_extension)))
	slots.sort()
	return slots
	
func delete_slot(slot: int) -> void:
	DirAccess.remove_absolute(slot_path(slot))
	
func next_slot() -> int:
	var slots := get_slots()
	if slots.is_empty():
		return 1
	return slots[-1] + 1
	
func slot_path(slot: int) -> String:
	return "%s/%s%03d%s" % [saves_dir, slot_prefix, slot, slot_extension]
