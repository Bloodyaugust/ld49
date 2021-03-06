extends Control

onready var _animation_player:AnimationPlayer = find_node("AnimationPlayer")
onready var _credits_button: Button = find_node("Credits")
onready var _play_button: Button = find_node("Play")

func end_game() -> void:
  Store.set_state("creatures", {
    "insect": 0,
    "rodent": 0,
    "deer": 0,
    "predator": 0,
  })
  Store.set_state("resources", {
    "pond": 0,
    "grass": 0,
    "berries": 0,
    "tree": 0,
  })
  Store.set_state("spawners", {
    "insect": 0,
    "rodent": 0,
    "deer": 0,
    "predator": 0,
  })

  Store.set_state("active_ability", null)
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_GAME_OVER)
  Store.set_state("game", GameConstants.GAME_OVER)

func start_game() -> void:
  Store.set_state("creatures", {
    "insect": 0,
    "rodent": 0,
    "deer": 0,
    "predator": 0,
  })
  Store.set_state("resources", {
    "pond": 0,
    "grass": 0,
    "berries": 0,
    "tree": 0,
  })
  Store.set_state("spawners", {
    "insect": 0,
    "rodent": 0,
    "deer": 0,
    "predator": 0,
  })

  Store.set_state("active_ability", null)
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_NONE)
  Store.set_state("game", GameConstants.GAME_STARTING)

func _on_credits_button_pressed() -> void:
  Store.set_state("client_view", ClientConstants.CLIENT_VIEW_CREDITS)

func _on_play_button_pressed() -> void:
  start_game()

func _on_state_changed(state_key: String, substate):
  match state_key:
    "client_view":
      match substate:
        ClientConstants.CLIENT_VIEW_MAIN_MENU:
          visible = true
          _animation_player.play("ui_show")
        _:
          _animation_player.play_backwards("ui_show")
          yield(_animation_player, "animation_finished")
          visible = false

func _ready():
  _credits_button.connect("pressed", self, "_on_credits_button_pressed")
  _play_button.connect("pressed", self, "_on_play_button_pressed")

  Store.connect("state_changed", self, "_on_state_changed")
