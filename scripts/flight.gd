extends Node

## The state every part of the world needs to place itself in depth: where the
## sky has drifted to, how high the Tomcat is flying, and the running score.
##
## The source had each MiG reach into the player by name to read these. Holding
## them here instead means enemies never need to know the player exists.

const MAX_ALTITUDE   = 30000.0
const START_ALTITUDE = 10000.0
const SPAWN_DISTANCE = 20000.0

## Where the sky has been pushed to by the player's stick, in pixels. Enemies
## displace against this to sell the illusion of turning.
var sky_position: Vector2 = Vector2.ZERO

var altitude: float = START_ALTITUDE:
	set(value):
		altitude = clampf(value, 0.0, MAX_ALTITUDE)

var score: int = 0
var hits: int = 0


func reset() -> void:
	sky_position = Vector2.ZERO
	altitude = START_ALTITUDE
	score = 0
	hits = 0


func add_score(points: int) -> void:
	score += points


func register_kill(points: int) -> void:
	score += points
	hits += 1


## How far from the horizon a target at this distance appears, 0 at the spawn
## point and 1 in the player's face.
func depth_ratio(distance: float) -> float:
	return 1.0 - clampf(distance / SPAWN_DISTANCE, 0.0, 1.0)
