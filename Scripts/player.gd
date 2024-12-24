class_name Player
extends CharacterBody2D

# -- Vertical --
const gravity : float = 900.0
const jump_speed : float = -140.0
const max_fall : float = 450.0
const half_grav_threshold : float = 40.0

var var_jump_time: float = 0.12
var var_jump_timer: float = 0.0
var current_jump_force: float = 0.0
var time_in_air := 0.0


# -- Horizontal --
const max_run: float = 90.0
const run_accel: float = 1000.0
const run_reduce: float = 400.0
const air_mult: float = 0.65

func _physics_process(delta: float) -> void:
    handle_vertical(delta)
    handle_horizontal(delta)

    move_and_slide()


func handle_horizontal(delta: float) -> void:
    var move_x := Input.get_action_strength("right") - Input.get_action_strength("left")

    var mult:float = 1.0
    if not is_on_floor():
        mult = air_mult

    if abs(velocity.x) > max_run and sign(velocity.x) == move_x:
        velocity.x = move_toward(velocity.x, max_run * move_x, run_reduce * mult * delta)
    else:
        velocity.x = move_toward(velocity.x, max_run * move_x, run_accel * mult * delta)


func handle_vertical(delta: float) -> void:
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
