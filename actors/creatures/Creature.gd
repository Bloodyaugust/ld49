extends Sprite

const consume_range:float = 5.0
const drink_range:float = 100.0
const state_indicator_textures:Dictionary = {
  "thirsty": preload("res://sprites/THIRSTY.png"),
  "hunting": preload("res://sprites/hunting.png"),
}

enum creature_states {
  IDLE,
  CONSUMING,
  DRINKING,
  HUNTING,
  THIRSTY,
  WANDERING
}

export var consumes:String
export var consume_amount:int
export var consume_meter:float
export var speed:float
export var thirst_meter:float = 5.0
export var type:String
export var wander_time_max:float = 2.5
export var wander_time_min:float = 0.5
export var wander_interval_max:float = 3.0
export var wander_interval_min:float = 1.0

var dead:bool = false
var spawner:Node2D

onready var _animation_player:AnimationPlayer = find_node("AnimationPlayer")
onready var _mouth:Node2D = find_node("Mouth")
onready var _pond:Node2D = get_tree().get_nodes_in_group("pond")[0]
onready var _state_indicator:TextureRect = find_node("Indicator")

var _current_consume_meter:float
var _resource_target:Node2D
var _state:int
var _time_to_idle:float
var _time_to_wander:float
var _thirst:float
var _wander_target:Vector2

func consume(_amount:int) -> void:
  _animation_player.play("die")
  yield(_animation_player, "animation_finished")
  queue_free()

  var _new_creatures_state = Store.state.creatures.duplicate(true)
  _new_creatures_state[type] -= 1
  Store.set_state("creatures", _new_creatures_state)

func _draw():
  if Engine.is_editor_hint():
    draw_line(Vector2.ZERO, to_local(spawner.global_position), Color.red)
    if _state == creature_states.WANDERING:
      draw_line(Vector2.ZERO, to_local(_wander_target), Color.green)
    if GDUtil.reference_safe(_resource_target) && _state == creature_states.HUNTING:
      draw_line(Vector2.ZERO, to_local(_resource_target.global_position), Color.blue)

func _find_resource_target() -> void:
  var _resources = get_tree().get_nodes_in_group("resources")
  _resources += get_tree().get_nodes_in_group("creatures")

  var _eligible_resources = []

  for _resource in _resources:
    if _resource.type in consumes && _resource.global_position.distance_to(spawner.global_position) <= spawner.spawn_move_range && !_resource.dead:
      _eligible_resources.append(_resource)

  if _eligible_resources.size() > 0:
    _resource_target = _eligible_resources[randi() % _eligible_resources.size()]

func _on_consume_complete() -> void:
  match _state:
    creature_states.CONSUMING:
      _resource_target.consume(consume_amount)
      _current_consume_meter = 0
    creature_states.DRINKING:
      _thirst = thirst_meter

  _state = creature_states.IDLE

func _process(delta):
  match _state:
    creature_states.DRINKING, creature_states.THIRSTY:
      _state_indicator.texture = state_indicator_textures.thirsty
    creature_states.HUNTING:
      _state_indicator.texture = state_indicator_textures.hunting
    _:
      _state_indicator.texture = null

  if dead:
    _state_indicator.texture = null

  if !dead && _state != creature_states.CONSUMING && _state != creature_states.DRINKING:
    update()
    _current_consume_meter += delta
    _thirst -= delta

    if _time_to_idle <= 0 && _state == creature_states.WANDERING:
      _animation_player.play("idle")
      _state = creature_states.IDLE
      _time_to_wander = rand_range(wander_interval_min, wander_interval_max)

    if _time_to_wander <= 0 && _state == creature_states.IDLE:
      _state = creature_states.WANDERING
      _time_to_idle = rand_range(wander_time_min, wander_time_max)
      _wander_target = spawner.global_position + (Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * rand_range(0, spawner.spawn_move_range))

    if _current_consume_meter >= consume_meter && _state != creature_states.HUNTING && _state != creature_states.THIRSTY:
        _find_resource_target()

        if GDUtil.reference_safe(_resource_target):
          _state = creature_states.HUNTING

    if _thirst <= 0 && _state != creature_states.THIRSTY:
      _state = creature_states.THIRSTY

    var _move_amount = speed * delta
    match _state:
      creature_states.IDLE:
        _time_to_wander -= delta
      creature_states.HUNTING:
        if GDUtil.reference_safe(_resource_target) && _resource_target.global_position.distance_to(spawner.global_position) <= spawner.spawn_move_range && !_resource_target.dead:
          global_position += global_position.direction_to(_resource_target.global_position) * _move_amount

          if global_position.distance_to(_resource_target.global_position) <= consume_range && !_resource_target.dead:
            if _resource_target.type in ["insect", "deer", "rodent"]:
              _resource_target.z_index = z_index + 1
              _resource_target.dead = true

            _animation_player.play("consume")
            _state = creature_states.CONSUMING
        else:
          _state = creature_states.IDLE
      creature_states.THIRSTY:
        global_position += global_position.direction_to(_pond.global_position) * _move_amount

        if global_position.distance_to(_pond.global_position) <= drink_range:
          print("Drinking at distance: " + str(global_position.distance_to(_pond.global_position)))
          _animation_player.play("consume")
          _state = creature_states.DRINKING
        
      creature_states.WANDERING:
        if global_position.distance_to(_wander_target) <= _move_amount:
          _wander_target = spawner.global_position + (Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * rand_range(0, spawner.spawn_move_range))

        global_position += global_position.direction_to(_wander_target) * _move_amount
        _time_to_idle -= delta

  if _state == creature_states.CONSUMING && _resource_target.type in ["insect", "deer", "rodent"]:
    _resource_target.global_position = _mouth.global_position

func _ready():
  _current_consume_meter = 0
  _state = creature_states.IDLE
  _thirst = thirst_meter
  _wander_target = spawner.global_position

  var _new_creatures_state = Store.state.creatures.duplicate(true)
  _new_creatures_state[type] += 1
  Store.set_state("creatures", _new_creatures_state)
