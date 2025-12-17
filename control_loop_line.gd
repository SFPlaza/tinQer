extends Line2D

var ID = 0
@onready var MP = get_node("/root/MainProcessor")
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.points = PackedVector2Array([Vector2(0-MP.staffPan.x,65)+MP.staffPan,Vector2(get_viewport_rect().size.x-MP.staffPan.x,65)+MP.staffPan])
	
