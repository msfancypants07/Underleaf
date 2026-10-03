extends RefCounted
const Art = preload("res://scripts/microhabitat_art.gd")
const Study = preload("res://scripts/mystery.gd")
var host: Control

func sidebar(c: CanvasItem) -> void:
	var h = host
	var m = h.state.mystery
	h.text(c,"AN ECOLOGICAL MYSTERY",1072,224,10,h.ACCENT,"mono")
	h.text(c,"The patch that",1072,257,28,h.CREAM,"serif")
	h.text(c,"holds the mist",1072,289,28,h.CREAM,"serif")
	if h.state.unlocked<1:
		h.paragraph(c,"Begin with the leafcutter ants. Their chemical world will help you find a small question in the clearing.",1072,328,330,16)
		return
	if h.state.zone!=0:
		h.paragraph(c,"Your observations are waiting beside the fallen log in premontane forest. Trials keep progressing while you are away.",1072,328,330,16)
		h.button(c,"Return to the clearing",Rect2(1072,449,340,42),"m:return")
		return
	if h.state.night:
		h.paragraph(c,"Return in daylight to inspect the surfaces. Your saved comparisons can still be read at night.",1072,328,330,16)
		h.button(c,"Return to daylight",Rect2(1072,420,340,40),"m:daylight")
		h.button(c,"Read observation journal",Rect2(1072,472,340,40),"m:journal")
		return
	var body := ""
	match m.phase:
		"discovery":
			if not m.trail_found: body = "The moving leaves vanish around the log. Try chemical perception, then inspect the route."
			elif h.state.sense!=0: body = "The trail leads around the log. It reveals a route, not moisture. Return to visible light and inspect the two patches."
			elif not m.ready(): body = "Why do these two patches look different? Inspect the forked stem and the opening. A and B on your keyboard also select them."
			else: body = "Two patches, one question: which stays damp? Start both equally wet and compare after the same four hours. Change nothing yet. Predictions are optional."
		"baseline": body = "First interval: both patches began equally wet. No cover has changed. Watch their surfaces, or skip ahead; each hourly observation is kept."
		"baseline_ready": body = "Both patches began equally wet. Which stayed damp after four hours? Compare the saved pictures, then try adding cover above the open patch only."
		"growing": body = "Shelter is growing at B. A stays unchanged. Growth is compressed into eight model hours; this is not a real plant-growth timetable."
		"ready_trial": body = "Cover has grown above the open patch. Wet both patches equally again. Keep the ground and weather the same; only cover at B has changed."
		"trial": body = "Second interval: the same weather, with more shelter at B. Watch the litter change. What do you expect compared with the earlier interval?"
		"result": body = "Two intervals are ready to compare. Does B behave differently now? Check A too: it was left unchanged."
	h.paragraph(c,body,1072,324,329,15,h.CREAM)
	var y := 430.0
	if m.phase=="discovery":
		if not m.trail_found:
			h.button(c,"Chemical perception  [2]",Rect2(1072,y,340,37),"sense:1",h.state.sense==1)
			h.button(c,"Inspect route  [T]",Rect2(1072,y+47,340,37),"m:trail",false,h.state.sense!=1)
		else:
			h.button(c,"A · Sheltered patch"+(" ✓" if m.inspected[0] else ""),Rect2(1072,y,165,37),"m:inspect:0")
			h.button(c,"B · Open patch"+(" ✓" if m.inspected[1] else ""),Rect2(1246,y,166,37),"m:inspect:1")
			if m.ready():
				h.button(c,"Optional prediction",Rect2(1072,y+47,340,37),"m:predict")
				h.button(c,"Begin the first comparison",Rect2(1072,y+94,340,42),"m:baseline",true)
			else: h.button(c,"Visible perception  [1]",Rect2(1072,y+47,340,37),"sense:0",h.state.sense==0)
	elif m.phase in ["baseline","trial"]:
		var run: Dictionary = m.baseline if m.phase=="baseline" else m.trial
		h.text(c,"%.1f / 4 MODEL HOURS" % float(run.elapsed),1072,y,11,h.ACCENT,"mono")
		h.box(c,Rect2(1072,y+14,340,7),h.LINE)
		h.box(c,Rect2(1072,y+14,maxf(1,340*float(run.elapsed)/4),7),h.ACCENT)
		h.button(c,"Observe one hour later",Rect2(1072,y+40,340,40),"m:advance",true)
		h.button(c,"Watch in visible light",Rect2(1072,y+90,340,37),"sense:0")
	elif m.phase=="baseline_ready":
		h.button(c,"Compare saved observations",Rect2(1072,y,340,40),"m:journal",true)
		if m.baseline_reviewed:
			h.button(c,"Preview shelter at B",Rect2(1072,y+50,340,40),"m:preview")
	elif m.phase=="growing":
		h.button(c,"Wait for the cover to grow",Rect2(1072,y+15,340,42),"m:advance",true)
	elif m.phase=="ready_trial":
		h.button(c,"Repeat with equal starting water",Rect2(1072,y,340,42),"m:trial",true)
		h.button(c,"Optional prediction",Rect2(1072,y+52,340,37),"m:predict")
	else:
		h.button(c,"Compare the two intervals",Rect2(1072,y,340,42),"m:journal",true)
		if not m.plate_record.is_empty(): h.button(c,"A Shelter That Holds · plate",Rect2(1072,y+52,340,37),"m:plate")
	h.button(c,"A little guidance",Rect2(1072,597,162,34),"m:hint")
	h.button(c,"Journal  [J]",Rect2(1244,597,168,34),"m:journal")
	if m.hint_level>0:
		h.paragraph(c,Study.HINTS[m.hint_level-1],1072,653,330,12)
	else:
		h.paragraph(c,"No score or deadline. A relationship page records what changed and what the comparison can tell you.",1072,661,330,13)

func observation_card(c: CanvasItem, rect: Rect2, run: Dictionary, title: String, sample_index: int, preview_cover: bool = false) -> void:
	var h = host
	h.box(c,rect,Color("e0ddc4"))
	var ink := Color("304637")
	h.text(c,title,rect.position.x+22,rect.position.y+30,12,ink,"mono")
	if run.is_empty():
		h.paragraph(c,"An unwritten comparison. Return after the next interval.",rect.position.x+30,rect.position.y+180,rect.size.x-60,20,ink)
		return
	var index := mini(sample_index,run.samples.size()-1)
	var s: Dictionary = run.samples[index]
	var base_y := rect.position.y+219
	for patch in range(2):
		var x := rect.position.x+rect.size.x*(0.27 if patch==0 else 0.73)
		var cover: float = run.shelter[patch]
		if preview_cover and patch==1: cover = 0.78
		Art.draw(c,Vector2(x,base_y),cover,float(s.water[patch]),2.0,preview_cover and patch==1)
		h.text(c,"A · Sheltered patch" if patch==0 else "B · Open patch",x-77,rect.position.y+70,16,ink,"serif")
		h.text(c,"More sheltered" if cover>0.5 else "Less sheltered",x-68,rect.position.y+93,12,ink)
		var desc := "Still damp" if s.water[patch]>=50 else "Drying litter"
		h.text(c,desc,x-48,base_y+48,14,ink)
		if h.state.mystery.details:
			h.text(c,"%d → %.1f units" % [82,float(s.water[patch])],x-70,base_y+71,12,ink,"mono")
		h.text(c,"Surface glints: %d" % int(float(s.water[patch])/9),x-68,base_y+94,12,ink)
	h.text(c,"%d h after shared wetting" % int(s.hours),rect.position.x+22,rect.end.y-19,12,ink,"mono")

func page(c: CanvasItem, view: String) -> void:
	var h = host
	var m = h.state.mystery
	var earned := view=="relationship"
	h.text(c,"RELATIONSHIP PLATE" if earned else "OBSERVATION JOURNAL",105,106,11,h.ACCENT,"mono")
	h.text(c,"A Shelter That Holds" if earned else "The Patch That Holds the Mist",105,149,36,h.CREAM,"serif")
	if view=="mystery_predict":
		h.paragraph(c,"What do you think shelter might change? This is your interpretation, not a quiz. You can change your mind or skip this step.",106,216,1020,22,h.CREAM)
		var options := ["More shelter may slow drying.","Shelter may make no difference.","I want to watch first."]
		for i in range(3): h.button(c,options[i],Rect2(106,329+i*78,880,54),"m:prediction:"+str(i),m.prediction==options[i])
		h.button(c,"Skip prediction",Rect2(106,620,270,43),"close")
		h.paragraph(c,"Your earlier predictions remain in the field notes. Revising one never costs progress.",106,716,1090,17)
		return
	if view=="mystery_preview":
		h.paragraph(c,"Change one thing: encourage shelter at the opening. The forked-stem patch stays as it is. No animal is moved.",106,192,1090,18,h.CREAM)
		observation_card(c,Rect2(105,231,577,362),m.baseline,"BEFORE · EXISTING COVER",4)
		observation_card(c,Rect2(704,231,577,362),m.baseline,"PROPOSED · COVER AT B ONLY",4,true)
		h.paragraph(c,"Preview of canopy only. Surface conditions shown are the baseline, not a predicted result. Growth takes a compressed eight-model-hour interval; the later experiment repeats the same weather.",106,630,1180,17,h.CREAM)
		h.button(c,"Encourage shelter here",Rect2(106,732,370,46),"m:grow",true)
		h.button(c,"Keep observing",Rect2(493,732,274,46),"close")
		return
	if view=="mystery_notes":
		h.text(c,"Your field notes",106,202,25,h.CREAM,"serif")
		var start: int = h.mystery_note_page*6
		for i in range(start,mini(start+6,m.notes.size())):
			var note: Dictionary = m.notes[i]
			var y := 246+(i-start)*72
			h.text(c,note.time,106,y,11,h.ACCENT,"mono")
			h.paragraph(c,note.text,106,y+24,1170,16,h.CREAM)
		if m.notes.is_empty(): h.paragraph(c,"Inspect the route and patches to begin a record.",106,269,1080,19)
		h.button(c,"← Comparison",Rect2(106,737,270,42),"m:journal")
		h.button(c,"Previous",Rect2(990,737,135,42),"m:notes_prev",false,start==0)
		h.button(c,"Next",Rect2(1140,737,135,42),"m:notes_next",false,start+6>=m.notes.size())
		return
	var before: Dictionary = m.plate_record.baseline if earned else m.baseline
	var after: Dictionary = m.plate_record.trial if earned else m.trial
	var max_sample := mini(4,before.get("samples",[]).size()-1)
	if not after.is_empty(): max_sample = mini(max_sample,after.samples.size()-1)
	for i in range(5): h.button(c,("Wetting" if i==0 else str(i)+" h"),Rect2(105+i*88,175,78,31),"m:sample:"+str(i),h.mystery_sample==i,i>max_sample)
	h.text(c,"SAME GROUND · SAME START · SAME WEATHER",660,197,10,h.ACCENT,"mono")
	observation_card(c,Rect2(105,222,577,356),before,"FIRST INTERVAL · NO INTERVENTION",h.mystery_sample)
	observation_card(c,Rect2(704,222,577,356),after,"REPEAT · MORE SHELTER AT B",h.mystery_sample)
	var summary: String = m.plate_record.conclusion if earned else m.conclusion()
	if m.phase in ["baseline","trial"] and not earned: summary = "An interval is still running. These are the observations so far; wait for the full four-hour comparison before interpreting the outcome."
	h.paragraph(c,summary,106,609,1160,17,h.CREAM)
	if earned:
		h.text(c,"RECORDED " + str(m.plate_record.time),106,683,11,h.ACCENT,"mono")
		h.text(c,"Next: care for a life in the surrounding clearing.",590,683,14,h.MUTED)
		h.button(c,"Continue: your host patch" if h.tutorial_ui.active() else "Return to this place",Rect2(106,724,330,43),"t:home" if h.tutorial_ui.active() else "m:return")
		h.button(c,"Your field notes",Rect2(453,724,252,43),"m:notes")
	elif m.phase=="baseline_ready":
		h.button(c,"I have compared both patches",Rect2(106,724,360,43),"m:review",true,h.mystery_sample!=4)
		if m.baseline_reviewed: h.button(c,"Preview shelter at B",Rect2(485,724,302,43),"m:preview")
	elif m.phase=="result":
		if not m.result_reviewed:
			h.button(c,"I have compared the intervals",Rect2(106,724,360,43),"m:review",true,h.mystery_sample!=4)
		else:
			h.button(c,"Record relationship" if m.plate_record.is_empty() else "Open relationship plate",Rect2(106,724,322,43),"m:record",true)
			h.button(c,"Optional reflection",Rect2(444,724,238,43),"m:reflect")
			h.button(c,"Repeat observation",Rect2(699,724,250,43),"m:repeat")
	else:
		h.button(c,"Return to the clearing",Rect2(106,724,320,43),"m:return")
	h.button(c,"Hide model units" if m.details else "Show model units",Rect2(1090,724,222,43),"m:details")
	h.paragraph(c,"Illustrative model · field review pending. This tests water retention, not fog capture or insect preference. Surface signs and rates are simplified; scent is not a moisture sensor.",106,802,1180,12,h.MUTED)

func reflection_page(c: CanvasItem) -> void:
	var h = host
	h.text(c,"What would you carry forward?",105,152,35,h.CREAM,"serif")
	h.paragraph(c,"No answer is graded. You can record the relationship without choosing a reflection.",106,221,1140,20)
	var options := ["Matches my prediction.","I would revise my prediction.","I need another comparison."]
	for i in range(3): h.button(c,options[i],Rect2(106,321+i*81,958,52),"m:reflection:"+str(i),h.state.mystery.reflection==options[i])
	h.button(c,"Return without a reflection",Rect2(106,659,390,44),"m:journal")

func dispatch(parts: PackedStringArray) -> void:
	var h = host
	var s = h.state
	var m = s.mystery
	if s.unlocked<1 and parts[1] not in ["motion","labels"]:
		h.notify("Document the leafcutters first to open chemical perception.")
		return
	var action := parts[1]
	match action:
		"open":
			h.panel = "inquiry"
			h.selected = ""
		"return":
			s.zone = 0
			s.night = false
			s.sense = 0 if m.trail_found else 1
			h.panel = "inquiry"
			h.modal = ""
			h.selected = ""
		"daylight": s.night = false
		"trail":
			if s.zone!=0 or s.sense!=1 or s.night:
				h.notify("Find the route in premontane daylight, using chemical perception.")
			else:
				h.notify(m.discover_trail(s.day,s.hour))
				h.panel = "inquiry"
		"inspect":
			if s.zone!=0 or s.sense!=0 or s.night:
				h.notify("Return to premontane daylight and visible perception to inspect the litter.")
			else:
				h.selected_patch = int(parts[2])
				h.notify(m.inspect_patch(h.selected_patch,s.day,s.hour))
				h.panel = "inquiry"
		"baseline":
			if s.zone==0 and not s.night: h.notify(m.begin_baseline(s.day,s.hour))
		"preview":
			if m.phase=="baseline_ready" and m.baseline_reviewed: h.modal = "mystery_preview"
		"grow":
			h.notify(m.encourage_shelter(s.day,s.hour))
			h.modal = ""
			h.panel = "inquiry"
		"trial":
			if s.zone==0 and not s.night: h.notify(m.begin_trial(s.day,s.hour))
		"advance":
			if m.phase not in ["baseline","growing","trial"]: return
			s.events.clear()
			s.advance_hours(8.0-m.growth_hours if m.phase=="growing" else 1.0)
			h.notify(s.events[-1] if not s.events.is_empty() else "Another observation is saved. The surfaces have had the same time to change.")
		"journal":
			h.modal = "mystery"
			h.mystery_sample = 4
			if not m.baseline.is_empty(): h.mystery_sample = mini(4,m.baseline.samples.size()-1)
			if not m.trial.is_empty(): h.mystery_sample = mini(h.mystery_sample,m.trial.samples.size()-1)
		"review":
			if h.mystery_sample==4 and m.review(): h.notify("Comparison noted. Your evidence remains here to revisit.")
		"record":
			h.notify(m.record_plate(s.day,s.hour))
			if not m.plate_record.is_empty(): h.modal = "relationship"
		"plate":
			if not m.plate_record.is_empty():
				h.modal = "relationship"
				h.mystery_sample = 4
		"sample": h.mystery_sample = clampi(int(parts[2]),0,4)
		"predict": h.modal = "mystery_predict"
		"prediction":
			var choices := ["More shelter may slow drying.","Shelter may make no difference.","I want to watch first."]
			m.predict(choices[clampi(int(parts[2]),0,2)],s.day,s.hour)
			h.modal = ""
			h.notify("Prediction saved. You can revise it; this is not a quiz.")
		"reflect":
			if m.phase=="result": h.modal = "mystery_reflect"
		"reflection":
			var choices := ["Matches my prediction.","I would revise my prediction.","I need another comparison."]
			m.reflect(choices[clampi(int(parts[2]),0,2)],s.day,s.hour)
			h.modal = "mystery"
		"repeat":
			if m.repeat_study(s.day,s.hour):
				h.modal = ""
				h.panel = "inquiry"
		"hint": h.notify(m.next_hint())
		"details": m.details = not m.details
		"labels": m.clear_labels = not m.clear_labels
		"motion": m.reduced_motion = not m.reduced_motion
		"notes":
			h.modal = "mystery_notes"
			h.mystery_note_page = 0
		"notes_next": h.mystery_note_page = mini(h.mystery_note_page+1,maxi(0,(m.notes.size()-1)/6))
		"notes_prev": h.mystery_note_page = maxi(0,h.mystery_note_page-1)
	if s.save_game()!=OK: h.notify("Could not save this observation. Check available disk space.")
