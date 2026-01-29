extends Node2D

var tileObject

func _ready() -> void: #initialization
	tileObject = $TileMapLayer  #this is for visualization, this doesn't need to exist
	var tiles = tileObject.tileArray()  #this can be any array of coords
	
	var paths = pathfind(tiles) #returns path as [hex coords, axial coords] uses even q coords
	runDebugLine(paths[1]) #pass axial coords

#hex to axial coord converter
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
		if (generateSuccessor(queuedCoords[0], coords, end, axialEnd, queuedCoords, completeCoords)):
			pathFound = true
	
	#for Coords in queuedCoords:  #debugging
	#	print(Coords.factor)
	
	var hexCoords = pathArray(completeCoords)
	var axialCoords = []
	
	for coord in hexCoords: #converts hex coords to axial coords
		axialCoords.append(Vector2(coord.x * 0.75, (coord.y - (coord.x + 1 if (int(coord.y) % 1) else 0) / 2) + (0.5 if (int(coord.x) % 2 == 1) else 0.0)))
	
	#print(axialCoords)
	#print(hexCoords)
	
	return [hexCoords,axialCoords]

func generateSuccessor(parentCoord, validCoords, end, axialEnd, queuedCoords, completeCoords): #pass in coordinate object
	var checkCoords
	if int(parentCoord.coord.x) % 2 == 0: #adds coords based on column(the surrounding tile coords differ by column being odd or even)
		checkCoords = [Vector2(parentCoord.coord.x + 1, parentCoord.coord.y),Vector2(parentCoord.coord.x - 1, parentCoord.coord.y),Vector2(parentCoord.coord.x, parentCoord.coord.y + 1),Vector2(parentCoord.coord.x, parentCoord.coord.y - 1),Vector2(parentCoord.coord.x - 1, parentCoord.coord.y - 1), Vector2(parentCoord.coord.x + 1, parentCoord.coord.y - 1)]
	else:
		checkCoords = [Vector2(parentCoord.coord.x + 1, parentCoord.coord.y),Vector2(parentCoord.coord.x - 1, parentCoord.coord.y),Vector2(parentCoord.coord.x, parentCoord.coord.y + 1),Vector2(parentCoord.coord.x, parentCoord.coord.y - 1),Vector2(parentCoord.coord.x - 1, parentCoord.coord.y + 1), Vector2(parentCoord.coord.x + 1, parentCoord.coord.y + 1)]
		
	for coord in checkCoords: #loops through each coord set to check
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
			queuedCoords.append(Coordinate.new(coord,newCost,newHeuristic,newFactor,parentCoord.coord))
		
		if coord == end: #complete path found
			completeCoords.append(parentCoord)
			completeCoords.append(queuedCoords[queuedCoords.size() - 1])
			return true
	
	#updates coord arrays and re-sorts queued array
	completeCoords.append(parentCoord) 
	queuedCoords.remove_at(0)
	queuedCoords.sort_custom(customSort)
	
	return false

func customSort(a,b):  #custom sort to compare only factor
	return a.factor < b.factor

func pathArray(completeCoords): #runs through completed coord making a path
	var currentCoord = completeCoords[completeCoords.size() - 1]
	var path = []
	while currentCoord.parentCoord != Vector2(-1,-1):
		#print(currentCoord.coord)
		path.append(currentCoord.coord)
		for coordObject in completeCoords:
			if currentCoord.parentCoord == coordObject.coord:
				currentCoord = coordObject
	
	path.append(currentCoord.coord) #adds the last element that gets missed by the while loop
	
	#print(path) # debugging
	
	return path

class Coordinate: #data storage for each coordinate being processed
	var coord: Vector2              #Coords own coordinate
	var cost: float                 #cost to reach this coord
	var heuristic: float            #estimate distance to target
	var factor: float               #sum of cost and heuristic
	var parentCoord: Vector2        #coordinate that submitted this coord to be checked
	
	func _init(Coord,Cost,Heuristic,Factor,ParentCoord):
		coord = Coord
		cost = Cost
		heuristic = Heuristic
		factor = Factor
		parentCoord = ParentCoord

func runDebugLine(axialCoords): #creates a debug line to show the path/points produced
	var debugLine = Line2D.new()
	debugLine.default_color = Color(0.0, 0.0, 0.0, 1.0)
	debugLine.scale = Vector2(64,64)
	debugLine.position += Vector2(32,32)
	debugLine.width = 0.2
	get_tree().current_scene.add_child(debugLine)
	debugLine.points = PackedVector2Array(axialCoords)
