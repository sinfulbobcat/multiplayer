extends Node

const GAME_SCENE = "res://scenes/game.tscn"
const MAIN_MENU = "res://scenes/main_menu.tscn"
const SERVER_PORT : int = 2007

var is_hosting_game = false

func create_server():
	var enet_network_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	enet_network_peer.create_server(SERVER_PORT)
	get_tree().get_multiplayer().multiplayer_peer = enet_network_peer
	is_hosting_game = true
	print("Server created!")

func create_client(host_ip: String = "localhost", host_port: int = SERVER_PORT):
	_setup_client_connection_signals()
	
	var enet_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	enet_network_peer.create_client(host_ip, host_port)
	get_tree().get_multiplayer().multiplayer_peer = enet_network_peer
	is_hosting_game = false
	print("Client peer created!")

func _setup_client_connection_signals():
	if not get_tree().get_multiplayer().server_disconnected.is_connected(_server_disconnected):
		get_tree().get_multiplayer().server_disconnected.connect(_server_disconnected)

func _server_disconnected():
	print("Server disconnected")
	terminate_connection_load_main_menu()

func load_game_scene():
	print("Loading game...")
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))

func terminate_connection_load_main_menu():
	print("Disconnected from server and loaded into main menu")
	_load_main_menu()
	_terminate_connection()
	_disconnect_client_connection_signals()

func _load_main_menu():
	get_tree().call_deferred(&"change_scene_to_packed", preload(MAIN_MENU))

func _terminate_connection():
	print("Connection terminated")
	get_tree().get_multiplayer().multiplayer_peer = null

func _disconnect_client_connection_signals():
	if get_tree().get_multiplayer().server_disconnected.has_connections():
		get_tree().get_multiplayer().server_disconnected.disconnect(_server_disconnected)
