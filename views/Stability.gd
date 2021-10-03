extends Control

onready var _animation_player:AnimationPlayer = find_node("AnimationPlayer")
onready var _stability_controller:Node = get_tree().get_root().find_node("StabilityController", true, false)
onready var _stability_label:Label = find_node("StabilityLabel")
onready var _lose_warning:Label = find_node("LoseWarning")
onready var _win_warning:Label = find_node("WinWarning")

var _unstable:bool = false
var _winning:bool = false

func _on_stability_changed(stability, unstable, winning):
  _unstable = unstable
  _winning = winning
  _stability_label.text = "Stability: " + str(int(stability * 100)) + "%"

  if unstable:
    _lose_warning.text = "(lose in " + str(int(_stability_controller.current_stability_timer)) + " seconds!)"
    _lose_warning.visible = true
    _stability_label.set("custom_colors/font_color", Color.red)
  else:
    _lose_warning.visible = false
    _stability_label.set("custom_colors/font_color", Color.white)

  if _winning:
    _win_warning.text = "(win in " + str(int(_stability_controller.current_win_timer)) + " seconds!)"
    _win_warning.visible = true
  else:
    _win_warning.visible = false

func _on_store_state_changed(state_key:String, substate) -> void:
  match state_key:
    "game":
      match substate:
        GameConstants.GAME_OVER:
          _animation_player.play_backwards("ui_show")
          yield(_animation_player, "animation_finished")
          visible = false
    "spawners":
      if substate.rodent > 0 && !visible:
        visible = true
        _animation_player.play("ui_show")

func _process(delta):
  if _unstable:
    _lose_warning.text = "(lose in " + str(int(_stability_controller.current_stability_timer)) + " seconds!)"

  if _winning:
    _win_warning.text = "(win in " + str(int(_stability_controller.current_win_timer)) + " seconds!)"


func _ready():
  _lose_warning.visible = false

  _stability_controller.connect("stability_changed", self, "_on_stability_changed")
  Store.connect("state_changed", self, "_on_store_state_changed")
