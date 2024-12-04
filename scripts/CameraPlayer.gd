extends Camera2D

func _ready() -> void:
	Events.room_enter.connect(func(room):
		global_position = room.global_position,
	)
