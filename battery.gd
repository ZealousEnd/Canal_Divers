extends StaticBody3D


var interact_type = "battery"


func interact(user: Node3D):
	var flashlight = user.get_node_or_null("head/flashlight") as Flashlight
	
	if flashlight != null:
		flashlight.recharge(1000.0)
		print("Battery power added")
		queue_free()
		
	else:
		print("Could not find flashlight on player!")
