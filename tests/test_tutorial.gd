extends SceneTree
const State = preload("res://scripts/ecology.gd")
var game
var failures := 0
var checks := 0
var screenshots := false
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run")
func frame() -> void:
	await process_frame
	if DisplayServer.get_name()=="headless": await process_frame
	else: await RenderingServer.frame_post_draw
func capture(name: String) -> void:
	await frame()
	if screenshots: root.get_texture().get_image().save_png("res://builds/tutorial-"+name+".png")
func click(action: String) -> void:
	await frame()
	var found := false
	for hit in game.actions:
		if hit.action==action:
			game.activate_at(hit.rect.get_center())
			found = true
			break
	check(found,"On-screen action reachable: "+action+" (chapter "+str(game.tutorial_ui.chapter())+")")
func inspect(id: String) -> void:
	await frame()
	var s: Dictionary = game.tutorial_ui.specimen(id)
	var pos: Vector2 = game.world_rect.position+game.forest.location(s)/Vector2(480,332)*game.world_rect.size
	game.activate_at(pos)
	check(game.selected==id,"World inspection selects "+id)
func reload_state() -> void:
	check(game.state.save_game()==OK,"Save succeeds")
	var restored := State.new()
	restored.save_path = game.state.save_path
	check(restored.load_game(),"Tutorial save reloads")
	check(restored.tutorial.enabled==game.state.tutorial.enabled and restored.tutorial.completed==game.state.tutorial.completed and restored.tutorial.inspected==game.state.tutorial.inspected,"Tutorial status round trips")
	check(restored.tutorial.history.size()==game.state.tutorial.history.size(),"Life history length round trips")
	for i in range(restored.tutorial.history.size()):
		check(restored.tutorial.history[i].stage==game.state.tutorial.history[i].stage and int(restored.tutorial.history[i].day)==int(game.state.tutorial.history[i].day),"Life event round trips")
	game.state = restored
	game.forest.state = restored
func run() -> void:
	screenshots = "--screenshots" in OS.get_cmdline_user_args()
	game = load("res://main.tscn").instantiate()
	game.state.save_path = "user://tutorial-test-isolated.json"
	DirAccess.remove_absolute(game.state.save_path)
	game.audio_on = false
	root.add_child(game)
	game.set_process_input(false)
	await capture("welcome")
	check(game.modal=="tutorial_welcome","Fresh forest explains role and goal")
	check(game.selected.is_empty(),"No observation selected in advance")
	await click("t:begin")
	await capture("opening")
	game.selected="ant"
	game.dispatch("document")
	check(game.state.documented.is_empty(),"Cannot record without world inspection")
	game.selected=""
	var hour: float = game.state.hour
	game.state.paused=false
	game._process(100)
	check(game.state.hour==hour,"Tutorial clock waits even when unpaused")
	await frame()
	var target_index := -1
	for i in range(game.actions.size()):
		if game.actions[i].action=="t:inspect:ant": target_index=i
	check(target_index>=0,"Creature inspection is a keyboard focus target")
	game.focus_index=-1
	var tab := InputEventKey.new()
	tab.keycode=KEY_TAB
	tab.pressed=true
	for i in range(target_index+1): game._input(tab)
	var enter := InputEventKey.new()
	enter.keycode=KEY_ENTER
	enter.pressed=true
	game._input(enter)
	check(game.selected=="ant" and game.state.tutorial.inspected.has("ant"),"Tab and Enter inspect the highlighted creature")
	await capture("ant-observed")
	await click("document")
	check(game.state.sense==0 and game.modal=="tutorial_unlock","Unlock explains without silently switching")
	await capture("unlock")
	await click("t:try")
	await click("m:trail")
	await click("sense:0")
	await click("m:inspect:0")
	await click("m:inspect:1")
	await click("m:baseline")
	for i in range(4): await click("m:advance")
	await reload_state()
	await click("m:journal")
	await capture("comparison")
	await click("m:review")
	await click("m:preview")
	await click("m:grow")
	await click("m:advance")
	await click("m:trial")
	for i in range(4): await click("m:advance")
	await click("m:journal")
	await click("m:review")
	await click("m:record")
	check(game.tutorial_ui.chapter()==3,"Relationship advances tutorial independently of species count")
	await capture("relationship")
	await click("t:home")
	await capture("care")
	await click("t:care:plants")
	await click("t:egg")
	check(game.state.larva_age==0,"Guided care welcomes an egg")
	check(game.state.tutorial.history[0].stage=="Egg","Egg is preserved in life history")
	await reload_state()
	await click("t:history")
	await capture("egg-history")
	await click("close")
	for id in ["treehopper","bumblebee","moth","scarab","ridge"]:
		var s: Dictionary = game.tutorial_ui.specimen(id)
		if game.state.zone!=int(s.zone): await click("zone:"+str(s.zone))
		var needs: Dictionary = game.tutorial_ui.requirements()
		while not game.state.supported(s):
			var changed := false
			for key in needs:
				if game.state.habitats[game.state.zone][key]<needs[key]:
					await click("t:care:"+key)
					changed = true
					break
			if not changed:
				check(false,"Habitat guide cannot progress: "+id)
				break
		if (id=="scarab" and not game.state.night) or (id=="ridge" and game.state.night): await click("night")
		if game.state.sense!=int(s.mode): await click("sense:"+str(s.mode))
		await capture(id+"-lesson")
		await inspect(id)
		await click("document")
		check(game.state.documented.has(id),"Guided encounter recorded: "+id)
		if id!="ridge": await click("t:try")
	check(game.state.unlocked==5,"All five perceptions practiced")
	check(game.state.larva_age==5,"Visits advance the butterfly to pupa")
	await click("t:home")
	await capture("pupa")
	for i in range(4):
		if game.state.adult: break
		if not game.tutorial_ui.safe_home(): await click("t:recover")
		else: await click("t:wait")
	check(game.state.adult,"Guided wait reaches adult without blind unsafe skipping")
	await reload_state()
	await inspect("morpho")
	await click("document")
	check(game.modal=="tutorial_end","Recording the adult produces an explicit ending")
	check(game.state.documented.size()==7,"Optional orchid bee not required")
	await capture("ending")
	await click("t:finish")
	check(game.state.tutorial.completed and not game.tutorial_ui.active(),"Completion enters exploration")
	await click("notebook")
	await capture("notebook")
	await click("t:history")
	await capture("life-history")
	var stages: Array = game.state.tutorial.history.map(func(e): return e.stage)
	check(stages==["Egg","Caterpillar","Pupa","Adult"],"Life history preserves the four actual stages")
	await click("close")
	await click("notebook")
	await click("stewardship")
	check(game.modal=="stewardship","Stewardship available without optional page gate")
	await click("close")
	var documented: Array = game.state.documented.duplicate()
	game.dispatch("t:lessons")
	await capture("lessons")
	check(game.state.documented==documented,"Review never resets progress")
	await reload_state()
	check(game.state.tutorial.completed,"Completion persists")
	# Old saves retain their world and do not retroactively force tutorial chapters.
	var legacy_path := "user://tutorial-legacy-test.json"
	var legacy = JSON.parse_string(FileAccess.get_file_as_string(game.state.save_path))
	legacy.version=2
	legacy.erase("tutorial")
	var file := FileAccess.open(legacy_path,FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	var old := State.new()
	check(old.load_game(legacy_path),"Version 2 forest migrates")
	check(not old.tutorial.enabled and old.documented==documented,"Migrated forest stays in exploration with discoveries intact")
	check(FileAccess.file_exists(legacy_path+".v2-backup"),"Old forest backed up")
	for path in [game.state.save_path,legacy_path,legacy_path+".v2-backup"]: DirAccess.remove_absolute(path)
	print("Tutorial checks: ",checks,"; failures: ",failures)
	game.queue_free()
	await process_frame
	quit(failures)
