extends Control
var host: Control
func _draw() -> void:
	if host: host.render(self)
