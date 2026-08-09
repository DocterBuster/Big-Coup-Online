class_name AbstractPickup extends RigidBody3D


var player_holding_id
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


@rpc("any_peer", "call_local", "reliable")
func update_state(player_id : String) -> void:
	
	#_set_authority_rpc(int(player_id))
	print("--------")

	if is_held:
		_set_authority_rpc(1) ## Return Auth to host
		player_holding_id = "1"
		_player_holding = null
		is_held = false
		self.freeze = false

	else:
		_set_authority_rpc(int(player_id)) ## Give Auth to user 
		player_holding_id = player_id
		_player_holding = get_tree().current_scene.find_child(player_id, true, false)
		self.freeze = true
		is_held = true



func _set_authority_rpc(new_peer_id: int) -> void:
	
	if(multiplayer.is_server()):
		pass
	
	print("Client " + str(multiplayer.get_unique_id()), " Setting pickup to " + str(new_peer_id))
	set_multiplayer_authority(new_peer_id)
	$MultiplayerSynchronizer.set_multiplayer_authority(new_peer_id)
