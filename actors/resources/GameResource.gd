extends Sprite

const exclusion_radius_color:Color = Color(1, 0, 0, 0.1)

export var exclusion_radius:float
export var starting_amount:int
export var type:String
export var resource_name:String

var _amount:int
var _bug_spawner_scene:PackedScene = preload("res://actors/spawners/Bug.tscn")

func consume(amount) -> void:
  _amount -= amount

  if _amount <= 0:
    queue_free()

func _draw():
  draw_circle(Vector2.ZERO, exclusion_radius, exclusion_radius_color)

func _ready():
  if type == "water":
    var _new_bug_spawner = _bug_spawner_scene.instance()

    _new_bug_spawner.global_position = global_position

    $"../../Spawners".add_child(_new_bug_spawner)

  var _new_resources_state = Store.state.resources.duplicate(true)
  _new_resources_state[resource_name] += 1
  Store.set_state("resources", _new_resources_state)
