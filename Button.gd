extends Button

func _on_Button_pressed():
	GameVars.playing = true
	get_tree().change_scene("res://Game.tscn")
