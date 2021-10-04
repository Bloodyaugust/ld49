extends Control

onready var _animation_player:AnimationPlayer = find_node("AnimationPlayer")
onready var _back_button: Button = find_node("Back")

func _on_back_button_pressed() -> void:
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_MAIN_MENU)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "client_view":
      match substate:
        ClientConstants.CLIENT_VIEW_CREDITS:
          visible = true
          _animation_player.play("ui_show")
        _:
          _animation_player.play_backwards("ui_show")
          yield(_animation_player, "animation_finished")
          visible = false

func _ready():
  _back_button.connect("pressed", self, "_on_back_button_pressed")

  Store.connect("state_changed", self, "_on_state_changed")
