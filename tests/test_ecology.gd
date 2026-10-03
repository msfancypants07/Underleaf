extends SceneTree
const State = preload("res://scripts/ecology.gd")
var failures: int = 0
func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1
func _init() -> void:
	var s := State.new()
	check(s.visible(s.species[0]), "Bootstrap ant is visible")
	check(not s.zone_open(1), "Lower montane starts locked")
	check(not s.visible(s.species[1]), "Treehopper starts hidden")
	s.document("scarab")
	check(s.unlocked==0, "Cannot document an invisible late-stage species")
	s.document("ant")
	check(s.unlocked==1 and s.sense==1, "Ant grants chemical")
	s.habitats[0].plants = 70.0
	check(s.visible(s.species[1]), "Restoration exposes chemical treehopper cue")
	s.document("treehopper")
	check(s.unlocked==2 and s.zone_open(1), "Treehopper grants vibration and lower montane")
	s.zone = 1
	s.habitats[1].plants = 70.0
	s.document("bumblebee")
	check(s.unlocked==3 and s.zone_open(2), "Bee grants UV and upper montane")
	s.zone = 2
	s.habitats[2].plants = 70.0
	s.document("moth")
	check(s.unlocked==4 and s.night, "Moth unlocks night and ultrasound")
	s.habitats[2].moisture = 75.0
	s.habitats[2].wood = 70.0
	s.document("scarab")
	check(s.unlocked==5 and s.zone_open(3), "Scarab grants polarization and ridge")
	s.zone = 3
	s.document("ridge")
	check(s.documented.has("ridge"), "Ridge plate can be completed")
	s.zone = 0
	s.night = false
	s.sense = 1
	s.document("orchid")
	check(s.documented.has("orchid"), "Earlier-zone senses retain optional discoveries")
	for i in range(9): s.advance_day()
	check(s.adult and s.larva_age==8, "Complete egg, larval instars, pupa, adult cycle")
	s.sense = 0
	s.document("morpho")
	check(s.documented.size()==8, "Full notebook is reachable")
	s.advance_day()
	check(s.threat>0, "Notebook completion enables habitat pressure")
	s.restoration = [0,1,2,3]
	s.advance_day()
	check(s.threat<1.8, "Restoration counters pressure")
	var p := "user://test-forest.json"
	check(s.save_game(p)==OK, "Atomic save succeeds")
	var loaded := State.new()
	check(loaded.load_game(p), "Versioned save loads")
	check(loaded.documented==s.documented and is_equal_approx(loaded.habitats[0].moisture, s.habitats[0].moisture) and loaded.adult, "Save roundtrip retains progress and habitat")
	DirAccess.remove_absolute(p)
	var neglected := State.new()
	neglected.larva_age=1
	neglected.habitats[0].canopy=0.0
	for i in range(3): neglected.advance_day()
	check(neglected.lost and not neglected.adult, "Three days of dangerous exposure causes loss")
	neglected.habitats[0].canopy=70.0
	neglected.habitats[0].plants=70.0
	neglected.habitats[0].moisture=70.0
	neglected.advance_day()
	check(neglected.larva_age==0 and not neglected.lost, "Restoring habitat allows recovery after loss")
	var imperfect := State.new()
	imperfect.larva_age=1
	imperfect.habitats[0].canopy=35.0
	imperfect.habitats[0].moisture=55.0
	imperfect.advance_day()
	check(not imperfect.lost and imperfect.larva_quality<1.0, "Imperfect safe care lowers condition without death")
	for d in [1,120,121,150,151,330,331,361]:
		s.day=d
		check(s.season() in ["Dry season","Rain transition","Wet season"],"Seasonal calendar remains valid")
	s.day=121
	check(s.season()=="Rain transition","Rain onset transition")
	s.day=151
	check(s.season()=="Wet season","Wet season begins")
	print("Ecology checks complete: ", failures, " failures")
	quit(failures)
