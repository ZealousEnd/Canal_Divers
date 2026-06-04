extends VehicleBody3D

@export var horse_power: float = 600.0        
@export var steer_angle: float = 45.0        
@export var steering_speed: float = 15.0     

func _physics_process(delta: float) -> void:
	if not $camera/SpringArm3D/Camera3D.current:
		return

	# 1. RAW UNCLAMPED STEERING (A/D) - Moved up so we can use steer_input for the engine boost
	var steer_input = Input.get_axis("right", "left")
	var max_steer_radians = steer_input * deg_to_rad(steer_angle)
	steering = lerp_angle(steering, max_steer_radians, steering_speed * delta)

	# 2. THROTTLE (W/S) with Turn Boost
	var throt_input = Input.get_axis("forward", "backward")
	
	# If we are steering (steer_input isn't 0) and trying to go forward
	var current_hp = horse_power
	var speed_limit = 20.0
	
	if abs(steer_input) > 0.1 and throt_input < 0: # Note: 'forward' is usually negative in get_axis
		current_hp += 400.0  # Give it an extra 400 HP in turns
		speed_limit = 28.0   # Raise the speed limit so the boost actually works!

	engine_force = throt_input * current_hp

	# 3. BRAKING (Spacebar)
	if Input.is_action_pressed("jump"):
		brake = 150.0  
	else:
		brake = 0.0

	# 4. VELOCITY LIMITER (Using our dynamic speed limit)
	var current_speed = linear_velocity.length()
	if current_speed > speed_limit:
		linear_velocity = linear_velocity.normalized() * speed_limit

	# 5. HARD RE-STABILIZATION
	rotation.x = 0.0
	rotation.z = 0.0
