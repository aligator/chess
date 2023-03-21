# This chess implementation uses a very naive approach using a two dimensional
# array. It should easily be fast enough to just check one figure.

extends Node2D

@export var figure_scene: PackedScene = preload("res://Objects/figure.tscn")

@onready var tile_map = $TileMap

var figures: Array = []

var selected_figure: Vector2i = Vector2i(-1, -1)

func _get_figure(position: Vector2i) -> Figure: 
	if position.x < 0 || position.x >= 8 || position.y < 0 || position.y >= 8:
		return null
		
	return figures[position.x][position.y]

# _setsFigure to the given state.
# This does not validate anything.
func _set_figure(position: Vector2i, color: Figure.COLOR, type: Figure.TYPE):
	_get_figure(position).color = color
	_get_figure(position).type = type

func _to_map(position: Vector2i) -> Vector2i:
	return Vector2i(position.x, 7 - position.y)

# Called when the node enters the scene tree for the first time.
func _ready():
	var tile_size = tile_map.tile_set.tile_size
	var offset: Vector2 = tile_map.position + Vector2(tile_size / 2)	
	
	# Fill the board with the starting setup.
	for x in 8:
		figures.append([])
		for y in 8:
			var figure: Figure = figure_scene.instantiate()
			figure.position.x = x * tile_size.x + offset.x
			figure.position.y = tile_size.y * 7 - y * tile_size.y + offset.y
			figure.color = Figure.COLOR.none
			
			(figure as CollisionObject2D).input_event.connect(_on_Figure_Input.bind(Vector2i(x, y)))
			
			figures[x].append(figure)
			add_child(figures[x][y])
	
	_set_figure(Vector2i(0, 0), Figure.COLOR.white, Figure.TYPE.rook)
	_set_figure(Vector2i(1, 0), Figure.COLOR.white, Figure.TYPE.knight)
	_set_figure(Vector2i(2, 0), Figure.COLOR.white, Figure.TYPE.bishop)
	_set_figure(Vector2i(3, 0), Figure.COLOR.white, Figure.TYPE.queen)
	_set_figure(Vector2i(4, 0), Figure.COLOR.white, Figure.TYPE.king)
	_set_figure(Vector2i(5, 0), Figure.COLOR.white, Figure.TYPE.bishop)
	_set_figure(Vector2i(6, 0), Figure.COLOR.white, Figure.TYPE.knight)
	_set_figure(Vector2i(7, 0), Figure.COLOR.white, Figure.TYPE.rook)
	
	_set_figure(Vector2i(0, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(Vector2i(1, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(Vector2i(2, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(Vector2i(3, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(Vector2i(4, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(Vector2i(5, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(Vector2i(6, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(Vector2i(7, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	
	_set_figure(Vector2i(0, 7), Figure.COLOR.black, Figure.TYPE.rook)
	_set_figure(Vector2i(1, 7), Figure.COLOR.black, Figure.TYPE.knight)
	_set_figure(Vector2i(2, 7), Figure.COLOR.black, Figure.TYPE.bishop)
	_set_figure(Vector2i(3, 7), Figure.COLOR.black, Figure.TYPE.queen)
	_set_figure(Vector2i(4, 7), Figure.COLOR.black, Figure.TYPE.king)
	_set_figure(Vector2i(5, 7), Figure.COLOR.black, Figure.TYPE.bishop)
	_set_figure(Vector2i(6, 7), Figure.COLOR.black, Figure.TYPE.knight)
	_set_figure(Vector2i(7, 7), Figure.COLOR.black, Figure.TYPE.rook)
	
	_set_figure(Vector2i(0, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(Vector2i(1, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(Vector2i(2, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(Vector2i(3, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(Vector2i(4, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(Vector2i(5, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(Vector2i(6, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(Vector2i(7, 6), Figure.COLOR.black, Figure.TYPE.pawn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_Figure_Input(_viewport: Node, event: InputEvent, _shape_idx: int, position: Vector2i):
	if event is InputEventMouseButton:
		if event.pressed && selected_figure != position:
			if _get_figure(selected_figure) != null:
				_get_figure(selected_figure).selected = false
			selected_figure = position
			_get_figure(position).selected = true
			
			var possible_moves = _get_possible_moves()
			_highlight_all(possible_moves)

func _highlight_all(positions: Array):
	tile_map.clear_layer(1)
	
	for i in positions:
		tile_map.set_cell(1, _to_map(i), 1, Vector2i(0, 0))
				

func _get_possible_moves() -> Array:
	# I use simple KISS ifs for now. Should be easy to understand 
	# and there is no need for any complicated algorithm.
	
	var selected: Figure = _get_figure(selected_figure)
	var result: Array = []
	
	# The king can move in all directions, one step only.
	if selected.type == Figure.TYPE.king:
		_check(selected, Vector2i(selected_figure.x-1, selected_figure.y), result)
		_check(selected, Vector2i(selected_figure.x-1, selected_figure.y+1), result)
		_check(selected, Vector2i(selected_figure.x, selected_figure.y+1), result)
		_check(selected, Vector2i(selected_figure.x+1, selected_figure.y+1), result)
		_check(selected, Vector2i(selected_figure.x+1, selected_figure.y), result)
		_check(selected, Vector2i(selected_figure.x+1, selected_figure.y-1), result)
		_check(selected, Vector2i(selected_figure.x, selected_figure.y-1), result)
		_check(selected, Vector2i(selected_figure.x-1, selected_figure.y-1), result)
			
	return result

func _check(selected: Figure, to_check: Vector2i, result: Array):
	var to_check_figure: Figure = _get_figure(to_check)
	if to_check_figure != null && to_check_figure.color != selected.color:
		result.append(to_check)
