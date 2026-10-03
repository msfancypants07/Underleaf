extends SceneTree
const State = preload("res://scripts/ecology.gd")
var failures := 0
var checks := 0
var game
var screenshots: bool = false
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		push_error(message)
		failures += 1
func _initialize() -> void:
	screenshots = "--screenshots" in OS.get_cmdline_user_args()
	call_deferred("run")
func frame() -> void:
	await process_frame
	if DisplayServer.get_name()=="headless": await process_frame
	else: await RenderingServer.frame_post_draw
func capture(name: String) -> void:
	await frame()
	if screenshots: root.get_texture().get_image().save_png("res://builds/mystery-"+name+".png")
func click(action: String) -> void:
	await frame()
	var found := false
	for hit in game.actions:
		if hit.action==action:
			game.activate_at(hit.rect.get_center())
			found = true
			break
	if not found: print("MISSING ",action," modal=",game.modal," phase=",game.state.mystery.phase," actions=",game.actions.map(func(a): return a.action))
	check(found,"Reachable on-screen action: "+action)
func key(code: int) -> void:
	var e := InputEventKey.new()
	e.keycode=code
	e.pressed=true
	game._input(e)
func run() -> void:
	game = load("res://main.tscn").instantiate()
	game.state.save_path="user://mystery-ui-isolated.json"
	DirAccess.remove_absolute(game.state.save_path)
	game.audio_on=false
	root.add_child(game)
	game.set_process_input(false) # Isolate the fixture from unrelated desktop keystrokes.
	game.state.tutorial.enabled=false
	game.selected="ant"
	game.modal=""
	game.state.paused=true
	game.state.seed_value=48271
	await frame()
	await click("document")
	check(game.panel=="inquiry" and game.state.unlocked==1,"Ants introduce the optional inquiry")
	await capture("invitation")
	await click("m:trail")
	check(game.state.mystery.trail_found,"Chemical route can be inspected")
	await click("sense:0")
	await frame()
	var pos: Vector2 = game.world_rect.position+Vector2(118,210)/Vector2(480,332)*game.world_rect.size
	game.activate_at(pos)
	key(KEY_B)
	check(game.state.mystery.ready(),"Mouse and keyboard can inspect local patches")
	await capture("patches")
	await click("m:predict")
	await click("m:prediction:1")
	await click("m:baseline")
	var before: float = game.state.mystery.baseline.elapsed
	game._process(10)
	check(game.state.mystery.baseline.elapsed==before,"Pause stops automatic trial time")
	await click("pause")
	game._process(1)
	check(game.state.mystery.baseline.elapsed>before,"Resume advances trial")
	await click("pause")
	for i in range(4): await click("m:advance")
	await click("m:journal")
	await capture("baseline")
	await click("m:sample:0")
	await frame()
	var has_review := false
	for hit in game.actions:
		if hit.action=="m:review": has_review=true
	check(not has_review,"Cannot acknowledge end comparison while viewing initial wetting")
	await click("m:sample:4")
	await click("m:review")
	await click("m:preview")
	await capture("preview")
	await click("m:grow")
	check(game.state.mystery.shelter[1]==0.22,"Preview confirmation does not instantly grow shelter")
	await click("m:advance")
	await click("m:trial")
	await click("m:advance")
	# Save/reload while the repeat is running, using the same interface afterwards.
	var saved = State.new()
	check(saved.load_game(game.state.save_path),"Can reopen during a running trial")
	saved.save_path=game.state.save_path
	saved.paused=true
	game.state=saved
	game.forest.state=saved
	for i in range(3): await click("m:advance")
	await click("m:journal")
	await capture("comparison")
	await click("m:review")
	await click("m:reflect")
	await click("m:reflection:1")
	await click("m:record")
	check(game.modal=="relationship" and not game.state.mystery.plate_record.is_empty(),"Relationship earned through UI")
	check(game.state.documented.size()==1,"Relationship does not inflate species count")
	await capture("plate")
	await click("m:notes")
	await capture("notes")
	await click("close")
	await click("notebook")
	await click("m:plate")
	check(game.modal=="relationship","Notebook reopens earned plate")
	await click("m:return")
	check(game.state.zone==0 and game.state.sense==0,"Bookmark returns to the living place")
	await click("m:journal")
	var snapshot: Dictionary = game.state.mystery.serialize().duplicate(true)
	game.activate_at(game.world_rect.position+Vector2(600,400))
	check(game.state.mystery.serialize()==snapshot,"Modal clicks do not leak into the forest")
	key(KEY_TAB)
	check(game.focus_index>=0,"Buttons accept keyboard focus")
	key(KEY_ESCAPE)
	await click("help")
	await capture("help")
	await click("m:motion")
	check(game.state.mystery.reduced_motion,"Reduced-motion control works")
	await click("close")
	game.state.save_game()
	DirAccess.remove_absolute(game.state.save_path)
	print("Mystery interface checks: ",checks,"; failures: ",failures)
	game.queue_free()
	await frame()
	quit(failures)
