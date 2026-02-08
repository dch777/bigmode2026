extends RigidBody2D
class_name BloodDroplet

@export var bake_time := 0.25
@export var slow_speed := 35.0
@export var slow_frames_needed := 4

@export var stain_min_scale := 1.0
@export var stain_max_scale := 2.0
@export var stain_color := Color(0.8, 0.0, 0.0, 1.0)

@export var stamps_min := 2
@export var stamps_max := 4
@export var stamp_scatter := 2.0

var _baked := false
var _slow_frames := 0

func _ready() -> void:
	get_tree().create_timer(bake_time).timeout.connect(_bake_to_ground)

func _physics_process(_delta: float) -> void:
	if _baked:
		return

	if linear_velocity.length() < slow_speed:
		_slow_frames += 1
		if _slow_frames >= slow_frames_needed:
			_bake_to_ground()
	else:
		_slow_frames = 0

func _bake_to_ground() -> void:
	if _baked:
		return
	_baked = true

	var blood_layer := get_tree().get_first_node_in_group("blood_layer")
	if blood_layer == null:
		queue_free()
		return

	var tex := ($Sprite as Sprite2D).texture
	var stamps := randi_range(stamps_min, stamps_max)

	for i in range(stamps):
		var stain := Sprite2D.new()
		stain.texture = tex
		stain.modulate = stain_color

		var s := randf_range(stain_min_scale, stain_max_scale)
		stain.scale = Vector2(s, s)
		stain.rotation = randf_range(0.0, TAU)

		blood_layer.add_child(stain)
		stain.global_position = global_position + Vector2(
			randf_range(-stamp_scatter, stamp_scatter),
			randf_range(-stamp_scatter, stamp_scatter)
		)
		
		stain.call_deferred("queue_free")
		#stain.z_index = clampi(int(stain.global_position.y), -4096, 4096)

	queue_free()
