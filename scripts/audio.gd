extends Node

## Sound bank for the cabinet. Names the clips once so scenes refer to them by
## role rather than by filename, and carries the mix the source set on each
## AudioSource as a linear volume.

const DIR = "res://assets/audio/"

const CLIPS := {
	"engine":      "Tomcat Engine.wav",
	"afterburner": "Tomcat Afterburner.wav",
	"enter":       "Tomcat Enter.wav",
	"gun":         "Gunshot.wav",
	"gun_single":  "GunshotSingle.wav",
	"gun_long":    "GunshotLong.wav",
	"explosion":   "Explosion.wav",
	"flyby":       "Mig Flyby.wav",
	"altitude":    "Altitude.wav",
	"theme":       "Afterburn.wav",
}

## Roles the source mixes below unity. Anything absent plays at full level.
const VOLUMES := {
	"engine":      0.1,
	"afterburner": 0.1,
	"gun":         0.1,
	"altitude":    0.508,
	"theme":       0.4,
}

## Bus carrying the engine note. It exists so the engine can be panned: a
## plain AudioStreamPlayer has no stereo pan, but an AudioEffectPanner on a bus
## does, and its range matches the source's panStereo.
const ENGINE_BUS = "Engine"

var _loaded: Dictionary = {}
var _engine_panner: AudioEffectPanner = null


func _ready() -> void:
	for role in CLIPS:
		var path: String = DIR + CLIPS[role]
		if ResourceLoader.exists(path):
			_loaded[role] = load(path)

	_build_engine_bus()


## Adds the engine bus and its panner, routed to Master.
func _build_engine_bus() -> void:
	if AudioServer.get_bus_index(ENGINE_BUS) != -1:
		return

	var index := AudioServer.bus_count
	AudioServer.add_bus(index)
	AudioServer.set_bus_name(index, ENGINE_BUS)
	AudioServer.set_bus_send(index, "Master")

	_engine_panner = AudioEffectPanner.new()
	AudioServer.add_bus_effect(index, _engine_panner)


func get_clip(role: String) -> AudioStream:
	return _loaded.get(role)


## Linear volume for a role, as decibels for a player's volume_db.
func get_volume_db(role: String) -> float:
	return linear_to_db(VOLUMES.get(role, 1.0))


## Places the engine in the stereo field. −1 is hard left, +1 hard right, the
## same range the source's panStereo uses.
func set_engine_pan(pan: float) -> void:
	if _engine_panner != null:
		_engine_panner.pan = clampf(pan, -1.0, 1.0)
