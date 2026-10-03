extends Control

const Ecology = preload("res://scripts/ecology.gd")
const Tutorial = preload("res://scripts/tutorial.gd")
const MysteryUI = preload("res://scripts/mystery_ui.gd")
const Study = preload("res://scripts/mystery.gd")
const Plates = preload("res://scripts/plates.gd")
const Forest = preload("res://scripts/forest.gd")
const CREAM = Color("ece9d5")
const MUTED = Color("9ea99a")
const ACCENT = Color("d0da9a")
const LINE = Color("34453a")
const PANEL = Color("15271f")
const MODES = ["Visible", "Chemical", "Vibration", "Ultraviolet", "Ultrasound", "Polarization"]
const ZONES = ["Premontane", "Lower montane", "Upper montane", "Elfin ridge"]
var state := Ecology.new()
var forest: Node2D
var font: Font
var serif: Font
var mono: Font
var actions: Array = []
var selected: String = ""
var panel: String = "observe"
var modal: String = ""
var plate: int = 0
var toast: String = "Follow the moving leaves. Click the leafcutter colony to begin."
var toast_time: float = 12
var elapsed: float = 0
var audio_clock: float = 0
var audio_on: bool = true
var voice: AudioStreamPlayer
var drag_key: String = ""
var world_rect := Rect2(24,158,1008,608)
var save_clock: float = 0
var hovered_action: String = ""
var inquiry_ui = MysteryUI.new()
var tutorial_ui = Tutorial.new()
var selected_patch: int = -1
var mystery_sample: int = 4
var mystery_note_page: int = 0
var focus_index: int = -1

func _ready() -> void:
	inquiry_ui.host = self
	tutorial_ui.host = self
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	if OS.has_feature("web"):
		font = load("res://assets/fonts/SourceSans3.ttf")
		serif = load("res://assets/fonts/Lora.ttf")
		mono = load("res://assets/fonts/IBMPlexMono.ttf")
	else:
		font = SystemFont.new()
		font.font_names = PackedStringArray(["Avenir Next", "DejaVu Sans"])
		serif = SystemFont.new()
		serif.font_names = PackedStringArray(["Georgia", "DejaVu Serif"])
		mono = SystemFont.new()
		mono.font_names = PackedStringArray(["Menlo", "DejaVu Sans Mono"])
	var loaded := state.load_game()
	if loaded:
		toast = "Welcome back. Your forest has been waiting."
		if state.mystery.trail_found:
			toast = "Your patch observations are saved. Open Inquiry or press J to pick up the study."
		selected = ""
	else:
		state.seed_value = int(Time.get_unix_time_from_system()) % 1000000
	if tutorial_ui.active():
		state.paused = true
		if not state.tutorial.started: modal = "tutorial_welcome"
	else:
		toast = "Welcome back. Your forest is preserved. Open ? for tutorial lessons or a backed-up fresh start."
	var container := SubViewportContainer.new()
	container.position = world_rect.position
	container.size = world_rect.size
	container.stretch = true
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(480,332)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	# Keep the forest's deliberately small pixel grid when stretching.
	container.stretch_shrink = 2
	forest = Forest.new()
	forest.state = state
	forest.scale = Vector2(504.0/480.0,304.0/332.0)
	viewport.add_child(forest)
	# Parent drawing is behind children; the UI is rendered in a top-level sibling.
	var overlay := Control.new()
	overlay.set_script(preload("res://scripts/interface.gd"))
	overlay.host = self
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	voice = AudioStreamPlayer.new()
	if OS.has_feature("web"): voice.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	voice.volume_db = -24
	add_child(voice)
	get_tree().auto_accept_quit = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		state.save_game()
		get_tree().quit()

func _process(delta: float) -> void:
	elapsed += delta
	toast_time = maxf(0,toast_time-delta)
	if not state.paused and modal.is_empty() and not tutorial_ui.active():
		state.events.clear()
		state.advance_hours(delta * 0.035)
		if not state.events.is_empty(): notify(state.events[-1])
		tutorial_ui.remember_stage()
	save_clock += delta
	if save_clock > 15:
		save_clock = 0
		state.save_game()
	forest.selected = selected
	forest.selected_patch = selected_patch
	audio_clock += delta
	if audio_on and modal.is_empty() and state.sense in [2,4] and audio_clock > 2.0:
		audio_clock = 0
		tone(220 if state.sense==2 else 930,0.16 if state.sense==2 else 0.07)
	get_child(1).queue_redraw()

func tone(hz: float, duration: float) -> void:
	if not audio_on: return
	var wav := AudioStreamWAV.new()
	wav.mix_rate = 22050
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	var bytes := PackedByteArray()
	bytes.resize(int(22050*duration)*2)
	for i in range(bytes.size()/2):
		var envelope := sin(PI*i/(bytes.size()/2.0))
		var sample := int(sin(TAU*hz*i/22050.0)*envelope*16000)
		bytes.encode_s16(i*2,sample)
	wav.data = bytes
	voice.stream = wav
	voice.play()

func notify(message: String) -> void:
	toast = message
	toast_time = 9

func text(c: CanvasItem, value: String, x: float, y: float, size_px: int = 16, color: Color = CREAM, style: String = "body") -> void:
	var f: Font = serif if style=="serif" else (mono if style=="mono" else font)
	c.draw_string(f,Vector2(x,y),value,HORIZONTAL_ALIGNMENT_LEFT,-1,size_px,color)

func paragraph(c: CanvasItem, value: String, x: float, y: float, width: float, size_px: int = 15, color: Color = MUTED) -> float:
	var line := ""
	for word in value.split(" "):
		if font.get_string_size(line+word,HORIZONTAL_ALIGNMENT_LEFT,-1,size_px).x > width and not line.is_empty():
			text(c,line,x,y,size_px,color)
			y += size_px*1.5
			line = ""
		line += word+" "
	if not line.is_empty(): text(c,line,x,y,size_px,color)
	return y+size_px*1.5

func box(c: CanvasItem, r: Rect2, color: Color, border: Color = Color.TRANSPARENT) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	if border.a > 0:
		style.border_color = border
		style.set_border_width_all(1)
	c.draw_style_box(style,r)

func button(c: CanvasItem, label: String, rect: Rect2, action: String, active: bool = false, disabled: bool = false) -> void:
	var over := rect.has_point(get_local_mouse_position()) and not disabled
	box(c,rect,Color("d0da9a") if active else (Color("304b39") if over else Color("1c3026")),Color("829466") if active else LINE)
	var col := Color("17281e") if active else (Color("64766a") if disabled else CREAM)
	var size_px := 14 if label.length()>23 else 15
	var sw := font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,size_px).x
	text(c,label,rect.position.x+(rect.size.x-sw)/2,rect.position.y+rect.size.y/2+5,size_px,col)
	if not disabled:
		if actions.size()==focus_index:
			c.draw_rect(rect.grow(3),CREAM,false,2)
		actions.append({"rect":rect,"action":action})

func render(c: CanvasItem) -> void:
	actions.clear()
	c.draw_rect(Rect2(0,0,1440,150),Color("101e18"))
	c.draw_rect(Rect2(1048,150,392,750),Color("101e18"))
	c.draw_rect(Rect2(0,766,1048,134),Color("101e18"))
	text(c,"U N D E R L E A F",26,53,29,CREAM,"serif")
	text(c,"YOUR FIRST FOREST · TUTORIAL EDITION",28,78,10,ACCENT,"mono")
	text(c,"COSTA RICA  /  " + ("NIGHT" if state.night else "DAYLIGHT"),509,38,11,MUTED,"mono")
	text(c,"Day %02d   ·   %s   ·   %02d:%02d" % [state.day,state.season(),int(state.hour),int(fmod(state.hour,1)*60)],509,65,16)
	button(c,"Notebook · %d creature pages" % state.documented.size(),Rect2(1072,25,272,46),"notebook")
	button(c,"?",Rect2(1355,25,56,46),"help")
	c.draw_line(Vector2(24,96),Vector2(1412,96),LINE)
	for i in range(4):
		button(c,("%02d  " % (i+1))+ZONES[i]+("  · locked" if not state.zone_open(i) else ""),Rect2(24+i*254,108,244,36),"zone:"+str(i),state.zone==i,not state.zone_open(i))
	text(c,"YOUR FIELD STATION",1072,132,11,ACCENT,"mono")
	# Floating location plaque and a small observation prompt.
	box(c,Rect2(42,177,239,55),Color(0.055,0.12,0.09,0.9))
	text(c,ZONES[state.zone]+" forest",56,200,19,CREAM,"serif")
	text(c,"FOG IMMERSION  %02d%%" % int(state.fog()*100),57,219,10,ACCENT,"mono")
	box(c,Rect2(816,179,197,31),Color(0.055,0.12,0.09,0.9))
	text(c,MODES[state.sense].to_upper()+" PERCEPTION",829,199,10,ACCENT,"mono")
	if toast_time>0 and modal.is_empty():
		box(c,Rect2(42,686,972,61),Color(0.045,0.1,0.075,0.94),Color("526249"))
		paragraph(c,toast,59,711,933,15,CREAM)
	# One current guide replaces competing sidebar destinations during the tutorial.
	if tutorial_ui.active():
		tutorial_ui.sidebar(c)
		tutorial_ui.banner(c)
	else:
		button(c,"Observe",Rect2(1072,157,106,37),"panel:observe",panel=="observe")
		button(c,"Habitat",Rect2(1188,157,106,37),"panel:habitat",panel=="habitat")
		button(c,"Inquiry",Rect2(1304,157,108,37),"panel:inquiry",panel=="inquiry")
		if panel == "observe": render_observation(c)
		elif panel == "inquiry": inquiry_ui.sidebar(c)
		else: render_habitat(c)
	if state.unlocked>=1 and state.zone==0 and not state.night:
		if not tutorial_ui.active(): button(c,"A question beside the log →" if state.mystery.plate_record.is_empty() else "A Shelter That Holds →",Rect2(42,244,307,35),"m:open" if state.mystery.plate_record.is_empty() else "m:plate")
		if state.sense==1:
			var route_center := world_rect.position+Vector2(196,272)/Vector2(480,332)*world_rect.size
			actions.append({"rect":Rect2(route_center-Vector2(31,23),Vector2(62,46)),"action":"m:trail"})
		if state.mystery.clear_labels:
			for i in range(2):
				var p: Vector2 = world_rect.position+Study.PATCH_POSITIONS[i]/Vector2(480,332)*world_rect.size
				box(c,Rect2(p+Vector2(-55,25),Vector2(116,24)),Color(0.05,0.1,0.075,0.91))
				text(c,"A · Sheltered" if i==0 else "B · Open",p.x-47,p.y+42,12,CREAM)
	if tutorial_ui.active():
		text(c,"TIME WAITS FOR YOUR NEXT ACTION",1072,754,10,ACCENT,"mono")
		button(c,"Revisit a lesson",Rect2(1072,768,340,33),"t:lessons")
	else:
		text(c,"PASSAGE OF TIME",1072,744,10,ACCENT,"mono")
		button(c,"Resume" if state.paused else "Pause",Rect2(1072,759,102,39),"pause")
		button(c,"Next day  →",Rect2(1184,759,228,39),"day")
		button(c,"Daylight" if state.night else "Enter night",Rect2(1072,808,163,36),"night",state.night,state.unlocked<4)
	button(c,"Sound on" if audio_on else "Sound off",Rect2(1245,808,167,36),"audio")
	text(c,"PROGRESS SAVES AUTOMATICALLY",1072,876,10,MUTED,"mono")
	text(c,"WAYS OF KNOWING",27,792,10,ACCENT,"mono")
	for i in range(6):
		button(c,str(i+1)+"  "+MODES[i]+(" ·" if i>state.unlocked else ""),Rect2(24+i*170,807,160,43),"sense:"+str(i),state.sense==i,i>state.unlocked)
	text(c,"CLICK TO OBSERVE    1–6 VIEWS    N NOTEBOOK    TAB / ENTER BUTTONS",27,879,11,MUTED,"mono")
	if not modal.is_empty(): render_modal(c)

func render_observation(c: CanvasItem) -> void:
	var s := selected_species()
	if s.is_empty():
		text(c,"A little closer.",1072,240,28,CREAM,"serif")
		paragraph(c,"Click a creature in the forest. A tiny light marks an observation you have not yet recorded.",1072,277,322,16)
	else:
		text(c,"OBSERVATION  /  %02d" % (state.species.find(s)+1),1072,227,10,ACCENT,"mono")
		text(c,s.common_name,1072,259,23,CREAM,"serif")
		text(c,s.genus+" "+s.species,1072,282,13,MUTED,"mono")
		box(c,Rect2(1072,300,340,95),PANEL,LINE)
		Forest.draw_bug(c,Vector2(1242,348),s,3.0,elapsed)
		var y := paragraph(c,s.signal,1072,423,330,16,CREAM)
		y = paragraph(c,s.requirement,1072,y+10,330,14,MUTED)
		button(c,"Recorded in notebook" if state.documented.has(s.id) else "Document observation  +",Rect2(1072,553,340,44),"document",not state.documented.has(s.id),not state.visible(s) or state.documented.has(s.id))
		if state.documented.has(s.id): button(c,"Open specimen plate",Rect2(1072,607,340,35),"plate:"+str(state.species.find(s)))
	text(c,"NEXT DISCOVERY",1072,674,10,ACCENT,"mono")
	paragraph(c,next_hint(),1072,698,333,13,MUTED)

func next_hint() -> String:
	return ["Document the leafcutter colony in visible light.","Restore native plants to 60%. Use chemical perception to find the treehopper.","Visit lower montane. Raise flowering cover to 65%; use vibration.","Visit upper montane. Keep canopy 65% and flowers 60%; use UV.","At night, keep upper montane moisture 65% and deadwood 55%; use ultrasound.","Explore the elfin ridge in polarization. Revisit earlier zones for optional plates."][state.unlocked]

func render_habitat(c: CanvasItem) -> void:
	text(c,"Make room for life.",1072,235,27,CREAM,"serif")
	paragraph(c,"Shape this patch gently. Each elevation keeps its own conditions.",1072,266,328,14)
	var h: Dictionary = state.habitats[state.zone]
	var keys := ["moisture","canopy","plants","wood"]
	var titles := ["Moisture retention","Canopy cover","Native stems & flowers","Decaying wood"]
	for i in range(4):
		var y := 324+i*66
		text(c,titles[i],1072,y,14)
		text(c,"%d%%" % h[keys[i]],1368,y,13,ACCENT,"mono")
		box(c,Rect2(1072,y+13,340,9),Color("2d4032"))
		box(c,Rect2(1072,y+13,340*h[keys[i]]/100,9),Color("a0b87a"))
		c.draw_circle(Vector2(1072+340*h[keys[i]]/100,y+17.5),6,CREAM)
		actions.append({"rect":Rect2(1066,y+3,352,29),"action":"slider:"+keys[i]})
	text(c,"LIFE IN THE HOST LEAVES",1072,600,10,ACCENT,"mono")
	text(c,state.larva_stage(),1072,628,19,CREAM,"serif")
	var desc := "Premontane: 65% plants, 55% canopy, 50% moisture welcomes a morpho egg. Advance a day."
	if state.larva_age >= 0:
		desc = "Development %d / 8 days · condition %d%%. Keep the premontane patch sheltered and moist." % [state.larva_age,int(state.larva_quality*100)]
	if state.exposure > 0: desc = "Exposed for %d days. Restore premontane moisture and canopy above 20%% now." % state.exposure
	paragraph(c,desc,1072,655,334,14)

func selected_species() -> Dictionary:
	for s in state.species:
		if s.id == selected: return s
	return {}

func render_modal(c: CanvasItem) -> void:
	# Remove covered hit targets, so clicks cannot leak into the world.
	actions.clear()
	c.draw_rect(Rect2(0,0,1440,900),Color(0.025,0.05,0.035,0.94))
	box(c,Rect2(65,50,1310,800),Color("14251d"),LINE)
	button(c,"Close  ×",Rect2(1215,73,129,37),"close")
	if modal.begins_with("tutorial_"):
		tutorial_ui.page(c,modal)
	elif modal.begins_with("mystery") or modal=="relationship":
		if modal=="mystery_reflect": inquiry_ui.reflection_page(c)
		else: inquiry_ui.page(c,modal)
	elif modal == "help":
		text(c,"A small world, newly perceived.",105,134,39,CREAM,"serif")
		var paragraphs := ["Observe → perceive → restore → return. There is no collecting and no capture. Click an animal, then document its behavior. Each anchor discovery awakens a sense.","Begin with the moving leaves on the forest floor. Document the ants to reveal scent trails. The next-discovery note tells you where to look and which habitat conditions help.","Use Habitat to adjust moisture, cover, native plants, and decaying wood. Changes are local to the current zone. Life in other zones also develops as days pass. A day takes about eleven minutes; Next day skips the wait.","Raise a morpho in place: restore its premontane host patch, then keep it safely sheltered for eight game days. Only three consecutive days of extreme exposure causes loss. Safe but imperfect care lowers condition.","Keys: 1–6 senses; Space pause; N notebook; H habitat; J inquiry journal; Escape close; F11 fullscreen. Tab and Enter navigate buttons. After the ants, open Inquiry: T follows the route and A/B inspect patches.","This first playable edition contains seven species and eight plates. Habitat thresholds, development times, synthesized sensory sounds, and some occurrence placements are illustrative. Each notebook plate provides its source and uncertainty; audio is not a field recording."]
		var y := 200.0
		for p in paragraphs: y = paragraph(c,p,107,y,1140,18,CREAM)+24
		text(c,"WORLD SEED  " + str(state.seed_value),107,786,12,ACCENT,"mono")
		button(c,"Motion reduced" if state.mystery.reduced_motion else "Reduce motion",Rect2(107,724,206,36),"m:motion",state.mystery.reduced_motion)
		button(c,"Patch labels on" if state.mystery.clear_labels else "Patch labels off",Rect2(330,724,220,36),"m:labels",state.mystery.clear_labels)
		button(c,"Review tutorial lessons",Rect2(570,724,310,36),"t:lessons")
		button(c,"Begin a fresh tutorial",Rect2(1000,758,343,43),"new_prompt")
	elif modal == "new_prompt":
		text(c,"Begin another forest?",106,155,40,CREAM,"serif")
		paragraph(c,"Your current forest will be backed up locally before a new seed begins. The new forest starts with an empty notebook and sleeping senses.",107,215,1050,20,CREAM)
		button(c,"Keep this forest",Rect2(106,342,300,48),"close")
		button(c,"Save backup & begin",Rect2(426,342,330,48),"new_world")
	elif modal == "notebook":
		text(c,"The field notebook",104,127,39,CREAM,"serif")
		text(c,"CREATURES · %02d / 08 OPTIONAL PAGES    |    RELATIONSHIPS & LIFE HISTORY BELOW" % state.documented.size(),107,157,12,ACCENT,"mono")
		for i in range(state.species.size()):
			var s: Dictionary = state.species[i]
			var x := 105+(i%4)*310
			var y := 190+(i/4)*253
			var known := state.documented.has(s.id)
			box(c,Rect2(x,y,288,228),Color("20372a") if known else Color("192b21"),LINE)
			text(c,"PLATE %02d" % (i+1),x+17,y+27,10,MUTED,"mono")
			if known: Forest.draw_bug(c,Vector2(x+144,y+95),s,4.0,0.5)
			else: text(c,"?",x+132,y+112,42,Color("596d55"),"serif")
			text(c,s.common_name if known else "An unwritten encounter",x+17,y+160,17,CREAM,"serif")
			text(c,ZONES[int(s.zone)],x+17,y+184,12,MUTED)
			button(c,"View plate" if known else "Discovery notes",Rect2(x+15,y+196,258,26),"plate:"+str(i))
		button(c,"Stewardship" if state.documented.size()==8 or state.tutorial.completed else "Stewardship · after your first forest",Rect2(105,730,460,48),"stewardship",false,state.documented.size()<8 and not state.tutorial.completed)
		button(c,"Relationship · A Shelter That Holds" if not state.mystery.plate_record.is_empty() else "Mystery · The patch that holds the mist",Rect2(584,730,728,48),"m:plate" if not state.mystery.plate_record.is_empty() else "m:journal",false,state.unlocked<1)
		button(c,"Life history · your butterfly",Rect2(105,788,460,38),"t:history")
		button(c,"Revisit tutorial lessons",Rect2(584,788,728,38),"t:lessons")
	elif modal == "plate":
		var s: Dictionary = state.species[plate]
		var known := state.documented.has(s.id)
		text(c,"PLATE %02d  /  %s" % [plate+1,"DOCUMENTED" if known else "NOT YET OBSERVED"],106,115,12,ACCENT,"mono")
		text(c,s.common_name,105,163,38,CREAM,"serif")
		text(c,s.genus+" "+s.species,107,193,17,MUTED,"mono")
		box(c,Rect2(105,230,535,465),Color("e3dfbf"))
		if known:
			for r in [100,155,198]: c.draw_arc(Vector2(372,445),r,0,TAU,90,Color("c7c9aa"),1)
			Plates.draw(c,Vector2(372,445),s)
			text(c,"OBSERVED IN PLACE  ·  NEVER COLLECTED",136,661,11,Color("59634d"),"mono")
		else:
			text(c,"A space for discovery.",181,430,27,Color("59634d"),"serif")
		text(c,"NATURAL HISTORY",683,257,12,ACCENT,"mono")
		var y := paragraph(c,s.fact if known else s.requirement,683,290,602,19,CREAM)
		text(c,"EVIDENCE  /  "+s.confidence.to_upper(),683,y+40,12,ACCENT,"mono")
		y = paragraph(c,s.uncertainty,683,y+70,602,16,MUTED)
		if known: y = paragraph(c,"Perception note: "+s.signal,683,y+20,602,16,CREAM)
		if known and s.id=="morpho": text(c,"REARED IN PLACE · CONDITION %d%%" % int(state.larva_quality*100),683,y+23,12,ACCENT,"mono")
		button(c,"Read research source ↗",Rect2(682,639,325,43),"source:"+str(plate))
		button(c,"← Notebook",Rect2(105,739,225,44),"notebook")
		button(c,"Previous",Rect2(1085,739,124,44),"prev")
		button(c,"Next",Rect2(1220,739,124,44),"next")
	elif modal == "stewardship":
		text(c,"The forest goes on.",106,139,44,CREAM,"serif")
		paragraph(c,"Your observations are a beginning. Nothing has been removed. How might you keep supporting this connected, living place?",106,186,1090,21,CREAM)
		text(c,"HABITAT PRESSURE   %d%%" % state.threat,106,285,13,ACCENT,"mono")
		paragraph(c,"A rising cloud base and drying edges slowly reduce moisture retention. Restoration counters this pressure on each passing day. These are illustrative conservation scenarios.",106,327,1070,18)
		var responses := ["Plant habitat corridors","Retain shade trees","Restore epiphyte cover","Restore specialist host plants"]
		for i in range(4): button(c,("Restored · " if state.restoration.has(i) else "")+responses[i],Rect2(106,411+i*73,900,53),"restore:"+str(i),state.restoration.has(i),state.restoration.has(i))
		button(c,"Return to the living forest",Rect2(106,744,410,43),"close")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_TAB:
			if not actions.is_empty(): focus_index = posmod(focus_index+(-1 if event.shift_pressed else 1),actions.size())
			return
		if event.keycode in [KEY_ENTER,KEY_KP_ENTER] and focus_index>=0 and focus_index<actions.size():
			var action: String = actions[focus_index].action
			dispatch(action)
			return
		match event.keycode:
			KEY_J: dispatch("m:journal")
			KEY_ESCAPE: modal = ""
			KEY_SPACE: state.paused = not state.paused
			KEY_N: modal = "" if modal=="notebook" else "notebook"
			KEY_H: panel = "habitat"
			KEY_F11: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
		if modal.is_empty():
			if event.keycode==KEY_A: dispatch("m:inspect:0")
			if event.keycode==KEY_B: dispatch("m:inspect:1")
			if event.keycode==KEY_T: dispatch("m:trail")
		if modal.is_empty() and event.keycode>=KEY_1 and event.keycode<=KEY_6: change_sense(event.keycode-KEY_1)
	if event is InputEventMouseMotion:
		if not drag_key.is_empty(): adjust_habitat(get_local_mouse_position().x)
		forest.hovered = ""
		if modal.is_empty() and world_rect.has_point(get_local_mouse_position()): forest.hovered = bug_at(get_local_mouse_position())
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if not event.pressed:
			if not drag_key.is_empty(): state.save_game()
			drag_key = ""
			return
		activate_at(get_local_mouse_position())

func activate_at(pos: Vector2) -> void:
	for hit in actions:
		if hit.rect.has_point(pos):
			dispatch(hit.action)
			return
	if modal.is_empty() and world_rect.has_point(pos):
		if state.zone==0 and state.unlocked>=1 and not state.night:
			var local_point := (pos-world_rect.position)/world_rect.size*Vector2(480,332)
			for i in range(2):
				if local_point.distance_to(Study.PATCH_POSITIONS[i])<32:
					dispatch("m:inspect:"+str(i))
					return
		selected_patch = -1
		selected = bug_at(pos)
		panel = "observe"
		tutorial_ui.observe(selected)
		state.save_game()
		if selected.is_empty(): notify("Look for movement, or try another way of sensing the forest.")

func bug_at(pos: Vector2) -> String:
	var p := (pos-world_rect.position)/world_rect.size*Vector2(480,332)
	var nearest := 20.0
	var result := ""
	for s in state.species:
		if state.visible(s):
			var distance: float = forest.location(s).distance_to(p)
			if distance < nearest:
				nearest = distance
				result = s.id
	return result

func adjust_habitat(x: float) -> void:
	state.habitats[state.zone][drag_key] = roundf(clampf((x-1072)/340*100,0,100))

func change_sense(index: int) -> void:
	if index > state.unlocked:
		notify("This perception is still sleeping. Follow the next discovery.")
		return
	state.sense = index
	selected = ""
	tone(180+index*95,0.14)
	state.save_game()

func dispatch(action: String) -> void:
	var parts := action.split(":")
	focus_index = -1
	if parts[0]=="t":
		tutorial_ui.dispatch(parts)
		return
	if parts[0]=="m":
		drag_key = ""
		inquiry_ui.dispatch(parts)
		return
	match parts[0]:
		"zone":
			if not state.zone_open(int(parts[1])): return
			state.zone = int(parts[1])
			selected = ""
			notify(ZONES[state.zone]+" forest. "+(tutorial_ui.goal() if tutorial_ui.active() else next_hint()))
		"sense": change_sense(int(parts[1]))
		"panel": panel = parts[1]
		"slider":
			drag_key = parts[1]
			adjust_habitat(get_local_mouse_position().x)
		"document":
			if tutorial_ui.active() and not state.tutorial.inspected.has(selected):
				notify("Click and inspect the creature before recording it.")
				return
			var previously_unlocked: int = state.unlocked
			var previous_sense: int = state.sense
			var previous_night: bool = state.night
			var previous_count: int = state.documented.size()
			notify(state.document(selected))
			if tutorial_ui.active():
				state.sense = previous_sense
				state.night = previous_night
				if state.documented.size()>previous_count and state.larva_age>=0 and not state.adult:
					state.advance_day()
					tutorial_ui.remember_stage()
				if state.unlocked>previously_unlocked: modal = "tutorial_unlock"
				if tutorial_ui.chapter()==6: modal = "tutorial_end"
			elif previously_unlocked==0 and state.unlocked==1:
				panel = "inquiry"
				notify("Scent becomes a landscape. Follow the route around the log: a small question is waiting there.")
			tone(600,0.3)
			if not tutorial_ui.active() and state.documented.size()==8 and not state.tutorial.completed: modal = "stewardship"
		"notebook": modal = "notebook"
		"help": modal = "help"
		"new_prompt": modal = "new_prompt"
		"new_world":
			if state.save_game("user://forest-backup-"+str(int(Time.get_unix_time_from_system()))+".json") != OK:
				notify("Could not back up the forest. Your current world is unchanged.")
				return
			state = Ecology.new()
			state.seed_value = int(Time.get_unix_time_from_system()) % 1000000
			forest.state = state
			selected = ""
			state.paused = true
			modal = "tutorial_welcome"
			panel = "observe"
			notify("A new clearing. Follow the moving leaves to begin.")
		"close": modal = ""
		"plate":
			plate = int(parts[1])
			modal = "plate"
		"prev": plate = posmod(plate-1,state.species.size())
		"next": plate = (plate+1)%state.species.size()
		"source": OS.shell_open(state.species[int(parts[1])].source)
		"pause": state.paused = not state.paused
		"day":
			state.advance_day()
			tutorial_ui.remember_stage()
			notify(state.events[-1] if not state.events.is_empty() else "Day %d. The forest grows quietly. %s." % [state.day,state.larva_stage()])
		"night":
			if state.unlocked < 4: return
			state.night = not state.night
			selected = ""
		"audio":
			audio_on = not audio_on
			if not audio_on: voice.stop()
		"stewardship":
			if state.documented.size() == 8 or state.tutorial.completed: modal = "stewardship"
		"restore":
			if state.documented.size() < 8 and not state.tutorial.completed: return
			var i := int(parts[1])
			if not state.restoration.has(i): state.restoration.append(i)
			state.threat = maxf(0,state.threat-8)
	if state.save_game() != OK: notify("Could not save your forest. Check available disk space.")
