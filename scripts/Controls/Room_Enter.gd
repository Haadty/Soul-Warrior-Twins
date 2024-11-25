extends Node

@onready var point = $"Point"
@export var left_area: Area2D 
@export var right_area: Area2D 
var side = false
var walk_entrance = false
var walk_out = false
var speed := 0.04
var player: PlayerPlataform 

func _physics_process(delta):
	if walk_entrance:
		# player.update_controls(true)

		if !side:

			player.velocity.x = lerpf(player.velocity.x, point.global_position.x * player.max_hspeed, speed * delta)

			player.move_and_slide()

			if player.global_position.x >= point.global_position.x:
				player.velocity = Vector2.ZERO
				player.global_position = point.global_position
				player.skin.flip_h = false
				print("end entrance")
				walk_out = true
				walk_entrance = false

		else:
			player.velocity.x = lerpf(player.velocity.x, (point.global_position.x * player.max_hspeed) * -1, speed * delta)

			player.move_and_slide()

			if player.global_position.x <= point.global_position.x:
				player.velocity = Vector2.ZERO
				player.global_position = point.global_position
				player.skin.flip_h = true
				print("end entrance")
				walk_out = true
				walk_entrance = false

	elif walk_out:

		if !side:

			player.velocity.x = lerpf(player.velocity.x, (point.global_position.x + 50) * player.max_hspeed, speed * delta)

			player.move_and_slide()

			if player.global_position.x >= point.global_position.x + 50:
				player.velocity = Vector2.ZERO
				print("end out")
				walk_out = false

		else:
			player.velocity.x = lerpf(player.velocity.x, ((point.global_position.x + 50) * player.max_hspeed) * -1, speed * delta)

			player.move_and_slide()

			if player.global_position.x <= point.global_position.x - 50:
				player.velocity = Vector2.ZERO
				print("end out")
				walk_out = false

func _on_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform and !walk_entrance and !walk_out:
		player = body
		walk_entrance = true
		print("enter")

func _on_left_area_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform and !walk_entrance and !walk_out:
		side = false
		Global.camera_room_change.emit(left_area)
		print("left")

func _on_right_area_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform and !walk_entrance and !walk_out:
		side = true
		Global.camera_room_change.emit(right_area)
		print("right")
