extends Node

const ability_resources:Array = [
  preload("res://abilities/Pond.tres"),
  preload("res://abilities/Grass.tres"),
  preload("res://abilities/Berries.tres"),
  preload("res://abilities/Tree.tres"),
]
const ability_usable_color:Color = Color(1, 1, 1, 0.3)
const ability_unusable_color:Color = Color(1, 0, 0, 0.3)

onready var _icon:Sprite = find_node("AbilityIcon")
onready var _resources_container = get_tree().get_root().find_node("Resources", true, false)

var ability_cooldowns:Dictionary = {}
var abilities_unlocked:Array = []

func _ability_usable() -> bool:
  var _active_ability:Resource = Store.state.active_ability
  var _resources:Array = get_tree().get_nodes_in_group("resources")
  var _mouse_position:Vector2 = _icon.get_global_mouse_position()
  
  if Store.state.resources[_active_ability.type] >= _active_ability.max_active:
    return false

  if ability_cooldowns[_active_ability.type] >= 0:
    return false

  for _resource in _resources:
    if _resource.global_position.distance_to(_mouse_position) <= _resource.exclusion_radius:
      return false

  return true

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "resources":
      abilities_unlocked = []
      for _ability in ability_resources:
        var _unlocked = true
        for _requirement in _ability.requirements:
          if substate[_requirement.type] < _requirement.amount:
            _unlocked = false
            break

        if _unlocked:
          abilities_unlocked.append(_ability)

    "active_ability":
      if substate:
        _icon.texture = substate.icon
        _icon.scale = substate.scale
        _icon.visible = true
      else:
        _icon.visible = false

func _process(delta):
  for _ability in ability_resources:
    ability_cooldowns[_ability.type] -= delta

  if _icon.visible:
    _icon.global_position = _icon.get_global_mouse_position()

    if _ability_usable():
      _icon.modulate = ability_usable_color
    else:
      _icon.modulate = ability_unusable_color

func _ready():
  _icon.visible = false

  for _ability in ability_resources:
    ability_cooldowns[_ability.type] = 0

  Store.connect("state_changed", self, "_on_store_state_changed")

func _unhandled_input(event):
  var _active_ability:Resource = Store.state.active_ability

  if _active_ability && event is InputEventMouseButton && event.pressed:
    if event.button_index == BUTTON_RIGHT:
      Store.set_state("active_ability", null)

    if event.button_index == BUTTON_LEFT && _ability_usable():
      var _instantiated_ability:Node2D = _active_ability.instantiates.instance()

      _instantiated_ability.global_position = _icon.get_global_mouse_position()

      _resources_container.add_child(_instantiated_ability)

      ability_cooldowns[_active_ability.type] = _active_ability.cooldown

      if Store.state.resources[_active_ability.type] >= _active_ability.max_active:
        Store.set_state("active_ability", null)

  if event is InputEventKey && event.pressed:
    match event.scancode:
      49, 50, 51, 52:
        Store.set_state("active_ability", ability_resources[event.scancode - 49])
