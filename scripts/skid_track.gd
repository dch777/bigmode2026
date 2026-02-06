extends MeshInstance2D

@export var player: Player
@export var wheel_rect: PackedVector2Array

var im = ImmediateMesh.new()

# Per-wheel previous frame data
var prev_corners: Array = []
var prev_speed: float
var has_prev := false

func _ready():
	mesh = im

func _process(_delta):
	mesh.clear_surfaces()
	if player == null or player.tank == null:
		return

	if player.tank.slip_curve < 0.01:
		if has_prev:
			_add_quad(prev_corners[3], prev_corners[2], prev_corners[0], prev_corners[1], prev_speed, prev_speed, 0, 1)
		has_prev = false
		return

	var xf := player.tank.global_transform

	var curr_corners := []
	for p in wheel_rect:
		curr_corners.append(xf * p)

	var curr_speed = player.tank.slip_curve #clamp((player.tank.linear_velocity.length() - 200) / 300, 0, 1)

	if !has_prev:
		prev_corners = curr_corners
		prev_speed = curr_speed
		has_prev = true
		_add_quad(curr_corners[3], curr_corners[2], curr_corners[0], curr_corners[1], curr_speed, curr_speed, 0, 1)
		return

	for i in range(4):
		var a = prev_corners[i]
		var b = prev_corners[(i + 1) % 4]
		var c = curr_corners[i]
		var d = curr_corners[(i + 1) % 4]

		_add_quad(a, b, c, d, prev_speed, curr_speed, int(i % 3 != 0), int(i < 2))

	prev_corners = curr_corners
	prev_speed = curr_speed

func _add_quad(a: Vector2, b: Vector2, c: Vector2, d: Vector2, ab_uv: float, cd_uv: float, ac_uv: float, bd_uv: float):
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	# Triangle 1
	mesh.surface_set_uv(Vector2(ab_uv, ac_uv))
	mesh.surface_add_vertex(Vector3(a.x, a.y, 0))
	mesh.surface_set_uv(Vector2(ab_uv, bd_uv))
	mesh.surface_add_vertex(Vector3(b.x, b.y, 0))
	mesh.surface_set_uv(Vector2(cd_uv, ac_uv))
	mesh.surface_add_vertex(Vector3(c.x, c.y, 0))

	# Triangle 2
	mesh.surface_set_uv(Vector2(cd_uv, ac_uv))
	mesh.surface_add_vertex(Vector3(c.x, c.y, 0))
	mesh.surface_set_uv(Vector2(ab_uv, bd_uv))
	mesh.surface_add_vertex(Vector3(b.x, b.y, 0))
	mesh.surface_set_uv(Vector2(cd_uv, bd_uv))
	mesh.surface_add_vertex(Vector3(d.x, d.y, 0))

	mesh.surface_end()
