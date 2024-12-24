class_name Player
extends CharacterBody2D

@export var gravity : float = 900.0
@export var jump_speed : float = -140.0
@export var max_fall : float = 450.0
@export var half_grav_threshold : float = 40.0
@export var var_jump_time : float = 0.2

var var_jump_timer : float = 0.0
var current_jump_force : float = 0.0

var time_in_air := 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		var mult := 1.0
		if abs(velocity.y) < half_grav_threshold and Input.is_action_pressed("jump"):
			mult = 0.5

		velocity.y = min(velocity.y + gravity * mult * delta, max_fall)
		time_in_air += delta
		print(time_in_air)

		if Input.is_action_pressed("jump"):
			if var_jump_timer > 0:
				var_jump_timer -= delta
				velocity.y += (current_jump_force - velocity.y) * delta * 10
		else:
			var_jump_timer = 0.0
	else:
		var_jump_timer = 0.0

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		current_jump_force = jump_speed
		velocity.y = current_jump_force
		var_jump_timer = var_jump_time
		time_in_air = 0

	move_and_slide()
