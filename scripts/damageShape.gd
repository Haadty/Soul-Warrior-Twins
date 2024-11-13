extends Area2D

#
# area de dano a cair em buracos
# aqui fica eventos que quando cair recebe dano
#

func _on_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform:
		body.back = true
		Events.damage.emit(3, 80)
