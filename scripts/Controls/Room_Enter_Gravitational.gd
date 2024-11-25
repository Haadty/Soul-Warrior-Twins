extends Node

@onready var point = $"Point"
@export var down_area: Area2D 
@export var up_area: Area2D 
@export var jump_left: bool = true
@export var jump_right: bool = false
var side = false
var direction = false
var walk_entrance = false
var offset = 0.1
var walk_out = false
var player: PlayerPlataform 

func _physics_process(delta):
	if walk_entrance:
		player.input_process = false
		player.gravity_process_control = false

		if !side:

			player.velocity.y = lerpf(player.velocity.y, point.global_position.y, 0.5)

			player.move_and_slide()

			if player.global_position.y >= point.global_position.y:
				player.velocity = Vector2.ZERO
				player.global_position = point.global_position
				walk_out = true
				walk_entrance = false

		else:
			player.velocity.y = lerpf(player.velocity.y, point.global_position.y * -1, 0.5)

			player.move_and_slide()

			if player.global_position.y <= point.global_position.y:
				player.velocity = Vector2.ZERO
				player.global_position = point.global_position
				walk_out = true
				walk_entrance = false

	elif walk_out:

		if !side:

			player.velocity.y = lerpf(player.velocity.y, point.global_position.y + 100,  0.5)

			player.move_and_slide()

			if player.global_position.y >= point.global_position.y + 50:
				player.input_process = true
				player.gravity_process_control = true
				walk_out = false

		else:

			player.room_up_out = true
			player.gravity_process_control = true

			if player.global_position.y > point.global_position.y - 50:
				player.velocity.y = lerpf(player.velocity.y, (point.global_position.y + 60) * -1, 0.1)
				player.move_and_slide()

			if jump_left and jump_right:
				if direction:
					player.skin.flip_h = false
					player.input_direction.x = 1
				else:
					player.skin.flip_h = true
					player.input_direction.x = -1

			elif jump_right:
				player.skin.flip_h = true
				player.input_direction.x = -1

			else:
				player.skin.flip_h = false
				player.input_direction.x = 1

			player.velocity.x = lerpf(player.velocity.x, player.input_direction.x * player.max_hspeed, player.acceleration - offset)
			player.move_and_slide()
			
			if player.on_floor():
				player.velocity = Vector2.ZERO
				player.input_direction = Vector2.ZERO
				player.input_process = true
				print("final final")
				walk_out = false
				
func _on_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform and !walk_entrance and !walk_out:
		player = body
		walk_entrance = true

func _on_down_area_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform and !walk_entrance and !walk_out:
		side = false
		Global.camera_room_change.emit(down_area)

func _on_up_area_body_entered(body:Node2D) -> void:
	if body is PlayerPlataform and !walk_entrance and !walk_out:
		side = true

		if jump_left and jump_right:
			direction = bool(randi() % 2)
			print(direction)
			
		Global.camera_room_change.emit(up_area)