extends CanvasLayer

## Heads-up display.
##
## Five fixed readouts: three static words and the two counts that change. The
## altitude count was never wired up in the source — the word stands alone and
## the altimeter it belonged to is commented out.

const UI_INTERVAL = 0.5

@onready var hit_count   : Label = $TextHitCount
@onready var score_count : Label = $TextScoreCount

var _elapsed: float = 0.0


func _ready() -> void:
	hit_count.text = "0"
	score_count.text = "0"


## The counts refresh twice a second rather than every frame.
func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed <= UI_INTERVAL:
		return

	_elapsed = 0.0
	hit_count.text = str(Flight.hits)
	score_count.text = str(Flight.score)
