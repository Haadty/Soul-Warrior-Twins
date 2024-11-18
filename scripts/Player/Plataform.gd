extends CharacterBody2D
class_name PlayerPlataform

#
# variaveis para o dash 
#

var dash_corner_correction := Vector2(12, 12)
var dash_can_only_used_when_on_solid := false
var dash_direction := Vector2.ZERO
var dash_duration := 0.2
@export var dash_has_ability : bool = true
var dash_after_dash_has_reset_speed := true
var dash_pause_time := 0.02
var dash_refresh_time := 0.18
var dash_refresh_timer := dash_refresh_time
var dash_refresh_timer_update := true
var dash_refresh_timer_update_on_wall_latch := true
var dash_reset_speed_value := Vector2(400, 400)
var dash_speed := 500
var dash_timer := 0.0

#
# variaveis para o coyote e buffer time
#

var facing_direction := 1.0
var jump_buffer_time := 0.08
var jump_buffer_timer := 0.0
var process_self := true
var coyote_time := 0.08
var coyote_timer := coyote_time

#
# variaveis para aceleração
#

var max_hspeed := 250
var current_max_hspeed = 0
var acceleration := 0.5
var hspeed_reset_threshold := 1.0
var friction := 0.7

#
# variaveis para pulo e gravidade
#

var max_vspeed := 1000
var jump_speed := -500
var gravity := 1000
var peak_gravity := 800
var peak_gravity_threshold = 200
var jump_cut := 0.2
var can_cut_speed := true
var jumping := false
var want_to_cut_speed := false

#
# variaveis para walljump e wallslide
#

@export var has_wall_jump : bool = true
var has_wall_latch := has_wall_jump
var wall_slide_latched := 0
var wall_slide_gravity := 1000
var wall_slide_max_vspeed := 150
var wall_slide_latch_on_pause := 0.1
var wall_slide_latch_on_timer := 0.0
var wall_jump_vertical_speed := -600
var wall_jump_horizontal_speed := 400
var wall_jump_lose_control_time := 0.2
var wall_jump_lose_control_timer := 0.0
var wall_jump_edge_horizontal_speed := 500
var wall_jump_edge_lose_control_time := 0.10
@onready var wall_jump_raycast1 = $"RaycastOne"
@onready var wall_jump_raycast2 = $"RaycastTwo"
@onready var wall_jump_raycast_cast_to = Vector2(19, 0)

#
# variaveis para o pulo no ar (walljump impulsionando)
#

@export var air_jump_has_ability : bool = false
var air_jump_refresh_on_wall_latch := true
var air_jump_speed := -800
var air_jump_used_ability := false
var corner_correction := Vector2(8, 4)

#
# sprites e animações
#

@onready var skin = $AnimatedSprite2D

#
# checkpoint
#

var back := false

#
# verificadores de lado e sinais
#

enum Touching_Side {
	BOTH,
	HORIZONTAL,
	VERTICAL,
	NONE
}

var input_direction := Vector2.ZERO
var last_solid := Vector2(0, 0)

#
# posição inicial a iniciar o jogo
#

var start_position := Vector2.ZERO

#
# quando iniciar o script
# qualquer variavel ou metodo inicial que for rodad deve ser aqui
#

func _ready():
	start_position = global_position

#
# processo de fisica
# qualquer metodo que seja relacionado a movimentação ou que precisa ser ativado o tempo todo, vem aqui
#

func _physics_process(delta):
	if process_self:
		update_timers(delta)
		
		if velocity.y >= 0:
			jumping = false
		
		if not jumping:
			want_to_cut_speed = false
		
		if can_move() and (on_floor() or
		(wall_slide_latched != 0 and dash_refresh_timer_update_on_wall_latch)):
			dash_refresh_timer_update = true
		if can_move() and (on_floor() or
		(wall_slide_latched != 0 and air_jump_refresh_on_wall_latch)):
			air_jump_used_ability = false
		
		if on_floor():
			coyote_timer = coyote_time
			last_solid = Vector2.DOWN
			
		if wall_slide_latched != 0 and not on_floor():
			coyote_timer = coyote_time
			last_solid = Vector2(wall_slide_latched, 0)

		if wall_slide_latched == 0 and not on_floor() and not place_free(Vector2.UP):
			last_solid = Vector2.UP
		
		update_input_direction()
		
		update_facing_direction()
		dash(delta)
		jump(delta) 
		
		update_velocity(delta) 
		wall_latching() 
		perform_movement(delta) 	

		if back:
			update_back()

		if skin.animation != "back":
			update_animation()
		elif skin.animation == "back" and skin.frame >= 3:
			update_animation()
		elif skin.animation == "back" and (input_direction.x != 0 or velocity.x != 0):
			update_animation()
			

#
# verificadores
# aqui fica verificadores como de dash, se pode se mover, se esta em uma parede e etc
#

func against_wall():
	if test_move(transform, Vector2(-1, 0)):
		return -1
	if test_move(transform, Vector2(1, 0)):
		return 1
	return 0
	
func can_dash():
	if not dash_can_only_used_when_on_solid:
		return dash_refresh_timer <= 0
	if dash_can_only_used_when_on_solid:
		if coyote_timer > 0:
			return (dash_refresh_timer <= 0 )
		else:
			return false
	
func can_move():
	return not (wall_jump_lose_control_timer > 0 or is_dashing())
	
func check_corner_correction(movement_vector: Vector2):
	assert (movement_vector.length() == 1 and movement_vector.x*movement_vector.y == 0, "ERROR: Must be a UP, DOWN, LEFT or RIGHT vector")
	var ccc = current_corner_correction()
	var mv = movement_vector
	if mv.y == -1 or (mv.y == 1 and is_dashing()):
		for i in range(ccc.x, 0, -1):
			if place_free(Vector2(i, mv.y)):
				return Vector2.RIGHT
		for i in range(ccc.x, 0, -1):
			if place_free(Vector2(-i, mv.y)):
				return Vector2.LEFT
	if abs(mv.x) == 1:
		for i in range(ccc.y, 0, -1):
			if place_free(Vector2(mv.x, -i)):
				return Vector2.UP
		if is_dashing(): 
			for i in range(ccc.y, 0, -1):
				if place_free(Vector2(mv.x, i)):
					return Vector2.DOWN
	return Vector2.ZERO
	
func on_floor():
	return test_move(transform, Vector2.DOWN)

func place_free(relative_position: Vector2):
	assert(abs(relative_position.x) <= 1 or abs(relative_position.y) <= 1, "ERROR: One of the values must fulfil |n| <= 1")
	return not test_move(transform, relative_position)

#
# verificadores de processos atuais (executa tempo todo)
# esse são verificadores se um processo atual esta ocorrendo ou não
#

func current_corner_correction() -> Vector2:
	if is_dashing():
		return dash_corner_correction
	return corner_correction

func current_gravity():
	if jumping == true and Input.is_action_pressed("Jump") and last_solid == Vector2.DOWN and velocity.y < 0 and abs(velocity.y) < peak_gravity_threshold:
		return peak_gravity
	else:
		return gravity
		
func current_max_vspeed():
	if wall_slide_latched:
		return wall_slide_max_vspeed
	if is_dashing():
		return dash_speed
	return max_vspeed

#
# dash
# aqui fica tudo relacionado a dash
#
	
func dash(_delta):
	if Input.is_action_just_pressed("Dash"):
		if can_move() and dash_has_ability and can_dash():
			dash_direction = Vector2.ZERO
			dash_direction.x = input_direction.x
			if dash_direction == Vector2.ZERO:
				dash_direction.x = facing_direction
			if (last_solid == Vector2.LEFT or last_solid == Vector2.RIGHT) and wall_slide_latched != 0:
				dash_direction.x *= -1.0
			dash_refresh_timer = dash_refresh_time
			dash_timer = dash_pause_time + dash_duration
			dash_after_dash_has_reset_speed = false
			dash_refresh_timer_update = false
			wall_slide_latched = 0
	if dash_after_dash_has_reset_speed == false and not is_dashing():
		velocity.y = clamp(velocity.y, -dash_reset_speed_value.y, dash_reset_speed_value.y)
		velocity.x = clamp(velocity.x, -dash_reset_speed_value.x, dash_reset_speed_value.x)
		dash_after_dash_has_reset_speed = true
		
func is_dashing():
	return dash_timer > 0

#
# jump
# aqui fica tudo relacionado a pulo, gravidade, wall jump e etc
#

func jump(_delta):
	if Input.is_action_just_pressed("Jump"):
		jump_buffer_timer = jump_buffer_time
	if coyote_timer > 0 and not is_dashing():
		if jump_buffer_timer > 0:
			if last_solid == Vector2.DOWN:
				velocity.y = jump_speed
				coyote_timer = 0
				jump_buffer_timer = 0
				jumping = true

			#
			# Wall jump
			#

			if (last_solid == Vector2.LEFT or last_solid == Vector2.RIGHT) and has_wall_jump:
				velocity.y = wall_jump_vertical_speed
				wall_jump_raycast1.force_raycast_update()
				wall_jump_raycast2.force_raycast_update()
				if (!wall_jump_raycast1.is_colliding() or !wall_jump_raycast2.is_colliding()) and input_direction.x == last_solid.x:
					velocity.x = wall_jump_edge_horizontal_speed * -last_solid.x
					wall_jump_lose_control_timer = wall_jump_edge_lose_control_time
				else:
					velocity.x = wall_jump_horizontal_speed * -last_solid.x
					wall_jump_lose_control_timer = wall_jump_lose_control_time
				wall_slide_latched = 0
				coyote_timer = 0
				jump_buffer_timer = 0
				jumping = true

	#
	# Air jump
	#
	
	elif coyote_timer <= 0 and jump_buffer_timer > 0 and not is_dashing():
		if air_jump_has_ability and not air_jump_used_ability:
			velocity.y = air_jump_speed
			coyote_timer = 0
			jump_buffer_timer = 0
			jumping = true
			air_jump_used_ability = true
				
	if Input.is_action_just_released("Jump") and jumping:
		want_to_cut_speed = true
	if want_to_cut_speed and can_move():
		if velocity.y < 0 and can_cut_speed:
			velocity.y *= jump_cut
			want_to_cut_speed = false

func wall_latching():
	if has_wall_latch and can_move():
		if not on_floor() and (against_wall() != 0) and (against_wall() == sign(velocity.x)):
			if wall_slide_latched == 0 and velocity.y > 0:
				wall_slide_latched = against_wall()
				wall_slide_latch_on_timer = wall_slide_latch_on_pause
		if wall_slide_latched != 0 and (wall_slide_latched != against_wall()):
			wall_slide_latched = 0
			wall_slide_latch_on_timer = 0
		if on_floor():
			wall_slide_latched = 0
			wall_slide_latch_on_timer = 0

func process_gravity():
	if wall_slide_latch_on_timer > 0 or is_dashing() == true:
		return false
	else:
		return true
		
#
# movement
# aqui fica tudo relacionado a movimentação
#

func process_horizontal_movement():
	if dash_timer > dash_duration and dash_timer <= dash_pause_time + dash_duration:
		return false
	return true
		
func process_vertical_movement():
	if wall_slide_latch_on_timer > 0:
		return false
	else:
		return true

func perform_movement(delta):
	var step = Vector2(sign(velocity.x), sign(velocity.y))
	if process_vertical_movement():
		for _i in range(int(abs(velocity.y * delta))):
			if not place_free(Vector2(0, step.y)):
				var d = check_corner_correction(Vector2(0, step.y))
				if d.x != 0:
					while not place_free(Vector2(0, step.y)):
						position.x += d.x
			if place_free(Vector2(0, step.y)):
				position.y += step.y
			else:
				velocity.y = 0
	if process_horizontal_movement():
		for _i in range(int(abs(velocity.x * delta))):
			if not place_free(Vector2(step.x, 0)):
				var d = check_corner_correction(Vector2(step.x, 0))
				if d.y != 0:
					while not place_free(Vector2(step.x, 0)):
						position.y += d.y
			if place_free(Vector2(step.x, 0)):
				position.x += step.x

func update_velocity(delta):
	if can_move() and input_direction.x != 0:
		velocity.x = lerpf(velocity.x, input_direction.x * max_hspeed, acceleration)
	elif can_move() and input_direction.x == 0:
		velocity.x = lerpf(velocity.x, 0, friction)
		if abs(velocity.x) < hspeed_reset_threshold:
			velocity.x = 0
	elif dash_timer >= 0 and dash_timer <= dash_duration:
		velocity = dash_direction * dash_speed
	if process_gravity():
		velocity.y += current_gravity() * delta
	velocity.y = clamp(velocity.y, -current_max_vspeed(), current_max_vspeed())
				
func update_input_direction():
	input_direction.x = (int(Input.is_action_pressed("Right"))-int(Input.is_action_pressed("Left")))

func update_facing_direction():
	var dir = sign(velocity.x)
	if velocity.x != 0:
		facing_direction = sign(velocity.x)
		wall_jump_raycast1.target_position = wall_jump_raycast_cast_to * dir
		wall_jump_raycast2.target_position = wall_jump_raycast_cast_to * dir

#
# updates timer
# aqui fica tudo a updates extras, como timers
#

func update_timers(delta):
	wall_slide_latch_on_timer -= delta
	coyote_timer -= delta
	wall_jump_lose_control_timer -= delta
	jump_buffer_timer -= delta
	if dash_refresh_timer_update:
		dash_refresh_timer -= delta
	dash_timer -= delta
	
#
# sprites
# aqui fica updates como skin e animação
#
	
func update_animation():
	if (last_solid == Vector2.LEFT or last_solid == Vector2.RIGHT) and  wall_slide_latched != 0:
		skin.play("wall")

	elif dash_timer >= 0 and dash_timer <= dash_duration: 
		skin.play("dash")

	elif dash_timer < 0:
		if velocity.y >= 0 and !on_floor():
			skin.play("fall")
		elif jumping: 
			skin.play("jump")
		elif velocity.x != 0 and on_floor(): 
			skin.play("walk")
		else:
			skin.play("idle")
			
	if dash_timer < 0:
		if (last_solid == Vector2.LEFT or last_solid == Vector2.RIGHT) and  wall_slide_latched != 0:
			if input_direction.x > 0:
				skin.flip_h = true
			elif input_direction.x < 0:
				skin.flip_h = false
		else:
			if input_direction.x > 0:
				skin.flip_h = false
			elif input_direction.x < 0:
				skin.flip_h = true
	
#
# checkpoint
# aqui fica updates de checkpoint
#

func update_back():
	position = Global.spawn_point
	skin.play("back")
	back = false