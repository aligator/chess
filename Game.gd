extends Node2D

@onready var _chess_board = $ChessBoard
@onready var _dead_figures_white = $FigureListWhite
@onready var _dead_figures_black = $FigureListBlack

# Called when the node enters the scene tree for the first time.
func _ready():
	_chess_board.figure_killed.connect(_on_figure_killed)

func _on_figure_killed(color: Figure.COLOR, type: Figure.TYPE):
	match color:
		Figure.COLOR.white:
			_dead_figures_white.add(type)
		Figure.COLOR.black:
			_dead_figures_black.add(type)
