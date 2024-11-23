extends Node

@onready var point = $"Point"

func room_enter(player: PlayerPlataform): 
	player.update_controls()
	player.global_position = point.global_position

func _on_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform:
		room_enter(body)

