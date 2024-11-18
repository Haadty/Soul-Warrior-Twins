extends Node2D

@onready var player: CharacterBody2D = $"../Player"

#
# sistema de controles de camera
#

func _ready():	
	Global.camera_room_change.connect(func(area):    
		change_room(area)
	)	

func change_room(area: Area2D) -> void:  
	Global.player_actual_camera = area.find_child("Camera")

	if area != Global.player_actual_area:
		if Global.player_actual_camera == Global.player_actual_area.find_child("Camera"):
			Global.player_actual_camera.set_priority(0)
			Global.player_actual_camera.set_follow_target(null)
			Global.player_actual_camera = area.find_child("Camera")
			Global.player_actual_camera.set_follow_target(player)
			Global.player_actual_camera.set_priority(20)
		Global.player_actual_area = area
	else: 
		Global.player_actual_camera.set_follow_target(player)
		Global.player_actual_camera.set_priority(20)

	if area == Global.player_actual_area:
		if Global.player_actual_camera != Global.player_actual_area.find_child("Camera"):
			Global.player_actual_camera.set_priority(0)
			Global.player_actual_camera.set_follow_target(null)
			Global.player_actual_camera = Global.player_actual_area.find_child("Camera")
			Global.player_actual_camera.set_follow_target(player)
			Global.player_actual_camera.set_priority(20)
