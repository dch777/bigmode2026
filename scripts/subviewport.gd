class_name SkidTracks
extends SubViewport

@export var player: Player
@export var wheel_rects: Array[PackedVector2Array]
# Each element = 4 points defining a wheel rectangle in LOCAL space

var mesh := ImmediateMesh.new()
var mesh_instance: MeshInstance2D

# Per-wheel previous frame data
var prev_corners: Array = []
var has_prev := false


# func _ready():
# 	mesh_instance = $MeshInstance2D
# 	mesh_instance.mesh = mesh


# func _process(_delta):
# 	if player == null or player.tank == null:
# 		return

# 	if !player.tank.skidding:
# 		has_prev = false
# 		return

# 	var xf := player.tank.global_transform

# 	var curr_corners := []

# 	for rect in wheel_rects:
# 		var world := PackedVector2Array()
# 		for p in rect:
# 			world.append(xf * p)
# 		curr_corners.append(world)

# 	if !has_prev:
# 		prev_corners = curr_corners
# 		has_prev = true
# 		return

# 	mesh.clear_surfaces()
# 	for i in curr_corners.size():
# 		_draw_wheel(prev_corners[i], curr_corners[i])

# 	prev_corners = curr_corners

# func _draw_wheel(prev: PackedVector2Array, curr: PackedVector2Array):
# 	for i in range(4):
# 		var a := prev[i]
# 		var b := prev[(i + 1) % 4]
# 		var c := curr[i]
# 		var d := curr[(i + 1) % 4]

# 		_add_quad(a, b, c, d)

# func _add_quad(a: Vector2, b: Vector2, c: Vector2, d: Vector2):
# 	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

# 	# Triangle 1
# 	mesh.surface_add_vertex(Vector3(a.x, a.y, 0))
# 	mesh.surface_add_vertex(Vector3(b.x, b.y, 0))
# 	mesh.surface_add_vertex(Vector3(c.x, c.y, 0))

# 	# Triangle 2
# 	mesh.surface_add_vertex(Vector3(c.x, c.y, 0))
# 	mesh.surface_add_vertex(Vector3(b.x, b.y, 0))
# 	mesh.surface_add_vertex(Vector3(d.x, d.y, 0))

# 	mesh.surface_end()
