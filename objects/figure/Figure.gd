@tool
@icon("res://art/WhiteKing.png")

class_name Figure
extends Area2D

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

const _scene = preload("Figure.tscn")

static func instantiate() -> Figure:
	var figure = _scene.instantiate()
	return figure

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	animation_sprite.visible = true
	
	if color == COLOR.white:
		animation_sprite.animation = "white"
	elif color == COLOR.black:
		animation_sprite.animation = "black"
	else:
		animation_sprite.visible = false
		
	animation_sprite.set_frame_and_progress(type, 1)
	
	selector.visible = selected
	
func get_size() -> Vector2:
	var frame = animation_sprite.sprite_frames.get_frame_texture("black", 0)
	return frame.get_size() * transform.get_scale()
