extends ProgressBar

var healt = 0 : set = _set_healt

func _set_healt(new_healt):
	healt = min(max_value, new_healt)
	value = healt 

	if healt <= 0:
		queue_free()

func init_healt(_healt):
	healt = _healt
	max_value = _healt
	value = _healt