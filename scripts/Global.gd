extends Node

#
# eventos globais
# aqui fica eventos que podem ocorrer em qualquer parte do mapa e não tem relação com nenhum objeto
#

var spawn_point = Vector2(211, 213)
var player_actual_camera: PhantomCamera2D
var player_actual_area: Area2D

signal damage(type:int, damage:int)

signal camera_room_change(area:Area2D)