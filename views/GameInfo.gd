extends Control

onready var _animation_player:AnimationPlayer = find_node("AnimationPlayer")
onready var _creatures_container:Control = find_node("CreaturesContainer")
onready var _expander:Control = find_node("Expand")
onready var _resources_container:Control = find_node("ResourcesContainer")
onready var _root_container:Control = find_node("Root")

var _expanded:bool = false

func _evaluate_creatures_unlocked() -> void:
  for _creature_key in Store.state.creatures.keys():
    if _creature_key != "insect":
      var _has_creature:bool = Store.state.creatures[_creature_key] > 0

      if _has_creature:
        find_node(_creature_key).modulate = Color.white
      else:
        find_node(_creature_key).modulate = Color.black

func _evaluate_resources_unlocked() -> void:
  for _resource_key in Store.state.resources.keys():
    if _resource_key != "pond":
      var _has_resource:bool = Store.state.resources[_resource_key] > 0

      if _has_resource:
        find_node(_resource_key).modulate = Color.white
      else:
        find_node(_resource_key).modulate = Color.black

func _on_expander_gui_input(event:InputEvent) -> void:
  if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.pressed:
    _expanded = !_expanded

    if _expanded:
      _animation_player.play("ui_show")
    else:
      _animation_player.play_backwards("ui_show")

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "creatures":
      _evaluate_creatures_unlocked()
    "resources":
      _evaluate_resources_unlocked()
    "game":
      match substate:
        GameConstants.GAME_STARTING:
          _root_container.visible = true
        GameConstants.GAME_OVER:
          _root_container.visible = false

func _ready():
  _expander.connect("gui_input", self, "_on_expander_gui_input")

  Store.connect("state_changed", self, "_on_store_state_changed")
