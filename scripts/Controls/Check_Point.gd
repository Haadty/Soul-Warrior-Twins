extends Area2D

#
# sistema de checkpoint
#

@onready var skin = $AnimatedSprite2D
var light = false

func _ready() -> void:
	skin.play("normal")

func _process(delta: float) -> void:
	if light:
		skin.play("ligado")

func _on_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform and !light:
		light = true
		Global.spawn_point = position
