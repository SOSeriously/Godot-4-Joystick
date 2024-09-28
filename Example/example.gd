extends Node2D

const SPEED = 200

enum direction_type { DIRECTION_8, DIRECTION_4, DIRECTION }
enum angle_type { ANGLE_8, ANGLE_4, ANGLE }

@onready var joy_stick_direction: JoyStickInput = $JoyStickDirection
@onready var joy_stick_angle: JoyStickInput = $JoyStickAngle
@onready var character_body_2d: CharacterBody2D = $CharacterBody2D

@export var move_and_rotate: bool = false
@export var select_direction_type: direction_type = direction_type.DIRECTION
@export var select_angle_type: angle_type = angle_type.ANGLE


func _on_joy_stick_direction_joystick_direction(direction_8: Vector2, direction_4: Vector2, direction: Vector2) -> void:
	match select_direction_type:
		direction_type.DIRECTION_8: character_body_2d.velocity = SPEED * direction_8
		direction_type.DIRECTION_4: character_body_2d.velocity = SPEED * direction_4
		direction_type.DIRECTION: character_body_2d.velocity = SPEED * direction
	
	if move_and_rotate:
		match select_angle_type:
			angle_type.ANGLE_8: character_body_2d.rotation = joy_stick_direction.get_angle_8()
			angle_type.ANGLE_4: character_body_2d.rotation = joy_stick_direction.get_angle_4()
			angle_type.ANGLE: character_body_2d.rotation = joy_stick_direction.get_angle()
	
	character_body_2d.move_and_slide()


func _on_joy_stick_angle_joystick_angle(angle_8: int, angle_4: int, angle: float) -> void:
	match select_angle_type:
		angle_type.ANGLE_8: character_body_2d.rotation = angle_8
		angle_type.ANGLE_4: character_body_2d.rotation = angle_4
		angle_type.ANGLE: character_body_2d.rotation = angle
