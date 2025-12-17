extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position.x = 0
	self.position.y = (get_viewport_rect().size.y - 60)/2
	self.scale.x = ((get_viewport_rect().size.x - 180) / 2) / 864
	self.scale.y = ((get_viewport_rect().size.y - 60) / 2) / 504


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position.x = 0
	self.position.y = (get_viewport_rect().size.y - 60)/2
	self.scale.x = ((get_viewport_rect().size.x - 180) / 2) / 864
	self.scale.y = ((get_viewport_rect().size.y - 60) / 2) / 504
