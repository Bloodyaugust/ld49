extends Control

onready var _abilities_container:HBoxContainer = find_node("AbilitiesContainer")
onready var _ability_controller = get_tree().get_root().find_node("AbilityController", true, false)
onready var _animation_player:AnimationPlayer = find_node("AnimationPlayer")

var _ability_item_scene:PackedScene = preload("res://views/components/AbilityItem.tscn")

func _on_ability_selected(ability) -> void:
  print(ability.type)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_STARTING:
          visible = true
          _animation_player.play("ui_show")
        GameConstants.GAME_OVER:
          _animation_player.play_backwards("ui_show")
          yield(_animation_player, "animation_finished")
          visible = false

func _ready():
  call_deferred("_setup")

  Store.connect("state_changed", self, "_on_state_changed")

func _setup():
  for _ability_resource in _ability_controller.ability_resources:
    var _new_ability_item = _ability_item_scene.instance()

    _new_ability_item.ability = _ability_resource
    _new_ability_item.connect("ability_selected", self, "_on_ability_selected")

    _abilities_container.add_child(_new_ability_item)
