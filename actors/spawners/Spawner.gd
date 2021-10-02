extends Sprite

export var requirements:Array
export var spawn_move_range:float
export var spawn_rate:float
export var spawn_scene:PackedScene
export var max_spawns:int

onready var _creature_container = get_tree().get_root().find_node("Creatures", true, false)

var _time_to_spawn:float
var _active_spawns:int

func _draw():
  draw_arc(Vector2.ZERO, spawn_move_range, 0, 2 * PI, 16, Color.red)

func _ready():
  update()
  _time_to_spawn = spawn_rate

func _process(delta):
  if _active_spawns < max_spawns:
    _time_to_spawn -= delta

  if _time_to_spawn <= 0:
    var _new_creature = spawn_scene.instance()

    _new_creature.global_position = global_position + Vector2(rand_range(-50, 50), rand_range(-50, 50))
    _new_creature.spawner = self

    _creature_container.add_child(_new_creature)

    _time_to_spawn = spawn_rate
    _active_spawns += 1
    print("spawning")
