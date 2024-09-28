@tool
class_name JoyStickInput
extends TouchScreenButton

## A general joystick for normal and grid based movement.

signal joystick_direction(direction_8: Vector2, direction_4: Vector2, direction: Vector2) 
signal joystick_angle(angle_8: int, angle_4: int, angle: float)

enum angles_8 {
	NONE = -1,
	RIGHT = 0,
	DOWN_RIGHT = 1,
	DOWN = 2,
	DOWN_LEFT = 3,
	LEFT = 4,
	UP_LEFT = 5,
	UP = 6,
	UP_RIGHT = 7,
}

enum angles_4 {
	NONE = -1,
	RIGHT = 0,
	DOWN = 1,
	LEFT = 2,
	UP = 3,
}


@export var threshold: int = 10
@export var recenter_on_pause: bool = true ## Recenters the knob when get_tree().paused = true
@export_category("Knob")
@export var knob: Sprite2D
@export var knob_texture: Texture2D:
	set(value):
		knob_texture = value
		if is_instance_valid(knob):
			knob.texture = value
	get(): return knob_texture

var max_length: int = 0
var stick_center: Vector2 = Vector2.ZERO
var pressing: bool = false

func _ready() -> void:
	pressed.connect(_on_pressed)
	released.connect(_on_released)
	
	max_length = shape.radius
	stick_center = texture_normal.get_size() / 2
	set_process(false)
	
	if not knob:
		knob =  Sprite2D.new()
		knob.position = stick_center
		add_child(knob)
	
	if knob_texture:
		knob.texture = knob_texture

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			set_process(true)
		elif not event.pressed:
			set_process(false)
			knob.position = stick_center

func _process(_delta: float) -> void:
	if pressing:
		knob.global_position = get_global_mouse_position()
		knob.position = stick_center + (knob.position - stick_center).limit_length(max_length)
		
		if is_processing():
			joystick_direction.emit(get_direction_8(), get_direction_4(), get_direction())
			joystick_angle.emit(get_angle_8(), get_angle_4(), get_angle())

func get_direction() -> Vector2:
	if check_threshold():
		var dir: Vector2 = knob.position - stick_center
		return dir.normalized()
	return Vector2.ZERO

func get_direction_8() -> Vector2:
	if check_threshold():
		match get_angle_8():
			angles_8.UP:                            # angle = 6
				return Vector2.UP
			angles_8.UP_RIGHT:                      # angle = 7
				return Vector2.UP + Vector2.RIGHT
			angles_8.RIGHT:                         # angle = 0
				return Vector2.RIGHT
			angles_8.DOWN_RIGHT:                    # angle = 1
				return Vector2.DOWN + Vector2.RIGHT
			angles_8.DOWN:                          # angle = 2
				return Vector2.DOWN
			angles_8.DOWN_LEFT:                     # angle = 3
				return Vector2.DOWN + Vector2.LEFT
			angles_8.LEFT:                          # angle = 4
				return Vector2.LEFT
			angles_8.UP_LEFT:                       # angle = 5
				return Vector2.UP + Vector2.LEFT
	return Vector2.ZERO

func get_direction_4() -> Vector2:
	if check_threshold():
		match get_angle_4():
			angles_4.UP:                            # angle = 3
				return Vector2.UP
			angles_4.RIGHT:                         # angle = 0
				return Vector2.RIGHT
			angles_4.DOWN:                          # angle = 1
				return Vector2.DOWN
			angles_4.LEFT:                          # angle = 2
				return Vector2.LEFT
	return Vector2.ZERO

func get_angle() -> float:
	if check_threshold():
		var dir: Vector2 = knob.position - stick_center
		return dir.angle()
	return angles_8.NONE

func get_angle_8() -> int:
	if check_threshold():
		var dir: Vector2 = knob.position - stick_center
		var angle = snappedf(dir.angle(), PI/4) / (PI/4)
		angle = wrapi(int(angle), 0, 8)
		return angle
	return angles_8.NONE

func get_angle_4() -> int:
	if check_threshold():
		var dir: Vector2 = knob.position - stick_center
		var angle = snappedf(dir.angle(), PI/2) / (PI/2)
		angle = wrapi(int(angle), 0, 4)
		return angle
	return angles_4.NONE

func check_threshold() -> bool:
	return knob.position.distance_to(stick_center) > threshold

func _on_pressed() -> void:
	pressing = true

func _on_released() -> void:
	pressing = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED and recenter_on_pause:
		knob.position = stick_center
