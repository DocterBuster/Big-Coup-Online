class_name Player extends CharacterBody3D


const WALK_SPEED := 5
const JUMP_SPEED := 5


@onready var camera : Camera3D = $Head/Camera3D
@onready var head: Node3D = $Head
@export var mouse_sensistivity = 0.5

## What # player is this? (Not multiplayer ID!) 
@export var player_number : int = -1 
## If control should be locked (Debug testing mainly) 
var lock_control : bool = false
## The pickup in this player's hand
var pickup_in_hand : AbstractPickup = null


func _enter_tree() -> void:
	set_multiplayer_authority(int(name.to_int()))


func _input(event):
	if !is_multiplayer_authority() or lock_control:
		return
	
	#Camera movement 
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * mouse_sensistivity)
		head.rotate_x(deg_to_rad(-event.relative.y) * mouse_sensistivity)
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-60),deg_to_rad(50))
	


func _physics_process(delta: float) -> void:
	camera.current = is_multiplayer_authority()
	
	if(Input.is_action_just_pressed("Pause")):
		lock_control = !lock_control
	
	

	
	if !is_multiplayer_authority() or lock_control:
		return
	
	
	if(Input.is_action_just_pressed("DEBUG1")):
		print("------ Calling RPC Debug! -------")
		rpc_debug.rpc()
	
	
	#Movement code that is rotated to be relative to the camera position 
	var movement = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = Vector3(movement.x, 0, movement.y).rotated(Vector3.UP, head.global_rotation.y).normalized()
	
	
	if(movement):
		velocity.x = direction.x * WALK_SPEED
		velocity.z = direction.z * WALK_SPEED
	else:
		velocity.x = 0
		velocity.z = 0
	
	#Jumping
	if(Input.is_action_just_pressed("Jump") and is_on_floor()):
		velocity.y = JUMP_SPEED
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	## Check for Interact
	if(Input.is_action_just_pressed("Interact")):
		
		## Drop a held pickup 
		if(pickup_in_hand):
			pickup_in_hand.player_drop.rpc()
		else:
			var colider = $Head/InteractCast.get_collider()
			if(colider):
				## Check if we can pick this up! 
				if(colider is AbstractPickup):
					if(not pickup_in_hand and not colider.is_held):
						colider.player_pickup.rpc(self.name)
	
	move_and_slide()



@rpc("call_local", "reliable")
func rpc_debug():
	print("rpc called for: "+ str(multiplayer.get_unique_id()))
