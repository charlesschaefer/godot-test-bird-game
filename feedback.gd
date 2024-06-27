extends Panel


const TYPE_ERROR = "error"
const TYPE_CORRECT = "correct"

var play_audio = true
var blink = true

func set_play_audio(play:bool):
	play_audio = play

func set_blink(blink:bool):
	self.blink = blink

func error(msg:String):
	show_msg(msg, TYPE_ERROR)

func correct(msg:String):
	show_msg(msg, TYPE_CORRECT)

func show_msg(msg:String, type:String):
	get_node("msg").text = msg
	var color = theme.get_color(type, "Panel")
	theme.get_stylebox("panel", "Panel").bg_color = color

	if play_audio:
		get_node(type + "_sound").play() 
	
	visible = true
	
	var timer = get_node("feedbackTimer")
	timer.one_shot = true
	timer.start(1)
	
	if blink:
		blink_feedback()


func blink_feedback():
	for i in range(15):
		self.modulate.a = 0.5 if i % 2 else 1
		await get_tree().create_timer(0.1).timeout


func hide_msg():
	visible = false
	self.modulate.a = 1
	blink = false


func _on_game_level_change(next_level):
	# feedback
	var idx = (next_level - 1) % 3
	if idx == 0:
		idx = 3
	print("idx: ", idx)
	var ntimer = Timer.new();
	ntimer.connect("timeout", func(): 
		
		get_parent().get_node("Bg1").visible = false
		get_parent().get_node("Bg2").visible = false
		get_parent().get_node("Bg3").visible = false
		
		get_parent().get_node("Bg" + str(idx)).visible = true
		remove_child(ntimer)
		ntimer.queue_free()
	)
	ntimer.one_shot = true
	add_child(ntimer)
	ntimer.start(1)
