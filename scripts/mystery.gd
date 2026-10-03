extends RefCounted
# One authored study. Rates are illustrative model values, not field measurements.
const DURATION = 4.0
const START_WATER = 82.0
const PATCH_POSITIONS = [Vector2(118,210), Vector2(279,249)]
const HINTS = [
	"Follow the ant route around the fallen log in chemical perception.",
	"Return to visible light. Compare the litter beside the forked stem and at the opening.",
	"Observe both patches over the same interval before changing anything.",
	"Try changing only the shelter at the opening. Keep the forked-stem patch as a comparison.",
	"Compare Patch B before and after its cover grows. The study holds starting water, substrate, and weather constant; its rates are illustrative."
]
const PHASES = ["discovery", "baseline", "baseline_ready", "growing", "ready_trial", "trial", "result"]
var phase: String = "discovery"
var trail_found: bool = false
var inspected: Array = [false, false]
var shelter: Array = [0.78, 0.22]
var water: Array = [57.2, 34.8]
var baseline: Dictionary = {}
var trial: Dictionary = {}
var baseline_reviewed: bool = false
var result_reviewed: bool = false
var growth_hours: float = 0
var notes: Array = []
var prediction: String = ""
var reflection: String = ""
var hint_level: int = 0
var details: bool = false
var clear_labels: bool = true
var reduced_motion: bool = false
var plate_record: Dictionary = {}
var archive: Array = []

func stamp(day: int, hour: float) -> String:
	return "Day %d · %02d:%02d" % [day, int(hour), int(fmod(hour, 1.0)*60)]

func ready() -> bool:
	return trail_found and inspected[0] and inspected[1]

func record_note(kind: String, message: String, day: int, hour: float) -> void:
	notes.append({"kind":kind,"text":message,"time":stamp(day,hour)})

func discover_trail(day: int, hour: float) -> String:
	if not trail_found:
		trail_found = true
		record_note("trail", "Chemical perception reveals a route around the log, not a measurement of moisture.", day, hour)
	return "A route around the log. Return to visible light to compare the two small patches."

func inspect_patch(index: int, day: int, hour: float) -> String:
	if index < 0 or index > 1: return ""
	var description := patch_description(index)
	if not inspected[index]:
		inspected[index] = true
		record_note("observation", ("A · " if index==0 else "B · ")+description, day, hour)
	return description

func patch_description(index: int) -> String:
	var condition := "The litter looks damp; small surface glints remain." if water[index] >= 50 else "The litter looks drier; fewer surface glints remain."
	return ("Beside the forked stem: " if index==0 else "At the opening: ")+condition

func predict(choice: String, day: int, hour: float) -> void:
	if choice not in ["More shelter may slow drying.", "Shelter may make no difference.", "I want to watch first."]: return
	prediction = choice
	record_note("prediction", choice, day, hour)

func reflect(choice: String, day: int, hour: float) -> void:
	if phase != "result": return
	if choice not in ["Matches my prediction.", "I would revise my prediction.", "I need another comparison."]: return
	reflection = choice
	record_note("reflection", choice, day, hour)

func sample_at(hours: float, covers: Array) -> Dictionary:
	# Shared no-input drying interval, identical initial water and substrate.
	return {"hours":hours,"water":[maxf(0,START_WATER-hours*(14.0-10.0*covers[0])),maxf(0,START_WATER-hours*(14.0-10.0*covers[1]))]}

func new_run(day: int, hour: float) -> Dictionary:
	return {"start":stamp(day,hour),"elapsed":0.0,"shelter":shelter.duplicate(),"samples":[sample_at(0,shelter)],"weather":"Shared wetting, then four model hours without additional water.","substrate":"Matching leaf litter","initial_water":START_WATER}

func begin_baseline(day: int, hour: float) -> String:
	if phase != "discovery" or not ready(): return "Inspect both patches and follow the chemical route first."
	baseline = new_run(day,hour)
	water = [START_WATER,START_WATER]
	phase = "baseline"
	record_note("interval", "Baseline begins after matched wetting. Cover is unchanged at both patches.", day, hour)
	return "Both patches begin equally wet. Watch them change, or advance to the next observation."

func encourage_shelter(day: int, hour: float) -> String:
	if phase != "baseline_ready" or not baseline_reviewed: return "Compare the baseline observations first."
	phase = "growing"
	growth_hours = 0
	record_note("intervention", "Encouraged cover at B only. Growth will be compressed into the next model interval; A remains unchanged.",day,hour)
	return "Cover at B is beginning to grow. Allow time to pass; this growth interval is compressed for play."

func begin_trial(day: int, hour: float) -> String:
	if phase != "ready_trial": return "The cover is not ready yet."
	trial = new_run(day,hour)
	water = [START_WATER,START_WATER]
	phase = "trial"
	record_note("interval", "Repeat begins after matched wetting. Only B's local shelter has changed.", day, hour)
	return "The same wetting and drying sequence begins again, now with shelter at B."

func advance(hours: float) -> String:
	if hours <= 0: return ""
	if phase == "growing":
		growth_hours = minf(8.0,growth_hours+hours)
		if growth_hours >= 8:
			shelter[1] = 0.78
			phase = "ready_trial"
			return "Shelter has grown at B. Return to the clearing to begin the matched comparison."
		return ""
	if phase not in ["baseline", "trial"]: return ""
	var run: Dictionary = baseline if phase=="baseline" else trial
	var target := minf(DURATION,float(run.elapsed)+hours)
	# Store every whole-hour sample, including when the user skips a day.
	for h in range(int(floor(float(run.elapsed)))+1,int(floor(target))+1):
		run.samples.append(sample_at(float(h),run.shelter))
	run.elapsed = target
	water = sample_at(target,run.shelter).water
	if target >= DURATION:
		if phase == "baseline":
			phase = "baseline_ready"
			return "The baseline interval is complete. Both patches' observations are saved for comparison."
		phase = "result"
		return "The repeat interval is complete. Compare B with its earlier self, and A with the unchanged reference."
	return ""

func review() -> bool:
	if phase == "baseline_ready":
		baseline_reviewed = true
		return true
	if phase == "result":
		result_reviewed = true
		return true
	return false

func conclusion(before: Dictionary = {}, after: Dictionary = {}) -> String:
	if before.is_empty(): before = baseline
	if after.is_empty(): after = trial
	if before.is_empty(): return "No matched interval has been recorded yet."
	if after.is_empty(): return "Both patches began equally wet. At the same elapsed time, the opening patch retained less modeled water. This comparison alone does not establish the cause."
	var b0: float = before.samples[-1].water[1]
	var b1: float = after.samples[-1].water[1]
	var a0: float = before.samples[-1].water[0]
	var a1: float = after.samples[-1].water[0]
	if b1 > b0 and is_equal_approx(a0,a1):
		return "After shelter increased at B, it lost modeled water more slowly in the matched interval. A, left unchanged, behaved as before. This supports a role for shelter in this model."
	return "These observations do not show the expected isolated change at B. Keep the evidence and try another comparison before drawing a causal conclusion."

func record_plate(day: int, hour: float) -> String:
	if phase != "result" or not result_reviewed: return "Compare the completed intervals first."
	if not plate_record.is_empty(): return "Your relationship plate is already in the notebook."
	plate_record = {"time":stamp(day,hour),"baseline":baseline.duplicate(true),"trial":trial.duplicate(true),"prediction":prediction,"reflection":reflection,"notes":notes.duplicate(true),"conclusion":conclusion()}
	return "A Shelter That Holds · a relationship joins your notebook. No new species was added."

func repeat_study(day: int, hour: float) -> bool:
	if phase != "result": return false
	archive.append({"baseline":baseline.duplicate(true),"trial":trial.duplicate(true),"notes":notes.duplicate(true)})
	# Preserve the first earned plate and all earlier trials.
	phase = "ready_trial"
	trial = {}
	result_reviewed = false
	reflection = ""
	record_note("repeat", "Revisit the same sheltered patch against the original baseline. Habitat changes are retained.",day,hour)
	return true

func next_hint() -> String:
	hint_level = mini(HINTS.size(),hint_level+1)
	return HINTS[hint_level-1]

func serialize() -> Dictionary:
	return {"phase":phase,"trail_found":trail_found,"inspected":inspected,"shelter":shelter,"water":water,"baseline":baseline,"trial":trial,"baseline_reviewed":baseline_reviewed,"result_reviewed":result_reviewed,"growth_hours":growth_hours,"notes":notes,"prediction":prediction,"reflection":reflection,"hint_level":hint_level,"details":details,"clear_labels":clear_labels,"reduced_motion":reduced_motion,"plate_record":plate_record,"archive":archive}

static func number_pair(value: Variant, low: float, high: float) -> bool:
	if not value is Array or value.size()!=2: return false
	for n in value:
		if not (n is float or n is int): return false
		if not is_finite(float(n)) or n < low or n > high: return false
	return true

static func valid_run(run: Variant) -> bool:
	if not run is Dictionary: return false
	if run.is_empty(): return true
	if not number_pair(run.get("shelter"),0,1): return false
	if not (run.get("elapsed") is float or run.get("elapsed") is int): return false
	if not is_finite(float(run.elapsed)) or run.elapsed<0 or run.elapsed>DURATION: return false
	if not run.get("samples") is Array or run.samples.is_empty(): return false
	if run.samples.size()!=int(floor(float(run.elapsed)))+1: return false
	for i in range(run.samples.size()):
		var s: Variant = run.samples[i]
		if not s is Dictionary or s.get("hours")!=i or not number_pair(s.get("water"),0,100): return false
	return run.get("start") is String

func restore(d: Variant) -> bool:
	if not d is Dictionary or d.get("phase") not in PHASES: return false
	if not number_pair(d.get("shelter"),0,1) or not number_pair(d.get("water"),0,100): return false
	if not d.get("inspected") is Array or d.inspected.size()!=2: return false
	for v in d.inspected:
		if not v is bool: return false
	if not valid_run(d.get("baseline")) or not valid_run(d.get("trial")): return false
	if d.phase in ["baseline","baseline_ready","growing","ready_trial","trial","result"] and d.baseline.is_empty(): return false
	if d.phase in ["trial","result"] and d.trial.is_empty(): return false
	if d.phase in ["baseline_ready","growing","ready_trial","trial","result"] and float(d.baseline.elapsed)<DURATION: return false
	if d.phase=="result" and float(d.trial.elapsed)<DURATION: return false
	if not d.get("notes") is Array or not d.get("archive") is Array or not d.get("plate_record") is Dictionary: return false
	for note in d.notes:
		if not note is Dictionary or not note.get("text") is String or not note.get("time") is String: return false
	var plate: Dictionary = d.plate_record
	if not plate.is_empty():
		if not valid_run(plate.get("baseline")) or not valid_run(plate.get("trial")): return false
		if plate.baseline.is_empty() or plate.trial.is_empty(): return false
		if float(plate.trial.elapsed)<DURATION or not plate.get("conclusion") is String: return false
		if not plate.get("time") is String: return false
	for key in ["trail_found","baseline_reviewed","result_reviewed","details","clear_labels","reduced_motion"]:
		if not d.get(key) is bool: return false
	for key in ["prediction","reflection"]:
		if not d.get(key) is String: return false
	if not (d.get("growth_hours") is float or d.get("growth_hours") is int): return false
	if not (d.get("hint_level") is float or d.get("hint_level") is int): return false
	for key in serialize():
		if d.has(key): set(key,d[key])
	growth_hours = clampf(growth_hours,0,8)
	hint_level = clampi(hint_level,0,HINTS.size())
	return true
