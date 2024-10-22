extends CharacterBody3D
@onready var camera_mount = $camera_mount
@onready var model : Node3D = $visuals/Sketchfab_Scene
@onready var visuals: Node3D = $visuals
@onready var animation_player: AnimationPlayer = $"visuals/Sketchfab_Scene/Sketchfab_model/4d9d2dbd36d84c0e89f35a79c3b6ee13_fbx/RootNode/Armature/Object_4/GeneralSkeleton/AnimationPlayer"



var SPEED = 3.0
const JUMP_VELOCITY = 4.5

var walking_speed = 3.0
var running_speed = 5.0
var running = false
var is_locked = false

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*sens_horizontal))
		model.rotate_y(deg_to_rad(event.relative.x*sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y*sens_vertical))

func _physics_process(delta: float) -> void:
	
	if !animation_player.is_playing():
		is_locked = false
	
	if Input.is_action_just_pressed("kick"):
		if animation_player.current_animation != "mixamo_base/kick":
			animation_player.play("mixamo_base/kick")
			is_locked = true

	if Input.is_action_pressed("run"):
			SPEED = running_speed
			running = true
	else:
			SPEED = walking_speed
			running = false
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if running :
				if animation_player.current_animation != "mixamo_base/running":
						animation_player.play("mixamo_base/running")
			else:
				if animation_player.current_animation != "mixamo_base/walking":
					animation_player.play("mixamo_base/walking")
			model.look_at(global_position + -direction)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if animation_player.current_animation != "mixamo_base/idle":
				animation_player.play("mixamo_base/idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	if !is_locked:
		move_and_slide()
