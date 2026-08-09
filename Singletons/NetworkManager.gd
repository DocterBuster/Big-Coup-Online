## Most Networking code should go here! 
extends Node

## When this client creates a lobby 
signal host_created()
## When this client joins a lobby 
signal joined_lobby()

## The peer of the client 
var peer : MultiplayerPeer 


## Backend Selection
enum BACKEND_TYPES {STEAM, LAN}
var backend_type : BACKEND_TYPES = BACKEND_TYPES.LAN

const MAX_MEMBERS := 4

## Lan Info
const LAN_PORT = 25565
## Steam Info
const STEAM_LOBBY_TYPE := Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY

const PLAYER_COLORS = [Color(0.0, 0.0, 1.0, 1.0), Color(1.0, 0.0, 0.0, 1.0), Color(0.0, 1.0, 0.0, 1.0), Color(1.0, 1.0, 0.0, 1.0), Color(1.0, 0.0, 1.0, 1.0), Color(0.0, 1.0, 1.0, 1.0), Color(1.0, 0.533, 0.0, 1.0), Color(1.0, 1.0, 1.0, 1.0)]

func _ready() -> void:
	
	## Setup Steam singals for Steam Backend
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(on_steam_lobby_created)
	Steam.lobby_joined.connect(on_steam_lobby_joined)
	Steam.join_requested.connect(on_steam_join_requested)



## Hosts a Lobby from either backend 
func host_lobby() -> void:
	match backend_type:
		BACKEND_TYPES.STEAM:
			Steam.createLobby(STEAM_LOBBY_TYPE, MAX_MEMBERS)
		BACKEND_TYPES.LAN:
			peer = ENetMultiplayerPeer.new()
			peer.create_server(LAN_PORT, MAX_MEMBERS)
			multiplayer.multiplayer_peer = peer
			host_created.emit()


#region LAN Pipeline 
func join_lan_lobby():
	match backend_type:
		BACKEND_TYPES.LAN:
			peer = ENetMultiplayerPeer.new()
			peer.create_client("localhost", LAN_PORT)
			multiplayer.multiplayer_peer = peer
			joined_lobby.emit()
#endregion



#region SteamAPI

# Called after creating a lobby locally
func on_steam_lobby_created(connect: int, lobby_id: int) -> void:
	match backend_type:
		BACKEND_TYPES.STEAM:
			# We created the lobby, so we act as server host
			if connect == Steam.RESULT_OK:
				peer = SteamMultiplayerPeer.new()
				peer.server_relay = true
				peer.create_host()
				multiplayer.multiplayer_peer = peer
				host_created.emit()

# Called when joining a lobby (after creating the lobby or joining a friend)
func on_steam_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	match backend_type:
		BACKEND_TYPES.STEAM:
			if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
				# If we created the lobby, we are already hosting, so we should not create a new client peer
				if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
					return
				peer = SteamMultiplayerPeer.new()
				peer.server_relay = true
				peer.create_client(Steam.getLobbyOwner(lobby_id))
				multiplayer.multiplayer_peer = peer
				joined_lobby.emit()

# Called when attempting to join from the Steam interface
func on_steam_join_requested(lobby_id: int, steam_id: int) -> void:
	
	match backend_type:
		BACKEND_TYPES.STEAM:
			# Will cause the "lobby_joined" signal to emit
			Steam.joinLobby(lobby_id)

#endregion 
