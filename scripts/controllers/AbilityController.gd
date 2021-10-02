extends Node

const ability_resources:Array = [
  preload("res://abilities/Pond.tres"),
]

onready var _icon:Sprite = find_node("AbilityIcon")
onready var _resources_container = get_tree().get_root().find_node("Resources", true, false)

var ability_cooldowns:Dictionary = {}

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "active_ability":
      if substate:
        _icon.texture = substate.icon
        _icon.visible = true
      else:
        _icon.visible = false

func _process(delta):
  for _ability in ability_resources:
    ability_cooldowns[_ability.type] -= delta

  if _icon.visible:
    _icon.global_position = _icon.get_global_mouse_position()

func _ready():
  for _ability in ability_resources:
    ability_cooldowns[_ability.type] = 0

  Store.connect("state_changed", self, "_on_store_state_changed")

func _unhandled_input(event):
  if Store.state.active_ability && event is InputEventMouseButton && event.pressed:
    if event.button_index == BUTTON_RIGHT:
      Store.set_state("active_ability", null)

    if event.button_index == BUTTON_LEFT:
      var _instantiated_ability:Node2D = Store.state.active_ability.instantiates.instance()

      _instantiated_ability.global_position = _icon.get_global_mouse_position()

      _resources_container.add_child(_instantiated_ability)

      ability_cooldowns[Store.state.active_ability.type] = Store.state.active_ability.cooldown
      Store.set_state("active_ability", null)
