class_name Player
extends CharacterBody2D

# -- States --
var jumping := false
var walking := false
var climbing := false

# -- Vertical --
const gravity := 900.0
const jump_speed := -140.0
const max_fall := 450.0
const half_grav_threshold := 40.0

var var_jump_time := 0.12
var var_jump_timer := 0.0
var current_jump_force := 0.0

# -- Horizontal --
const max_run := 90.0
const run_accel := 1000.0
const run_reduce := 400.0
const air_mult := 0.65

# -- Climbing --
const climbing_left_pos := Vector2(-4, 0)
const climbing_right_pos := Vector2(4, 0)
const climb_speed := 50

func _physics_process(delta: float) -> void:
    handle_vertical(delta)
    handle_horizontal(delta)
    handle_climbing(delta)

    move_and_slide()


func handle_climbing(_delta: float) -> void:
    if !climbing:
        var dir := Input.get_axis(&"right", &"left")
        if dir > 0:
            %SideCollision.position = climbing_left_pos
        elif dir < 0:
            %SideCollision.position = climbing_right_pos

    climbing = %SideDetector.has_overlapping_bodies() and Input.is_action_pressed(&"climb")
    if climbing:
        var dir := Input.get_axis(&"up", &"down") * climb_speed
        velocity.y = dir
    print(climbing)


func handle_horizontal(delta: float) -> void:
    if climbing:
        return

    var dir := Input.get_axis(&"left", &"right")

    var mult := 1.0
    if not is_on_floor():
        mult = air_mult

    if abs(velocity.x) > max_run and sign(velocity.x) == dir:
        velocity.x = move_toward(velocity.x, max_run * dir, run_reduce * mult * delta)
    else:
        velocity.x = move_toward(velocity.x, max_run * dir, run_accel * mult * delta)


func handle_vertical(delta: float) -> void:
    if climbing:
        return

    if not is_on_floor():
        var mult := 1.0
        if abs(velocity.y) < half_grav_threshold and Input.is_action_pressed(&"jump"):
            mult = 0.5

        velocity.y = min(velocity.y + gravity * mult * delta, max_fall)

        if Input.is_action_pressed(&"jump"):
            if var_jump_timer > 0:
                var_jump_timer -= delta
                velocity.y += (current_jump_force - velocity.y) * delta * 10
        else:
            var_jump_timer = 0.0
    else:
        var_jump_timer = 0.0
        jumping = false

    if is_on_floor() and Input.is_action_just_pressed(&"jump"):
        current_jump_force = jump_speed
        velocity.y = current_jump_force
        var_jump_timer = var_jump_time
        jumping = true
