extends SceneTree
func _initialize() -> void:
	var svg := '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024"><rect x="24" y="24" width="976" height="976" rx="215" fill="#142b21"/><circle cx="512" cy="500" r="342" fill="none" stroke="#71895b" stroke-width="4"/><path d="M512 705C245 748 191 489 262 283C454 286 527 436 512 705Z" fill="#a6bd77"/><path d="M512 705C779 748 833 489 762 283C570 286 497 436 512 705Z" fill="#cddd98"/><path d="M512 722L312 355M512 722L712 355" stroke="#536c43" stroke-width="9"/><path d="M454 419L387 362M570 419L637 362M453 492L365 465M571 492L659 465M455 570L376 599M569 570L648 599" stroke="#d8dfa9" stroke-width="8"/><ellipse cx="512" cy="542" rx="54" ry="165" fill="#bc8851"/><ellipse cx="512" cy="388" rx="46" ry="44" fill="#d7aa68"/><path d="M492 359L465 306M532 359L559 306" stroke="#e1c393" stroke-width="12" stroke-linecap="round"/></svg>'
	var img := Image.new()
	img.load_svg_from_string(svg)
	img.save_png("res://builds/icon.png")
	quit()
