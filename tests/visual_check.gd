extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game = load("res://main.tscn").instantiate()
	game.state.save_path = "user://isolated-test-start.json"
	root.add_child(game)
	game.state = load("res://scripts/ecology.gd").new()
	game.state.seed_value = 48271
	game.forest.state = game.state
	game.state.paused = true
	await process_frame
	await process_frame
	await create_timer(1.0).timeout
	root.get_texture().get_image().save_png("res://builds/forest.png")
	game.panel = "habitat"
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://builds/habitat.png")
	game.state.document("ant")
	game.modal = "notebook"
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://builds/notebook.png")
	game.modal = "plate"
	game.plate = 0
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://builds/plate.png")
	quit()
