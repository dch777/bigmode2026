# https://jreo.itch.io/jreo-sva

@tool
class_name SVA
extends Resource

@export var pitch_calibrate: float = 7600
@export var highest_index_rpm: float = 7000
@export var lowest_index_rpm: float = 1000

@export var on_throttle_offset: float
@export var off_throttle_offset: float
@export_range(0,1) var reverberance: float

@export var overall_volume: float = 1
@export var off_volume_multiplier: float = 1

@export var before_vvt_index: float = 1000.0
@export var after_vvt_add_index: float = 0.0

@export var Streams: Array:
	get:
		return Streams
	set(val):
		if val.size()>0:
			if not val[val.size()-1]:
				var new_id: int = val.size()-1
				val[new_id] = [
					"audio_file_here",
					0,
					100000,
					1.0,
					1.0,
				]
		Streams = val
