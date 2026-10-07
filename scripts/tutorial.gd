extends RefCounted
const Art = preload("res://scripts/forest.gd")

var host: Control
const CHAPTERS = ["Notice life", "Reveal a hidden world", "Ask, change, compare", "Make room for a life", "Practice new perceptions", "Return to a familiar life", "Tutorial complete"]
const SENSE_NOTES = [
	"Ordinary light reveals shapes and movement, but it represents only the narrow range of wavelengths human eyes detect.",
	"Chemical perception translates a pheromone trail into a visible plume. A pheromone is a molecule released by one animal that changes the behavior of others of the same species.",
	"Vibration perception reveals signals traveling through living stems. The plant acts as the communication channel, carrying motion between insects that may be hidden from one another.",
	"Ultraviolet perception translates wavelengths beyond human vision. Many bees detect ultraviolet contrast, so a flower can present different information to a bee than it does to us.",
	"Ultrasound perception slows and visualizes frequencies above ordinary human hearing. It makes an otherwise inaccessible exchange between a hunting bat and a clicking moth perceptible.",
	"Polarization perception shows the orientation of reflected light as shifting bands. It is an analytical view for the player, not a claim that every animal shown can see polarized light."
]

const ENCOUNTER_QUESTIONS = {
	"treehopper":"A stem can carry information as well as water. Treehoppers send vibrations through plant tissue, and some exchange patterned signals called duets. Find the repeating exchange traveling along a living stem.",
	"bumblebee":"Human eyes detect only part of the electromagnetic spectrum. Many bees can detect ultraviolet wavelengths, and some flowers create strong ultraviolet contrast around their centers. Compare what this flower presents to a bee with what you see in ordinary light.",
	"moth":"Bats hunt with echolocation: they emit high-frequency calls and interpret returning echoes. This tiger moth answers with rapid ultrasonic clicks. Enter the night forest and investigate how those signals overlap.",
	"scarab":"This scarab's metallic appearance comes partly from microscopic structure in its outer covering, or cuticle, rather than pigment alone. Locate the beetle now; a later study will examine how its shell organizes reflected light.",
	"ridge":"This is the same jewel scarab, seen through a different measurement. Polarization describes the orientation in which light waves oscillate. Watch how the translated pattern shifts across its curved shell."
}

const ENCOUNTER_INTERPRETATIONS = {
	"ant":"Leafcutter ants do not eat the leaf fragments directly. Workers carry them underground as growing material for a cultivated fungus, which becomes the colony's food crop. The moving leaves are the visible edge of an insect agricultural system.",
	"treehopper":"The pulses form a patterned exchange rather than random shaking. Plant-borne vibration lets small insects communicate through the stem without relying on an airborne call. The visualization is a translation of motion that normally requires specialized equipment to detect.",
	"bumblebee":"The flower did not acquire a new pattern when you changed views. Ultraviolet perception revealed contrast that human vision omits. The game draws on bee vision, while this exact flower pattern and its relationship with this particular bumblebee remain illustrative.",
	"moth":"The broad pulse represents a bat's searching call. The moth's rapid clicks overlap the returning information and make the target harder to track. This defensive strategy is called sonar jamming; the slowed sound and visible pulses are translations for human players.",
	"scarab":"Microscopic layers in the scarab's cuticle interact with light to produce structural color. The ultrasound cue used to locate it is a game convention, not evidence that this beetle produces or detects ultrasound. The next encounter examines its optical signal.",
	"ridge":"A familiar animal stands out because you measured a different property of the same reflected light. The bands translate an optical signature created by shell structure, illumination, and viewing angle; they do not establish that the scarab itself sees polarized light."
}

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
	return ["Investigate what is carrying the moving leaves.", "Translate and follow the ants' chemical information.", "Test whether changing shelter alters water retention.", "Prepare a host patch and look for an egg.", "Use five translated senses to answer five questions.", "Follow the same butterfly through metamorphosis.", "Separate what you observed from what it can establish."][chapter()]

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
		body = "Pieces of leaf are moving across the forest floor. Look beneath them: what animal could move material many times its own size, and where might it be taking it?"
		why = "Inspect before recording. Your notebook preserves an observation without collecting the animal."
	elif ch==1:
		body = "The ants follow nearly the same route even where no path is visible. Translate their pheromone trail into a visible plume, then follow its strongest branch toward the fallen log."
		why = "A pheromone is chemical information shared between members of a species. The view is a translation for you, not a new sense acquired by the ants."
	elif ch==3:
		body = "Apply what you learned about local conditions to the surrounding clearing. A caterpillar depends on host plants: plants on which its species can feed during the larval stage. Prepare native growth, cover, and moisture before returning to inspect the leaf."
		why = "These settings represent a simplified habitat relationship, not instructions for rearing a real butterfly."
	elif ch==4:
		body = str(ENCOUNTER_QUESTIONS.get(id,"Investigate how this animal becomes visible through a different kind of information."))
		why = "Visit "+h.ZONES[int(sp.zone)]+", prepare the indicated habitat, and use "+h.MODES[int(sp.mode)]+" perception. Recording this encounter advances one game day while your butterfly develops."
	elif ch==5:
		body = butterfly_stage_explanation()
		why = "You are following the same individual through complete metamorphosis. Each button states how far tutorial time will advance; the timetable is compressed for play."
	else:
		body = "You followed evidence from an unexplained movement to chemical signals, a controlled comparison, five translated senses, and a complete butterfly life cycle. Review what was observed, what was interpreted, and what remains uncertain."
		why = "Science becomes more trustworthy when conclusions stay within the limits of the evidence."
	if not id.is_empty() and h.selected==id and s.tutorial.inspected.has(id):
		body = str(ENCOUNTER_INTERPRETATIONS.get(id,sp.fact))+" Record the encounter to preserve its evidence, source, and uncertainty note."
	var y: float = h.paragraph(c,body,1072,280,332,16,h.CREAM)
	y = h.paragraph(c,"WHY · "+why,1072,y+13,332,13,h.MUTED)+13
	if ch==0:
		if h.selected=="ant" and s.tutorial.inspected.has("ant"):
			action(c,"Record the colony and reveal its trail", "document",y,true)
		else: action(c,"Point out the colony", "t:point",y)
	elif ch==1:
		if s.zone!=0 or s.night: action(c,"Return to the clearing", "t:home",y,true)
		elif s.sense!=1: action(c,"Translate the pheromone trail", "sense:1",y,true)
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
		elif h.selected==id and s.tutorial.inspected.has(id): action(c,"Record evidence · advance one day","document",y,true)
		else: action(c,"Point out the encounter","t:point",y)
	elif ch==5:
		if s.zone!=0 or s.night: action(c,"Return to your butterfly","t:home",y,true)
		elif s.sense!=0: action(c,"Look in ordinary light","sense:0",y,true)
		elif not s.adult:
			if not safe_home(): action(c,"Restore cover and moisture","t:recover",y,true)
			else: action(c,butterfly_advance_label(),"t:wait",y,true)
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
		h.paragraph(c,"The host patch now has suitable growth, protective cover, and retained moisture.",1072,y,330,14,h.ACCENT)
		action(c,"Advance one day · inspect the host leaf","t:egg",y+55,true)

func butterfly_stage_explanation() -> String:
	var s = host.state
	if s.adult: return "The adult has emerged, a process called eclosion. Look for blue flashes in ordinary light, then inspect the same individual you first encountered as an egg."
	if s.larva_age==0: return "The embryo is developing inside the egg. Advance one game day to find the newly emerged caterpillar, also called a larva: the feeding and growing stage of complete metamorphosis."
	if s.larva_age<5: return "The caterpillar grows through stages called instars. An instar is the period between two molts, when the animal sheds an outer covering that can no longer expand with it."
	return "The caterpillar has formed a pupa. It may appear inactive, but its body is reorganizing into the adult form inside. Advance to adult emergence, then inspect the wings in ordinary light."

func butterfly_advance_label() -> String:
	var s = host.state
	if s.larva_age==0: return "Advance one day · find the caterpillar"
	if s.larva_age<5: return "Advance to the final larval instar"
	return "Advance to adult emergence"

func safe_home() -> bool:
	var h: Dictionary = host.state.habitats[0]
	return h.moisture>=50 and h.canopy>=55 and h.plants>=65

func page(c: CanvasItem, view: String) -> void:
	var h = host
	var s = h.state
	var title := "Your First Forest"
	var paragraphs: Array = []
	if view=="tutorial_welcome":
		paragraphs = ["You have arrived at a cloud-forest field station to investigate information that human senses only partly reveal. Animals here communicate through chemicals, vibrations, ultraviolet contrast, high-frequency sound, and patterns in reflected light.","Your task is to follow evidence rather than collect animals. You will begin with an unexplained movement, compare two small habitats, and observe one butterfly through a compressed life cycle. Each discovery adds a sourced field plate to your notebook.","The tutorial clock waits while you read. Time moves only when a button says that an hour, a day, or a field visit will pass. Before recording a discovery, ask: what changed in the forest, and what does that evidence allow you to conclude?"]
	elif view=="tutorial_unlock":
		title = h.MODES[s.unlocked]+" perception is ready"
		var completed_id := "ant" if s.unlocked==1 else ("treehopper" if s.unlocked==2 else ("bumblebee" if s.unlocked==3 else ("moth" if s.unlocked==4 else "scarab")))
		paragraphs = [str(ENCOUNTER_INTERPRETATIONS[completed_id]),SENSE_NOTES[s.unlocked],"The notebook separates the observation from its interpretation and keeps an uncertainty note beside the source. The next encounter asks you to use this translated view to answer a new question."]
	elif view=="tutorial_discovery":
		title = "A familiar animal, newly measured"
		paragraphs = [str(ENCOUNTER_INTERPRETATIONS["ridge"]),"Ordinary color and brightness do not describe every property of light. Polarization describes the orientation in which a light wave oscillates; the shifting bands make that property legible to a human player.","This is an optical study of the same jewel scarab, not another species. The ridge location and visualization remain interpretive, and the observation does not establish that the beetle sees polarization."]
	elif view=="tutorial_history":
		title = "A life in your clearing"
		paragraphs = ["Egg → Caterpillar (larva) → Pupa → Adult", "Now: "+s.larva_stage()+". You are following the same individual through complete metamorphosis, a life cycle in which the immature and adult forms have very different bodies.",butterfly_stage_explanation(),"The host settings and eight-day development are compressed game rules. The shelter comparison tested modeled water retention; it did not test butterfly preference or establish real care requirements."]
		for entry in s.tutorial.history.slice(maxi(0,s.tutorial.history.size()-5)):
			paragraphs.append("Day %d · %s" % [entry.day,entry.stage])
	elif view=="tutorial_end":
		title = "Tutorial complete"
		paragraphs = ["You began with unexplained movement and followed it into several kinds of evidence. Leafcutter agriculture led to chemical communication; a controlled comparison tested shelter and water retention; five translated views exposed information outside ordinary human perception.","You also followed one butterfly through complete metamorphosis. Its life history and the shelter study answer different questions: one concerns development and habitat relationships, while the other concerns modeled water retention. Neither is proof of the other.","Your notebook distinguishes observations from interpretations and uncertainty. An observation records what was detected, an interpretation explains what it may mean, and an uncertainty note identifies what the evidence cannot yet establish.","Free exploration restores the normal forest clock. Pause or Resume controls continuous time, while Next day advances directly. Additional species pages are optional discoveries."]
	else:
		title = "Revisit a lesson"
		paragraphs = ["NOTICE · Begin with a question. Inspect what changed in the scene before recording an observation; nothing is collected.","PREDICT · State what you expect when the game offers a prediction. It is a record of your reasoning, not a graded answer.","ACT · Translated senses reveal chemical, vibrational, ultraviolet, ultrasonic, and polarized information. Buttons explicitly state when an hour, day, or field visit will pass.","INTERPRET · Compare the result with the earlier condition. Keep the observation, its possible meaning, and its limits separate.","RETURN · After the tutorial, Habitat exposes full controls and time can run or pause. Reviewing these lessons does not reset your forest."]
	if view=="tutorial_unlock" and s.larva_age>=0:
		paragraphs.append("Meanwhile in your clearing: "+s.larva_stage()+". A game day passed during this field visit. Its life history is saved.")
	h.text(c,title,105,146,38,h.CREAM,"serif")
	var y := 211.0
	for p in paragraphs:
		y = h.paragraph(c,p,107,y,1130,19,h.CREAM)+22
	if view=="tutorial_end":
		Art.draw_bug(c,Vector2(1130,584),specimen("morpho"),7.0,0.5)
		h.text(c,"OBSERVED IN YOUR CLEARING",840,668,12,h.ACCENT,"mono")
	if view=="tutorial_welcome": h.button(c,"Begin by investigating the moving leaves",Rect2(107,737,480,46),"t:begin",true)
	elif view=="tutorial_unlock": h.button(c,"Try "+h.MODES[s.unlocked]+" perception",Rect2(107,737,425,46),"t:try",true)
	elif view=="tutorial_end":
		h.button(c,"Complete the tutorial and explore freely",Rect2(107,737,390,46),"t:finish",true)
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
				var reasons := {"plants":"Native growth now offers stems, flowers, and—at the home patch—leaf tissue that can represent a caterpillar host plant.","canopy":"Retained canopy moderates exposure in the simulation and provides more protective cover above this patch.","moisture":"Vegetation and litter now help this zone retain local moisture; this represents habitat structure, not directly watering an animal.","wood":"Decaying wood now remains as habitat and as a resource for organisms that depend on decomposition."}
				h.notify(reasons[parts[2]]+" The percentage is a simplified game variable, not a field prescription.")
		"recover":
			for key in {"plants":65.0,"canopy":65.0,"moisture":65.0}:
				s.habitats[0][key] = maxf(s.habitats[0][key],65.0)
			h.notify("Protective cover, native growth, and moisture restored in the home clearing.")
		"egg":
			if chapter()==3 and safe_home():
				s.advance_day()
				remember_stage()
				h.notify("One game day passed. An egg now rests beneath the host leaf; the embryo is the first stage of this butterfly's life history.")
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
