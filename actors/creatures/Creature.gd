extends Sprite

const consume_range:float = 5.0

enum creature_states {
  IDLE,
  CONSUMING,
  WANDERING
}

export var consumes:String
export var consume_amount:int
export var consume_meter:float
export var speed:float
export var type:String
export var wander_time_max:float = 2.5
export var wander_time_min:float = 0.5
export var wander_interval_max:float = 3.0
export var wander_interval_min:float = 1.0

var spawner:Node2D

var _current_consume_meter:float
var _resource_target:Node2D
var _state:int
var _time_to_idle:float
var _time_to_wander:float
var _wander_target:Vector2

func consume(_amount:int) -> void:
  queue_free()

  var _new_creatures_state = Store.state.creatures.duplicate(true)
  _new_creatures_state[type] -= 1
  Store.set_state("creatures", _new_creatures_state)

func _draw():
  draw_line(Vector2.ZERO, to_local(spawner.global_position), Color.red)
  if _state == creature_states.WANDERING:
    draw_line(Vector2.ZERO, to_local(_wander_target), Color.green)
  if GDUtil.reference_safe(_resource_target) && _state == creature_states.CONSUMING:
    draw_line(Vector2.ZERO, to_local(_resource_target.global_position), Color.blue)

func _find_resource_target() -> void:
  var _resources = get_tree().get_nodes_in_group("resources")
  _resources += get_tree().get_nodes_in_group("creatures")

  var _eligible_resources = []

  for _resource in _resources:
    if _resource.type in consumes && _resource.global_position.distance_to(spawner.global_position) <= spawner.spawn_move_range:
      _eligible_resources.append(_resource)

  if _eligible_resources.size() > 0:
    _resource_target = _eligible_resources[randi() % _eligible_resources.size()]

func _process(delta):
  update()
  _current_consume_meter += delta

  if _time_to_idle <= 0 && _state == creature_states.WANDERING:
    _state = creature_states.IDLE
    _time_to_wander = rand_range(wander_interval_min, wander_interval_max)
    print("idling")

  if _time_to_wander <= 0 && _state == creature_states.IDLE:
    _state = creature_states.WANDERING
    _time_to_idle = rand_range(wander_time_min, wander_time_max)
    _wander_target = spawner.global_position + (Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * rand_range(0, spawner.spawn_move_range))
    print("wandering")

  if _current_consume_meter >= consume_meter && _state != creature_states.CONSUMING:
      _find_resource_target()

      if GDUtil.reference_safe(_resource_target):
        _state = creature_states.CONSUMING
        print("consuming")

  var _move_amount = speed * delta
  match _state:
    creature_states.IDLE:
      _time_to_wander -= delta
    creature_states.CONSUMING:
      if GDUtil.reference_safe(_resource_target) && _resource_target.global_position.distance_to(spawner.global_position) <= spawner.spawn_move_range:
        global_position += global_position.direction_to(_resource_target.global_position) * _move_amount

        if global_position.distance_to(_resource_target.global_position) <= consume_range:
          _resource_target.consume(consume_amount)
          _current_consume_meter = 0
          _state = creature_states.IDLE
      else:
        _state = creature_states.IDLE
    creature_states.WANDERING:
      if global_position.distance_to(_wander_target) <= _move_amount:
        _wander_target = spawner.global_position + (Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * rand_range(0, spawner.spawn_move_range))

      global_position += global_position.direction_to(_wander_target) * _move_amount
      _time_to_idle -= delta

func _ready():
  _current_consume_meter = 0
  _state = creature_states.IDLE
  _wander_target = spawner.global_position

  var _new_creatures_state = Store.state.creatures.duplicate(true)
  _new_creatures_state[type] += 1
  Store.set_state("creatures", _new_creatures_state)
