extends Sprite

const exclusion_radius_color:Color = Color(1, 0, 0, 0.1)
const game_resource_data:Dictionary = {
  "grass": preload("res://actors/resources/GrassData.tres"),
  "berries": preload("res://actors/resources/BerriesData.tres"),
}

export var exclusion_radius:float
export var starting_amount:int
export var type:String

var claimed:bool = false

onready var _spawners_container:Node = get_tree().get_root().find_node("Spawners", true, false)

var _amount:int
var _bug_spawner_scene:PackedScene = preload("res://actors/spawners/Bug.tscn")

func consume(amount) -> void:
  _amount -= amount

  if _amount <= 0:
    queue_free()

func _draw():
  draw_circle(Vector2.ZERO, exclusion_radius / scale.x, exclusion_radius_color)

func _ready():
  _amount = starting_amount

  var _new_resources_state = Store.state.resources.duplicate(true)
  _new_resources_state[type] += 1
  Store.set_state("resources", _new_resources_state)

  if type == "pond":
    var _new_bug_spawner = _bug_spawner_scene.instance()

    _new_bug_spawner.global_position = global_position

    _spawners_container.add_child(_new_bug_spawner)
  else:
    var _resources:Array = get_tree().get_nodes_in_group("resources")
    var _unclaimed_matching_resources:Array = []

    for _resource in _resources:
      if !_resource.claimed && _resource.type == game_resource_data[type].spawner_requirements.type:
        _unclaimed_matching_resources.append(_resource)

    if _unclaimed_matching_resources.size() >= game_resource_data[type].spawner_requirements.amount:
      var _new_spawner:Node2D = game_resource_data[type].spawner_scene.instance()
      var _resource_positions:Array = []

      for _resource in _unclaimed_matching_resources:
        _resource_positions.append(_resource.global_position)
        _resource.claimed = true

      _new_spawner.global_position = GDUtil.centroid(_resource_positions)

      _spawners_container.add_child(_new_spawner)
