@icon("res://Art/WhiteKing.png")

extends Area2D
class_name Figure

enum COLOR {
	none,
	white,
	black
}

enum TYPE {
	queen,
	king,
	rook,
	knight,
	bishop,
	pawn,
}

@export var color: COLOR = COLOR.white
@export var type: TYPE = TYPE.pawn
@export var selected: bool = false

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var selector: Sprite2D = $Selector

# Called when the node enters the scene tree for the first time.
func _ready():
	selector.visible = selected
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	visible = true
	
	if color == COLOR.white:
		animation_sprite.animation = "white"
	elif color == COLOR.black:
		animation_sprite.animation = "black"
	else:
		visible = false
		
	animation_sprite.set_frame_and_progress(type, 1)
	
	selector.visible = selected
