extends Node3D


const PLAYER_CONTROLLER = preload("res://Scenes/Player.tscn")
var players: Array[CharacterBody3D]
@onready var spawn_point = $PLAYER_SPAWN
@onready var multiplayer_ui = $ConnectionMenu

func _on_host_pressed():
	
	NetworkManager.host_lobby()
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game!")
			add_player(pid)
	)
	add_player(multiplayer.get_unique_id())
	multiplayer_ui.hide()


func _on_join_pressed():
	
	match NetworkManager.backend_type:
		NetworkManager.BACKEND_TYPES.LAN:
			NetworkManager.join_lan_lobby()
		NetworkManager.BACKEND_TYPES.STEAM:
			pass
	
	add_player(multiplayer.get_unique_id())
	multiplayer_ui.hide()


func add_player(pid):
	var player : CharacterBody3D = PLAYER_CONTROLLER.instantiate()
	player.name = str(pid)
	player.position = spawn_point.position
	$PlayerSpawns/PlayerPuppets.add_child(player)
