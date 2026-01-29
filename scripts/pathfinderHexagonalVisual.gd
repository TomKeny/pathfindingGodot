extends Node2D

var tileObject

func _ready() -> void: #initialization
	tileObject = $TileMapLayer  #this is for visualization, this doesn't need to exist
	var tiles = tileObject.tileArray()  #this can be any array of coords
	
	var paths = pathfind(tiles)
	runDebugLine(paths[1])

#func _process(_delta: float) -> void:  #perfromance testing
#	print("FPS: " + str(Engine.get_frames_per_second()))

#the schizo hex to axial coord converter
#Vector2(coord.x * 0.75, (coord.y - (coord.x + 1 if (int(coord.y) % 1) else 0) / 2) + (0.5 if (int(coord.x) % 2 == 1) else 0))

func pathfind(coords): #expects an array of coords with indexes 0 = start 1 = ends
	var pathFound = false
	
	var start = coords[0]  #first coord is start
	var end = coords[1]  #second coord is end
	var axialEnd = Vector2(end.x * 0.75, (end.y - (end.x + 1 if (int(end.y) % 1) else 0) / 2) + (0.5 if (int(end.x) % 2 == 1) else 0.0))
	
	var queuedCoords = []
	var completeCoords = []
	
	queuedCoords.append(Coordinate.new(start,0,0,0,Vector2(-1,-1))) #[coord, cost, distance from target, sum of previous 2, parent coord]
	while !pathFound:
		if (generateSuccessor(queuedCoords[0], coords, start, end, axialEnd, queuedCoords, completeCoords)):
			pathFound = true
	
	for Coords in queuedCoords:
		print(Coords.factor)
	
	#even q coords
	
	var hexCoords = pathArray(start,completeCoords)
	var axialCoords = []
	
	for coord in hexCoords:
		axialCoords.append(Vector2(coord.x * 0.75, (coord.y - (coord.x + 1 if (int(coord.y) % 1) else 0) / 2) + (0.5 if (int(coord.x) % 2 == 1) else 0.0)))
	
	print(axialCoords)
	print(hexCoords)
	
	return [hexCoords,axialCoords]

func generateSuccessor(parentCoord, validCoords, start, end, axialEnd, queuedCoords, completeCoords): #pass in coordinate object
	var checkCoords
	if int(parentCoord.coord.x) % 2 == 0:
		checkCoords = [Vector2(parentCoord.coord.x + 1, parentCoord.coord.y),Vector2(parentCoord.coord.x - 1, parentCoord.coord.y),Vector2(parentCoord.coord.x, parentCoord.coord.y + 1),Vector2(parentCoord.coord.x, parentCoord.coord.y - 1),Vector2(parentCoord.coord.x - 1, parentCoord.coord.y - 1), Vector2(parentCoord.coord.x + 1, parentCoord.coord.y - 1)]
	else:
		checkCoords = [Vector2(parentCoord.coord.x + 1, parentCoord.coord.y),Vector2(parentCoord.coord.x - 1, parentCoord.coord.y),Vector2(parentCoord.coord.x, parentCoord.coord.y + 1),Vector2(parentCoord.coord.x, parentCoord.coord.y - 1),Vector2(parentCoord.coord.x - 1, parentCoord.coord.y + 1), Vector2(parentCoord.coord.x + 1, parentCoord.coord.y + 1)]
		
	for coord in checkCoords: 
		var i = 0
		var found = false
		
		while i < validCoords.size(): #checks coord validity
			if coord == validCoords[i]:
				validCoords.remove_at(i)
				found = true
			else:
				i += 1
		
		if found: #if valid adds coord to queue
			var newCost = parentCoord.cost + 0.5
			var newHeuristic = Vector2(coord.x * 0.75, (coord.y - (coord.x + 1 if (int(coord.y) % 1) else 0) / 2) + (0.5 if (int(coord.x) % 2 == 1) else 0.0)).distance_to(axialEnd)
			var newFactor = newCost + newHeuristic
			if coord != start && coord != end:
				tileObject.colourCell(coord,"blue")
			queuedCoords.append(Coordinate.new(coord,newCost,newHeuristic,newFactor,parentCoord.coord))
		
		if coord == end: #complete path found
			if parentCoord.coord != start: tileObject.colourCell(parentCoord.coord,"yellow")
			completeCoords.append(parentCoord)
			completeCoords.append(queuedCoords[queuedCoords.size() - 1])
			return true
	completeCoords.append(parentCoord)
	queuedCoords.remove_at(0)
	queuedCoords.sort_custom(customSort)
	
	if parentCoord.coord != start: tileObject.colourCell(parentCoord.coord,"yellow")
	
	return false

class Coordinate: #data storage for each coordinate being processed
	var coord: Vector2
	var cost: float
	var heuristic: float
	var factor: float
	var parentCoord: Vector2
	
	func _init(Coord,Cost,Heuristic,Factor,ParentCoord):
		coord = Coord
		cost = Cost
		heuristic = Heuristic
		factor = Factor
		parentCoord = ParentCoord

func customSort(a,b):  #custom sort to compare only factor
	return a.factor < b.factor

func pathArray(start, completeCoords): #runs through completed coord making a path
	var currentCoord = completeCoords[completeCoords.size() - 1]
	var path = []
	while currentCoord.coord != start:
		print(currentCoord.coord)
		path.append(currentCoord.coord)
		for coordObject in completeCoords:
			if currentCoord.parentCoord == coordObject.coord:
				currentCoord = coordObject
	
	path.append(currentCoord.coord) #adds the last element that gets missed by the while loop
	
	#print(path) # debugging
	
	return path

func runDebugLine(axialCoords):
	var debugLine = Line2D.new()
	debugLine.default_color = Color(0.0, 0.0, 0.0, 1.0)
	debugLine.scale = Vector2(64,64)
	debugLine.position += Vector2(32,32)
	debugLine.width = 0.2
	get_tree().current_scene.add_child(debugLine)
	debugLine.points = PackedVector2Array(axialCoords)
