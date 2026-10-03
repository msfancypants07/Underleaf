extends SceneTree
var failures: int = 0
func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://main.tscn").instantiate()
	game.state.save_path = "user://isolated-test-start.json"
	root.add_child(game)
	game.state = load("res://scripts/ecology.gd").new()
	game.state.save_path = "user://interface-test.json"
	game.forest.state = game.state
	game.state.tutorial.enabled = false
	game.modal = ""
	game.state.paused = true
	await process_frame
	await process_frame
	game.selected = "ant"
	game.dispatch("document")
	check(game.state.unlocked==1,"Document button unlocks chemical sense")
	game.dispatch("panel:habitat")
	game.drag_key="plants"
	game.adjust_habitat(1327)
	check(game.state.habitats[0].plants==75,"Slider maps screen position to habitat percentage")
	game.selected="treehopper"
	game.dispatch("document")
	game.dispatch("zone:1")
	check(game.state.zone==1 and game.state.unlocked==2,"UI discovery opens and navigates lower montane")
	game.dispatch("notebook")
	await process_frame
	await process_frame
	check(game.modal=="notebook","Notebook opens")
	for action in game.actions:
		check(not action.action.begins_with("slider:"),"Modal excludes hidden habitat hit targets")
	game.dispatch("plate:0")
	check(game.modal=="plate" and game.plate==0,"Plate opens from notebook")
	game.dispatch("close")
	game.dispatch("day")
	check(game.state.day==2,"Next day advances simulation")
	game.dispatch("audio")
	check(not game.audio_on,"Audio can be muted")
	DirAccess.remove_absolute(game.state.save_path)
	print("Interface checks complete: ",failures," failures")
	await create_timer(0.5).timeout
	game.queue_free()
	await process_frame
	quit(failures)
