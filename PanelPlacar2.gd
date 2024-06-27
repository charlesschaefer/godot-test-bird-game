extends Panel


func blink_diamond():
	for i in range(15):
		get_node("Diamond").modulate.a = 0.5 if i % 2 else 1
		get_node("coins_label").modulate.a = 0.5 if i % 2 else 1
		await get_tree().create_timer(0.1).timeout

func blink_medal():
	for i in range(15):
		get_node("Medal").modulate.a = 0.5 if i % 2 else 1
		get_node("LabelLevel").modulate.a = 0.5 if i % 2 else 1
		get_node("level").modulate.a = 0.5 if i % 2 else 1
		await get_tree().create_timer(0.1).timeout

func _on_game_correct_selection(correct_number):
	get_node("coins_label").text = "%02d" % correct_number
	blink_diamond()


func _on_game_level_change(next_level):
	# panel 2
	get_node("level").text = str(next_level)
	blink_medal()
