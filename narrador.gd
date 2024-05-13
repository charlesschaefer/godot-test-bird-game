extends Area2D

const MSGS = [
	"Olá, ser humaninho lindo! \nQue bom que chegou... Precisamos da sua ajuda!",
	"Estamos vendo vários pássaros no aeroporto ultimamente. \nIsso é muito perigoso... e precisamos que descubra para onde estão indo.",
	"Assim podemos enviar os drones de abatimento das aves.",
	"Para isso, basta usar as teclas direcionais para indicar para qual lado o pássaro que você viu está indo!",
	"Todos os nossos passageiros contam com isso! Nós contamos com você"
]

const TW_INTERVAL = 0.03

var current_text = 0
var typewriting = false


signal finished

func _ready():
	pass

func start():
	visible = true
	current_text = 0
	typewrite(MSGS[current_text])

func _process(delta):
	var button = get_node("Panel/continue_button")
	if not typewriting && button.visible && Input.is_action_just_pressed("confirm"):
		print("Apertou enter em doidão")
		button.emit_signal("pressed")

func typewrite(text:String):
	var label = get_node("Panel/Label")
	label.text = ""
	typewriting = true
	await get_tree().create_timer(0.2).timeout
	for i in range(text.length()):
		print("Tô indo no %d" % i)
		if Input.is_action_pressed("confirm"):
			label.text = text
			break;
		if [".", "?", "!"].has(text[i-1]):
			await get_tree().create_timer(TW_INTERVAL * 5).timeout
		else:
			await get_tree().create_timer(TW_INTERVAL).timeout
		label.text += text[i]
	typewriting = false
	get_node("Panel/continue_button/show_timer").start(0.1)
	#show_button()

func _on_continue_button_pressed():
	hide_button()
	next_message()

func next_message():
	if current_text < MSGS.size() - 1:
		current_text += 1
		typewrite(MSGS[current_text])
	else:
		emit_signal("finished")

func hide_button():
	get_node("Panel/continue_button").visible = false

func show_button():
	get_node("Panel/continue_button").visible = true
