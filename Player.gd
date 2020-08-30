extends KinematicBody2D

const ACCELERATION = 10000
var MAX_SPEED = 200
const FRICTION = 0.25

var x = 0
var motion = Vector2.ZERO
onready var TheDude = $TheDude
var anim = "still"

func _physics_process(delta):
	if !GameVars.playing:
		return
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var y_input = (Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down"))*(-1)
	
	if x_input != 0 :
		motion.x += x_input * ACCELERATION * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		TheDude.flip_h = x_input < 0
		anim = "Walking"
		
	if y_input != 0 :
		motion.y += y_input * ACCELERATION * delta
		motion.y = clamp(motion.y, -MAX_SPEED, MAX_SPEED)
		TheDude.flip_h = x_input < 0
		anim = "Walking"
	
	if x_input == 0:
		motion.x = 0
	if y_input == 0:
		motion.y = 0
	
	if x_input != 0 and y_input != 0:
		anim = "Walking"
	if x_input == 0 and y_input == 0:
		anim = "still"

	motion = move_and_slide(motion, Vector2.UP)
	TheDude.play(anim)
