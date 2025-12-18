extends CharacterBody3D

@onready var camera_mount: Node3D = $"Camera Mount"
@onready var animation_player: AnimationPlayer = $Model/mixamo_base/AnimationPlayer
@onready var model: Node3D = $Model

var SPEED : float = 3.1
var jump_speed : float = 4.5

var waling_speed : float = 3.0
var sprint_speed : float = 5.0

var is_sprinting : bool = false
var is_anim_locked : bool = false

@export var sensitivity_horz : float = 0.5
@export var sensitivity_vert : float = 0.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	# sets the mouse to captured (meaning we can listen for mouse input) when the mouse clicks the screen
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# when the escape key is hit it makes the mouse visible again
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x*sensitivity_horz))
			model.rotate_y(deg_to_rad(event.relative.x*sensitivity_horz))
			camera_mount.rotate_x(deg_to_rad(-event.relative.y*sensitivity_vert))
			camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	
	if !animation_player.is_playing():
		is_anim_locked = false
	
	if Input.is_action_just_pressed("kick"):
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_anim_locked = true
		
	
	if Input.is_action_pressed("sprint"):
		SPEED = sprint_speed
		is_sprinting = true
	else:
		SPEED = waling_speed
		is_sprinting = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_anim_locked: 
			if is_sprinting:
				if animation_player.current_animation != "running":
					animation_player.play("running")
			else:
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
			
			model.look_at(position + direction)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_anim_locked: 
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if !is_anim_locked:
		move_and_slide()
