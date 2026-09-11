extends Area2D

## A MiG approaching head-on.
##
## There is no depth here, only the arithmetic of it: distance shrinks every
## frame, scale grows as its inverse, and the aircraft displaces against the
## sky so it appears to hold station in a world that is turning. Once close
## enough it breaks off, veering out of frame on a course picked at spawn.
##
## The aircraft is drawn with one sprite. The source rotates that sprite and
## flips it, and reserves a nine-view sprite set that was never built.

const PPU = 32.0

const SCALE_FACTOR   = 0.1
const HORIZON_OFFSET = 1.3
const FLYBY_DISTANCE = 4500.0
const MAX_HEALTH     = 2

const ALTITUDE_REFERENCE = 10000.0
const DISPLACE_VERTICAL  = 5.0
const DISPLACE_DIVISOR   = 25.0
const SCALE_NUMERATOR    = 10000.0

const VEER_HORIZONTAL = 10.0
const VEER_VERTICAL   = 6.0
const BANK_HORIZONTAL = 50.0
const BANK_VERTICAL   = 20.0
const BANK_VERTICAL_WEIGHT = 0.5
const FLIP_ANGLE      = -35.0
const PERSPECTIVE_GAIN = 0.12

const WOBBLE_AMPLITUDE = 0.1
const DRIFT_RATE_BREAK = 0.5

const CULL_HORIZONTAL = 12.0
const CULL_VERTICAL   = 10.0
const CULL_DISTANCE   = 100.0
const SCALE_FLOOR     = 100.0

const CLOSE_NUMERATOR = 50000.0
const CLOSE_FACTOR    = 2.0
const CLOSE_CONSTANT  = 50.0

@export var distance: float = 10000.0

@onready var sprite     : Sprite2D = $Sprite
@onready var flyby_sfx  : AudioStreamPlayer2D = $Flyby
@onready var explode_sfx: AudioStreamPlayer2D = $Explosion
@onready var explosion  : Explosion = $Explosion2D

var health: int = MAX_HEALTH

## Lateral station in world units, drifting slowly across the aircraft's life.
var _base_x: float = 0.0
var _wobble_phase: float = 0.0
var _wobble_speed: float = 0.0
var _drift_x: float = 0.0

var _breaking_off: bool = false
var _break_distance: float = 0.0
var _break_course: Vector2 = Vector2.ZERO
var _dying: bool = false
var _age: float = 0.0


func _ready() -> void:
	add_to_group("enemies")
	flyby_sfx.stream = Audio.get_clip("flyby")
	explode_sfx.stream = Audio.get_clip("explosion")

	_base_x = position.x / PPU
	_wobble_phase = randf_range(0.0, TAU)
	_wobble_speed = randf_range(2.0, 4.0)
	_drift_x = randf_range(-0.3, 0.3)
	_break_course = _pick_break_course()

	explosion.visible = false


## Most break left or right with a little vertical; the rest climb or dive.
## The course is held in the source's y-up frame and negated on use.
func _pick_break_course() -> Vector2:
	var roll := randf()
	if roll < 0.35:
		return Vector2(-1.0, randf_range(-0.4, 0.4))
	if roll < 0.70:
		return Vector2(1.0, randf_range(-0.4, 0.4))
	return Vector2(randf_range(-0.3, 0.3), 0.8 if randf() > 0.5 else -0.8)


func _physics_process(delta: float) -> void:
	if _dying:
		return

	_age += delta

	if not _breaking_off and distance < FLYBY_DISTANCE:
		_begin_break_off()

	var depth := Flight.depth_ratio(distance)
	var rise := (1.0 - Flight.altitude / ALTITUDE_REFERENCE) \
		* depth * DISPLACE_VERTICAL
	var slide := (Flight.sky_position.x / PPU) * depth / DISPLACE_DIVISOR
	var horizon := (-Flight.sky_position.y / PPU) + HORIZON_OFFSET

	if _breaking_off:
		_fly_break_off(delta, rise, slide, horizon)
	else:
		_fly_approach(delta, depth, rise, slide, horizon)

	# Closing speed rises as it nears: the last stretch comes up fast.
	distance -= (CLOSE_NUMERATOR / distance * CLOSE_FACTOR) + CLOSE_CONSTANT


func _begin_break_off() -> void:
	_breaking_off = true
	_break_distance = distance
	flyby_sfx.play()


func _fly_approach(
		delta: float, depth: float, rise: float,
		slide: float, horizon: float) -> void:
	_base_x += _drift_x * delta
	var wobble := sin(_age * _wobble_speed + _wobble_phase) \
		* WOBBLE_AMPLITUDE * depth

	_place(_base_x + slide + wobble, horizon + rise)
	_apply_scale(SCALE_NUMERATOR / distance * SCALE_FACTOR)

	rotation = 0.0
	sprite.flip_h = false


func _fly_break_off(
		delta: float, rise: float, slide: float, horizon: float) -> void:
	var progress := smoothstep(0.0, 1.0, clampf(
		(_break_distance - distance) / _break_distance, 0.0, 1.0))

	var veer := Vector2(
		_break_course.x * progress * VEER_HORIZONTAL,
		_break_course.y * progress * VEER_VERTICAL
	)

	_base_x += _drift_x * delta * DRIFT_RATE_BREAK
	_place(_base_x + slide + veer.x, horizon + rise + veer.y)

	# A climbing break reads as smaller, a diving one as larger.
	var perspective := 1.0 - veer.y * PERSPECTIVE_GAIN
	_apply_scale(
		SCALE_NUMERATOR / maxf(distance, SCALE_FLOOR)
		* SCALE_FACTOR * perspective)

	var bank := (_break_course.x * progress * BANK_HORIZONTAL) \
		+ (_break_course.y * progress * BANK_VERTICAL * BANK_VERTICAL_WEIGHT)
	rotation_degrees = -bank
	sprite.flip_h = bank < FLIP_ANGLE

	if absf(_base_x + slide + veer.x) > CULL_HORIZONTAL \
		or absf(rise + veer.y) > CULL_VERTICAL \
		or distance < CULL_DISTANCE:
		queue_free()


## Positions arrive in world units with y pointing up.
func _place(x: float, y: float) -> void:
	position = Vector2(x * PPU, -y * PPU)


func _apply_scale(factor: float) -> void:
	scale = Vector2(factor, factor)


## Called by the player's gun when a round lands on this aircraft.
func take_hit() -> void:
	if _dying:
		return

	Flight.add_score(Scoring.for_hit(distance))
	health -= 1
	if health <= 0:
		_destroy()


func _destroy() -> void:
	_dying = true
	Flight.register_kill(Scoring.for_kill(distance))

	sprite.visible = false
	explode_sfx.play()
	explosion.burst(
		scale.x * Explosion.SCALE_MULTIPLE,
		clampf((15000.0 - distance) / 1500.0, 1.0, 10.0))
	explosion.finished.connect(queue_free)
