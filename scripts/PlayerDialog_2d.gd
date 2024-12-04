extends Node2D

var dialog = false
var numeroDialog = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if numeroDialog == 0:
		get_node("Dialogos/Dialog1").set_visible(true)
		get_node("Dialogos/Dialog2").set_visible(true)
		get_node("Dialogos/Retornar").set_visible(true)
		get_node("Dialogos/Avancar").set_visible(true)
		get_tree().set_pause(false)
		

		
	if Input.is_action_pressed("tiro") and dialog == true: #vai mais = a 1
		numeroDialog += 1
		get_tree().set_pause(true)
		
	if numeroDialog == 1:
		get_tree().set_pause(true)
		get_node("Dialogos/Dialog1").set_visible(false)
		get_node("Dialogos/Dialog2").set_visible(true)
		get_node("Dialogos/Retornar").set_visible(false)
		get_node("Dialogos/Avancar").set_visible(false)
		
	if numeroDialog == 2:
		get_tree().set_pause(true)
		get_node("Dialogos/Dialog1").set_visible(true)
		get_node("Dialogos/Dialog2").set_visible(false)
		get_node("Dialogos/Retornar").set_visible(false)
		get_node("Dialogos/Avancar").set_visible(false)
		
	if numeroDialog > 2: 
		numeroDialog = 0
		
func _on_Detector_body_enter( _body ):
	dialog = true
	pass
	
func _on_Detector_body_exit( _body ):
	dialog =	 false
	pass

func _on_Avancar_pressed():
	numeroDialog += 1
	pass
	
func _on_Retornar_pressed():
	numeroDialog -= 1
	pass
