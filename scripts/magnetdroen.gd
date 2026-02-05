extends RigidBody2D

@export var player: Player

@export var max_speed: float = 200.0
@export var drive_force: float = 350.0
@export var forward_friction_strength: float = 22.0
@export var sideways_friction_strength: float = 75.0
@export var lateral_grip: float = 0.35

@export var aggro_radius: float = 1200.0
@export var lock_radius: float = 360.0
@export var stop_radius: float = 220.0

@export var pull_strength: float = 150.0
@export var pull_falloff_radius: float = 360.0
@export var pull_cap: float = 120.0

@export var active_time: float = 1.2
@export var linger_time: float = 1.0
@export var cooldown_time: float = 5

@export var mouth_offset: Vector2 = Vector2(14, 0)

@onready var lens: Lens = $lens
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionPolygon2D = $ChasingHitbox

enum State { IDLE, APPROACH, ACTIVE, LINGER, COOLDOWN }
var state_mode: int = State.IDLE
var state_timer: float = 0.0

func _ready() -> void:
	if sprite.animation != "default":
		sprite.play("default")
	hitbox.disabled = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if !is_instance_valid(player) or !is_instance_valid(player.tank):
		return

	var tank := player.tank
	var to_player: Vector2 = tank.global_position - global_position
	var dist: float = to_player.length()

	match state_mode:
		State.IDLE:
			lens.active = false
			if sprite.animation != "default":
				sprite.play("default")
			if dist < aggro_radius:
				state_mode = State.APPROACH

		State.APPROACH:
			lens.active = false
			if sprite.animation != "default":
				sprite.play("default")
			if dist < lock_radius:
				state_mode = State.ACTIVE
				state_timer = active_time
			elif dist > aggro_radius * 1.2:
				state_mode = State.IDLE

		State.ACTIVE:
			lens.active = true
			if sprite.animation != "active":
				sprite.play("active")
			state_timer -= state.step
			if state_timer <= 0.0:
				state_mode = State.LINGER
				state_timer = linger_time

		State.LINGER:
			lens.active = true
			if sprite.animation != "default":
				sprite.play("default")
			state_timer -= state.step
			if state_timer <= 0.0:
				state_mode = State.COOLDOWN
				state_timer = cooldown_time

		State.COOLDOWN:
			lens.active = false
			if sprite.animation != "default":
				sprite.play("default")
			state_timer -= state.step
			if state_timer <= 0.0:
				state_mode = State.APPROACH

	_apply_friction_like_tank(state)

	if state_mode == State.IDLE:
		_face_velocity(state)
		return

	var desired_dir := Vector2.ZERO
	if dist > 0.001:
		desired_dir = to_player / dist

	var target_dir := desired_dir
	if dist < stop_radius:
		target_dir = -desired_dir

	var grip := lateral_grip
	var force := drive_force
	if state_mode == State.LINGER or state_mode == State.COOLDOWN:
		grip *= 0.65
		force *= 0.6

	var v: Vector2 = state.linear_velocity
	var forward: Vector2 = target_dir
	if v.length() > 10.0:
		forward = v.normalized()
	var right: Vector2 = forward.orthogonal()

	var desired_v: Vector2 = target_dir * max_speed
	var dv: Vector2 = desired_v - v

	var dv_forward: float = dv.dot(forward)
	var dv_side: float = dv.dot(right)

	var accel_vec: Vector2 = forward * dv_forward + right * (dv_side * grip)
	if accel_vec.length() > 0.001:
		accel_vec = accel_vec.normalized() * force

	state.apply_force(accel_vec)

	if state_mode == State.ACTIVE:
		_apply_magnet_pull(tank, dist)

	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed

	_face_velocity(state)

func _apply_magnet_pull(tank: RigidBody2D, dist: float) -> void:
	if dist > pull_falloff_radius or dist < 0.001:
		return

	var t: float = 1.0 - (dist / pull_falloff_radius)
	var strength: float = pull_strength * (t * t * t * t)
	if strength > pull_cap:
		strength = pull_cap

	var mouth_global: Vector2 = global_position + mouth_offset.rotated(rotation)
	var dir: Vector2 = (mouth_global - tank.global_position)
	if dir.length() < 0.001:
		return
	dir = dir.normalized()

	tank.apply_central_force(dir * strength)

func _apply_friction_like_tank(state: PhysicsDirectBodyState2D) -> void:
	var facing := Vector2.from_angle(rotation)

	var forward_velocity: Vector2 = state.linear_velocity.project(facing)
	var sideways_velocity: Vector2 = state.linear_velocity.slide(facing)

	if forward_velocity.length() > 0.001:
		state.apply_force(forward_friction_strength * -forward_velocity.normalized())
	if sideways_velocity.length() > 0.001:
		state.apply_force(sideways_friction_strength * -sideways_velocity.normalized())

func _face_velocity(state: PhysicsDirectBodyState2D) -> void:
	if state.linear_velocity.length() > 6.0:
		rotation = state.linear_velocity.angle()
