extends Sprite2D

var ID = 0
@onready var MP = get_node("/root/MainProcessor")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	ID = MP.PBCount
	MP.PBCount += 1
	#print(MP.Gates.size(),ID)
	if MP.PBCount < 15:
		var node = self.duplicate()
		MP.add_child.call_deferred(node)
	self.set_name("Qubit " + str(ID) + " Start")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position.x = MP.Step*65 + MP.staffPan.x + 0.5
	self.position.y = 65*(ID-1) + MP.staffPan.y
