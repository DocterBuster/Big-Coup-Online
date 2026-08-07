class_name PickupComponent extends Node

var player_holding : Player = null
var object : RigidBody3D
var is_held : bool = false

## How far away should the pickup be held
const pickup_distance : Vector3 = Vector3(0, 0, -1)
const pickup_lerp : float = 0.3


func _physics_process(delta: float) -> void:
	if is_held and player_holding:
		var camera_transform = player_holding.camera.global_transform
		object.global_transform = object.global_transform.interpolate_with(camera_transform.translated_local(pickup_distance), pickup_lerp)

func update_state(interactable : RigidBody3D, player : Player) -> void:
	if is_held:
		player_holding = null
		is_held = false
		object = null
		interactable.freeze = false
	else:
		player_holding = player
		object = interactable
		interactable.freeze = true
		is_held = true
