@tool
extends Node

@onready var figure: Figure = get_node("../")
@onready var selector: Sprite2D = get_node("../Selector")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	selector.visible = figure.selected

