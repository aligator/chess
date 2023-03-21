# This chess implementation uses a very naive approach using a two dimensional
# array. It should easily be fast enough to just check one figure.

extends Node2D

@export var figure_scene: PackedScene = preload("res://Objects/figure.tscn")
@export var rotate_board: bool = false

@onready var tile_map: TileMap = $TileMap

var active_player: Figure.COLOR = Figure.COLOR.white

var figures: Array = []

var selected_figure: Vector2i = Vector2i(-1, -1)

func _get_figure(at: Vector2i) -> Figure: 
	if at.x < 0 || at.x >= 8 || at.y < 0 || at.y >= 8:
		return null
	
	return figures[at.x][at.y]

# _setsFigure to the given state.
# This does not validate anything.
func _set_figure(at: Vector2i, color: Figure.COLOR, type: Figure.TYPE):
	_get_figure(at).color = color
	_get_figure(at).type = type

func _to_map(at: Vector2i) -> Vector2i:
	return Vector2i(at.x, 7 - at.y)

func vector2i_rotate180(do_rotate: bool, x: int, y: int) -> Vector2i:
	if do_rotate:
		return Vector2i(7 - x, 7 - y)
	else:
		return Vector2i(x, y)

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
	
	_set_figure(vector2i_rotate180(rotate_board, 0, 0), Figure.COLOR.white, Figure.TYPE.rook)
	_set_figure(vector2i_rotate180(rotate_board, 1, 0), Figure.COLOR.white, Figure.TYPE.knight)
	_set_figure(vector2i_rotate180(rotate_board, 2, 0), Figure.COLOR.white, Figure.TYPE.bishop)
	_set_figure(vector2i_rotate180(rotate_board, 3, 0), Figure.COLOR.white, Figure.TYPE.queen)
	_set_figure(vector2i_rotate180(rotate_board, 4, 0), Figure.COLOR.white, Figure.TYPE.king)
	_set_figure(vector2i_rotate180(rotate_board, 5, 0), Figure.COLOR.white, Figure.TYPE.bishop)
	_set_figure(vector2i_rotate180(rotate_board, 6, 0), Figure.COLOR.white, Figure.TYPE.knight)
	_set_figure(vector2i_rotate180(rotate_board, 7, 0), Figure.COLOR.white, Figure.TYPE.rook)
	
	_set_figure(vector2i_rotate180(rotate_board, 0, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 1, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 2, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 3, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 4, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 5, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 6, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 7, 1), Figure.COLOR.white, Figure.TYPE.pawn)
	
	_set_figure(vector2i_rotate180(rotate_board, 0, 7), Figure.COLOR.black, Figure.TYPE.rook)
	_set_figure(vector2i_rotate180(rotate_board, 1, 7), Figure.COLOR.black, Figure.TYPE.knight)
	_set_figure(vector2i_rotate180(rotate_board, 2, 7), Figure.COLOR.black, Figure.TYPE.bishop)
	_set_figure(vector2i_rotate180(rotate_board, 3, 7), Figure.COLOR.black, Figure.TYPE.queen)
	_set_figure(vector2i_rotate180(rotate_board, 4, 7), Figure.COLOR.black, Figure.TYPE.king)
	_set_figure(vector2i_rotate180(rotate_board, 5, 7), Figure.COLOR.black, Figure.TYPE.bishop)
	_set_figure(vector2i_rotate180(rotate_board, 6, 7), Figure.COLOR.black, Figure.TYPE.knight)
	_set_figure(vector2i_rotate180(rotate_board, 7, 7), Figure.COLOR.black, Figure.TYPE.rook)
	
	_set_figure(vector2i_rotate180(rotate_board, 0, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 1, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 2, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 3, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 4, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 5, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 6, 6), Figure.COLOR.black, Figure.TYPE.pawn)
	_set_figure(vector2i_rotate180(rotate_board, 7, 6), Figure.COLOR.black, Figure.TYPE.pawn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_Figure_Input(_viewport: Node, event: InputEvent, _shape_idx: int, at: Vector2i):
	if event is InputEventMouseButton:
		if event.pressed && selected_figure != at:
			var event_figure = _get_figure(at)

			if event_figure == null:
				return
			
			if event_figure.color == Figure.COLOR.none || event_figure.color != active_player:
				# A NONE fiugre is selected.
				# If it is a valid move -> e.g. the field is highlited, then just make the move.
				var tile: TileData = tile_map.get_cell_tile_data(1, _to_map(at))
				# If the tile exists in that layer, it is highlighted.
				if tile != null:
					var selected = _get_figure(selected_figure)
					_set_figure(at, selected.color, selected.type)
					_set_figure(selected_figure, Figure.COLOR.none, Figure.TYPE.pawn)
					selected.selected = false
					_highlight_clear()
					selected_figure = Vector2i(-1, -1)
					_toggle_active_player()
				return
			else:
				# A normal figure is selected.
				if _get_figure(selected_figure) != null:
					_get_figure(selected_figure).selected = false
				selected_figure = at
				_get_figure(at).selected = true
				
				var possible_moves = _get_possible_moves()
				_highlight_all(possible_moves)

func _toggle_active_player():
	if active_player == Figure.COLOR.white:
		active_player = Figure.COLOR.black
	else:
		active_player = Figure.COLOR.white

func _highlight_clear():
	tile_map.clear_layer(1)

func _highlight_all(positions: Array):
	_highlight_clear()
	
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
	
	#Moves of pawns.
	if selected.type == Figure.TYPE.pawn:
		if selected.color == Figure.COLOR.white && !rotate_board || selected.color == Figure.COLOR.black && rotate_board:
			_check_only_attack(selected, Vector2i(selected_figure.x-1, selected_figure.y+1), result)
			_check_only_attack(selected, Vector2i(selected_figure.x+1, selected_figure.y+1), result)
			var blocked = _check_no_attack(Vector2i(selected_figure.x, selected_figure.y+1), result)
			if selected_figure.y == 1 && !blocked:
				_check_no_attack(Vector2i(selected_figure.x, selected_figure.y+2), result)
		if selected.color == Figure.COLOR.black && !rotate_board || selected.color == Figure.COLOR.white && rotate_board:
			_check_only_attack(selected, Vector2i(selected_figure.x-1, selected_figure.y-1), result)
			_check_only_attack(selected, Vector2i(selected_figure.x+1, selected_figure.y-1), result)
			var blocked =_check_no_attack(Vector2i(selected_figure.x, selected_figure.y-1), result)
			if selected_figure.y == 6 && !blocked:
				_check_no_attack(Vector2i(selected_figure.x, selected_figure.y-2), result)
		
	# Check all posible moves of the knight.
	if selected.type == Figure.TYPE.knight:
		_check(selected, Vector2i(selected_figure.x-2, selected_figure.y-1), result)
		_check(selected, Vector2i(selected_figure.x-2, selected_figure.y+1), result)
		_check(selected, Vector2i(selected_figure.x-1, selected_figure.y-2), result)
		_check(selected, Vector2i(selected_figure.x-1, selected_figure.y+2), result)
		_check(selected, Vector2i(selected_figure.x+1, selected_figure.y-2), result)
		_check(selected, Vector2i(selected_figure.x+1, selected_figure.y+2), result)
		_check(selected, Vector2i(selected_figure.x+2, selected_figure.y-1), result)
		_check(selected, Vector2i(selected_figure.x+2, selected_figure.y+1), result)
	
	# Check all posible moves of the bishop.
	if selected.type == Figure.TYPE.bishop:
		_check_all_diagonal(selected, result)

	# Check all posible moves of the rook.
	if selected.type == Figure.TYPE.rook:
		_check_all_straight(selected, result)

	# Check all posible moves of the queen.
	if selected.type == Figure.TYPE.queen:
		_check_all_diagonal(selected, result)
		_check_all_straight(selected, result)

	return result

func _check(selected: Figure, to_check: Vector2i, result: Array) -> bool:
	var to_check_figure: Figure = _get_figure(to_check)
	if to_check_figure != null && to_check_figure.color != selected.color:
		result.append(to_check)

	return to_check_figure == null || to_check_figure.color != Figure.COLOR.none

# Same as _check but attack is not allowed.
func _check_no_attack(to_check: Vector2i, result: Array) -> bool:
	var to_check_figure: Figure = _get_figure(to_check)
	if to_check_figure != null && to_check_figure.color == Figure.COLOR.none:
		result.append(to_check)
		return false
	return true

# Same as _check but only attack is allowed.
func _check_only_attack(selected: Figure, to_check: Vector2i, result: Array):
	var to_check_figure: Figure = _get_figure(to_check)
	if to_check_figure != null && to_check_figure.color != Figure.COLOR.none && to_check_figure.color != selected.color:
		result.append(to_check)

# Checks all diagonal moves.
func _check_all_diagonal(selected: Figure, result: Array):
	# To top left.
	for i in range(1, 7):
		if _check(selected, Vector2i(selected_figure.x-i, selected_figure.y+i), result):
			break

	# To top right.
	for i in range(1, 7):
		if _check(selected, Vector2i(selected_figure.x+i, selected_figure.y+i), result):
			break

	# To bottom left.
	for i in range(1, 7):
		if _check(selected, Vector2i(selected_figure.x-i, selected_figure.y-i), result):
			break

	# To bottom right.
	for i in range(1, 7):
		if _check(selected, Vector2i(selected_figure.x+i, selected_figure.y-i), result):
			break

func _check_all_straight(selected: Figure, result: Array):
	# To top.
	for i in range(1, 7):
		if _check(selected, Vector2i(selected_figure.x, selected_figure.y+i), result):
			break

	# To bottom.
	for i in range(1, 7):
		if _check(selected, Vector2i(selected_figure.x, selected_figure.y-i), result):
			break

	# To left.
	for i in range(1, 7):
		if _check(selected, Vector2i(selected_figure.x-i, selected_figure.y), result):
			break

	# To right.
	for i in range(1, 7):
		if _check(selected, Vector2i(selected_figure.x+i, selected_figure.y), result):
			break
