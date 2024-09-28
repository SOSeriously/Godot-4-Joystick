# Godot 4 Joystick
 
A joystick for general or grid based movement.<br />
The joystick supports 8 directional and 4 directional movement.

# Add to Project

- Copy the Joystick folder into your exiting project
- Add the joystick as a scene or a node

![Screenshot 2024-09-28 183934](https://github.com/user-attachments/assets/620a13d5-a07b-4728-96f6-c6db2dc5b7de)

# How to Use

Signals:<br />

joystick_direction(direction_8: Vector2, direction_4: Vector2, direction: Vector2)<br />

direction_8 is for 8 directional movement<br />
direction_4 is for 4 directional movement<br />
direction is for general movement<br />

joystick_angle(angle_8: int, angle_4: int, angle: float)<br />

angle_8 to get the angle in 8 directional movement<br />
angle_4 to get the angle in 4 directional movement<br />
angle to get the angle in general movement<br />

Methods:<br />

get_direction_8()<br />
Get the direction for 8 directional movement<br />

get_direction_4()<br />
Get the direction for 4 directional movement<br />

get_direction()<br />
Get the general direction for general movement<br />
