extends Area2D

func _on_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform:
		body.back = true
		Events.damage.emit(3, 80)
