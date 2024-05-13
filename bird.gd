extends Area2D

const BASE_SPEED = 400
const TO_LEFT = 0
const TO_RIGHT = 1
const TO_UP = 2
const TO_DOWN = 3
const DIRECTIONS = {
	TO_LEFT: Vector2.LEFT,
	TO_RIGHT: Vector2.RIGHT,
	TO_UP: Vector2.UP,
	TO_DOWN: Vector2.DOWN
}
const WIDTH = 90

const VERTICAL_LANE = 205
const HORIZONTAL_LANE = 51

var SPEED = BASE_SPEED

var running = false
var area = DisplayServer.window_get_size()
var left_edge = 0
var right_edge = area.x
var top_edge = 0
var bottom_edge = area.y
var sliding_direction = TO_RIGHT

var original_pos

func _ready():
	original_pos = global_position
	print_debug("O: ", original_pos, "L: ", position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not running:
		return
	
	slide(delta, sliding_direction)
	#print_debug("position.x: %f, edge: %f e %f, dir: %d" % [position.x, left_edge, right_edge, sliding_direction])
	
	if sliding_direction == TO_RIGHT && position.x > right_edge:
		running = false
		visible = false
		#print_debug("parou um")
	if (sliding_direction == TO_LEFT && position.x < left_edge - WIDTH):
		running = false
		visible = false
	
	if sliding_direction == TO_DOWN && position.y > bottom_edge:
		running = false
		visible = false
		#print_debug("parou um")
	if (sliding_direction == TO_UP && position.y < top_edge - WIDTH):
		running = false
		visible = false
		#print_debug("parou dois")

func update_speed(multiplier):
	SPEED = BASE_SPEED * (1 + multiplier)

func reset_speed():
	SPEED = BASE_SPEED

func start(bird:int = 0):
	var bird_animation = get_node("birdAnimation")
	bird_animation.animation = str(bird)
	
	if bird == 0:
		sliding_direction = randi() % 2
	if bird == 1:
		sliding_direction = randi() % 2 + 2
	
	#sliding_direction = randi() % 4
	var pos
	
	if sliding_direction == TO_RIGHT: 
		position.x = Vector2.RIGHT.x * left_edge
		bird_animation.flip_h = true
		bird_animation.flip_v = false
	
	if sliding_direction == TO_LEFT:
		position.x = Vector2.RIGHT.x * right_edge
		#pos = left_edge
		bird_animation.flip_h = false
		bird_animation.flip_v = false
	
	if sliding_direction == TO_UP:
		position.y = Vector2.DOWN.y * bottom_edge
		bird_animation.flip_v = false
		bird_animation.flip_h = false
	
	if sliding_direction == TO_DOWN:
		position.y = Vector2.DOWN.y * top_edge
		bird_animation.flip_v = true
		bird_animation.flip_h = false
	
	if [TO_DOWN, TO_UP].has(sliding_direction):
		position.x = Vector2.RIGHT.x * VERTICAL_LANE
	else:
		position.y = Vector2.DOWN.y * HORIZONTAL_LANE
	
	visible = true
	running = true
	#print_debug("Left: %s, Right: %s, Dir: ." % [DIRECTIONS[0], DIRECTIONS[1], sliding_direction])

func kill():
	visible = false
	position = original_pos

func slide(delta, direction:int = TO_RIGHT):
	position += SPEED * delta * DIRECTIONS[direction]
