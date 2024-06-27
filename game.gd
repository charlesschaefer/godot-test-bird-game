extends Node2D

const AUTO_RESPAWN_INTERVAL = 2.5
const BIRD_TYPES = 2
const AUTO_RESPAWN = true
const MSG_LOST = "Ops! Perdeu o pássaro!"

const LEVEL_MULTIPLIER = 0.2
const HITS_TO_NEXT_LEVEL = 10

const MSG_ERROR = "Que pena, você errou a direção do pássaro! Continue tentando!"
const MSG_CORRECT = "Muito bem! Continue assim!"
const MSG_LEVEL = "Parabéns! Você foi promovido para o %dº nível!"

enum RESULT_TYPE {
	ERROR,
	CORRECT,
	LOST
}

var result_labels = {
	RESULT_TYPE.ERROR: "error",
	RESULT_TYPE.CORRECT: "correct",
	RESULT_TYPE.LOST: "lost"
}

var bird_direction = -1
var bird_on_screen = false
var bird_object
var user_interacted = false

var direction_map = {
	"left": 0,
	"right": 1,
	"up": 2,
	"down": 3
}

var user_steps = []
var user_steps_reaction_time = {
	RESULT_TYPE.CORRECT: [],
	RESULT_TYPE.ERROR: []
}

var current_step = 0
var current_step_result:RESULT_TYPE
var start_time = 0

var current_level = 1
var level_changed = false


# Called when the node enters the scene tree for the first time.
func _ready():
	#show_narrator_screen()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_end"):
		print("end")
		spawn_bird()
	if bird_on_screen && Input.is_anything_pressed():
		check_player_input();
	
	if Input.is_action_just_pressed("close"):
		get_node("continue_game").visible = true
		get_tree().paused = true

func check_player_input():
	var buttons = ["left", "right", "up", "down"]
	for i in buttons:
		if not user_interacted && Input.is_action_just_pressed(i):
			user_interacted = true
			if bird_direction != direction_map[i]:
				save_user_result(RESULT_TYPE.ERROR)
				feedback(RESULT_TYPE.ERROR, MSG_ERROR)
			else:
				save_user_result(RESULT_TYPE.CORRECT)
				level_controller()
				if not level_changed:
					feedback(RESULT_TYPE.CORRECT, MSG_CORRECT)
				
			
			remove_bird()
			return

func spawn_bird():
	bird_object = get_node("playArea/bird")
	
	if AUTO_RESPAWN:
		var timer = bird_object.get_node("spawnTimer")
		timer.one_shot = true
		var interval = AUTO_RESPAWN_INTERVAL
		interval += (randi() % (current_level + 1)) * LEVEL_MULTIPLIER * current_level
		print("Interval:", interval)
		timer.start(interval)
		print_debug(timer.is_paused(), "Tà?")

	bird_object.start(randi() % BIRD_TYPES)
	#bird_object.start(0)

func remove_bird():
	bird_object.kill()

func feedback(type:RESULT_TYPE, msg:String, play_audio:bool = true, blink:bool = false):
	var feedback = get_node("playArea/feedback")
	feedback.set_play_audio(play_audio)
	feedback.set_blink(blink)
	if type == RESULT_TYPE.ERROR:
		feedback.error(msg)
	else:
		feedback.correct(msg)

func save_user_result(type:RESULT_TYPE):
	var reaction_time = stop_reaction_timer()
	user_steps.append(type)
	
	var reaction_type = type if type != RESULT_TYPE.LOST else RESULT_TYPE.ERROR
	user_steps_reaction_time[reaction_type].append(reaction_time)
	current_step += 1
	current_step_result = type
	
	update_reaction_times(reaction_time)
	
	var number_label = get_node("playArea/score/Panel/" + result_labels[type] + "_value")
	var value = user_steps.count(type)
	number_label.text = str(value)

func update_reaction_times(reaction_time):
	get_node("playArea/score/Panel2/label_ultimo")\
		.text = str(reaction_time) + " ms"
	
	var sum = user_steps_reaction_time[RESULT_TYPE.CORRECT]\
		.reduce(func(sum, val): return sum + val, 0)
	print("sum", sum)
	
	var average = 0
	if sum:
		average = sum / user_steps_reaction_time[RESULT_TYPE.CORRECT].size()
	
	print("avg", average, "size", user_steps_reaction_time[RESULT_TYPE.CORRECT].size())
	
	get_node("playArea/score/Panel2/label_media")\
		.text = "%d ms" % [average]

func level_controller():
	level_changed = false
	if user_steps.size() <= 0:
		return
	
	var corrects = user_steps.count(RESULT_TYPE.CORRECT)
	if corrects % HITS_TO_NEXT_LEVEL == 0:
		new_level()

func new_level():
	level_changed = true
	var next_level = current_level + 1
	bird_object.update_speed(next_level * LEVEL_MULTIPLIER)
	
	current_level = next_level
	get_node("playArea/score/Panel/level").text = str(current_level)
	get_node("playArea/score/Panel/lost_value").text = "0"
	get_node("playArea/score/Panel/correct_value").text = "0"
	get_node("playArea/score/Panel/error_value").text = "0"
	
	var timer = get_node("playArea/bird/spawnTimer")
	timer.stop()
	
	var timer2 = get_node("playArea/feedback/feedbackTimer")
	feedback(RESULT_TYPE.CORRECT, MSG_LEVEL % [next_level], false, true)
	timer2.stop()
	
	get_node("level_audio").play()
	timer2.start(AUTO_RESPAWN_INTERVAL)
	timer.start(AUTO_RESPAWN_INTERVAL + 1)
	
	var idx = current_level % 3
	if idx == 0:
		idx = 3
	print("idx: ", idx)
	var ntimer = Timer.new();
	ntimer.connect("timeout", func(): 
		get_node("playArea/Bg1").visible = false
		get_node("playArea/Bg2").visible = false
		get_node("playArea/Bg3").visible = false
		
		get_node("playArea/Bg" + str(idx)).visible = true
		remove_child(ntimer)
		ntimer.queue_free()
	)
	ntimer.one_shot = true
	add_child(ntimer)
	ntimer.start(1)


func _on_area_2d_area_entered(area):
	start_reaction_timer()
	if area.name.begins_with("bird"):
		bird_direction = area.sliding_direction
		bird_on_screen = true

func _on_area_2d_area_exited(area):
	bird_on_screen = false
	
	if not user_interacted:
		save_user_result(RESULT_TYPE.LOST)
		feedback(RESULT_TYPE.ERROR, MSG_LOST)
	
	user_interacted = false

func start_reaction_timer():
	start_time = Time.get_ticks_msec()

func stop_reaction_timer():
	var time = Time.get_ticks_msec() - start_time
	start_time = 0
	return time

func show_narrator_screen():
	get_node("playArea/Narrador").start()
	get_node("playArea/Bg1").show()

func _on_narrador_finished():
	get_node("playArea/score").visible = true
	var narrador = get_node("playArea/Narrador")
	narrador.visible = false
	remove_child(narrador)
	narrador.queue_free()
	spawn_bird()


func _on_continue_game_pressed():
	print("foi?")
	get_tree().paused = false
	get_node("continue_game").visible = false

func start_game():
	show_narrator_screen()
