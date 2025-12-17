extends TextureButton

var ID = 0
@onready var MP = get_node("/root/MainProcessor")
@onready var GH = get_node("/root/MainProcessor/GateHolder")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ID = MP.ButtonCount
	MP.ButtonCount += 1
	#print(MP.Gates.size(),ID)
	if MP.ButtonCount < MP.Gates.size():
		var node = self.duplicate()
		MP.add_child.call_deferred(node)
	self.set_name(MP.Gates.keys()[ID] + " Maker")
	#self.text = MP.Gates.keys()[ID]
	var Identifier = Label.new()
	Identifier.text = "" + MP.Gates.keys()[ID]
	Identifier.scale = Vector2(1,1)
	Identifier.add_theme_font_size_override("font_size", 48)
	Identifier.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	Identifier.position.x = 30 - Identifier.get_theme_font("font").get_string_size(Identifier.text, HORIZONTAL_ALIGNMENT_LEFT, -1, Identifier.get_theme_font_size("font_size")).x/2
	Identifier.position.y = 30 - Identifier.get_theme_font("font").get_string_size(Identifier.text, HORIZONTAL_ALIGNMENT_LEFT, -1, Identifier.get_theme_font_size("font_size")).y/2
	self.add_child.call_deferred(Identifier)
	if MP.Gates.keys()[ID] == "C":
		self.texture_normal = ImageTexture.create_from_image(Image.load_from_file("GateIconRed.png"))
	if MP.Gates.keys()[ID] == "𝕏" or MP.Gates.keys()[ID] == "𝕐":
		self.texture_normal = ImageTexture.create_from_image(Image.load_from_file("GateIconGray.png"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position.x = ID*75 + 30
	self.position.y = (get_viewport_rect().size.y - 60)/2 + 30
	while self.position.x + 60 > ((get_viewport_rect().size.x - 180) / 2):
		self.position.x -= floor(((get_viewport_rect().size.x - 180) / 2 - 15)/75)*75
		self.position.y += 75


func _on_button_down() -> void:
	var NewGate = get_node("/root/MainProcessor/Gate").duplicate()
	NewGate.Type = MP.Gates.keys()[ID]
	NewGate.position = get_viewport().get_mouse_position() - Vector2(30,30)
	GH.add_child.call_deferred(NewGate)
