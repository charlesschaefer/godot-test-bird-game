extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_enviar_pressed():
	var nome = get_node("MarginContainer/Rows/Cols1/InputNome").text
	var email = get_node("MarginContainer/Rows/Cols2/InputEmail").text
	var nascimento = get_node("MarginContainer/Rows/Cols3/InputNascimento").text
	print("Nome, email e nascimento: ")
	print(nome)
	print(email)
	print(nascimento)
	self.hide()
	get_parent().start_game()
