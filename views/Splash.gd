extends Control

onready var _animation_player:AnimationPlayer = find_node("AnimationPlayer")

func _on_state_changed(state_key: String, substate):
  match state_key:
    "client_view":
      match substate:
        ClientConstants.CLIENT_VIEW_SPLASH:
          visible = true
          _animation_player.play("ui_show")
          yield(_animation_player, "animation_finished")
          visible = false
          Store.set_state("client_view", ClientConstants.CLIENT_VIEW_MAIN_MENU)


func _ready():
  Store.connect("state_changed", self, "_on_state_changed")
