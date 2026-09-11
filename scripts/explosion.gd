class_name Explosion
extends AnimatedSprite2D

## The fireball an aircraft leaves behind.
##
## It does not fade. It steps through its frames over a fixed lifetime, grows
## as though the player were still closing on a now-stationary object, and is
## removed outright when the lifetime runs out.
##
## The artwork pivots at or below the bottom edge of each frame, so the effect
## is dropped by its own scale to sit over the aircraft it replaced.

signal finished

const LIFETIME       = 0.5
const APPROACH_SPAN  = 10.0
const RECENTRE       = 1.0
const SCALE_MULTIPLE = 6.0
const PPU            = 32.0

var _base_scale: float = 0.0
var _approach_speed: float = 0.0
var _timer: float = 0.0
var _running: bool = false


func _ready() -> void:
	visible = false
	set_process(false)


func burst(base_scale: float, approach_speed: float) -> void:
	_base_scale = base_scale
	_approach_speed = approach_speed
	_timer = 0.0
	_running = true

	visible = true
	rotation = 0.0
	flip_h = false
	modulate = Color.WHITE
	scale = Vector2(_base_scale, _base_scale)
	position.y += _base_scale * RECENTRE * PPU
	frame = 0

	set_process(true)


func _process(delta: float) -> void:
	if not _running:
		return

	_timer += delta

	var count := sprite_frames.get_frame_count(animation)
	frame = mini(int(_timer / LIFETIME * count), count - 1)

	if _approach_speed > 0.0:
		var growth := 1.0 + (_timer / LIFETIME) * (_approach_speed / APPROACH_SPAN)
		scale = Vector2(_base_scale * growth, _base_scale * growth)

	if _timer >= LIFETIME:
		_running = false
		set_process(false)
		finished.emit()
