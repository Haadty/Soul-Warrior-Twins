extends Control

@onready var player = $Camera/SubViewportContainer/SubViewport/Level/Player
@onready var atackPanel = $panelBattle
@onready var status = $PlayerStatus
@onready var oneSkin = $Camera/SubViewportContainer/SubViewport/Level/Player/One/AnimatedSprite2D
@onready var twoSkin = $Camera/SubViewportContainer/SubViewport/Level/Player/Two/AnimatedSprite2D
@onready var enemySkin = $Camera/SubViewportContainer/SubViewport/Level/Enemy/AnimatedSprite2D
@onready var enemy = $Camera/SubViewportContainer/SubViewport/Level/Enemy
@onready var musics = $AudioStreamPlayer

@onready var buttons = [
	$panelBattle/buttons/Button1,
	$panelBattle/buttons/Button2,
	$panelBattle/buttons/Button3,
	$panelBattle/buttons/Button4
]

var queue = 0
var oneAttack
var twoAttack
var startPos = Vector2(5673, -75)
var enemyHealth = 200
var oneInAnimation	= "idle"
var twoInAnimation	= "idle"
var enemyAnimation = "idle"

const battleMusic = preload("res://musics/battle.wav")

var habilidadesOne = [
	{"name": "Cortes Rápidos", "damage": 50},
	{"name": "Quebra Postura", "damage": 40},
	{"name": "Corte Triplo", "damage": 60},
	{"name": "Lâmina Vampírica", "damage": 30}
]

var habilidadesTwo = [
	{"name": "Avanço", "damage": 50},
	{"name": "Perfurada", "damage": 60},
	{"name": "Carga de Almas", "damage": 80},
	{"name": "Leveza Plateada", "damage": 40}
]

func changeQueue():
	if enemyHealth > 0:
		if queue != 2: 
			queue += 1
		else: 
			queue = 0	

		battlePanel()

		if queue == 2:  	
			attackLogic()	
			await get_tree().create_timer(3).timeout
			if enemyHealth > 0:
				EnemyAttack()	

	elif oneAttack == null and twoAttack == null:
		atackPanel.visible = false

func battlePanel():
	if queue != 2:
		atackPanel.visible = true
		if queue == 0:
			buttons[0].text = habilidadesOne[0]["name"]
			buttons[1].text = habilidadesOne[1]["name"]
			buttons[2].text = habilidadesOne[2]["name"]
			buttons[3].text = habilidadesOne[3]["name"]	
		elif queue == 1:
			buttons[0].text = habilidadesTwo[0]["name"]
			buttons[1].text = habilidadesTwo[1]["name"]
			buttons[2].text = habilidadesTwo[2]["name"]
			buttons[3].text = habilidadesTwo[3]["name"]
	else: 	
		atackPanel.visible = false

func _process(delta: float) -> void:

	if !player.inBattle and status.healtOne <= 0 and status.healtTwo <= 0: 
		get_tree().reload_current_scene()

	Events.battleStart.connect(func():
		if !player.inBattle:
			startBattle(),
	)

	oneSkin.play(oneInAnimation)	
	twoSkin.play(twoInAnimation)
	enemySkin.play(enemyAnimation)

	if enemyHealth <= 0 and oneAttack == null and twoAttack == null:
		win()


func win():
	enemy.visible = false
	oneInAnimation = "idle"
	twoInAnimation = "idle"


func startBattle():
	musics.stream = battleMusic
	musics.play()
	queue = 0
	player.inBattle = true
	status.healtOne = status.healtMax
	status.healtTwo = status.healtMax
	Events.spawn_point = startPos
	player.position = startPos
	player.skin.play("start")
	await get_tree().create_timer(1.5).timeout
	player.skin.visible = false
	player.one.visible = true
	player.two.visible = true
	atackPanel.visible = true
	battlePanel()

func _on_button_1_pressed() -> void:
	if queue == 0: oneAttack = habilidadesOne[0]
	elif queue == 1: twoAttack = habilidadesTwo[0]
	changeQueue()


func _on_button_2_pressed() -> void:
	if queue == 0: oneAttack = habilidadesOne[1]
	elif queue == 1: twoAttack = habilidadesTwo[1]
	changeQueue()

func _on_button_3_pressed() -> void:
	if queue == 0: oneAttack = habilidadesOne[2]
	elif queue == 1: twoAttack = habilidadesTwo[2]
	changeQueue()

func _on_button_4_pressed() -> void:
	if queue == 0: oneAttack = habilidadesOne[3]
	elif queue == 1: twoAttack = habilidadesTwo[3]
	changeQueue()

func EnemyAttack():
	enemyAnimation = "attack"
	await get_tree().create_timer(2).timeout
	status.allDamage(40)
	enemyAnimation = "idle"
	changeQueue()

func AttackOne(type:String, damage:int):
	if type == "Cortes Rápidos":
		oneInAnimation = "attack_1"
		await get_tree().create_timer(1).timeout
		enemyHealth -= damage
		oneInAnimation = "idle"
	elif type == "Quebra Postura":
		oneInAnimation = "attack_2"
		await get_tree().create_timer(1).timeout
		enemyHealth -= damage
		oneInAnimation = "idle"
	elif type == "Corte Triplo":
		oneInAnimation = "attack_3"	
		await get_tree().create_timer(1).timeout
		enemyHealth -= damage
		oneInAnimation = "idle"
	elif type == "Lâmina Vampírica":
		oneInAnimation = "attack_4"	
		await get_tree().create_timer(1).timeout
		enemyHealth -= damage
		oneInAnimation = "idle"

func AttackTwo(type:String, damage:int):
	if type == "Avanço":
		twoInAnimation = "attack_1"
		await get_tree().create_timer(1).timeout
		enemyHealth -= damage
		twoInAnimation = "idle"
	elif type == "Perfurada":
		twoInAnimation = "attack_2"
		await get_tree().create_timer(1).timeout
		enemyHealth -= damage
		twoInAnimation = "idle"
	elif type == "Carga de Almas":
		twoInAnimation = "attack_3"	
		await get_tree().create_timer(1).timeout
		enemyHealth -= damage
		twoInAnimation = "idle"
	elif type == "Leveza Plateada":
		twoInAnimation = "attack_4"	
		await get_tree().create_timer(1).timeout
		enemyHealth -= damage
		twoInAnimation = "idle"

func attackLogic():
	if oneAttack != null:
		for habilidade in habilidadesOne:
			if habilidade == oneAttack:
				AttackOne(habilidade["name"], habilidade["damage"])
				break
		oneAttack = null 

	await get_tree().create_timer(1.5).timeout

	if twoAttack != null:
		for habilidade in habilidadesTwo:
			if habilidade == twoAttack:
				AttackTwo(habilidade["name"], habilidade["damage"])
				break
		twoAttack = null 
