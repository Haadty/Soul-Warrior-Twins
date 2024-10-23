extends Node

@onready var SoulOneHealtBar = $"VidaSoulOne"
@onready var SoulTwoHealtBar = $"VidaSoulTwo"

var healtMax = 400
var healtOne = healtMax
var healtTwo = healtMax
	
func _ready():	
	SoulOneHealtBar.init_healt(healtMax)	
	SoulTwoHealtBar.init_healt(healtMax)
	Events.damage.connect(func(type, damage):
		if type == 1: 
			basicDamageOne(damage)
		elif type == 2: 
			basicDamageTwo(damage)
		elif type == 3: 
			allDamage(damage)
	)	

func basicDamageOne(damage:int):
	healtOne -= damage
	SoulOneHealtBar.healt = healtOne

func basicDamageTwo(damage:int):
	healtTwo -= damage
	SoulTwoHealtBar.healt = healtTwo

func allDamage(damage:int):
	healtOne -= damage
	SoulOneHealtBar.healt = healtOne
	healtTwo -= damage
	SoulTwoHealtBar.healt = healtTwo
