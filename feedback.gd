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
