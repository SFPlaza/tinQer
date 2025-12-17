extends Line2D

func _process(delta: float) -> void:
	self.points = PackedVector2Array([Vector2(0,get_viewport_rect().size.y-60),Vector2(get_viewport_rect().size.x,get_viewport_rect().size.y-60)])
