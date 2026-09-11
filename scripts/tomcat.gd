extends Node2D

## The player's Tomcat.
##
## The crosshairs lead, the aircraft trails below them, and the world banks
## against both. Unity authored this at 32 pixels to the world unit with y
## pointing up; the constants below are those measurements, and the conversion
## to pixels happens where each one is used.

signal fired(muzzle_position: Vector2)

const PPU = 32.0

## TomcatController.speed, serialized in the scene.
const SPEED = 1.0

const INPUT_MULTIPLIER = 1.25
const STICK_RATE       = 10.0
const AIM_LIMIT        = Vector2(3.2, 2.8)
const TRAIL_RATE       = 4.0
const TRAIL_DROP       = 0.5
const BANK_DEGREES     = 10.0
const SKY_COUNTER      = 1.5
const SKY_ROLL         = 8.0

const FIRE_INTERVAL = 0.125
const AIM_RADIUS    = 0.4

const CLIMB_RATE    = 1000.0
const ALTITUDE_WARN = 10000.0
const WARN_INTERVAL = 5.0

## The angle of attack and the lateral step are rounded to integers and index
## the pose grid. Both clamp to the range the artwork covers.
const AOT_LIMIT  = 2.5
const BANK_LIMIT = 2

const ENGINE_PITCH_GAIN  = 0.2
const ENGINE_PITCH_RATE  = 2.0
const ENGINE_PAN_DIVISOR = 6.0

@onready var sky        : Node2D = get_parent().get_node("Sky")
@onready var ocean      : AnimatedSprite2D = sky.get_node("Ocean")
@onready var crosshairs : Node2D = get_parent().get_node("Crosshairs")
@onready var sprite     : AnimatedSprite2D = $Sprite
@onready var engine_sfx : AudioStreamPlayer = $Engine
@onready var gun_sfx    : AudioStreamPlayer = $Gun
@onready var warn_sfx   : AudioStreamPlayer = $Warning

## The crosshair position in world units with y still pointing up. Everything
## below derives from this and converts to pixels only on write.
var _aim: Vector2 = Vector2.ZERO
var _fire_cooldown: float = 0.0
var _warn_cooldown: float = 0.0


func _ready() -> void:
	add_to_group("player")
	_aim = Vector2(crosshairs.position.x / PPU, -crosshairs.position.y / PPU)

	engine_sfx.stream = Audio.get_clip("engine")
	engine_sfx.volume_db = Audio.get_volume_db("engine")
	engine_sfx.bus = Audio.ENGINE_BUS
	gun_sfx.stream = Audio.get_clip("gun")
	gun_sfx.volume_db = Audio.get_volume_db("gun")
	warn_sfx.stream = Audio.get_clip("altitude")
	warn_sfx.volume_db = Audio.get_volume_db("altitude")

	if engine_sfx.stream != null:
		engine_sfx.play()


func _physics_process(delta: float) -> void:
	_move_aim(delta)
	_trail_aircraft(delta)
	_bank_world(delta)
	_update_altitude(delta)
	_update_pose()
	_update_engine_note(delta)
	_service_gun(delta)
	_service_altitude_warning(delta)


## Stick input moves the aim point. The vertical axis inverts on the way in so
## the aim stays in the source's y-up frame.
func _move_aim(delta: float) -> void:
	var stick := Vector2(
		Input.get_axis("fly_left", "fly_right"),
		-Input.get_axis("fly_up", "fly_down")
	)

	_aim += stick * INPUT_MULTIPLIER * SPEED * STICK_RATE * delta
	_aim.x = clampf(_aim.x, -AIM_LIMIT.x, AIM_LIMIT.x)
	_aim.y = clampf(_aim.y, -AIM_LIMIT.y, AIM_LIMIT.y)

	crosshairs.position = Vector2(_aim.x * PPU, -_aim.y * PPU)


## The aircraft chases its aim point, riding half a unit below it, and rolls
## with the crosshair's lateral deflection.
func _trail_aircraft(delta: float) -> void:
	var target := Vector2(_aim.x * PPU, -(_aim.y - TRAIL_DROP) * PPU)
	position = position.lerp(target, 1.0 - exp(-TRAIL_RATE * SPEED * delta))
	rotation_degrees = _aim.x * BANK_DEGREES


## The world slides and rolls against the turn. The slide's vertical component
## keeps its sign because the axis flip cancels the source's negation; the roll
## flips because the euler convention reverses.
##
## The ocean's own playback is scaled by the same speed. Ocean Animation's only
## state runs its clip with m_SpeedParameterActive set and m_SpeedParameter
## "speed", so the parameter the source writes here multiplies the clip's rate.
func _bank_world(delta: float) -> void:
	var weight := 1.0 - exp(-SPEED * delta)

	var target := Vector2(-_aim.x, _aim.y) * SKY_COUNTER * PPU
	sky.position = sky.position.lerp(target, weight)
	sky.rotation_degrees = lerpf(
		sky.rotation_degrees, -_aim.x * SKY_ROLL, weight)

	ocean.speed_scale = SPEED

	Flight.sky_position = sky.position


func _update_altitude(delta: float) -> void:
	Flight.altitude += CLIMB_RATE * (-position.y / PPU) * delta


## Pose is indexed by two rounded integers: the lateral step, and the angle of
## attack, which is the gap the aircraft opens below its aim while manoeuvring.
func _update_pose() -> void:
	var aot := clampf(_aim.y - (-position.y / PPU), -AOT_LIMIT, AOT_LIMIT)
	var state_y := roundi(aot)
	var state_x := absi(roundi(clampf(_aim.x, -BANK_LIMIT, BANK_LIMIT)))

	sprite.play(_pose_name(state_x, state_y))
	sprite.flip_h = _aim.x < 0.0


## Poses are named for their place in the grid, the way TomcatAnimator maps its
## X and Y parameters: vertical step, then lateral step.
func _pose_name(state_x: int, state_y: int) -> String:
	var vertical := "C"
	if state_y > 0:
		vertical = "U%d" % state_y
	elif state_y < 0:
		vertical = "D%d" % -state_y

	return vertical + ("C" if state_x == 0 else "R%d" % state_x)


## The engine note rises with vertical deflection, and the sound follows the
## crosshairs across the stereo field. The pan rides the engine's own bus,
## which carries an AudioEffectPanner; a player has no pan of its own.
func _update_engine_note(delta: float) -> void:
	var target := SPEED + absf(_aim.y) * ENGINE_PITCH_GAIN
	engine_sfx.pitch_scale = lerpf(
		engine_sfx.pitch_scale, target, ENGINE_PITCH_RATE * delta)

	Audio.set_engine_pan(_aim.x / ENGINE_PAN_DIVISOR)


func _service_gun(delta: float) -> void:
	_fire_cooldown += delta

	if not Input.is_action_pressed("fire"):
		return
	if _fire_cooldown <= FIRE_INTERVAL:
		return

	_fire_cooldown = 0.0
	gun_sfx.play()
	fired.emit(crosshairs.global_position)
	_strike_target_under_pipper()


## Rounds land on whatever sits under the crosshairs.
func _strike_target_under_pipper() -> void:
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = AIM_RADIUS * PPU
	query.shape = shape
	query.transform = Transform2D(0.0, crosshairs.global_position)
	query.collide_with_areas = true
	query.collide_with_bodies = false

	for hit in get_world_2d().direct_space_state.intersect_shape(query, 4):
		var target = hit.get("collider")
		if target != null and target.has_method("take_hit"):
			target.take_hit()
			return


func _service_altitude_warning(delta: float) -> void:
	_warn_cooldown += delta
	if Flight.altitude < ALTITUDE_WARN and _warn_cooldown > WARN_INTERVAL:
		_warn_cooldown = 0.0
		warn_sfx.play()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
