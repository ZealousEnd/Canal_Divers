extends Node3D

@onready var spring_arm: SpringArm3D = $"3rdpersoncam/SpringArm3D"
@onready var camera_3d: Camera3D = $SpringArm3D/Camera3D

var camlock = false

func _ready() -> void:
	set_process_unhandled_input(false)
	set_physics_process(false)
	camera_3d.current = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$SpringArm3D.add_excluded_object(self)

func _input(event):
	
	#toggle the camera
	if Input.is_action_just_pressed("camera"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
	
	#move camera
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion && camlock == false:
			rotation_degrees.x = clamp(rotation_degrees.x-event.relative.y*0.1, -70, 70)
			rotation_degrees.y -= event.relative.x*0.1

func _physics_process(_delta: float) -> void:
	
	#toggle camera lock
	if Input.is_action_just_pressed("interact"):
		if camlock == false:
			camlock = true
		else:
			camlock = false
	
	#lock camera
	if camlock == true:
		rotation.x = lerp_angle(rotation.x, 0, 0.1)
		rotation.y = lerp_angle(rotation.y, 0, 0.1)
		
func activate_camera() -> void:
	set_process_unhandled_input(true)
	set_physics_process(true)
	camera_3d.make_current()
	
	
