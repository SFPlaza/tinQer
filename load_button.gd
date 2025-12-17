extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position.x = ((get_viewport_rect().size.x - 180) / 2) + 9
	self.position.y = (get_viewport_rect().size.y / 2) + 9 - 30 + 18 + min(1,(get_viewport_rect().size.y/1080))*72*2
	self.scale.x = 1#(get_viewport_rect().size.x) / 512
	self.scale.y = min(1,(get_viewport_rect().size.y/1080))#60


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position.x = ((get_viewport_rect().size.x - 180) / 2) + 9
	self.position.y = (get_viewport_rect().size.y / 2) + 9 - 30 + 36 + min(1,(get_viewport_rect().size.y/1080))*72*4
	self.scale.x = 1#(get_viewport_rect().size.x) / 512
	self.scale.y = min(1,(get_viewport_rect().size.y/1080))#60

func _on_button_down() -> void:
	get_node("/root/MainProcessor/LoadDialog").show()
	await get_node("/root/MainProcessor/LoadDialog").file_selected
	var loadFile = FileAccess.open(get_node("/root/MainProcessor/LoadDialog").get_current_file(),FileAccess.READ)
	var loadVars = loadFile.get_var()
	get_node("/root/MainProcessor").RawProgram = loadVars[0]
	get_node("/root/MainProcessor").VControlArray = loadVars[1]
	loadFile.close()
	print(get_node("/root/MainProcessor").RawProgram)
	
	for r in get_node("/root/MainProcessor").GateRefs:
		r.queue_free()
	
	get_node("/root/MainProcessor").GateRefs = []
	
	var InstCount = -1
	for u in get_node("/root/MainProcessor").RawProgram:
		InstCount += 1
		var QubitCount = -1
		for v in range(u.length()-1,-1,-1):
			print(u[v], " Q:", QubitCount + 1, " I: ", InstCount)
			QubitCount += 1
			if u[v] != "I":
				var NewGate = get_node("/root/MainProcessor/Gate").duplicate()
				NewGate.Type = u[v]
				NewGate.placed = true
				NewGate.InstNum = InstCount
				NewGate.Qubit = QubitCount
				get_node("/root/MainProcessor").add_child.call_deferred(NewGate)
	get_node("/root/MainProcessor").trim()
	
	
