extends Node2D

## Feeds the sky. Head-on waves arrive in a spread line at staggered ranges;
## rear waves trickle in behind at irregular intervals so they never read as
## a formation.

const PPU = 32.0

## Spread and spawn heights are world units in the source's y-up frame.
const SPREAD        = 2.0
const SPAWN_HEIGHT  = 2.0
const REAR_HEIGHT   = -5.0
const START_DISTANCE = 15000.0
const RANGE_STAGGER  = 500.0

@export var mig_scene: PackedScene
@export var rear_mig_scene: PackedScene

@export var wave_interval: float = 5.0
@export var rear_wave_interval: float = 7.0
@export var wave_size: int = 4
@export var rear_wave_size: int = 2

var _wave_timer: float = 0.0
var _rear_timer: float = 0.0


func _ready() -> void:
	_spawn_wave()
	# Rear aircraft start part-way into their cycle so the two never coincide.
	_rear_timer = rear_wave_interval * 0.5


func _process(delta: float) -> void:
	_wave_timer += delta
	if _wave_timer >= wave_interval:
		_wave_timer = 0.0
		_spawn_wave()

	_rear_timer += delta
	if _rear_timer >= rear_wave_interval and rear_mig_scene != null:
		_rear_timer = 0.0
		_spawn_rear_wave()


func _spawn_wave() -> void:
	if mig_scene == null:
		return

	for i in wave_size:
		var mig := mig_scene.instantiate()
		var t := float(i) / maxf(wave_size - 1, 1)
		mig.position = Vector2(
			lerpf(-SPREAD, SPREAD, t) * PPU, -SPAWN_HEIGHT * PPU)
		mig.distance = START_DISTANCE + i * RANGE_STAGGER
		add_child(mig)


## Rear aircraft arrive one at a time with a gap between, not as a block.
func _spawn_rear_wave() -> void:
	for i in rear_wave_size:
		var rear := rear_mig_scene.instantiate()
		rear.position = Vector2(0.0, -REAR_HEIGHT * PPU)
		add_child(rear)
		if i < rear_wave_size - 1:
			await get_tree().create_timer(randf_range(2.0, 4.0)).timeout
