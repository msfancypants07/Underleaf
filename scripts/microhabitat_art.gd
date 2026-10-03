extends RefCounted
# Shared geometry for the living patches and the notebook's saved observations.
static func draw(c: CanvasItem, p: Vector2, cover: float, water: float, scale_value: float = 1.0, preview: bool = false) -> void:
	var soil := Color("746245").lerp(Color("2c5547"),water/100.0)
	var leaf_color := Color("8ca16c")
	if preview: leaf_color = Color("dfd7a0")
	var u := scale_value
	var outline := PackedVector2Array()
	for i in range(24):
		var a := i*TAU/24
		outline.append(p+Vector2(cos(a)*31,sin(a)*11)*u)
	c.draw_colored_polygon(outline,soil)
	for j in range(17):
		var v := Vector2(sin(j*5.3)*25,cos(j*7.1)*7)
		c.draw_line(p+v*u,p+(v+Vector2(4,1))*u,Color("8b8060"),u)
	# Surface glints change in number as well as color.
	for j in range(int(water/9)):
		var v := Vector2(sin(j*2.1)*23,cos(j*3.2)*6)
		c.draw_line(p+v*u,p+(v+Vector2(3,0))*u,Color("b9d5bc"),u)
	c.draw_polyline(PackedVector2Array([p+Vector2(-18,-3)*u,p+Vector2(-21,-42)*u,p+Vector2(-30,-53)*u]),Color("657c4e"),2*u)
	c.draw_line(p+Vector2(-21,-32)*u,p+Vector2(-7,-45)*u,Color("657c4e"),2*u)
	for i in range(int(3+cover*15)):
		var x := -22+sin(i*2.5)*24
		var y := -42+cos(i*1.7)*10
		var points := PackedVector2Array([p+Vector2(x-11,y)*u,p+Vector2(x,y-5)*u,p+Vector2(x+12,y+2)*u,p+Vector2(x,y+5)*u])
		c.draw_colored_polygon(points,leaf_color.darkened((i%3)*0.1))
		c.draw_line(p+Vector2(x-8,y)*u,p+Vector2(x+8,y+1)*u,Color("c5cd96"),0.6*u)
	# The local shadow footprint follows the modeled shelter, not the zone slider.
	c.draw_rect(Rect2(p+Vector2(-28,-5)*u,Vector2(56*cover,10)*u),Color(0.08,0.17,0.1,0.22))
