extends Node

@onready var point = $"Point"
@export var left_area: Area2D 
@export var right_area: Area2D 
var side = false
var walk_entrance = false
var offset = 0.3
var walk_out = false
var player: PlayerPlataform 

func _physics_process(delta):
	if walk_entrance:
		player.input_process = false

		if !side:

			player.velocity.x = lerpf(player.velocity.x, point.global_position.x, player.acceleration - offset)

			player.move_and_slide()

			if player.global_position.x >= point.global_position.x:
				player.velocity = Vector2.ZERO
				player.global_position = point.global_position
				player.skin.flip_h = false
				walk_out = true
				walk_entrance = false

		else:
			player.velocity.x = lerpf(player.velocity.x, point.global_position.x * -1, player.acceleration - offset)

			player.move_and_slide()

			if player.global_position.x <= point.global_position.x:
				player.velocity = Vector2.ZERO
				player.global_position = point.global_position
				player.skin.flip_h = true
				walk_out = true
				walk_entrance = false

	elif walk_out:

		if !side:

			player.velocity.x = lerpf(player.velocity.x, point.global_position.x + 60, player.acceleration - offset)

			player.move_and_slide()

			if player.global_position.x >= point.global_position.x + 50:
				player.velocity = Vector2.ZERO
				player.input_process = true
				walk_out = false

		else:
			player.velocity.x = lerpf(player.velocity.x, (point.global_position.x + 60) * -1, player.acceleration - offset)

			player.move_and_slide()

			if player.global_position.x <= point.global_position.x - 50:
				player.velocity = Vector2.ZERO
				player.input_process = true
				walk_out = false

func _on_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform and !walk_entrance and !walk_out:
		player = body
		walk_entrance = true

func _on_left_area_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform and !walk_entrance and !walk_out:
		side = false
		Global.camera_room_change.emit(left_area)

func _on_right_area_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform and !walk_entrance and !walk_out:
		side = true
		Global.camera_room_change.emit(right_area)
