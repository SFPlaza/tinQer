extends Node2D

var ButtonCount = 0;
var LineCount = 0;
var VLineCount = 0;
var VControlCount = 0;
var VControlArray = [false];
var QubitCount = 0;
var PBCount = 0;

var GateRefs = []

var PixelCount = 0;
var PixelData = []

var XPix = 2
var YPix = 2

var possibilities = ["0","1"];
#init in ready

var Gates = {
	
		"I" :[[[1,0], [0,0]],

			 [[0,0], [1,0]]],


		"X" :[[[0,0], [1,0]],

			 [[1,0], [0,0]]],



		"H" :[[[0.70710678118,0], [0.70710678118,0]],

			 [[0.70710678118,0], [-0.70710678118,0]]],


		"Z" :[[[1,0], [0,0]],

			 [[0,0], [-1,0]]],


		"T" :[[[1,0], [0,0]],

			 [[0,0], [0.70710678118,0.70710678118]]],

		"C" :[[[0,0], [0,0]],

			 [[0,0], [0,0]]],
			
		"𝕏" :[[[0,0]]],
		
		"𝕐" :[[[0,0]]]
}

var GennedGates = {}
var kroneckerStore = {}

var Step = 0
var StepChange = 0
var Program = []#["II"]
var RawProgram = ["IIIIIIIIIIIIII"]
var SV = null
var VP = null

func kronecker(gate1, gate2, gatesName):
	if !kroneckerStore.keys().has(gatesName):
		print(gatesName," MANUAL")
		var size1 = gate1.size()
		var size2 = gate2.size()
		var product = [];
		var productLine = [];
		
		productLine.resize(size1 * size2)
		for w in range(size1 * size2):
			product.append(productLine.duplicate(true))
		
		for x in range(size1):
			for y in range(size1):
				for a in range(size2):
					for b in range(size2):
						#print(x,y,a,b)
						product[x * size2 + a][y * size2 + b] = [gate1[x][y][0] * gate2[a][b][0] - gate1[x][y][1] * gate2[a][b][1], gate1[x][y][0] * gate2[a][b][1] + gate1[x][y][1] * gate2[a][b][0]]
		kroneckerStore[gatesName] = product.duplicate(true)
		return product
	else:
		print(gatesName," CACHED")
		return kroneckerStore[gatesName]

func mat_add(mat1, mat2):
	var size = mat1.size()
	var res = [];
	var resLine = [];
	
	resLine.resize(size)
	for w in range(size):
		res.append(resLine.duplicate(true))
	
	for x in range(size):
		for y in range(size):
			res[x][y] = [mat1[x][y][0] + mat2[x][y][0], mat1[x][y][1] + mat2[x][y][1]]
	return res
	
func mat_sub(mat1, mat2):
	var size = mat1.size()
	var res = [];
	var resLine = [];
	
	resLine.resize(size)
	for w in range(size):
		res.append(resLine.duplicate(true))
	
	for x in range(size):
		for y in range(size):
			res[x][y] = [mat1[x][y][0] - mat2[x][y][0], mat1[x][y][1] - mat2[x][y][1]]
	return res

func trim():
	var Instructions = RawProgram.size()
	var RevRawProgram = RawProgram.duplicate(true)
	RevRawProgram.reverse()
	for x in RevRawProgram:
		var Identity = true
		for y in x:
			if y != "I":
				Identity = false
		if Identity:
			Instructions -= 1
		else:
			break
	var QubitNum = 0
	for x in range(14):
		for y in RawProgram:
			if y[-1 - x] != "I":
				QubitNum = x + 1
	print("Trimmed, Qubits:",QubitNum," Instructions:",Instructions)
	
	Program = []
	
	Program.push_front(RawProgram[-1].substr(RawProgram[-1].length() - QubitNum,QubitNum))
	
	for x in range(Instructions):
		Program.append(RawProgram[x].substr(RawProgram[x].length() - QubitNum,QubitNum))
			
	Program.push_back(RawProgram[-1].substr(RawProgram[-1].length() - QubitNum,QubitNum))
	#print(RawProgram)
	print(Program)
		
	initProgram()

func measure(gateMask):
	var data = VP
	var dataList = [0]
	dataList.resize(2**gateMask.length())
	dataList.fill(0)
	if data != null:
		data = data.get_texture().get_image()
		data.crop(1,2**Program[Step].length())
		for m in range(2**gateMask.length()):
			var getcolor = (data.get_pixel(0,m))
			dataList[m] = (getcolor.r**2 + getcolor.g**2)
	#print(dataList)
	if possibilities.size() != (2**gateMask.length()):
		possibilities = ["0","1"]
		while possibilities.size() < 2**gateMask.length():
			var newPos = []
			for j in possibilities:
				newPos.append(j + "0")
				newPos.append(j + "1")
			possibilities = newPos
	var measures = {}
	for k in possibilities:
		var measure = ""
		for l in range(gateMask.length()):
			if gateMask[l] != "I":
				measure += k[l]
		if !measures.has(measure):
			measures[measure] = 0
		measures[measure] += dataList[k.bin_to_int()]
	print(measures)
	#print(possibilities)
	return measures

func generate(parallelGates: String):
	print("GEN REQ ", parallelGates)
	var skip = false;
	if ResourceLoader.exists(parallelGates + ".png"):
		if !GennedGates.keys().has(parallelGates):
			GennedGates[parallelGates] = Image.load_from_file(parallelGates + ".png")
			print(parallelGates + "LOADED")
	if !GennedGates.keys().has(parallelGates) or String(parallelGates).contains("𝕐") or String(parallelGates).contains("𝕏"):#!ResourceLoader.exists(parallelGates + ".png"):
		var gatesImg = Image.create(2**parallelGates.length(), 2**parallelGates.length(), false, Image.FORMAT_RGBA8)
		
		var gateQueue = String(parallelGates)
		var outputGate = [[[1,0]]]
		if gateQueue.contains("𝕏") or gateQueue.contains("𝕐"):
			var measurements = measure(gateQueue)
			#PixelData[0][0] = 0.5
			#PixelData[1][0] = 1
			#print(PixelData)
			
			PixelData.fill(0)
			PixelData = PixelData.duplicate(true)
			
			for n in measurements.keys():
				var xPart = ""
				var yPart = ""
				var measIterCount = -1
				for o in gateQueue:
					if o != "I":
						if o == "𝕏":
							measIterCount += 1
							xPart += n[measIterCount]
						if o == "𝕐":
							measIterCount += 1
							yPart += n[measIterCount]
				XPix = 2**xPart.length()
				YPix = 2**yPart.length()
				updatePixelData()
				if (XPix*yPart.bin_to_int() + xPart.bin_to_int()) < PixelData.size():
					PixelData[XPix*yPart.bin_to_int() + xPart.bin_to_int()] = measurements[n]

			gateQueue = "I".repeat(parallelGates.length())
			if !GennedGates.keys().has(gateQueue):
				var gennedName = ""
				while (gateQueue.length() > 0):
					gennedName = gateQueue[-1] + gennedName
					outputGate = kronecker(Gates[gateQueue[-1]],outputGate,gennedName)
					gateQueue = gateQueue.substr(0,gateQueue.length()-1)
			else:
				gatesImg = GennedGates[gateQueue]
				skip = true
		elif !gateQueue.contains("C"):
			var gennedName = ""
			while (gateQueue.length() > 0):
				gennedName = gateQueue[-1] + gennedName
				outputGate = kronecker(Gates[gateQueue[-1]],outputGate,gennedName)
				gateQueue = gateQueue.substr(0,gateQueue.length()-1)
		else:
			var baseGate = [[[1,0]]]
			var removeGate = [[[1,0]]]
			var conditionGate = [[[1,0]]]
			var baseName = ""
			var removeName = ""
			var conditionName = ""
			while (gateQueue.length() > 0):
				if gateQueue[-1] == "C":
					baseName = "I" + baseName
					baseGate = kronecker(Gates["I"],baseGate,baseName)
					removeName = "1" + removeName
					removeGate = kronecker([[[0,0], [0,0]], [[0,0], [1,0]]],removeGate,removeName)
					conditionName = "1" + conditionName
					conditionGate = kronecker([[[0,0], [0,0]], [[0,0], [1,0]]],conditionGate,conditionName)
				else:
					baseName = "I" + baseName
					baseGate = kronecker(Gates["I"],baseGate,baseName)
					removeName = "I" + removeName
					removeGate = kronecker(Gates["I"],removeGate,removeName)
					conditionName = gateQueue[-1] + conditionName
					conditionGate = kronecker(Gates[gateQueue[-1]],conditionGate,conditionName)
				gateQueue = gateQueue.substr(0,gateQueue.length()-1)
			outputGate = mat_add(mat_sub(baseGate,removeGate),conditionGate)
		if !skip:
			var R = 0
			var G = 0
			var B = 0
			for c in range(2**parallelGates.length()):
				for d in range(2**parallelGates.length()):
					#print(c,d," ",outputGate.size())
					R = outputGate[c][d][0]
					G = outputGate[c][d][1]
					B = 0
					if R < 0:
						R *= -1
						B += 0.25
					if G < 0:
						G *= -1
						B += 0.5
					gatesImg.set_pixel(c,d,Color(R,G,B))
			gatesImg.save_png(parallelGates + ".png");
			GennedGates[parallelGates] = gatesImg
			print("Genned " + parallelGates)
		return gatesImg
	else:
		#print("Stored")
		return GennedGates[parallelGates]#load(parallelGates + ".png")

func newStateVector(n):
	var SVImg = Image.create(1, 2**n, false, Image.FORMAT_RGBAF)
	SVImg.fill(Color.BLACK)
	SVImg.set_pixel(0,0,Color(1,0,0,1))
	SVImg.save_png("SV.png");
	return SVImg

func displayScale(statevector : Sprite2D, svSize : int):
	statevector.apply_scale(Vector2(60.0,floor(get_viewport_rect().size.x / svSize)))
	
func computeScale(statevector : Sprite2D, svSize : int):
	statevector.apply_scale(Vector2(1.0/60.0,1.0/floor(get_viewport_rect().size.x / svSize)))

func runProgram(program : Array):
	var StateVector = get_node("Compute/StateVector")
	var CompView = get_node("Compute")
	StateVector.material.set("shader_parameter/inactive",1)
	StateVector.texture = ImageTexture.create_from_image(newStateVector(program[0].length()))
	await RenderingServer.frame_post_draw
	var test = CompView.get_texture().get_image()
	test.save_png("TEST.png");
	#displayScale($StateVector, 2**program[0].length())
	#await get_tree().process_frame
	for f in program:
		#computeScale($StateVector, 2**program[0].length())
		StateVector.material.set("shader_parameter/inactive",0)
		#await get_tree().process_frame
		StateVector.material.set("shader_parameter/gateTexture",ImageTexture.create_from_image(generate(f)))
		StateVector.material.set("shader_parameter/inactive",0)
		await RenderingServer.frame_post_draw
		var result = CompView.get_texture().get_image()
		var SVImg = Image.create(1, 2**f.length(), false, Image.FORMAT_RGBA8)
		for g in range(2**f.length()):
			@warning_ignore("narrowing_conversion")
			#print(f,g,result.get_pixel(0,g),StateVector.global_transform.get_scale())
			@warning_ignore("narrowing_conversion")
			SVImg.set_pixel(0,g,result.get_pixel(0,g))
		StateVector.texture = ImageTexture.create_from_image(SVImg)
		#displayScale($StateVector, 2**program[0].length())
		StateVector.material.set("shader_parameter/inactive",1)
		await RenderingServer.frame_post_draw
	StateVector.material.set("shader_parameter/gateTexture",ImageTexture.create_from_image(generate(program[0])))

func initProgram():
	if Program.size() > 0:
		SV = get_node("Compute/StateVector")
		VP = get_node("Compute")
		SV.material.set("shader_parameter/inactive",1)
		SV.texture = ImageTexture.create_from_image(newStateVector(Program[0].length()))
		Step = 0
		await RenderingServer.frame_post_draw
		#displayScale($StateVector, 2**program[0].length())
		#await get_tree().process_frame

func stepProgram():
	if SV != null and VP != null and StepChange != 0:
		if Step < (Program.size() - 1) or StepChange < 0:
			if StepChange > 0:
				Step += 1
				StepChange -= 1
				if Step > 0:
					if !VControlArray[Step] and VControlArray[Step-1]:
						var jumpLen = 1
						while VControlArray[Step-jumpLen-1]:
							jumpLen += 1
						print("JUMPING BACK ",jumpLen)
						Step -= jumpLen

				SV.material.set("shader_parameter/gateTexture",ImageTexture.create_from_image(generate(Program[Step])))
				SV.material.set("shader_parameter/inactive",0)
				await RenderingServer.frame_post_draw
				var result = VP.get_texture().get_image()
				result.crop(1,2**Program[Step].length())
				var SVImg = result#Image.create(1, 2**Program[Step].length(), false, Image.FORMAT_RGBAF)
				#for g in range(2**Program[Step].length()):
				#	@warning_ignore("narrowing_conversion")
				#	if g == 2**Program[Step].length()/2:
				print(Program[Step],result.get_pixel(0,2**Program[Step].length()/2),SV.global_transform.get_scale())
				#	@warning_ignore("narrowing_conversion")
				#	SVImg.set_pixel(0,g,result.get_pixel(0,g))
				SV.texture = ImageTexture.create_from_image(SVImg)
				SV.material.set("shader_parameter/inactive",1)
				await RenderingServer.frame_post_draw
				#print(SV.texture.get_format())
			elif StepChange < 0:
				Step += StepChange
				if Step < 0:
					Step = 0
				StepChange = 0
				initProgram()

func initPixelData():
	PixelData.resize(XPix*YPix)
	PixelData.fill(0)
	PixelData = PixelData.duplicate(true)

func updatePixelData():
	PixelData.resize(XPix*YPix)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initPixelData()

	var grover6 = ["IIIIII","HHHHHH","IXXXXX","ZCCCCC","IXXXXX","HHHHHH","XXXXXX","HIIIII","XCCCCC","HIIIII","XXXXXX","HHHHHH"
	,"IXXXXX","ZCCCCC","IXXXXX","HHHHHH","XXXXXX","HIIIII","XCCCCC","HIIIII","XXXXXX","HHHHHH"
	,"IXXXXX","ZCCCCC","IXXXXX","HHHHHH","XXXXXX","HIIIII","XCCCCC","HIIIII","XXXXXX","HHHHHH"
	,"IXXXXX","ZCCCCC","IXXXXX","HHHHHH","XXXXXX","HIIIII","XCCCCC","HIIIII","XXXXXX","HHHHHH"
	,"IXXXXX","ZCCCCC","IXXXXX","HHHHHH","XXXXXX","HIIIII","XCCCCC","HIIIII","XXXXXX","HHHHHH"]
	
	var grover5 = ["IIIII","HHHHH","IXXXX","ZCCCC","IXXXX","HHHHH","XXXXX","HIIII","XCCCC","HIIII","XXXXX","HHHHH"
	,"IXXXX","ZCCCC","IXXXX","HHHHH","XXXXX","HIIII","XCCCC","HIIII","XXXXX","HHHHH"
	,"IXXXX","ZCCCC","IXXXX","HHHHH","XXXXX","HIIII","XCCCC","HIIII","XXXXX","HHHHH"
	,"IXXXX","ZCCCC","IXXXX","HHHHH","XXXXX","HIIII","XCCCC","HIIII","XXXXX","HHHHH"]
	
	var add3 = ["III","XCC","IXC","IIX"]
	while add3.size() < 4*(2**3):
		add3 += add3
		
	var add7 = ["IIIIIII","XCCCCCC","IXCCCCC","IIXCCCC","IIIXCCC","IIIIXCC","IIIIIXC","IIIIIIX"]
	while add7.size() < 8*(2**7):
		add7 += add7
	add7.push_front("IIIIIII")
	add7[1] = "IIIIIHH"
	
	var Sup_add5 = ["IIIII","HIIII","CXCCC","CIXCC","CIIXC","CIIIX"]
	while Sup_add5.size() < 6*(2**5):
		Sup_add5 += Sup_add5
	
	var add9 = ["IIIIIIIII","XCCCCCCCC","IXCCCCCCC","IIXCCCCCC","IIIXCCCCC","IIIIXCCCC","IIIIIXCCC","IIIIIIXCC","IIIIIIIXC","IIIIIIIIX"]
	while add9.size() < 10*(2**9):
		add9 += add9
	add9.push_front("IIIIIIIII")
	add9[1] = "IIIIIIHHH"
	
	var test = ["II","HI","CX"]
	
	#runProgram(grover)
	#Program = add9
	measure("IIDDD")
	initProgram()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print(Step," ",StepChange)
	stepProgram()
	
var staffPan = Vector2(0,0)
var gateDragging = false
var staffPanning = false
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if get_viewport().get_mouse_position().y < (get_viewport_rect().size.y - 60)/2:
			staffPanning = true
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		staffPanning = false
		gateDragging = false
	if event is InputEventMouseMotion and staffPanning:
		staffPan += event.relative
		staffPan.x = min(0,staffPan.x)
		staffPan.y = min(0,staffPan.y)
