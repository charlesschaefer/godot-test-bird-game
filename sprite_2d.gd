extends Sprite2D

var speed = 600

var left_start = -64
var right_start = 1214

var side

func _init():
	side = randi() % 2 # rand between 0 (RTL) and 1 (LTR)
	
	position.x = left_start
	rotation_degrees = 60
	flip_h = 0
	if side == 0:
		position.x = right_start
		rotation_degrees = -60
		flip_h = 1


func _process(delta):
	var velocity = Vector2.LEFT.round() * speed
	if side == 1:
		position -= velocity * delta
	else:
		position += velocity * delta
	
	


