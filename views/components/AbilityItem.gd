extends Control

var ability:Resource

onready var _ability_controller = get_tree().get_root().find_node("AbilityController", true, false)
onready var _active_label:Label = find_node("Active")
onready var _icon:TextureRect = find_node("Icon")
onready var _name_label:Label = find_node("Name")
onready var _progress_bar:ProgressBar = find_node("ProgressBar")

func _gui_input(event:InputEvent):
  if _usable() && event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.pressed:
    Store.set_state("active_ability", ability)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "resources":
      _active_label.text = str(substate[ability.type]) + "/" + str(ability.max_active)

func _process(_delta):
  _progress_bar.value = 1 - (_ability_controller.ability_cooldowns[ability.type] / ability.cooldown)
  _update_modulate()

func _ready():
  _icon.texture = ability.icon
  _active_label.text = str(Store.state.resources[ability.type]) + "/" + str(ability.max_active)
  _name_label.text = ability.type

  Store.connect("state_changed", self, "_on_state_changed")

func _usable() -> bool:
  if Store.state.resources[ability.type] >= ability.max_active:
    return false

  if _ability_controller.ability_cooldowns[ability.type] >= 0:
    return false

  return true

func _update_modulate() -> void:
  if !_usable():
    modulate = Color.gray
    return

  if Store.state.active_ability && Store.state.active_ability.type == ability.type:
    modulate = Color.yellow
  else:
    modulate = Color.white
