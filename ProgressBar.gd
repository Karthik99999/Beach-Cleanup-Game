extends ProgressBar

var health = 100 # 100 health points

func attack(damage):
	health = health - damage # new health value is old health minus the damage
	update_healthbar(health) # runs the update function beneath

func update_healthbar(health):
	# That is the relevant part now, which updates it:
	get_node("/root/Game/HealthBar").set_value(health)
	print(health)
	
func _process(delta):
	update_healthbar(health)
	print(health)
