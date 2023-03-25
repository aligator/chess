# This chess implementation uses a very naive approach using a two dimensional
# array. It should easily be fast enough to just check one figure.

extends Node2D

@export var figure_scene: PackedScene = preload("res://Objects/figure.tscn")
@export var debug_moves: bool = false
@export var rotate_board_after_move: bool = true
@export var is_board_rotated: bool = false

@onready var tile_map: TileMap = $TileMap


var active_player: Figure.COLOR = Figure.COLOR.white

var figures: Array = []

var selected_figure: Vector2i = Vector2i(-1, -1)

var king_in_danger = false

var checkmate = false
var stalemate = false

var _white_can_castle_kingside = true
var _white_can_castle_queenside = true
var _black_can_castle_kingside = true
var _black_can_castle_queenside = true

# The en passant is the position where a pawn can be captured in the next move.
var _en_passant: Vector2i = Vector2i(-1, -1)

func _get_figure(at: Vector2i) -> Figure: 
	return _get_figure_in(figures, at)

func _get_figure_in(board:Array, at: Vector2i) -> Figure: 
	if at.x < 0 || at.x >= 8 || at.y < 0 || at.y >= 8:
		return null
	
	return board[at.x][at.y]

# _setsFigure to the given state.
# This does not validate anything.
func _set_figure(at: Vector2i, color: Figure.COLOR, type: Figure.TYPE):
	_set_figure_in(figures, at, color, type)

# _setsFigure to the given state.
# This does not validate anything.
func _set_figure_in(board: Array, at: Vector2i, color: Figure.COLOR, type: Figure.TYPE):
	_get_figure_in(board, at).color = color
	_get_figure_in(board, at).type = type

func _to_map(at: Vector2i) -> Vector2i:
	return Vector2i(at.x, 7 - at.y)
func _to_global(at: Vector2i) -> Vector2:
	var tile_size = tile_map.tile_set.tile_size
	var offset: Vector2 = tile_map.position + Vector2(tile_size / 2)
	return (Vector2(_to_map(at)) * Vector2(tile_size)) + offset

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
			tile_map.add_child(figures[x][y])
	
	_reset_board()

func _reset_board():
	_highlight_clear()
		
	selected_figure = Vector2i(-1, -1)
	
	king_in_danger = false
	
	checkmate = false
	stalemate = false
	
	_white_can_castle_kingside = true
	_white_can_castle_queenside = true
	_black_can_castle_kingside = true
	_black_can_castle_queenside = true

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

func _rotate_board(): 
	is_board_rotated = !is_board_rotated

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var tile_size = tile_map.tile_set.tile_size

	# Update the figures based on the rotation.
	for x in range(8):
		for y in range(8):
			var figure = figures[x][y]
			if is_board_rotated:
				figure.rotation_degrees = 180
				tile_map.rotation_degrees = 180
				tile_map.position = tile_size * 7 + tile_size
			else:
				figure.rotation_degrees = 0
				tile_map.rotation_degrees = 0
				tile_map.position = Vector2i(0, 0)

func _find_current_king(board: Array):
	for x in range(8):
		for y in range(8):
			var figure = _get_figure_in(board, Vector2i(x, y))
			if figure != null && figure.color == active_player && figure.type == Figure.TYPE.king:
				return Vector2i(x, y)
	return null

func _check_king_in_danger(board: Array, king_pos: Vector2i) -> bool:
	for x in range(8):
		for y in range(8):
			var enemy_figure = _get_figure_in(board, Vector2i(x, y))
			# If it is really an enemey:
			if enemy_figure.color != active_player:
				var possible_moves = _get_possible_moves(board, Vector2i(x, y))
				for move in possible_moves:
					if move == king_pos:
						return true
						
	return false

func _clone_figures() -> Array:
	var figures_clone = []

	for x in 8:
		figures_clone.append([])
		for y in 8:
			var figure = _get_figure(Vector2i(x, y))
			var new_figure: Figure = figure_scene.instantiate()
			new_figure.position.x = figure.position.x
			new_figure.position.y = figure.position.y
			new_figure.color =  figure.color
			new_figure.type =  figure.type
			figures_clone[x].append(new_figure)

	return figures_clone

func _free_board(board: Array):
	for x in range(8):
		for y in range(8):
			board[x][y].free()
		board[x].clear()
	board.clear()
	
func _filter_illegal_moves(possible_moves: Array, source: Vector2i):
	# Filter all moves that would put the king in danger.
	for move in possible_moves.duplicate(): # (duplicate is needed because otherwise the array is modified while iterating over it)
		var board_copy = _clone_figures()
		var source_figure = _get_figure_in(board_copy, source)
		if source_figure != null:
			_set_figure_in(board_copy, move, source_figure.color,source_figure.type)
			_set_figure_in(board_copy, source, Figure.COLOR.none, Figure.TYPE.pawn)
			var king = _find_current_king(board_copy)
			if king == null:
				possible_moves.erase(move)
			else:
				if _check_king_in_danger(board_copy, king):
					possible_moves.erase(move)
		_free_board(board_copy)

func _check_checkmate_stalemate():
	var is_checkmate = true
	var is_stalemate = true
	
	for x in range(8):
		for y in range(8):
			var figure = _get_figure(Vector2i(x, y))
			if figure.color == active_player:
				var possible_moves = _get_possible_moves(figures, Vector2i(x, y))
				
				# For every own figure, check if there is any possible move.
				# If there is no such move, then it is stalemate.
				if possible_moves.size() > 0:
					is_stalemate = false
					
				# For every own figure, check if there is any possible move which would not put the king in danger.
				# If there is no such move, then it is checkmate.
				_filter_illegal_moves(possible_moves, Vector2i(x, y))
				if possible_moves.size() > 0:
					is_checkmate = false

	checkmate = is_checkmate
	stalemate = is_stalemate

func _can_do_castle(board: Array, source: Vector2i, target: Vector2i) -> bool:
	var source_figure = _get_figure_in(board, source)
	var target_figure = _get_figure_in(board, target)
	
	if source_figure == null || target_figure == null:
		return false
	
	if source_figure.color != active_player || target_figure.color != active_player:
		return false
	
	if source_figure.type != Figure.TYPE.king || target_figure.type != Figure.TYPE.rook:
		return false
	
	var direction = target.x - source.x
	if direction > 0:
		direction = 1
	else:
		direction = -1

	if active_player == Figure.COLOR.white:
		if direction == 1 && !(_white_can_castle_kingside):
			return false
		if direction == -1 && !(_white_can_castle_queenside):
			return false
	else:
		if direction == 1 && !(_black_can_castle_kingside):
			return false
		if direction == -1 && !(_black_can_castle_queenside):
			return false
	
	# Check if the space between the rook and king is empty.
	var x = source.x + direction
	while x != target.x:
		if x == 0 || x == 7:
			break
		var figure = _get_figure_in(board, Vector2i(x, source.y))
		if figure.color != Figure.COLOR.none:
			return false
		x += direction
	
	return true

func _on_Figure_Input(_viewport: Node, event: InputEvent, _shape_idx: int, at: Vector2i):
	if event is InputEventMouseButton:
		if event.pressed && selected_figure != at:
			var event_figure = _get_figure(at)

			if event_figure == null:
				return
			
			if event_figure.color == Figure.COLOR.none || event_figure.color != active_player:
				# A NONE figure or an enemy is selected.
				# If it is a valid move -> e.g. the field is highlited, then just make the move.
				var tile: TileData = tile_map.get_cell_tile_data(1, _to_map(at))
				# If the tile exists in that layer, it is highlighted.
				if tile != null:
					var selected = _get_figure(selected_figure)

					# Set castling to false if the king or a rook is moved.
					if selected.type == Figure.TYPE.king:
						# Also do the castling if the king is moved	two fields.
						if at.x == 6 && (selected.color == Figure.COLOR.white && _white_can_castle_kingside || selected.color == Figure.COLOR.black && _black_can_castle_kingside):
							_set_figure(Vector2i(7, at.y), Figure.COLOR.none, Figure.TYPE.pawn)
							_set_figure(Vector2i(5, at.y), selected.color, Figure.TYPE.rook)
						elif at.x == 2 && (selected.color == Figure.COLOR.white && _white_can_castle_queenside || selected.color == Figure.COLOR.black && _black_can_castle_queenside):
							_set_figure(Vector2i(0, at.y), Figure.COLOR.none, Figure.TYPE.pawn)
							_set_figure(Vector2i(3, at.y), selected.color, Figure.TYPE.rook)
							
						if active_player == Figure.COLOR.white:
							_white_can_castle_kingside = false
							_white_can_castle_queenside = false	
						if active_player == Figure.COLOR.black:
							_black_can_castle_kingside = false
							_black_can_castle_queenside = false
						
					if selected.type == Figure.TYPE.rook:
						if active_player == Figure.COLOR.white:
							if selected_figure.x == 0:
								_white_can_castle_queenside = false
							if selected_figure.x == 7:
								_white_can_castle_kingside = false
						if active_player == Figure.COLOR.black:
							if selected_figure.x == 0:
								_black_can_castle_queenside = false
							if selected_figure.x == 7:
								_black_can_castle_kingside = false

					_en_passant = Vector2i(-1, -1)
					if selected.type == Figure.TYPE.pawn:
						# Set en passant if a pawn is moved two fields.
						# Or reset the en passant if it was only moved one field.
						if at.y == selected_figure.y + 2:
							_en_passant = Vector2i(selected_figure.x, selected_figure.y+1)
						if at.y == selected_figure.y - 2:
							_en_passant = Vector2i(selected_figure.x, selected_figure.y-1)

						# If a pawn is moved to the last row, then it is promoted.
						if at.y == 0 || at.y == 7:
							# TODO: Implement a way to select the figure type.
							selected.type = Figure.TYPE.queen
							
					_set_figure(at, selected.color, selected.type)
					_set_figure(selected_figure, Figure.COLOR.none, Figure.TYPE.pawn)

					selected.selected = false
					_highlight_clear()
					selected_figure = Vector2i(-1, -1)
					_toggle_active_player()
					
					# Check if the current players king is in danger.
					var king = _find_current_king(figures)
					king_in_danger = false
					if king == null:
						print("no king exists")
					else:
						king_in_danger = _check_king_in_danger(figures, king)
					
					if king_in_danger:
						_check_checkmate_stalemate()
				return
			else:
				# An own figure is selected.
				# Switch the selected figure.
				if _get_figure(selected_figure) != null:
					_get_figure(selected_figure).selected = false
				selected_figure = at
				_get_figure(at).selected = true
				
				var possible_moves = _get_possible_moves(figures, selected_figure)
				if !debug_moves:
					_filter_illegal_moves(possible_moves, selected_figure)
				_highlight_all(possible_moves)

func _toggle_active_player():
	if active_player == Figure.COLOR.white:
		active_player = Figure.COLOR.black
	else:
		active_player = Figure.COLOR.white

	if rotate_board_after_move:
		_rotate_board()	

func _highlight_clear():
	tile_map.clear_layer(1)

func _highlight_all(positions: Array):
	_highlight_clear()
	
	for i in positions:
		tile_map.set_cell(1, _to_map(i), 1, Vector2i(0, 0))
				

func _get_possible_moves(board: Array, at: Vector2i) -> Array:
	# I use simple KISS ifs for now. Should be easy to understand 
	# and there is no need for any complicated algorithm.
	
	var figure: Figure = _get_figure_in(board, at)
	var result: Array = []
	
	# The king can move in all directions, one step only.
	if figure.type == Figure.TYPE.king:
		_check(board, figure, Vector2i(at.x-1, at.y), result)
		_check(board, figure, Vector2i(at.x-1, at.y+1), result)
		_check(board, figure, Vector2i(at.x, at.y+1), result)
		_check(board, figure, Vector2i(at.x+1, at.y+1), result)
		_check(board, figure, Vector2i(at.x+1, at.y), result)
		_check(board, figure, Vector2i(at.x+1, at.y-1), result)
		_check(board, figure, Vector2i(at.x, at.y-1), result)
		_check(board, figure, Vector2i(at.x-1, at.y-1), result)

		if _can_do_castle(board, at, Vector2i(0, at.y)):
				result.append(Vector2i(2, at.y))
		if _can_do_castle(board, at, Vector2i(7, at.y)):
				result.append(Vector2i(6, at.y))
	
	#Moves of pawns.
	if figure.type == Figure.TYPE.pawn:
		if figure.color == Figure.COLOR.white:
			_check_only_attack_or_en_passant(board, figure, Vector2i(at.x-1, at.y+1), result)
			_check_only_attack_or_en_passant(board, figure, Vector2i(at.x+1, at.y+1), result)
			var blocked = _check_no_attack(board, Vector2i(at.x, at.y+1), result)
			if at.y == 1 && !blocked:
				_check_no_attack(board, Vector2i(at.x, at.y+2), result)
		if figure.color == Figure.COLOR.black:
			_check_only_attack_or_en_passant(board, figure, Vector2i(at.x-1, at.y-1), result)
			_check_only_attack_or_en_passant(board, figure, Vector2i(at.x+1, at.y-1), result)
			var blocked =_check_no_attack(board, Vector2i(at.x, at.y-1), result)
			if at.y == 6 && !blocked:
				_check_no_attack(board, Vector2i(at.x, at.y-2), result)
		
	# Check all posible moves of the knight.
	if figure.type == Figure.TYPE.knight:
		_check(board, figure, Vector2i(at.x-2, at.y-1), result)
		_check(board, figure, Vector2i(at.x-2, at.y+1), result)
		_check(board, figure, Vector2i(at.x-1, at.y-2), result)
		_check(board, figure, Vector2i(at.x-1, at.y+2), result)
		_check(board, figure, Vector2i(at.x+1, at.y-2), result)
		_check(board, figure, Vector2i(at.x+1, at.y+2), result)
		_check(board, figure, Vector2i(at.x+2, at.y-1), result)
		_check(board, figure, Vector2i(at.x+2, at.y+1), result)
	
	# Check all posible moves of the bishop.
	if figure.type == Figure.TYPE.bishop:
		_check_all_diagonal(board, figure, at, result)

	# Check all posible moves of the rook.
	if figure.type == Figure.TYPE.rook:
		_check_all_straight(board, figure, at, result)

	# Check all posible moves of the queen.
	if figure.type == Figure.TYPE.queen:
		_check_all_diagonal(board, figure, at, result)
		_check_all_straight(board, figure, at, result)

	return result

func _check(board: Array, figure: Figure, to_check: Vector2i, result: Array) -> bool:
	var to_check_figure: Figure = _get_figure_in(board, to_check)
	if to_check_figure != null && to_check_figure.color != figure.color:
		result.append(to_check)

	return to_check_figure == null || to_check_figure.color != Figure.COLOR.none

# Same as _check but attack is not allowed.
func _check_no_attack(board: Array, to_check: Vector2i, result: Array) -> bool:
	var to_check_figure: Figure = _get_figure_in(board, to_check)
	if to_check_figure != null && to_check_figure.color == Figure.COLOR.none:
		result.append(to_check)
		return false
	return true

# Same as _check but only attack is allowed.
# However, en passant is also allowed.
func _check_only_attack_or_en_passant(board: Array, figure: Figure, to_check: Vector2i, result: Array):
	var to_check_figure: Figure = _get_figure_in(board, to_check)
	if to_check_figure != null && to_check_figure.color != Figure.COLOR.none && to_check_figure.color != figure.color:
		result.append(to_check)
	if to_check_figure != null && to_check_figure.color == Figure.COLOR.none && to_check == _en_passant:
		result.append(to_check)

# Checks all diagonal moves.
func _check_all_diagonal(board: Array, figure: Figure, at: Vector2i, result: Array):
	# To top left.
	for i in range(1, 8):
		if _check(board, figure, Vector2i(at.x-i, at.y+i), result):
			break

	# To top right.
	for i in range(1, 8):
		if _check(board, figure, Vector2i(at.x+i, at.y+i), result):
			break

	# To bottom left.
	for i in range(1, 8):
		if _check(board, figure, Vector2i(at.x-i, at.y-i), result):
			break

	# To bottom right.
	for i in range(1, 8):
		if _check(board, figure, Vector2i(at.x+i, at.y-i), result):
			break

func _check_all_straight(board: Array, figure: Figure, at: Vector2i, result: Array):
	# To top.
	for i in range(1, 8):
		if _check(board, figure, Vector2i(at.x, at.y+i), result):
			break

	# To bottom.
	for i in range(1, 8):
		if _check(board, figure, Vector2i(at.x, at.y-i), result):
			break

	# To left.
	for i in range(1, 8):
		if _check(board, figure, Vector2i(at.x-i, at.y), result):
			break

	# To right.
	for i in range(1, 8):
		if _check(board, figure, Vector2i(at.x+i, at.y), result):
			break
