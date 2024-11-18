extends Area2D

#
# sistema para verificar se o player entrou em uma sala
#

func _on_area_entered(area:Area2D) -> void:
	if area.is_in_group("room"):
		if Global.player_actual_area != area:
			Global.player_actual_area = area
			
		Global.camera_room_change.emit(area)




