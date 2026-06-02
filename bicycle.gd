extends VehicleBody3D

var horse_power = 200
var accel_speed = 20

var steer_angle = deg_to_rad(20)
var steer_speed = 2

var brake_power = 40
var brake_speed = 40

var grounded = false
var steer_lean = false

const stability_spring = 150.0
const stability_damping = 15.0

func _physics_process(delta: float) -> void:
	if $camera/SpringArm3D/Camera3D.current == true:
		
		#throttle
		var throt_input = Input.get_axis("backward", "forward")
		engine_force = lerp(engine_force, throt_input * horse_power, accel_speed*delta)
		
		#steering
		var steer_input = Input.get_axis("right", "left")
		steering = lerp_angle(steering, steer_input * steer_angle, steer_speed*delta)
		
		#braking
		var brake_input = Input.get_action_strength("jump")
		brake = brake_input*brake_power
		

func _integrate_forces(state):
	if $camera/SpringArm3D/Camera3D.current == true:
		var forward_speed = -(transform.basis.inverse() * linear_velocity).z 
		
		#ground check
		if $front.is_in_contact() || $back.is_in_contact():
			grounded = true
		else:
			grounded = false
			
		if forward_speed >= 15:
			steer_lean = true
		elif forward_speed < 13:
			steer_lean = false
			
		if grounded:
			var current_tilt = transform.basis.z.y
			
			var local_ang_vel = transform.basis.inverse() * state.angular_velocity
			var roll_velocity = local_ang_vel.z
			
			var target_lean = 0.0
			if steer_lean: 
				var steer_input = Input.get_axis("right", "left")
				target_lean = steer_input * 0.15
			
			var tilt_error = current_tilt - target_lean
			var correction_torque = (tilt_error * stability_spring) - (roll_velocity * stability_damping)
			
			state.apply_torque(transform.basis.z * correction_torque)
		else:
			var current_tilt = transform.basis.z.y
			state.apply_torque(transform.basis.z * current_tilt * 30.0)
