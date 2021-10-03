extends Node

signal state_changed(state_key, substate)

var persistent_store:PersistentStore
var state: Dictionary = {
  "client_view": "",
  "game": "",
  "creatures": {
    "insect": 0,
    "deer": 0,
    "rodent": 0,
    "predator": 0,
  },
  "resources": {
    "pond": 0,
    "grass": 0,
    "berries": 0,
    "tree": 0,
  },
  "spawners": {
    "insect": 0,
    "rodent": 0,
    "deer": 0,
    "predator": 0,
  },
  "active_ability": null
 }

func save_persistent_store() -> void:
  if ResourceSaver.save(ClientConstants.CLIENT_PERSISTENT_STORE_PATH, persistent_store) != OK:
    print("Failed to save persistent store")

func set_state(state_key: String, new_state) -> void:
  state[state_key] = new_state
  emit_signal("state_changed", state_key, state[state_key])
  print("State changed: ", state_key, " -> ", state[state_key])
  
func _initialize():
  set_state("client_view", ClientConstants.CLIENT_VIEW_MAIN_MENU)
  set_state("game", GameConstants.GAME_OVER)

func _ready():
  if Directory.new().file_exists(ClientConstants.CLIENT_PERSISTENT_STORE_PATH):
    persistent_store = load(ClientConstants.CLIENT_PERSISTENT_STORE_PATH)

  if !persistent_store:
    persistent_store = PersistentStore.new()
    save_persistent_store()

  call_deferred("_initialize")
