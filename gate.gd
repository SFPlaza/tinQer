extends TextureButton

var Type = "?"
var placed = false
@onready var MP = get_node("/root/MainProcessor")
var Qubit = -1
var InstNum = -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.z_index = 4
	if get_child_count() == 0:
		var Identifier = Label.new()
		Identifier.text = "" + Type
		Identifier.scale = Vector2(1,1)
		Identifier.add_theme_font_size_override("font_size", 48)
		Identifier.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		Identifier.position.x = 30 - Identifier.get_theme_font("font").get_string_size(Identifier.text, HORIZONTAL_ALIGNMENT_LEFT, -1, Identifier.get_theme_font_size("font_size")).x/2
		Identifier.position.y = 30 - Identifier.get_theme_font("font").get_string_size(Identifier.text, HORIZONTAL_ALIGNMENT_LEFT, -1, Identifier.get_theme_font_size("font_size")).y/2
		self.add_child.call_deferred(Identifier)
	else:
		var Identifier = get_children()[0]
		print(Type)
		Identifier.text = "" + Type
		Identifier.scale = Vector2(1,1)
		Identifier.add_theme_font_size_override("font_size", 48)
		Identifier.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		Identifier.position.x = 30 - Identifier.get_theme_font("font").get_string_size(Identifier.text, HORIZONTAL_ALIGNMENT_LEFT, -1, Identifier.get_theme_font_size("font_size")).x/2
		Identifier.position.y = 30 - Identifier.get_theme_font("font").get_string_size(Identifier.text, HORIZONTAL_ALIGNMENT_LEFT, -1, Identifier.get_theme_font_size("font_size")).y/2
		self.add_child.call_deferred(Identifier)
	if self.position.x < 0:
		placed = true
	if Type != "?":
		MP.GateRefs.append(self)
	if Type == "C":
		self.texture_normal = ImageTexture.create_from_image(Image.load_from_file("GateIconRed.png"))
	if Type == "𝕏" or Type == "𝕐":
		self.texture_normal = ImageTexture.create_from_image(Image.load_from_file("GateIconGray.png"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if placed:
		self.z_index = -2
		self.position = Vector2(InstNum*65 + 97.5,Qubit*65 + 97.5) + MP.staffPan - Vector2(30,30)
		if (Type == "?"):
			self.position = Vector2(-300,-30)
		if (self.position.y > (get_viewport_rect().size.y - 60)/2):
			self.disabled = true
		else:
			self.disabled = false
	
func _input(event):
	if event is InputEventMouseMotion and !placed:
		self.position += event.relative
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT and (get_viewport().get_mouse_position()-(self.position+Vector2(30,30))).length() <= 30:
		placed = true
		self.z_index = -2
		Qubit = round(((self.position.y - MP.staffPan.y + 30) - 97.5) / 65)
		InstNum = round(((self.position.x - MP.staffPan.x + 30) - 97.5) / 65)
		if Qubit < 0:
			Qubit = 0
		if Qubit > 12:
			Qubit = 12
		print("Q:",Qubit," I:",InstNum)
		while MP.RawProgram.size() < InstNum + 2:
			MP.RawProgram += ["IIIIIIIIIIIIII"]
		MP.RawProgram[InstNum][max(-12,-1 - Qubit)] = Type
		print(MP.RawProgram[InstNum])
		MP.trim()
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT and (get_viewport().get_mouse_position()-(self.position+Vector2(30,30))).length() <= 30:
		MP.RawProgram[InstNum][max(-12,-1 - Qubit)] = "I"
		print(MP.RawProgram[InstNum])
		MP.trim()
		self.queue_free()
