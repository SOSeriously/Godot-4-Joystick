@tool
class_name JoyStickInput
extends TouchScreenButton
## A general joystick for normal and grid based movement.

## Emitted when the knob is dragged.[br]
## Use [code]direction_8[/code] for 8 directional movement.[br]
## Use [code]direction_4[/code] for 4 directional movement.[br]
## Use [code]direction[/code] for general movement.
signal joystick_direction(direction_8: Vector2, direction_4: Vector2, direction: Vector2)
## Emitted when the knob is dragged.[br]
## Use [code]angle_8[/code] to get the angle in 8 directional movement.[br]
## Use [code]angle_4[/code] to get the angle in 4 directional movement.[br]
## Use [code]direction[/code] to get the angle in general movement.
signal joystick_angle(angle_8: int, angle_4: int, angle: float)

enum angles_8 { ## Enum used for 8 directional movement.
	NONE = -1, ## No input.
	RIGHT = 0, ## Move to the RIGHT.
	DOWN_RIGHT = 1,## Move DOWN and RIGHT.
	DOWN = 2, ## Move DOWN.
	DOWN_LEFT = 3, ## Move DOWN and LEFT.
	LEFT = 4, ## Move LEFT.
	UP_LEFT = 5, ## Move UP and LEFT.
	UP = 6, ## Move UP.
	UP_RIGHT = 7, ## Move UP and RIGHT.
}

enum angles_4 { ## Enum used for 4 directional movement.
	NONE = -1, ## No input.
	RIGHT = 0, ## Move RIGHT.
	DOWN = 1, ## Move DOWN.
	LEFT = 2, ## Move LEFT.
	UP = 3, ## Move UP.
}

@export var deadzone: float = 10 ## The knob's distance from the center must be greater than the [code]deadzone[/code] before the direction and angle are updated.
@export var recenter_on_pause: bool = true ## Recenters the knob when get_tree().paused = true.
@export_category("Knob")
@export var knob: Sprite2D ## The joystick's knob.
@export var knob_texture: Texture2D: ## The knob's texture.
	set(value):
		knob_texture = value
		if is_instance_valid(knob):
			knob.texture = value
	get(): return knob_texture

var _joystick_radius: int = 0 ## The radius of the joystick's shape.
var _stick_center: Vector2 = Vector2.ZERO ## The knob's center position.
var _pressing: bool = false ## Set when the joystick is pressed.

func _ready() -> void:
	pressed.connect(_on_pressed)
	released.connect(_on_released)
	
	_joystick_radius = shape.radius
	_stick_center = texture_normal.get_size() / 2
	set_process(false)
	
	if not knob:
		knob =  Sprite2D.new()
		knob.position = _stick_center
		add_child(knob)
	
	if knob_texture:
		knob.texture = knob_texture

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			set_process(true)
		elif not event.pressed:
			set_process(false)
			knob.position = _stick_center

func _process(_delta: float) -> void:
	if _pressing:
		knob.global_position = get_global_mouse_position()
		knob.position = _stick_center + (knob.position - _stick_center).limit_length(_joystick_radius)
		
		if is_processing():
			joystick_direction.emit(get_direction_8(), get_direction_4(), get_direction())
			joystick_angle.emit(get_angle_8(), get_angle_4(), get_angle())

## Get the general direction for general movement.
func get_direction() -> Vector2:
	if check_deadzone():
		var dir: Vector2 = knob.position - _stick_center
		return dir.normalized()
	return Vector2.ZERO

## Get the direction for 8 directional movement.
func get_direction_8() -> Vector2:
	if check_deadzone():
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

## Get the direction for 4 directional movement.
func get_direction_4() -> Vector2:
	if check_deadzone():
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

## Get the angle for general movement.[br]
## get_angle() is the same as [code](knob.position - _stick_center).angle()[/code]
func get_angle() -> float:
	if check_deadzone():
		var dir: Vector2 = knob.position - _stick_center
		return dir.angle()
	return angles_8.NONE

## Get the angle for 8 directional movement.
func get_angle_8() -> int:
	if check_deadzone():
		var dir: Vector2 = knob.position - _stick_center
		var angle = snappedf(dir.angle(), PI/4) / (PI/4)
		angle = wrapi(int(angle), 0, 8)
		return angle
	return angles_8.NONE

## Get the angle for 4 directional movement.
func get_angle_4() -> int:
	if check_deadzone():
		var dir: Vector2 = knob.position - _stick_center
		var angle = snappedf(dir.angle(), PI/2) / (PI/2)
		angle = wrapi(int(angle), 0, 4)
		return angle
	return angles_4.NONE

## Check if the knob's distance from the center is greater than the [code]deadzone[/code].
func check_deadzone() -> bool:
	return knob.position.distance_to(_stick_center) > deadzone

func _on_pressed() -> void:
	_pressing = true

func _on_released() -> void:
	_pressing = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED and recenter_on_pause:
		knob.position = _stick_center
