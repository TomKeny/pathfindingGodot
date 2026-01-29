extends TileMapLayer

func _ready() -> void:
	pass
	
	

#grid area 0,0 - 17,9

func tileArray() -> Array[Vector2]:
	var temp: Array[Vector2]
	var start
	var end
	var cells = get_used_cells()
	for cell in cells:
		match get_cell_atlas_coords(Vector2(cell.x,cell.y)):
			Vector2i(0,0):
				start = Vector2(cell.x,cell.y)
			Vector2i(8,0):
				temp.append(Vector2(cell.x,cell.y))
			Vector2i(4,4):
				end = Vector2(cell.x,cell.y)
	temp.push_front(end)
	temp.push_front(start)
	return temp

func colourCell(coords,colourName) -> void:
	var atlasCoords
	match colourName: 
		"green":
			atlasCoords = Vector2i(0,0)
		"black":
			atlasCoords = Vector2i(4,0)
		"white":
			atlasCoords = Vector2i(8,0)
		"red":
			atlasCoords = Vector2i(4,4)
		"blue":
			atlasCoords = Vector2i(0,4)
		"yellow":
			atlasCoords = Vector2i(8,4)
	set_cell(coords,0,atlasCoords)

#green set_cell(Vector2(0,0), 0, Vector2i(2,2))
#black set_cell(Vector2(0,0), 0, Vector2i(10,2))
#white set_cell(Vector2(0,0), 0, Vector2i(2,10))
#red   set_cell(Vector2(0,0), 0, Vector2i(10,10))
