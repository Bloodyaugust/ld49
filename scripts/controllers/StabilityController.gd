extends Node

const end_timer:float = 60.0
const unstable_below_stability:float = 0.75

signal stability_changed(stability, unstable, winning)

var current_stability_timer:float = 0.0
var current_win_timer:float = 0.0

onready var _creatures_container:Node = get_tree().get_root().find_node("Creatures", true, false)
onready var _resources_container:Node = get_tree().get_root().find_node("Resources", true, false)
onready var _spawners_container:Node = get_tree().get_root().find_node("Spawners", true, false)
onready var _main_menu:Node = get_tree().get_root().find_node("MainMenu", true, false)

var _current_stability:float = 0.0
var _unstable:bool
var _winning:bool

func _calculate_stability() -> void:
  var _spawners:Array = get_tree().get_nodes_in_group("spawners")
  var _max_creatures:int = 0
  var _num_creatures:int = 0

  if Store.state.spawners.rodent == 0:
    _current_stability = 1.0
    _unstable = false
    return

  for _creature_count in Store.state.creatures.values():
    _num_creatures += _creature_count

  for _spawner in _spawners:
    _max_creatures += _spawner.max_spawns

  if _max_creatures > 0:
    _current_stability = float(_num_creatures) / float(_max_creatures)
  _unstable = _current_stability <= unstable_below_stability
  _winning = !_unstable
  for _creature_key in Store.state.creatures.keys():
    if Store.state.creatures[_creature_key] == 0:
      _winning = false
      break


func _end_game() -> void:
  GDUtil.free_children(_creatures_container)
  GDUtil.free_children(_resources_container)
  GDUtil.free_children(_spawners_container)
  _main_menu.end_game()

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "creatures", "spawners":
      _calculate_stability()
      emit_signal("stability_changed", _current_stability, _unstable, _winning)

func _process(delta):
  if _unstable:
    current_stability_timer -= delta
  else:
    current_stability_timer = end_timer

  if _winning:
    current_win_timer -= delta
  else:
    current_win_timer = end_timer

  if current_stability_timer <= 0 || current_win_timer <= 0:
    _end_game()

func _ready():
  Store.connect("state_changed", self, "_on_store_state_changed")
