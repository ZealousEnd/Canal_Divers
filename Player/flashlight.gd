extends Node3D
# flashlight activity ; 0 for off 1 for on
var flashlight_state = 0
func _enter_tree() -> void:
	$SpotLight3D.light_energy = 0;

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("flashlight"):
		if flashlight_state == 0:
			$SpotLight3D.light_energy = 9
			flashlight_state = 1
			print("flashlight is on")
		elif flashlight_state == 1:
			$SpotLight3D.light_energy = 0
			flashlight_state = 0
			print("flashlight is off")
