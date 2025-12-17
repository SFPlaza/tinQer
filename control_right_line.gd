extends Line2D

func _process(delta: float) -> void:
	self.points = PackedVector2Array([Vector2(get_viewport_rect().size.x/2,get_viewport_rect().size.y/2-30),Vector2(get_viewport_rect().size.x/2,get_viewport_rect().size.y-60)])
