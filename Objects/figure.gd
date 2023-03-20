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

@onready var animationSprite = $AnimatedSprite2D

var isBeingClicked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	visible = true
	
	if color == COLOR.white:
		animationSprite.animation = "white"
	elif color == COLOR.black:
		animationSprite.animation = "black"
	else:
		visible = false
		
	animationSprite.set_frame_and_progress(type, 1)
