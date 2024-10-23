extends Node


func _on_player_body_entered(body:Node2D) -> void:
	Events.room_enter.emit(self)
	Events.battleStart.emit()