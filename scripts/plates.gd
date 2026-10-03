extends RefCounted
# Original vector field illustrations, separate from the tiny world sprites.
static func oval(c: CanvasItem, p: Vector2, r: Vector2, color: Color, angle: float = 0) -> void:
	var points := PackedVector2Array()
	for i in range(64): points.append(p+Vector2(cos(i*TAU/64)*r.x,sin(i*TAU/64)*r.y).rotated(angle))
	c.draw_colored_polygon(points,color)
	points.append(points[0])
	c.draw_polyline(points,color.darkened(0.25),1.3,true)

static func leg(c: CanvasItem, p: Vector2, side: int, y: float, color: Color, reach: float = 1.0) -> void:
	var q := p+Vector2(side*25,y)
	var knee := p+Vector2(side*(69+absf(y)*0.4)*reach,y*1.7)
	var foot := knee+Vector2(side*22,36 if y>=0 else -29)
	c.draw_polyline(PackedVector2Array([q,knee,foot,foot+Vector2(side*10,-5)]),color,3.5,true)
	c.draw_polyline(PackedVector2Array([q,knee,foot]),color.lightened(0.15),1,true)
	c.draw_circle(knee,3,color)

static func draw(c: CanvasItem, p: Vector2, s: Dictionary) -> void:
	var body := Color(s.color)
	var ink := Color("3c4436")
	var kind: String = s.kind
	if kind in ["butterfly","moth"]:
		for side in [-1,1]:
			var pts := PackedVector2Array([p+Vector2(side*9,-30),p+Vector2(side*40,-64),p+Vector2(side*153,-119),p+Vector2(side*179,-113),p+Vector2(side*187,-89),p+Vector2(side*171,-31),p+Vector2(side*132,21),p+Vector2(side*148,67),p+Vector2(side*130,112),p+Vector2(side*86,134),p+Vector2(side*31,111),p+Vector2(side*11,55)])
			c.draw_colored_polygon(pts,ink)
			var inner := PackedVector2Array()
			for q in pts: inner.append(p+(q-p)*0.87)
			c.draw_colored_polygon(inner,body)
			for j in range(8):
				var tip := p+Vector2(side*(47+j*16),-40-j*9)
				c.draw_line(p+Vector2(side*11,0),tip,body.darkened(0.4),1.5,true)
				c.draw_line(p+Vector2(side*14,35),p+Vector2(side*(40+j*12),102-j*8),body.darkened(0.4),1.4,true)
				oval(c,p+Vector2(side*(143-j*9),-76+j*18),Vector2(3,6),Color("e6e1bf"),side*0.6)
			for j in range(5):
				oval(c,p+Vector2(side*(43+j*17),91-j*8),Vector2(4,5),ink)
			if kind=="moth":
				for j in range(9): oval(c,p+Vector2(side*(40+(j%3)*32),-65+(j/3)*36),Vector2(9,13),ink,0.3)
		oval(c,p+Vector2(0,30),Vector2(10,53),ink)
		oval(c,p+Vector2(0,-21),Vector2(12,23),body.darkened(0.5))
		oval(c,p+Vector2(0,-46),Vector2(9,10),ink)
		for side in [-1,1]:
			c.draw_polyline(PackedVector2Array([p+Vector2(side*4,-50),p+Vector2(side*15,-72),p+Vector2(side*22,-77)]),ink,1.5,true)
			c.draw_circle(p+Vector2(side*22,-77),3,ink)
	elif kind=="ant":
		# Dorsal view: head, mesosoma, narrow waist, gaster, six jointed legs.
		for side in [-1,1]:
			for y in [-28,0,28]: leg(c,p,side,y,body.darkened(0.45))
		oval(c,p+Vector2(0,86),Vector2(42,57),body.darkened(0.25))
		for y in [72,92,109]: c.draw_arc(p+Vector2(0,y-12),34,0.3,PI-0.3,30,body.darkened(0.45),1.3,true)
		oval(c,p+Vector2(0,35),Vector2(10,17),body)
		oval(c,p,Vector2(24,39),body.darkened(0.1))
		oval(c,p+Vector2(0,-64),Vector2(36,34),body)
		oval(c,p+Vector2(-10,-73),Vector2(11,16),body.lightened(0.15),0.3)
		for side in [-1,1]:
			oval(c,p+Vector2(side*28,-72),Vector2(5,8),ink)
			c.draw_polyline(PackedVector2Array([p+Vector2(side*18,-85),p+Vector2(side*52,-120),p+Vector2(side*92,-124)]),body.darkened(0.3),3,true)
			c.draw_polyline(PackedVector2Array([p+Vector2(side*14,-91),p+Vector2(side*12,-104),p+Vector2(side*4,-100)]),ink,3,true)
	elif kind=="beetle":
		for side in [-1,1]:
			for y in [-39,0,39]: leg(c,p,side,y,body.darkened(0.55),1.1)
		oval(c,p+Vector2(0,26),Vector2(70,101),body.darkened(0.25))
		oval(c,p+Vector2(-4,22),Vector2(63,95),body)
		for i in range(13):
			var x := -53+i*8.5
			var h := sqrt(maxf(0,1-pow(x/66,2)))*85
			c.draw_line(p+Vector2(x,24-h),p+Vector2(x,24+h),body.lightened(0.12) if i%2==0 else body.darkened(0.13),2,true)
		c.draw_line(p+Vector2(0,-64),p+Vector2(0,119),ink,2,true)
		oval(c,p+Vector2(0,-68),Vector2(48,32),body.darkened(0.15))
		oval(c,p+Vector2(0,-104),Vector2(26,18),body.darkened(0.45))
		oval(c,p+Vector2(-23,-1),Vector2(11,48),Color(1,1,0.84,0.35),0.18)
		for side in [-1,1]:
			c.draw_circle(p+Vector2(side*22,-109),5,ink)
			c.draw_polyline(PackedVector2Array([p+Vector2(side*16,-115),p+Vector2(side*33,-133),p+Vector2(side*45,-136)]),ink,2,true)
	elif kind=="bee":
		for side in [-1,1]:
			for y in [-25,5,28]: leg(c,p,side,y,ink,0.83)
			oval(c,p+Vector2(side*71,-30),Vector2(36,94),Color(0.85,0.9,0.79,0.72),side*0.65)
			for j in range(5): c.draw_line(p+Vector2(side*21,-11),p+Vector2(side*(53+j*16),-95+j*17),Color("a3b69f"),1,true)
		oval(c,p+Vector2(0,45),Vector2(35,64),body)
		for y in [17,44,69]:
			oval(c,p+Vector2(0,y),Vector2(33 if y<69 else 29,8),ink)
		oval(c,p+Vector2(0,-28),Vector2(38,41),body)
		for i in range(85):
			var a := i*2.399
			var r := sqrt(i/85.0)*38
			var v := Vector2(cos(a),sin(a))*r
			c.draw_line(p+Vector2(0,-28)+v,p+Vector2(0,-28)+v*1.1,body.lightened(0.3),1,true)
		oval(c,p+Vector2(0,-73),Vector2(25,22),ink)
		for side in [-1,1]: c.draw_polyline(PackedVector2Array([p+Vector2(side*10,-86),p+Vector2(side*19,-108),p+Vector2(side*30,-111)]),ink,2,true)
	else:
		# Side-on treehopper study, with helmet-like pronotum and wing venation.
		for i in range(3): c.draw_polyline(PackedVector2Array([p+Vector2(i*19-30,20),p+Vector2(i*24-45,75),p+Vector2(i*34-20,103)]),ink,3,true)
		oval(c,p+Vector2(10,20),Vector2(95,40),body.darkened(0.2),0.1)
		c.draw_colored_polygon(PackedVector2Array([p+Vector2(-87,7),p+Vector2(-29,-102),p+Vector2(67,-16),p+Vector2(106,12)]),body)
		c.draw_polyline(PackedVector2Array([p+Vector2(-87,7),p+Vector2(-29,-102),p+Vector2(67,-16),p+Vector2(106,12)]),ink,2,true)
		for i in range(8): c.draw_line(p+Vector2(-63+i*18,11),p+Vector2(-45+i*17,45),body.darkened(0.5),1,true)
		oval(c,p+Vector2(82,4),Vector2(22,20),body)
		c.draw_circle(p+Vector2(90,-3),7,ink)
		c.draw_circle(p+Vector2(88,-5),2,Color("eae2ba"))
