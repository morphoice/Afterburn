class_name Scoring
extends RefCounted

## Distance-banded scoring, one ladder per case.
##
## Each band is [floor distance, score at the floor, score added across the
## band, divisor]. The divisor is the span the source divides by, which is not
## always the gap to the next band, so it is carried per band rather than
## derived.

const HIT_BANDS: Array = [
	[15000.0, 500,   0,     1.0],
	[10000.0, 200, 200,  5000.0],
	[ 5000.0, 100, 100,  5000.0],
	[ 2000.0,  50,  50,  3000.0],
	[    0.0,  20,  30,  2000.0],
]

const KILL_BANDS: Array = [
	[8000.0, 300, 300, 12000.0],
	[4000.0, 150, 150,  4000.0],
	[1000.0,  50, 100,  3000.0],
	[   0.0,  20,  30,  1000.0],
]

## Aircraft the Tomcat has already passed score on their own ladder.
const REAR_KILL_BANDS: Array = [
	[4000.0, 150, 150, 2000.0],
	[2000.0,  75,  75, 2000.0],
	[   0.0,  30,  45, 2000.0],
]


static func for_hit(distance: float) -> int:
	return _banded(distance, HIT_BANDS)


static func for_kill(distance: float) -> int:
	return _banded(distance, KILL_BANDS)


static func for_rear_kill(distance: float) -> int:
	return _banded(distance, REAR_KILL_BANDS)


static func _banded(distance: float, bands: Array) -> int:
	for band in bands:
		var floor_distance: float = band[0]
		if distance < floor_distance:
			continue

		var base: int = band[1]
		var span: int = band[2]
		if span == 0:
			return base

		var divisor: float = band[3]
		return roundi(base + (distance - floor_distance) / divisor * span)

	return 0
