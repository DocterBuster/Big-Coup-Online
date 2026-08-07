class_name AbstractPickup extends RigidBody3D


var player_holding : Player = null
@export var is_held : bool = false

## How far away should the pickup be held
const pickup_distance : Vector3 = Vector3(0, 0, -1.5)
const pickup_lerp : float = 0.3


func _physics_process(delta: float) -> void:
	if is_held and player_holding:
		var camera_transform = player_holding.camera.global_transform
		self.global_transform = self.global_transform.interpolate_with(camera_transform.translated_local(pickup_distance), pickup_lerp)

func update_state(player : Player) -> void:
	if is_held:
		player_holding = null
		is_held = false
		self.gravity_scale = 1.0
	else:
		player_holding = player
		self.gravity_scale = 0.0
		is_held = true
