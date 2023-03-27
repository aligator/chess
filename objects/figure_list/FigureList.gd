@tool
extends Node2D

@export var color: Figure.COLOR = Figure.COLOR.white
@export var gap: int = 4

func _ready():
	if Engine.is_editor_hint():
		add(Figure.TYPE.pawn)	
		add(Figure.TYPE.rook)
		add(Figure.TYPE.rook)
		add(Figure.TYPE.bishop)
		add(Figure.TYPE.bishop)
		add(Figure.TYPE.knight)
		add(Figure.TYPE.pawn)
		add(Figure.TYPE.knight)
		add(Figure.TYPE.queen)	
		add(Figure.TYPE.rook)
		add(Figure.TYPE.pawn)
		add(Figure.TYPE.pawn)
		add(Figure.TYPE.pawn)
		add(Figure.TYPE.pawn)
		add(Figure.TYPE.pawn)
		add(Figure.TYPE.king)
		

func add(type: Figure.TYPE):
	var new_figure = Figure.instantiate()
	add_child(new_figure)
	new_figure.position.x = (get_child_count(false)-1) * (new_figure.get_size().x + gap)
	new_figure.color = color
	new_figure.type = type
