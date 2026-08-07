class_name AbstractPickup extends RigidBody3D


var player_holding : Player = null
@export var is_held : bool = false

## How far away should the pickup be held
const pickup_distance : Vector3 = Vector3(0, 0, -1.5)
const pickup_lerp : float = 0.3


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	if is_held and player_holding:
		var camera_transform = player_holding.camera.global_transform
		self.global_transform = self.global_transform.interpolate_with(camera_transform.translated_local(pickup_distance), pickup_lerp)


@rpc("call_remote", "authority", "reliable")
func update_state(player : Player) -> void:
	if is_held:
		player_holding = null
		is_held = false
		self.freeze = false
		_set_authority_rpc(1) ## Return Auth to host
	else:
		player_holding = player
		self.freeze = true
		is_held = true
		_set_authority_rpc(int(player.name)) ## Give Auth to user 


@rpc("call_remote", "authority", "reliable")
func _set_authority_rpc(new_peer_id: int) -> void:
	print(new_peer_id)
	set_multiplayer_authority(new_peer_id)
	$MultiplayerSynchronizer.set_multiplayer_authority(new_peer_id)
