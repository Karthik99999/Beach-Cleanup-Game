extends Node2D

# preload trash scenes
onready var bottle = preload("res://Trash/Bottle.tscn")
onready var can = preload("res://Trash/Can.tscn")
onready var trash_ball = preload("res://Trash/TrashBall.tscn")

onready var seagull = preload("res://Seagull.tscn")
onready var crab = preload("res://Crab.tscn")
onready var sea_urchin = preload("res://SeaUrchin.tscn")
var seagulls = []
var crabs = []
var sea_urchins = []
onready var player = $Player
onready var health_bar = $HealthBar
onready var EndDialog = $EndDialog
onready var TrashTimer = $TrashTimer
onready var SeagullTimer = $SeagullTimer
onready var CrabTimer = $CrabTimer
onready var SeaUrchinTimer = $SeaUrchinTimer
var score = 0
var highscore = 0
var label = Label.new()

func _ready():
	# Change rng seed
	randomize()
	# set up end dialog
	var resetBtn = EndDialog.get_ok()
	var quitBtn = EndDialog.get_cancel()
	resetBtn.set_text("Restart")
	resetBtn.connect("pressed", self, "restart")
	quitBtn.set_text("Quit")
	quitBtn.connect("pressed", self, "quit")
	# Set up score label
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://assets/arial.ttf")
	dynamic_font.size = 32
	dynamic_font.use_filter = false

	label.text = "Score: 0"
	label.rect_size.x = 320
	label.rect_size.y = 32
	label.align = 0
	label.valign = VALIGN_CENTER
	label.set_global_position(Vector2(0,568))
	label.add_font_override("font", dynamic_font)
	label.add_color_override("font_color", Color.black)

	add_child(label)
	
func _process(delta):
	for s in seagulls:
		var wr = weakref(s[0])
		if wr.get_ref():
			s[0].global_position.x += s[1]
			if s[0].global_position.x > 1024 or s[0].global_position.x < 0:
				s[0].queue_free()
	for c in crabs:
		var wr = weakref(c[0])
		if wr.get_ref():
			c[0].global_position.y += c[1]
			if c[0].global_position.y > 600 or c[0].global_position.y < 0:
				c[0].queue_free()

# Function for adding trash once timer is finished
func add_trash():
	# Choose random location for trash
	var x = rand_range(64,960)
	var y = rand_range(60,540)
	# Choose random trash to place
	var pieces = [bottle, can, trash_ball]
	var trash = pieces[(randi() % len(pieces)) - 1].instance()
	trash.global_position = Vector2(x, y)
	trash.connect("body_entered", self, "_on_trash_collide", [trash])
	add_child_below_node($Rock7, trash)

# pick up trash
func _on_trash_collide(body, trash):
	if body == player:
		trash.queue_free()
		$PickupSound.play()
		score += 10
		label.text = "Score: " + str(score)

# add new seagull
func _on_SeagullTimer_timeout():
	var new_seagull = seagull.instance()
	var move_x = -10
	var x_vals = [0, 1024]
	new_seagull.global_position = Vector2(x_vals[(randi() % len(x_vals)) - 1], rand_range(60,540))
	if new_seagull.global_position.x == 0:
		new_seagull.get_node("AnimatedSeagull").set_flip_h(true)
		move_x = 10
	new_seagull.connect("body_entered", self, "_on_seagull_collide")
	seagulls.append([new_seagull, move_x])
	add_child_below_node($Player, new_seagull)

func _on_seagull_collide(body):
	if body == player:
		health_bar.attack(10)
		# check if health is zero
		if health_bar.health <= 0:
			# set highscore
			if score > highscore:
				highscore = score
				$HighscoreSound.play()
				show_end_dialog("New High Score! Score: " + str(score) + " Highscore: " + str(highscore))
			else:
				$DeathSound.play()
				show_end_dialog("Score: " + str(score) + " Highscore: " + str(highscore))

# add new crab
func _on_CrabTimer_timeout():
	var new_crab = crab.instance()
	var move_y = 5
	var y_vals = [0, 600]
	new_crab.global_position = Vector2(rand_range(64,960), y_vals[(randi() % len(y_vals)) - 1])
	if new_crab.global_position.y == 600:
		move_y = -5
	new_crab.connect("body_entered", self, "_on_crab_collide")
	crabs.append([new_crab, move_y])
	add_child_below_node($Rock7, new_crab)

func _on_crab_collide(body):
	if body == player:
		health_bar.attack(10)
		# check if health is zero
		if health_bar.health <= 0:
			# set highscore
			if score > highscore:
				highscore = score
				$HighscoreSound.play()
				show_end_dialog("New High Score! Score: " + str(score) + " Highscore: " + str(highscore))
			else:
				$DeathSound.play()
				show_end_dialog("Score: " + str(score) + " Highscore: " + str(highscore))

# add new sea urchin
func _on_SeaUrchinTimer_timeout():
	# Choose random location for sea urchin
	var x = rand_range(64,960)
	var y = rand_range(60,540)
	# Choose random trash to place
	var new_sea_urchin = sea_urchin.instance()
	new_sea_urchin.global_position = Vector2(x, y)
	new_sea_urchin.connect("body_entered", self, "_on_sea_urchin_collide", [new_sea_urchin])
	sea_urchins.append(new_sea_urchin)
	add_child_below_node($Rock7, new_sea_urchin)
	# keep only 3 sea urchins on the screen at once
	if len(sea_urchins) > 3:
		var wr = weakref(sea_urchins[0])
		if wr.get_ref():
			sea_urchins[0].queue_free()
		sea_urchins.remove(0)

func _on_sea_urchin_collide(body, new_sea_urchin):
	if body == player:
		health_bar.attack(15)
		new_sea_urchin.queue_free()
		# check if health is zero
		if health_bar.health <= 0:
			# set highscore
			if score > highscore:
				highscore = score
				$HighscoreSound.play()
				show_end_dialog("New High Score! Score: " + str(score) + " Highscore: " + str(highscore))
			else:
				$DeathSound.play()
				show_end_dialog("Score: " + str(score) + " Highscore: " + str(highscore))

# stop all processes on game over
func show_end_dialog(text):
	EndDialog.dialog_text = text
	EndDialog.show()
	TrashTimer.stop()
	SeagullTimer.stop()
	CrabTimer.stop()
	SeaUrchinTimer.stop()
	GameVars.playing = false
	set_process(false)

# restart and reset everything
func restart():
	for s in seagulls:
		var wr = weakref(s[0])
		if wr.get_ref():
			s[0].queue_free()
	seagulls = []
	for c in crabs:
		var wr = weakref(c[0])
		if wr.get_ref():
			c[0].queue_free()
	crabs = []
	for su in sea_urchins:
		var wr = weakref(su)
		if wr.get_ref():
			su.queue_free()
	sea_urchins = []
	for n in get_children():
		if "Bottle" in n.name or "Can" in n.name or "TrashBall" in n.name:
			n.queue_free()
	health_bar.health = 100
	score = 0
	label.text = "Score: " + str(score)
	TrashTimer.start()
	SeagullTimer.start()
	CrabTimer.start()
	SeaUrchinTimer.start()
	GameVars.playing = true
	set_process(true)

func quit():
	get_tree().quit()
