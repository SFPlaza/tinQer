extends Label

func _process(delta: float) -> void:
	self.position.x = 5
	self.position.y = get_viewport_rect().size.y - 105
