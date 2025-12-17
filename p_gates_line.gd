extends Line2D

var ID = 0
@onready var MP = get_node("/root/MainProcessor")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ID = MP.VLineCount
	MP.VLineCount += 1
	#print(MP.Gates.size(),ID)
	#if MP.VLineCount < 14:
	#	var node = self.duplicate()
	#	MP.add_child.call_deferred(node)
	self.set_name("Gates " + str(ID) + " Line")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.points = PackedVector2Array([Vector2(92.5+65*ID,0)+MP.staffPan,Vector2(92.5+65*ID,65*14)+MP.staffPan])
	if (MP.Program.size() - 1) <= ID:
		if ID != 0:
			MP.VLineCount -= 1
			self.queue_free()
	if (MP.Program.size() - 1) > MP.VLineCount:
		if ID == MP.VLineCount - 1:
			var node = self.duplicate()
			MP.add_child.call_deferred(node)
