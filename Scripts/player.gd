class_name Player
extends CharacterBody2D

# -- States --
enum Dirs {
    Left,
    Right,
    Toward,
    Away,
}
var jumping := false
var walking := false
var climbing := false
var direction: Dictionary = {
    Dirs.Toward: Dirs.Left,
    Dirs.Away: Dirs.Right
}
var dir_vec: Vector2i

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
const climb_speed := 50
const climb_cooldown := 0.1

var current_climb_cooldown := 0.0

func _physics_process(delta: float) -> void:
    ready_inputs()
    handle_vertical(delta)
    handle_horizontal(delta)
    handle_climbing(delta)

    move_and_slide()


func ready_inputs() -> void:
    dir_vec.x = roundi(Input.get_axis(&"left", &"right"))
    dir_vec.y = roundi(Input.get_axis(&"up", &"down"))

func handle_climbing(delta: float) -> void:
    current_climb_cooldown -= delta
    
    if current_climb_cooldown > 0.0:
        return
    
    climbing = get_facing_detector().has_overlapping_bodies() and Input.is_action_pressed(&"climb")
    if climbing:
        velocity.y = dir_vec.y * climb_speed
        if Input.is_action_just_pressed(&"jump"):
            climbing = false
            jump()
            current_climb_cooldown = climb_cooldown
            
            #if dir_vec.x != 0:
            var mult := 1 if direction[Dirs.Toward] == Dirs.Left else -1
            if !(dir_vec.y == -1 and dir_vec.x == 0):
                velocity.x += 100 * mult
            
            #velocity.x += %SideCollision.position.x * -30
            
    print(climbing)


func handle_horizontal(delta: float) -> void:
    if climbing:
        return

    if dir_vec.x < 0:
        face_direction(Dirs.Left)
    elif dir_vec.x > 0:
        face_direction(Dirs.Right)

    var mult := 1.0
    if not is_on_floor():
        mult = air_mult

    if abs(velocity.x) > max_run and sign(velocity.x) == dir_vec.x:
        velocity.x = move_toward(velocity.x, max_run * dir_vec.x, run_reduce * mult * delta)
    else:
        velocity.x = move_toward(velocity.x, max_run * dir_vec.x, run_accel * mult * delta)

    walking = velocity.x != 0


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
        #hdjfkjshvsoivj
        jump()


func jump() -> void:
    current_jump_force = jump_speed
    velocity.y = current_jump_force
    var_jump_timer = var_jump_time
    jumping = true
    for detector: Area2D in [$LeftDetector, $RightDetector]:
        pass

func face_direction(dir: Dirs) -> void:
    var opposite_dir := Dirs.Left if dir == Dirs.Right else Dirs.Right
    #%SideCollision.position = climbing_right_pos if dir == Dirs.Right else climbing_left_pos
    direction = {
        Dirs.Toward: dir,
        Dirs.Away: opposite_dir,
    }

func get_facing_detector() -> Area2D:
    if direction[Dirs.Toward] == Dirs.Left:
        return $LeftDetector
    else:
        return $RightDetector
