extends CharacterBody3D


@export var max_speed: float = 20.0
@export var acceleration: float = 30.0
@export var friction: float = 15.0
@export var brake_force: float = 50.0

@export var steer_speed: float = 4.0      # How fast the bike changes direction
@export var slide_factor: float = 5.0     # Higher = sharp/snappy, Lower = slidy/drifty

@export var mesh_node: Node3D             # Menu avaliable in inspector
@export var max_lean_angle: float = 30.0  # Max degrees to lean into a turn
@export var lean_speed: float = 8.0       # How fast the mesh tilts

@export var interact_type = "bike"

var current_speed: float = 0.0
var steer_angle: float = 0.0
var is_driving: bool = false 



func _physics_process(delta: float) -> void:
	#GET INPUT
	var throt_input = Input.get_axis("backward", "forward") # Forward is usually positive in 3D custom code
	var steer_input = Input.get_axis("right", "left")       # Left is positive rotation around Y axis
	var is_braking = Input.is_action_pressed("jump")

	#HANDLE ACCELERATION & BRAKING
	if is_braking:
		current_speed = move_toward(current_speed, 0.0, brake_force * delta)
	elif throt_input != 0:
		current_speed = move_toward(current_speed, throt_input * max_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, friction * delta)

	#SHARP, FLUID STEERING
	# Only allow steering if we are actually moving
	if abs(current_speed) > 1.0:
		# Multiplier makes steering sharper at lower speeds, smoother at high speeds
		var speed_ratio = current_speed / max_speed
		rotate_y(steer_input * steer_speed * speed_ratio * delta)

	#THE DRIFT / SLIDING MECHANIC (The Magic Step)
	# Instead of instantly moving where the bike is pointing, we smoothly interpolate (lerp)
	# our actual velocity toward our forward direction. 
	var forward_dir = -global_transform.basis.z # In Godot, -Z is forward
	var target_velocity = forward_dir * current_speed
	
	# slide_factor controls how fast the velocity catches up to the rotation.
	# Low slide_factor = back end slides out. High slide_factor = rails on a track.
	velocity.x = lerp(velocity.x, target_velocity.x, slide_factor * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, slide_factor * delta)
	
	# Handle gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0

	# Apply the movement
	move_and_slide()

	#VISUAL LEANING
	if mesh_node:
		# Calculate target lean based on steering input and forward movement
		var target_lean = 0.0
		if abs(current_speed) > 1.0:
			target_lean = steer_input * deg_to_rad(max_lean_angle)
		
		# Smoothly blend the current lean toward the target lean
		mesh_node.rotation.z = lerp_angle(mesh_node.rotation.z, target_lean, lean_speed * delta)
