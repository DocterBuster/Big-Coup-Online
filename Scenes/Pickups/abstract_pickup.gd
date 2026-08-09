class_name AbstractPickup extends RigidBody3D


var player_holding_id : int = 1 ## Set to server by default 
var _player_holding : Player = null
@export var is_held : bool = false

## How far away should the pickup be held
const pickup_distance : Vector3 = Vector3(0, 0, -1.5)
const pickup_lerp : float = 0.3


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	if is_held and _player_holding:
		var camera_transform = _player_holding.camera.global_transform
		self.global_transform = self.global_transform.interpolate_with(camera_transform.translated_local(pickup_distance), pickup_lerp)




## Network Calls
@rpc("any_peer", "call_local", "reliable")
func update_state(player_id : String) -> void:
	
	
	print("--------")
	if is_held:
		## Return Auth to host
		player_holding_id = 1
		_player_holding.pickup_in_hand = null
		_player_holding = null
		is_held = false
		self.freeze = false

	else:
		## Give auth to user holding object 
		player_holding_id = int(player_id)
		_player_holding = get_tree().current_scene.find_child(player_id, true, false)
		_player_holding.pickup_in_hand = self
		self.freeze = true
		is_held = true
	
	_set_authority_rpc(player_holding_id)

func _set_authority_rpc(new_peer_id: int) -> void:
	print("Client " + str(multiplayer.get_unique_id()), " Setting pickup to " + str(new_peer_id))
	set_multiplayer_authority(new_peer_id)
