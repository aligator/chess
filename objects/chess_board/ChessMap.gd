extends TileMap
class_name ChessMap

@export var active_player: Figure.COLOR = Figure.COLOR.white
@export var selected_figure: Vector2i = Vector2i(-1, -1)
@export var white_can_castle_kingside = true
@export var white_can_castle_queenside = true
@export var black_can_castle_kingside = true
@export var black_can_castle_queenside = true
# The en passant is the position where a pawn can be captured in the next move.
@export var en_passant: Vector2i = Vector2i(-1, -1)

var board: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var figures = get_children(false)
		
	for x in 8:
		board.append([])
		for y in 8:		
			board[x].append(figures[x*8+y])
			add_child(board[x][y])
	
	reset_board()

func highlight_clear():
	clear_layer(1)

func reset_board():
	highlight_clear()
	selected_figure = Vector2i(-1, -1)
	white_can_castle_kingside = true
	white_can_castle_queenside = true
	black_can_castle_kingside = true
	black_can_castle_queenside = true
	
func get_figure(at: Vector2i) -> Figure: 
	if at.x < 0 || at.x >= 8 || at.y < 0 || at.y >= 8:
		return null
	
	return board[at.x][at.y]

func set_figure(at: Vector2i, color: Figure.COLOR, type: Figure.TYPE):
	get_figure(at).color = color
	get_figure(at).type = type

static func to_map(at: Vector2i) -> Vector2i:
	return Vector2i(at.x, 7 - at.y)

func toggle_active_player():
	if active_player == Figure.COLOR.white:
		active_player = Figure.COLOR.black
	else:
		active_player = Figure.COLOR.white
