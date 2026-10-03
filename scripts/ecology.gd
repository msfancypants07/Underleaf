class_name ForestState
extends RefCounted

const SAVE_VERSION = 3
const Mystery = preload("res://scripts/mystery.gd")
var mystery = Mystery.new()
var tutorial: Dictionary = {"enabled":true,"started":false,"completed":false,"inspected":[],"history":[]}
const SAVE_PATH = "user://forest.json"
var save_path: String = SAVE_PATH
var seed_value: int = 48271
var day: int = 1
var hour: float = 9.0
var zone: int = 0
var sense: int = 0
var unlocked: int = 0
var paused: bool = false
var night: bool = false
var documented: Array = []
var habitats: Array = []
var larva_age: int = -1
var larva_quality: float = 1.0
var exposure: int = 0
var adult: bool = false
var lost: bool = false
var threat: float = 0.0
var restoration: Array = []
var species: Array = []
var events: Array = []

func _init() -> void:
	species = JSON.parse_string(FileAccess.get_file_as_string("res://data/species.json"))
	for i in range(4):
		habitats.append({"moisture":58.0 + i * 5,"canopy":62.0 + i * 3,"plants":40.0,"wood":42.0})

func season() -> String:
	var d := (day - 1) % 360
	if d < 120 or d >= 330: return "Dry season"
	if d < 150: return "Rain transition"
	return "Wet season"

func fog() -> float:
	var base := 0.45 if season() == "Dry season" else 0.72
	return clampf(base + zone * 0.08 + sin(day * 0.61) * 0.13 - threat * 0.002, 0.15, 0.95)

func zone_open(z: int) -> bool:
	return z == 0 or (z == 1 and unlocked >= 2) or (z == 2 and unlocked >= 3) or (z == 3 and unlocked >= 5)

func id_is_night_target(id: String) -> bool:
	return id=="scarab"

func supported(s: Dictionary) -> bool:
	var h: Dictionary = habitats[int(s.zone)]
	match s.id:
		"ant": return true
		"treehopper": return h.plants >= 60 and h.canopy >= 50
		"bumblebee": return h.plants >= 65
		"moth": return h.canopy >= 65 and h.plants >= 60
		"scarab": return h.moisture >= 65 and h.wood >= 55
		"orchid": return h.plants >= 65
		"morpho": return adult
		"ridge": return h.canopy >= 55
	return false

func visible(s: Dictionary) -> bool:
	if int(s.zone) != zone or not supported(s): return false
	if int(s.grant) > unlocked + 1: return false
	if s.id == "scarab" and not night: return false
	if s.id in ["ant", "morpho"]: return not night or sense == 1
	return sense == int(s.mode) or (documented.has(s.id) and sense == 0)

func document(id: String) -> String:
	for s in species:
		if s.id != id: continue
		if not visible(s): return "Find the animal in its sensory world first."
		if documented.has(id): return "Already recorded. The forest still has more to say."
		documented.append(id)
		if int(s.grant) == unlocked + 1:
			unlocked += 1
			sense = unlocked
			if unlocked == 4: night = true
			return ["", "Scent becomes a landscape. Chemical perception awakened.", "The stems are singing. Vibration perception awakened.", "Flowers reveal a second language. Ultraviolet awakened.", "Half the forest was waiting for night. Ultrasound awakened.", "Light has an orientation. Polarization awakened."][unlocked]
		if documented.size() == species.size(): return "Your notebook is complete. The forest goes on. Stewardship is now open."
		return "A new plate joins your field notebook."
	return ""

func advance_hours(hours: float) -> void:
	if hours <= 0: return
	var remaining := hours
	while remaining > 0:
		var step := minf(remaining,24.0-hour)
		var notice: String = mystery.advance(step)
		hour += step
		remaining -= step
		if hour >= 24:
			# Daily ecology runs at midnight without silently skipping morning hours.
			advance_day(false)
			hour = 0.0
		if not notice.is_empty(): events.append(notice)

func advance_day(advance_mystery: bool = true) -> void:
	events.clear()
	var notice: String = mystery.advance(24.0-hour+8.0) if advance_mystery else ""
	day += 1
	hour = 8.0
	for h in habitats:
		h.moisture = clampf(h.moisture + (1.5 if season() != "Dry season" else -1.2) + (h.canopy - 60) * 0.035 - threat * 0.015, 0, 100)
	var home: Dictionary = habitats[0]
	if larva_age < 0 and not adult and home.plants >= 65 and home.canopy >= 55 and home.moisture >= 50:
		larva_age = 0
		lost = false
		exposure = 0
		larva_quality = 1.0
		events.append("A morpho egg has appeared beneath a host leaf.")
	elif larva_age >= 0 and not adult:
		if home.moisture < 20 or home.canopy < 20:
			exposure += 1
			larva_quality = maxf(0.35, larva_quality - 0.15)
		else:
			exposure = 0
			larva_age += 1
			if home.moisture < 45 or home.canopy < 45: larva_quality = maxf(0.35, larva_quality - 0.06)
		if exposure >= 3:
			larva_age = -1
			lost = true
			events.append("Prolonged exposure has lost the larva. Restore cover and moisture to welcome another.")
		elif larva_age >= 8:
			adult = true
			events.append("A blue morpho has emerged. Return to premontane forest to observe it.")
	if documented.size() >= species.size() or tutorial.completed:
		threat = clampf(threat + 1.8 - restoration.size() * 0.7, 0, 100)

	if not notice.is_empty(): events.append(notice)

func larva_stage() -> String:
	if adult: return "Adult emerged"
	if lost: return "Habitat needs recovery"
	if larva_age < 0: return "Waiting for a host plant"
	if larva_age == 0: return "Egg beneath a leaf"
	if larva_age < 5: return "Larva · instar " + str(larva_age)
	return "Pupa · quiet transformation"

func save_game(path: String = "") -> Error:
	if path.is_empty(): path = save_path
	var data := {"version":SAVE_VERSION,"seed":seed_value,"day":day,"hour":hour,"zone":zone,"sense":sense,"unlocked":unlocked,"night":night,"documented":documented,"habitats":habitats,"larva_age":larva_age,"larva_quality":larva_quality,"exposure":exposure,"adult":adult,"lost":lost,"threat":threat,"restoration":restoration,"mystery":mystery.serialize(),"tutorial":tutorial}
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if not file: return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return DirAccess.rename_absolute(path + ".tmp", path)

func load_game(path: String = "") -> bool:
	if path.is_empty(): path = save_path
	if not FileAccess.file_exists(path): return false
	var d = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not d is Dictionary: return false
	if int(d.get("version",0)) not in [1,2,SAVE_VERSION]: return false
	if not d.get("habitats") is Array or d.habitats.size() != 4: return false
	for h in d.habitats:
		if not h is Dictionary: return false
		for key in ["moisture", "canopy", "plants", "wood"]:
			if not h.get(key) is float and not h.get(key) is int: return false
	if not d.get("documented") is Array: return false
	var restored_mystery = Mystery.new()
	if int(d.version)>=2 and not restored_mystery.restore(d.get("mystery")): return false
	# Keep the original v1 file available before the first migrated autosave.
	if int(d.version)==1 and not FileAccess.file_exists(path+".v1-backup"):
		if DirAccess.copy_absolute(path,path+".v1-backup") != OK: return false
	var restored_tutorial: Dictionary = {"enabled":false,"started":true,"completed":false,"inspected":[],"history":[]}
	if int(d.version)>=3:
		var t = d.get("tutorial")
		if not t is Dictionary: return false
		for key in ["enabled","started","completed"]:
			if not t.get(key) is bool: return false
		for key in ["inspected","history"]:
			if not t.get(key) is Array: return false
		for entry in t.history:
			if not entry is Dictionary or not entry.get("stage") is String or not (entry.get("day") is float or entry.get("day") is int): return false
		restored_tutorial = t
	if int(d.version)==2 and not FileAccess.file_exists(path+".v2-backup"):
		if DirAccess.copy_absolute(path,path+".v2-backup")!=OK: return false
	tutorial = restored_tutorial
	mystery = restored_mystery
	seed_value = int(d.get("seed", 48271))
	day = maxi(1, int(d.get("day", 1)))
	hour = clampf(float(d.get("hour", 9)), 0, 24)
	unlocked = clampi(int(d.get("unlocked", 0)), 0, 5)
	zone = clampi(int(d.get("zone", 0)), 0, 3)
	if not zone_open(zone): zone = 0
	sense = clampi(int(d.get("sense", 0)), 0, unlocked)
	night = bool(d.get("night", false)) and unlocked >= 4
	documented = d.documented
	habitats = d.habitats
	for h in habitats:
		for key in h: h[key] = clampf(float(h[key]), 0, 100)
	larva_age = clampi(int(d.get("larva_age", -1)), -1, 8)
	larva_quality = clampf(float(d.get("larva_quality", 1)), 0.35, 1)
	exposure = clampi(int(d.get("exposure", 0)), 0, 3)
	adult = bool(d.get("adult", false))
	lost = bool(d.get("lost", false))
	threat = clampf(float(d.get("threat", 0)), 0, 100)
	restoration = d.get("restoration", [])
	return true
