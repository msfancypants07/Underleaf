extends Node2D

const PatchArt = preload("res://scripts/microhabitat_art.gd")
const Study = preload("res://scripts/mystery.gd")
var selected_patch: int = -1
var state: ForestState
var t: float = 0.0
var selected: String = ""
var hovered: String = ""
var rng := RandomNumberGenerator.new()
const W = 480
const H = 332

func _process(delta: float) -> void:
	if not state or not state.mystery.reduced_motion: t += delta
	queue_redraw()

func pixel(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_rect(Rect2(floor(x), floor(y), ceil(w), ceil(h)), c)

func tint(c: Color) -> Color:
	if state.night: c = c * Color(0.48,0.62,0.86)
	match state.sense:
		1: return c.lerp(Color(0.06,0.16,0.13), 0.35)
		2: return c.lerp(Color(0.055,0.12,0.18), 0.65)
		3: return c.lerp(Color(0.18,0.055,0.26), 0.64)
		4: return c.lerp(Color(0.025,0.055,0.13), 0.82)
		5: return c.lerp(Color(0.11,0.19,0.25), 0.35)
	return c

func leaf(p: Vector2, length: float, angle: float, col: Color) -> void:
	var tip := p + Vector2.from_angle(angle) * length
	var mid := p.lerp(tip, 0.48)
	var normal := Vector2.from_angle(angle + PI/2) * length * 0.22
	draw_colored_polygon(PackedVector2Array([p,mid+normal,tip,mid-normal]), col)
	draw_line(p, tip, col.lightened(0.15), 1)

func fern(p: Vector2, size: float, col: Color) -> void:
	for branch in range(5):
		var a := -PI + branch * PI/4
		var end := p + Vector2.from_angle(a) * size
		draw_line(p,end,col,1)
		for j in range(2,8):
			var q := p.lerp(end,j/8.0)
			leaf(q,size*(1-j/10.0)*0.32,a-0.8,col)
			leaf(q,size*(1-j/10.0)*0.32,a+0.8,col)

func location(s: Dictionary) -> Vector2:
	var p := Vector2(float(s.position[0])*W,float(s.position[1])*H)
	if s.kind in ["bee","butterfly","moth"]:
		p += Vector2(sin(t*0.6+float(s.position[0])*8)*9,cos(t*0.9)*4)
	if s.kind == "ant": p.x += sin(t*0.35)*8
	return p

func _draw() -> void:
	if not state: return
	rng.seed = state.seed_value + state.zone*789
	var sky := Color("789a87") if state.zone < 3 else Color("a4b9ad")
	pixel(0,0,W,H,tint(sky))
	# Distant mist, layered ridges, and narrow trunks.
	for layer in range(3):
		var ground := PackedVector2Array([Vector2(0,H)])
		for x in range(0,W+30,24):
			ground.append(Vector2(x,95+layer*34+sin(x*0.019+layer)*20+rng.randf_range(-8,8)))
		ground.append(Vector2(W,H))
		draw_colored_polygon(ground,tint([Color("607f72"),Color("456b5a"),Color("2b5143")][layer]))
		for i in range(16):
			var x := rng.randf_range(0,W)
			var width := rng.randf_range(2,6)
			pixel(x,15,width,220,tint(Color("324f43").lightened((2-layer)*0.10)))
			draw_line(Vector2(x,90),Vector2(x+25,30),tint(Color("49695a")),2)
	# A shaft of daylight remains geometry in every sensory rendition.
	for i in range(4):
		draw_colored_polygon(PackedVector2Array([Vector2(210+i*28,0),Vector2(221+i*28,0),Vector2(155+i*29,260),Vector2(107+i*29,260)]),Color(0.76,0.9,0.67,0.025 if state.night else 0.045))
	var soil := PackedVector2Array([Vector2(0,217),Vector2(72,224),Vector2(150,210),Vector2(238,235),Vector2(308,209),Vector2(397,213),Vector2(480,195),Vector2(480,332),Vector2(0,332)])
	draw_colored_polygon(soil,tint(Color("244839")))
	for i in range(1200):
		var x := rng.randf_range(0,W)
		var y := rng.randf_range(222,H)
		pixel(x,y,rng.randf_range(1,6),rng.randf_range(1,3),tint([Color("30553d"),Color("3b6546"),Color("53784c"),Color("213a30"),Color("607b4c")][rng.randi_range(0,4)]))
	# Stream: offset stepping pools with animated pixel highlights.
	if state.seed_value % 3 != 0 or state.zone == 0:
		for j in range(64):
			var y := 211+j*2
			var x := 310+sin(j*0.04)*38
			pixel(x,y,30+j*0.32,3,tint(Color("497d76")))
			if j%3 == 0: pixel(x+fmod(t*5+j*9,25),y,12,1,tint(Color("91b6a2")))
	# Fallen nursery log with end grain and bracket fungi.
	pixel(94,235,135,24,tint(Color("2b2823")))
	pixel(100,230,128,20,tint(Color("635441")))
	pixel(101,231,126,3,tint(Color("8a7851")))
	for i in range(25):
		pixel(100+rng.randf()*126,235+rng.randf()*13,rng.randf_range(3,18),1,tint(Color("393d2e")))
	draw_circle(Vector2(226,243),12,tint(Color("a18b61")))
	for rad in [9,6,3]: draw_arc(Vector2(226,243),rad,0,TAU,20,tint(Color("6e6346")),1)
	for i in range(9):
		pixel(100+i*12,229-rng.randf()*3,9,4,tint(Color("6d9457")))
	for p in [Vector2(130,244),Vector2(162,248),Vector2(192,237)]:
		pixel(p.x,p.y,2,7,tint(Color("bca57d")))
		draw_arc(p,5,PI,TAU,8,tint(Color("d2b997")),3)
	# Large framing trees; taller zones have stunted silhouettes.
	for side in range(2):
		var x: float = 49 if side == 0 else 423
		var tw: float = 26 if state.zone != 3 else 17
		draw_colored_polygon(PackedVector2Array([Vector2(x-9,-5),Vector2(x+tw,-5),Vector2(x+tw-5,235),Vector2(x+tw+24,274),Vector2(x+5,259),Vector2(x-20,278),Vector2(x-5,228)]),tint(Color("293d31")))
		pixel(x+5,0,5,246,tint(Color("4e6042")))
		pixel(x+12,0,3,245,tint(Color("66704c")))
		for j in range(37):
			pixel(x+rng.randf_range(-3,tw),rng.randf_range(0,245),rng.randf_range(2,8),rng.randf_range(2,10),tint(Color("3b553b")))
		draw_line(Vector2(x+15,105),Vector2(x+(95 if side==0 else -93),49),tint(Color("344a36")),10)
		for j in range(7):
			fern(Vector2(x+tw*0.5,40+j*28),rng.randf_range(12,23),tint(Color("638759")))
	# Hanging vines and epiphytes.
	for i in range(14):
		var x := rng.randf_range(0,W)
		var end := rng.randf_range(65,175)
		for y in range(0,int(end),3):
			pixel(x+sin(y*0.045+i)*4,y,1,3,tint(Color("71835a")))
			if y%18 == 0: leaf(Vector2(x+sin(y*0.045+i)*4,y),7,0.8 if y%36==0 else 2.2,tint(Color("598054")))
	# Host stems grow with the player's restoration.
	var h: Dictionary = state.habitats[state.zone]
	for i in range(5 + int(h.plants/8)):
		var x := 95+i*23
		var y := 218+rng.randf_range(-12,10)
		var height := rng.randf_range(22,65)
		draw_line(Vector2(x,y),Vector2(x-5,y-height),tint(Color("6e9660")),2)
		for j in range(4):
			leaf(Vector2(x-3,y-j*height/4),17, -0.5 if j%2==0 else -2.7,tint(Color("547c48")))
		if i%2 == 0:
			var c := Color("c59fbd") if state.sense != 3 else Color("eea6ff")
			for petal in range(5):
				var p := Vector2(x-5,y-height)+Vector2.from_angle(petal*TAU/5)*4
				pixel(p.x-2,p.y-2,4,4,c if state.sense==3 else tint(c))
			pixel(x-6,y-height-1,3,3,Color("f1d784"))
	# Crowns are mosaics, with transparent gaps toward the clearing.
	for i in range(290):
		var x := rng.randf_range(-20,W+20)
		var y := rng.randf_range(-30,45)
		if absf(x-240) < 75: y -= 24
		pixel(x,y,rng.randf_range(8,25),rng.randf_range(5,17),tint([Color("18372e"),Color("264b37"),Color("365c3e"),Color("496d45"),Color("698451")][rng.randi_range(0,4)]))
	for i in range(25):
		fern(Vector2(rng.randf_range(0,W),rng.randf_range(286,345)),rng.randf_range(13,38),tint([Color("173f30"),Color("477148"),Color("71965a")][i%3]))
	# Ant workers and their conspicuous moving leaves bootstrap perception.
	if state.zone == 0:
		for i in range(13):
			var x := 95+fmod(i*12+t*5,158)
			var y := 270+sin(x*0.03)*7
			pixel(x,y,4,2,Color("ad7047"))
			leaf(Vector2(x+2,y),5,-1.0,Color("92b963"))
	if state.zone == 0 and state.larva_age >= 0 and not state.adult:
		var p := Vector2(244,194)
		if state.larva_age == 0:
			draw_circle(p,2.5,Color("ece9d5"))
		elif state.larva_age < 5:
			for j in range(5): draw_circle(p+Vector2(j*2, sin(t+j)*0.5),2,Color("d1c27f"))
		else: draw_circle(p,4,Color("97b275"))
	# Sense-specific information: scent topology, stem waves, floral guides,
	# echo geometry and directional sky bands. Not a screen-color overlay.
	match state.sense:
		1:
			for j in range(80):
				var x := 80+j*4
				var y := 250+sin(j*0.06)*22
				draw_circle(Vector2(x,y),2+sin(t+j)*0.7,Color(0.66,0.84,0.4,0.3))
			for j in range(40):
				var a := j*0.25+t*0.3
				draw_circle(Vector2(125+cos(a)*j,128+sin(a)*j*0.4),1,Color(0.77,0.83,0.41,0.6))
		2:
			for i in range(7):
				var x := 145+i*24
				for j in range(20):
					pixel(x+sin(t*6+j*0.5)*4,125+j*4,2,2,Color(0.48,0.86,0.8,0.65))
		3:
			for i in range(9):
				var p := Vector2(98+i*34,174+sin(i*2)*25)
				draw_arc(p,7+sin(t+i)*2,0,TAU,12,Color(0.82,0.5,0.96,0.6),1)
		4:
			for i in range(5):
				var radius := fmod(t*26+i*30,160)
				draw_arc(Vector2(350,75),radius,0.3,2.8,40,Color(0.56,0.71,0.92,(1-radius/160)*0.5),1)
			var bat := Vector2(335+sin(t)*20,65+cos(t*1.4)*8)
			draw_polyline(PackedVector2Array([bat+Vector2(-13,-4),bat+Vector2(-5,3),bat,bat+Vector2(5,3),bat+Vector2(13,-4)]),Color("94b6db"),2)
		5:
			for x in range(100,390,15):
				draw_line(Vector2(x,48),Vector2(x+16,64),Color(0.73,0.86,0.75,0.45),1)
	if state.zone==0:
		var m = state.mystery
		for i in range(2):
			var p: Vector2 = Study.PATCH_POSITIONS[i]
			var cover: float = m.shelter[i]
			if i==1 and m.phase=="growing": cover = lerpf(0.22,0.78,m.growth_hours/8.0)
			PatchArt.draw(self,p,cover,float(m.water[i]))
			if i==selected_patch:
				draw_arc(p,34,0,TAU,36,Color("ece3ae"),1)
		if state.sense==1:
			var route := PackedVector2Array([Vector2(145,264),Vector2(194,274),Vector2(246,270),Vector2(279,249),Vector2(276,217)])
			draw_polyline(route,Color(0.72,0.84,0.48,0.55),2)
			for i in range(route.size()-1):
				var phase := fmod(t*0.3+i*0.31,1.0)
				var p := route[i].lerp(route[i+1],phase)
				draw_circle(p,2,Color("d3df98"))
			draw_arc(Vector2(196,272),9,0,TAU,20,Color("d3df98"),1)
	for s in state.species:
		if not state.visible(s): continue
		var p := location(s)
		if selected == s.id or hovered == s.id:
			draw_arc(p,14+sin(t*2),0,TAU,32,Color("eddb9c"),1)
			draw_line(p+Vector2(-19,0),p+Vector2(-15,0),Color("eddb9c"),1)
			draw_line(p+Vector2(15,0),p+Vector2(19,0),Color("eddb9c"),1)
		draw_bug(self,p,s,0.65+state.larva_quality*0.35 if s.id=="morpho" else 1.0,t)
		if not state.documented.has(s.id): pixel(p.x-1,p.y-19,2,2,Color("eee6bb"))
	# Mist remains soft, drifting pixel ribbons rather than obscuring controls.
	for i in range(9):
		var x := fmod(i*78+t*(1+i%3),650)-100
		pixel(x,95+i*19,130,4+i%3,Color(0.74,0.83,0.77,state.fog()*0.04))

static func draw_bug(canvas: CanvasItem, p: Vector2, s: Dictionary, scale_value: float, time: float) -> void:
	var c := Color(s.color)
	var k: String = s.kind
	var u := scale_value
	var dark := Color("182d28")
	if k in ["butterfly","moth"]:
		var span := (0.75+sin(time*3)*0.2)*u
		for side in [-1,1]:
			var pts := PackedVector2Array([p,p+Vector2(side*12*span,-10*u),p+Vector2(side*17*span,-7*u),p+Vector2(side*14*span,4*u),p+Vector2(side*8*span,11*u),p+Vector2(side*2*u,6*u)])
			canvas.draw_colored_polygon(pts,c)
			canvas.draw_polyline(pts,dark,1*u)
			for j in range(3): canvas.draw_circle(p+Vector2(side*(6+j*3)*span,(-4+j*4)*u),1.2*u,c.lightened(0.5))
		canvas.draw_line(p+Vector2(0,-7*u),p+Vector2(0,9*u),dark,2*u)
	elif k == "bee":
		for side in [-1,1]:
			canvas.draw_circle(p+Vector2(side*5*u,-4*u),4*u,Color(0.83,0.91,0.83,0.65))
		canvas.draw_circle(p,4*u,c)
		canvas.draw_line(p+Vector2(-3*u,0),p+Vector2(3*u,0),dark,2*u)
		canvas.draw_circle(p+Vector2(0,-4*u),2*u,dark)
	elif k == "beetle":
		c = c.lerp(Color("8bc9a3"), (sin(time*1.2)+1)*0.22)
		for side in [-1,1]:
			for j in range(3): canvas.draw_line(p+Vector2(side*3*u,(j-1)*3*u),p+Vector2(side*7*u,(j-1)*5*u),c.darkened(0.3),u)
		canvas.draw_circle(p,6*u,c)
		canvas.draw_circle(p+Vector2(0,-6*u),3*u,c.darkened(0.3))
		canvas.draw_line(p+Vector2(0,-4*u),p+Vector2(0,5*u),dark,u)
		canvas.draw_line(p+Vector2(-3*u,-3*u),p+Vector2(-3*u,3*u),c.lightened(0.5),u)
	elif k == "hopper":
		canvas.draw_colored_polygon(PackedVector2Array([p+Vector2(-7,-2)*u,p+Vector2(0,-9)*u,p+Vector2(7,3)*u,p+Vector2(-5,4)*u]),c)
		canvas.draw_line(p,p+Vector2(8,7)*u,dark,u)
		canvas.draw_circle(p+Vector2(5,1)*u,1.2*u,dark)
	else:
		for j in range(3):
			canvas.draw_circle(p+Vector2((j-1)*4*u,0),2*u,c)
			for side in [-1,1]: canvas.draw_line(p+Vector2((j-1)*3*u,0),p+Vector2((j-1)*5*u,side*4*u),c,u)
