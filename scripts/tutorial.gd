extends RefCounted
const Art = preload("res://scripts/forest.gd")

var host: Control
const CHAPTERS = ["Notice life", "Reveal a hidden world", "Ask, change, compare", "Make room for a life", "Practice new perceptions", "Return to a familiar life", "Tutorial complete"]
const SENSE_NOTES = ["Ordinary light reveals shapes and movement.", "Chemical perception draws scent information as a trail you can follow.", "Vibration reveals signals traveling through living stems.", "Ultraviolet translates otherwise invisible contrasts into colors you can see.", "Ultrasound translates high-frequency sound into visible pulses and synthetic tones.", "Polarization reveals the orientation of reflected light as shifting bands."]

func active() -> bool:
	return host.state.tutorial.enabled and not host.state.tutorial.completed

func chapter() -> int:
	var s = host.state
	if not s.documented.has("ant"): return 0
	if not s.mystery.trail_found: return 1
	if s.mystery.plate_record.is_empty(): return 2
	if s.larva_age<0 and not s.adult: return 3
	if not s.documented.has("ridge"): return 4
	if not s.documented.has("morpho"): return 5
	return 6

func target() -> String:
	var s = host.state
	if chapter()==0: return "ant"
	if chapter()==5: return "morpho" if s.adult else ""
	if chapter()!=4: return ""
	for id in ["treehopper","bumblebee","moth","scarab","ridge"]:
		if not s.documented.has(id): return id
	return ""

func specimen(id: String) -> Dictionary:
	for s in host.state.species:
		if s.id==id: return s
	return {}

func goal() -> String:
	return ["Find and record the moving leaves.", "Follow a trail ordinary sight cannot reveal.", "Find out whether shelter changes drying.", "Prepare a host patch and welcome an egg.", "Learn each view while your butterfly develops.", "Return to the butterfly and observe its adult form.", "You have observed, investigated, and cared."][chapter()]

func banner(c: CanvasItem) -> void:
	var h = host
	h.box(c,Rect2(42,239,735,70),Color(0.045,0.10,0.075,0.96),h.LINE)
	h.text(c,"YOUR FIRST FOREST  /  CHAPTER %d OF 7" % (chapter()+1),58,260,11,h.ACCENT,"mono")
	h.text(c,CHAPTERS[chapter()]+" · "+goal(),58,286,14,h.CREAM)
	var id := target()
	if not id.is_empty():
		var s := specimen(id)
		if h.state.visible(s):
			var p: Vector2 = h.world_rect.position+h.forest.location(s)/Vector2(480,332)*h.world_rect.size
			c.draw_arc(p,28,0,TAU,40,h.ACCENT,2)
			h.text(c,"Look here",p.x-29,p.y-34,13,h.CREAM)
			var hit := Rect2(p-Vector2(28,28),Vector2(56,56))
			if h.actions.size()==h.focus_index: c.draw_rect(hit.grow(3),h.CREAM,false,2)
			h.actions.append({"rect":hit,"action":"t:inspect:"+id})
	elif chapter() in [3,5] and h.state.zone==0:
		var p: Vector2 = h.world_rect.position+Vector2(244,194)/Vector2(480,332)*h.world_rect.size
		c.draw_arc(p,30,0,TAU,40,h.ACCENT,2)
		h.text(c,"Your host leaf",p.x-45,p.y-37,13,h.CREAM)

func action(c: CanvasItem, title: String, id: String, y: float, primary: bool = false) -> void:
	host.button(c,title,Rect2(1072,y,340,39),id,primary)

func sidebar(c: CanvasItem) -> void:
	var h = host
	var s = h.state
	var ch := chapter()
	if ch==2:
		h.inquiry_ui.sidebar(c)
		return
	h.text(c,"YOUR NEXT STEP",1072,183,11,h.ACCENT,"mono")
	h.paragraph(c,CHAPTERS[ch],1072,219,332,25,h.CREAM)
	var body := ""
	var why := ""
	var id := target()
	var sp := specimen(id)
	if ch==0:
		body = "Some leaves are moving across the forest floor. Click the outlined colony to inspect it, then record what you found."
		why = "Your notebook keeps observations of living creatures. Nothing is captured."
	elif ch==1:
		body = "Try chemical perception, then follow the highlighted route beside the fallen log. A new view reveals information ordinary sight misses."
		why = "These are translated sensory views. Recording an animal unlocks a learning tool in this game."
	elif ch==3:
		body = "Your study showed how to compare habitat changes. Now prepare the host patch for a butterfly, using its separate care rules."
		why = "The study changed only patch B. Butterfly care uses the surrounding clearing; its settings and timing are simplified game rules."
	elif ch==4:
		body = "Next encounter: "+str(sp.common_name)+". Visit "+h.ZONES[int(sp.zone)]+", prepare its habitat, and inspect it in "+h.MODES[int(sp.mode)]+" perception."
		why = "Each new view has one encounter to practice. Discovery cues are authored game conventions; species pages explain the evidence."
	elif ch==5:
		body = "Return to the host leaf in premontane forest. Follow the remaining stages, then click the adult's blue wings and record your observation."
		why = "You are following the same life through change. Days and care conditions are compressed, not real-world rearing instructions."
	else:
		body = "You recorded hidden life, compared shelter, and followed a butterfly to adulthood. Your first forest story is complete."
		why = "There is still room to explore. Extra notebook pages are optional discoveries, not missing tutorial tasks."
	if not id.is_empty() and h.selected==id and s.tutorial.inspected.has(id):
		body = "Observed: "+str(sp.common_name)+". "+str(sp.fact if ch==0 else sp.signal)+" Record this encounter to keep its evidence and source in the notebook."
	var y: float = h.paragraph(c,body,1072,280,332,16,h.CREAM)
	y = h.paragraph(c,"WHY · "+why,1072,y+13,332,13,h.MUTED)+13
	if ch==0:
		if h.selected=="ant" and s.tutorial.inspected.has("ant"):
			action(c,"Record the leafcutters", "document",y,true)
		else: action(c,"Point out the colony", "t:point",y)
	elif ch==1:
		if s.zone!=0 or s.night: action(c,"Return to the clearing", "t:home",y,true)
		elif s.sense!=1: action(c,"Reveal scent trails", "sense:1",y,true)
		else: action(c,"Follow the route beside the log", "m:trail",y,true)
	elif ch==3:
		if s.zone!=0 or s.night: action(c,"Return to the host patch", "t:home",y,true)
		else: care_actions(c,y,true)
	elif ch==4:
		if s.zone!=int(sp.zone): action(c,"Visit "+h.ZONES[int(sp.zone)],"zone:"+str(sp.zone),y,true)
		elif not s.supported(sp): care_actions(c,y,false)
		elif id=="ridge" and s.night: action(c,"Return to daylight","night",y,true)
		elif s.id_is_night_target(id) and not s.night: action(c,"Enter the night forest","night",y,true)
		elif s.sense!=int(sp.mode): action(c,"Try "+h.MODES[int(sp.mode)],"sense:"+str(sp.mode),y,true)
		elif h.selected==id and s.tutorial.inspected.has(id): action(c,"Record "+str(sp.common_name),"document",y,true)
		else: action(c,"Point out the encounter","t:point",y)
	elif ch==5:
		if s.zone!=0 or s.night: action(c,"Return to your butterfly","t:home",y,true)
		elif s.sense!=0: action(c,"Look in ordinary light","sense:0",y,true)
		elif not s.adult:
			if not safe_home(): action(c,"Restore cover and moisture","t:recover",y,true)
			else: action(c,"Continue to the next change","t:wait",y,true)
		elif h.selected=="morpho" and s.tutorial.inspected.has("morpho"): action(c,"Record your butterfly","document",y,true)
		else: action(c,"Point out the butterfly","t:point",y)
	else: action(c,"Celebrate your first forest","t:ending",y,true)
	if ch>=3:
		h.text(c,"YOUR BUTTERFLY",1072,635,10,h.ACCENT,"mono")
		h.text(c,s.larva_stage(),1072,659,17,h.CREAM,"serif")
		h.text(c,"Egg  →  Caterpillar  →  Pupa  →  Adult",1072,682,12,h.MUTED)
		action(c,"Open life history","t:history",695)

func requirements() -> Dictionary:
	if chapter()==3: return {"plants":65.0,"canopy":55.0,"moisture":55.0}
	match target():
		"treehopper": return {"plants":65.0,"canopy":55.0}
		"bumblebee": return {"plants":70.0}
		"moth": return {"canopy":70.0,"plants":65.0}
		"scarab": return {"moisture":70.0,"wood":60.0}
		"ridge": return {"canopy":60.0}
	return {}

func care_actions(c: CanvasItem, y: float, butterfly: bool) -> void:
	var h = host
	var habitat: Dictionary = h.state.habitats[h.state.zone]
	var labels := {"plants":"Encourage native host growth" if butterfly else "Encourage native stems & flowers", "canopy":"Retain protective canopy", "moisture":"Restore moisture retention", "wood":"Retain decaying wood"}
	var needs := requirements()
	for key in needs:
		if habitat[key]<needs[key]:
			action(c,labels[key],"t:care:"+key,y,true)
			return
	if butterfly:
		h.paragraph(c,"Host growth, cover, and moisture are ready.",1072,y,330,14,h.ACCENT)
		action(c,"Return tomorrow: look for an egg","t:egg",y+42,true)

func safe_home() -> bool:
	var h: Dictionary = host.state.habitats[0]
	return h.moisture>=50 and h.canopy>=55 and h.plants>=65

func page(c: CanvasItem, view: String) -> void:
	var h = host
	var s = h.state
	var title := "Your First Forest"
	var paragraphs: Array = []
	if view=="tutorial_welcome":
		paragraphs = ["You are a quiet presence watching over a cloud-forest clearing. Learn to notice its hidden inhabitants, understand how their surroundings change, and help a butterfly complete its life cycle.","Your journey: notice hidden life → investigate shelter → follow an egg to adulthood. Seven guided chapters connect these goals. Extra creature pages are optional.","Follow the chapter guide beside the forest. Click what it points out, then record what you observe. Time waits while you read; tutorial time advances only when you choose an action."]
	elif view=="tutorial_unlock":
		title = h.MODES[s.unlocked]+" perception is ready"
		paragraphs = ["You recorded an encounter. Your notebook preserves it, and a new way of noticing the forest is now available.",SENSE_NOTES[s.unlocked],"This is a learning tool unlocked by observation, not a creature acquiring a new biological sense. The next encounter lets you practice it."]
	elif view=="tutorial_history":
		title = "A life in your clearing"
		paragraphs = ["Egg → Caterpillar → Pupa → Adult", "Now: "+s.larva_stage()+". This same butterfly develops in premontane forest while you explore.","The host plants and eight-day development are simplified game rules. The shelter experiment did not test butterfly preference or establish care requirements."]
		for entry in s.tutorial.history.slice(maxi(0,s.tutorial.history.size()-5)):
			paragraphs.append("Day %d · %s" % [entry.day,entry.stage])
	elif view=="tutorial_end":
		title = "Tutorial complete"
		paragraphs = ["A blue morpho has emerged in the clearing you tended, and you recorded the adult without capturing it.","You followed the leafcutters, used five new sensory views, and compared the same patches before and after changing shelter. Your relationship page preserves the evidence.","You followed a butterfly from egg to adult. These observations, the relationship study, and its life history are together in your notebook.","Continue exploring this small forest, revisit a lesson, or try stewardship: how might you keep supporting this place? Additional species pages are optional."]
	else:
		title = "Revisit a lesson"
		paragraphs = ["NOTICE · Click a moving creature, inspect it, then record an observation. Nothing is collected.","PERCEIVE · Choose an unlocked view with 1–6. Each translates a different kind of information; unlock order is a game convention.","COMPARE · At the log, inspect both patches in visible light. Start equally wet, compare after equal time, change cover at B only, and repeat. The study changes only the two local patches.","CARE · Prepare the premontane host patch and follow Egg → Caterpillar → Pupa → Adult in Life history. Conditions and days are illustrative; consult species sources for evidence.","RETURN · In exploration, Habitat offers full controls, and time can run or pause. Notebook pages keep your discoveries. Reviewing lessons does not reset your forest."]
	if view=="tutorial_unlock" and s.larva_age>=0:
		paragraphs.append("Meanwhile in your clearing: "+s.larva_stage()+". A game day passed during this field visit. Its life history is saved.")
	h.text(c,title,105,146,38,h.CREAM,"serif")
	var y := 211.0
	for p in paragraphs:
		y = h.paragraph(c,p,107,y,1130,19,h.CREAM)+22
	if view=="tutorial_end":
		Art.draw_bug(c,Vector2(1130,584),specimen("morpho"),7.0,0.5)
		h.text(c,"OBSERVED IN YOUR CLEARING",840,668,12,h.ACCENT,"mono")
	if view=="tutorial_welcome": h.button(c,"Begin: follow the moving leaves",Rect2(107,737,425,46),"t:begin",true)
	elif view=="tutorial_unlock": h.button(c,"Try "+h.MODES[s.unlocked]+" perception",Rect2(107,737,425,46),"t:try",true)
	elif view=="tutorial_end":
		h.button(c,"Continue exploring",Rect2(107,737,330,46),"t:finish",true)
		h.button(c,"Revisit a lesson",Rect2(460,737,300,46),"t:lessons")
	else:
		h.button(c,"Return to the forest",Rect2(107,737,330,46),"close",true)
		if view=="tutorial_history": h.button(c,"Read butterfly evidence",Rect2(460,737,330,46),"plate:6")

func observe(id: String) -> void:
	if not id.is_empty() and not host.state.tutorial.inspected.has(id):
		host.state.tutorial.inspected.append(id)

func remember_stage() -> void:
	var s = host.state
	if s.larva_age<0 and not s.lost: return
	var stage: String = "Adult" if s.adult else ("Egg" if s.larva_age==0 else ("Pupa" if s.larva_age>=5 else "Caterpillar"))
	if s.lost: stage = "Habitat needs recovery"
	if s.tutorial.history.is_empty() or s.tutorial.history[-1].stage!=stage:
		s.tutorial.history.append({"day":s.day,"stage":stage})
		host.notify("Your butterfly: "+stage+". Its life history is saved in the notebook.")

func dispatch(parts: PackedStringArray) -> void:
	var h = host
	var s = h.state
	match parts[1]:
		"begin":
			s.tutorial.started = true
			h.modal = ""
		"try":
			h.change_sense(s.unlocked)
			h.modal = ""
		"home":
			s.zone = 0
			s.night = false
			h.change_sense(0)
			h.modal = ""
		"care":
			var needs := requirements()
			if needs.has(parts[2]):
				s.habitats[s.zone][parts[2]] = maxf(s.habitats[s.zone][parts[2]],needs[parts[2]])
				var reasons := {"plants":"Native growth now offers more host stems and flowers in this zone.","canopy":"Canopy now provides more protective cover in this zone.","moisture":"This zone now retains more moisture.","wood":"Decaying wood now remains in this zone's habitat."}
				h.notify(reasons[parts[2]]+" These are the tutorial's simplified habitat settings.")
		"recover":
			for key in {"plants":65.0,"canopy":65.0,"moisture":65.0}:
				s.habitats[0][key] = maxf(s.habitats[0][key],65.0)
			h.notify("Protective cover, native growth, and moisture restored in the home clearing.")
		"egg":
			if chapter()==3 and safe_home():
				s.advance_day()
				remember_stage()
		"wait":
			if not safe_home(): return
			var before: String = s.larva_stage()
			var days := 0
			var age_goal: int = 1 if s.larva_age==0 else (5 if s.larva_age<5 else 8)
			while s.larva_age<age_goal and not s.adult and days<8 and safe_home():
				s.advance_day()
				days += 1
				remember_stage()
				h.notify("%d game day(s) passed. %s → %s. Check Life history." % [days,before,s.larva_stage()])
		"history": h.modal = "tutorial_history"
		"lessons": h.modal = "tutorial_lessons"
		"ending":
			if chapter()==6: h.modal = "tutorial_end"
		"finish":
			if chapter()!=6: return
			s.tutorial.completed = true
			s.paused = true
			h.modal = ""
			h.panel = "observe"
			h.notify("Tutorial complete. Explore at your pace; Resume starts the forest clock. Your notebook keeps every discovery.")
		"inspect":
			if parts.size()>2 and parts[2]==target():
				var sp := specimen(parts[2])
				if s.visible(sp):
					h.selected = parts[2]
					observe(parts[2])
		"point": h.notify("Look for the outlined creature in the forest. Click it before recording your observation.")
	s.save_game()
