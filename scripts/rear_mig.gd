extends Area2D

## A MiG the Tomcat has already passed, pulling away.
##
## The reverse of the head-on case: it starts large and close, drifts outward
## from the centre of the screen, weaves for a few seconds and then commits to
## one side. Shrinking as it goes is what reads as distance opening up.
##
## It carries no range of its own. Its score comes from a distance inferred
## from how long it has been on screen.

const PPU = 32.0

const LIFETIME    = 8.0
const SPAWN_SCALE = 0.14
const FINAL_SCALE = 0.03

const RECEDE_SPEED = 0.8
const WEAVE_RATE   = 2.0
const WEAVE_AMOUNT = 0.3

## Banking runs only in this window; before it the aircraft holds level.
const BANK_FROM  = 1.0
const BANK_UNTIL = 7.0
const BANK_WEAVE_GAIN = 2.0
const BANK_WEAVE_SPAN = 20.0
const BANK_BREAK      = 45.0
const BANK_NUDGE      = 0.2
const BREAK_SPEED     = 1.5
const FLIP_ANGLE      = -30.0

const FLYBY_DELAY = 0.5
const MAX_HEALTH  = 2

const CULL_HORIZONTAL = 12.0
const CULL_VERTICAL   = 8.0

@onready var sprite     : Sprite2D = $Sprite
@onready var flyby_sfx  : AudioStreamPlayer2D = $Flyby
@onready var explode_sfx: AudioStreamPlayer2D = $Explosion
@onready var explosion  : Explosion = $Explosion2D

var health: int = MAX_HEALTH

## Position in world units with y pointing up, mirroring the source's frame.
var _pos: Vector2 = Vector2.ZERO
var _bank: float = 0.0
var _scale: float = SPAWN_SCALE
var _age: float = 0.0
var _flyby_played: bool = false
var _dying: bool = false


func _ready() -> void:
	add_to_group("enemies")
	flyby_sfx.stream = Audio.get_clip("flyby")
	explode_sfx.stream = Audio.get_clip("explosion")
	_place_at_spawn()
	explosion.visible = false


## Four spawn arrangements: above, below, or off either shoulder.
func _place_at_spawn() -> void:
	var roll := randf()
	if roll < 0.3:
		_pos = Vector2(randf_range(-1.5, 1.5), 1.5)
	elif roll < 0.6:
		_pos = Vector2(randf_range(-1.5, 1.5), -1.5)
	elif roll < 0.8:
		_pos = Vector2(-2.0, randf_range(-0.5, 1.0))
	else:
		_pos = Vector2(2.0, randf_range(-0.5, 1.0))

	_scale = SPAWN_SCALE
	_commit()


func _physics_process(delta: float) -> void:
	if _dying:
		return

	_age += delta

	# Everything moves outward from screen centre, which is where the Tomcat is.
	var outward := _pos.normalized()
	if outward == Vector2.ZERO:
		outward = Vector2.RIGHT

	_pos += outward * RECEDE_SPEED * delta

	if _age > BANK_FROM and _age < BANK_UNTIL:
		_weave(delta, outward)
	elif _age >= BANK_UNTIL:
		_break_away(delta)
	else:
		_bank = 0.0

	_scale = lerpf(SPAWN_SCALE, FINAL_SCALE, _age / LIFETIME)

	if not _flyby_played and _age > FLYBY_DELAY:
		_flyby_played = true
		flyby_sfx.play()

	_commit()

	if _age > LIFETIME \
		or absf(_pos.x) > CULL_HORIZONTAL \
		or absf(_pos.y) > CULL_VERTICAL:
		queue_free()


## A lazy S across its own line of travel, rolling into each direction change.
func _weave(delta: float, outward: Vector2) -> void:
	var phase := _age * WEAVE_RATE
	var across := Vector2(-outward.y, outward.x)
	_pos += across * sin(phase) * WEAVE_AMOUNT * delta

	_bank = cos(phase) * BANK_WEAVE_GAIN * BANK_WEAVE_SPAN
	_pos.x += (_bank / BANK_WEAVE_SPAN) * delta * BANK_NUDGE


## Past the weave it picks the nearer edge and leaves.
func _break_away(delta: float) -> void:
	var side := 1.0 if _pos.x > 0.0 else -1.0
	_bank = side * BANK_BREAK
	_pos.x += side * BREAK_SPEED * delta


## Writes the world-unit state out to the node, flipping y and the euler.
func _commit() -> void:
	position = Vector2(_pos.x * PPU, -_pos.y * PPU)
	scale = Vector2(_scale, _scale)
	rotation_degrees = -_bank
	sprite.flip_h = _bank < FLIP_ANGLE


## How far off this aircraft reads as being, from how long it has been visible.
func _simulated_distance() -> float:
	if _age < 3.0:
		return 2000.0
	if _age < 8.0:
		return lerpf(2000.0, 5000.0, (_age - 3.0) / 5.0)
	return lerpf(5000.0, 8000.0, (_age - 8.0) / 3.0)


## How fast the player still seems to be closing on the wreck.
func _approach_speed() -> float:
	if _age < 3.0:
		return 6.0
	if _age < 8.0:
		return lerpf(3.0, 0.5, (_age - 3.0) / 5.0)
	return 0.3


func take_hit() -> void:
	if _dying:
		return

	Flight.add_score(Scoring.for_hit(_simulated_distance()))
	health -= 1
	if health <= 0:
		_destroy()


func _destroy() -> void:
	_dying = true
	Flight.register_kill(Scoring.for_rear_kill(_simulated_distance()))

	sprite.visible = false
	explode_sfx.play()
	explosion.burst(_scale * Explosion.SCALE_MULTIPLE, _approach_speed())
	explosion.finished.connect(queue_free)
