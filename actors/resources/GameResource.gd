extends Sprite

const exclusion_radius_color:Color = Color(1, 0, 0, 0.1)
const game_resource_data:Dictionary = {
  "grass": preload("res://actors/resources/GrassData.tres"),
  "berries": preload("res://actors/resources/BerriesData.tres"),
}

export var exclusion_radius:float
export var starting_amount:int
export var type:String

onready var _spawners_container:Node = get_tree().get_root().find_node("Spawners", true, false)

var _amount:int
var _bug_spawner_scene:PackedScene = preload("res://actors/spawners/Bug.tscn")

func consume(amount) -> void:
  _amount -= amount

  if _amount <= 0:
    queue_free()

func _draw():
  draw_circle(Vector2.ZERO, exclusion_radius, exclusion_radius_color)

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
    var _num_resources_requirement_type = Store.state.resources[game_resource_data[type].spawner_requirements.type]
    var _num_wanted_spawners = _num_resources_requirement_type / game_resource_data[type].spawner_requirements.amount

    print("num wanted spawners: " + str(_num_wanted_spawners))
    print("num spawners: " + str(Store.state.spawners[game_resource_data[type].spawner_requirements.spawner_type]))
    if _num_wanted_spawners > Store.state.spawners[game_resource_data[type].spawner_requirements.spawner_type]:
      var _new_spawner:Node2D = game_resource_data[type].spawner_scene.instance()
      var _resources:Array = get_tree().get_nodes_in_group("resources")
      var _resource_positions:Array = []

      for _resource in _resources:
        if _resource.type == game_resource_data[type].spawner_requirements.type:
          _resource_positions.append(_resource.global_position)

      _new_spawner.global_position = GDUtil.centroid(_resource_positions)

      _spawners_container.add_child(_new_spawner)
