extends RigidBody2D

@export var player: Player
@export var max_speed: float = 350.0


@export var drive_force: float = 800.0


@export var aggro_radius: float = 1400.0
@export var lead_amount: float = 0.35          
@export var velocity_match: float = 0.25       
@export var wobble_amount: float = 0.18        
@export var wobble_hz: float = 1.4


@export var forward_friction_strength: float = 18.0
@export var sideways_friction_strength: float = 55.0
@export var lateral_grip: float = 0.15       

@onready var lens: Lens = $lens
@onready var hitbox: CollisionPolygon2D = $ChasingHitbox

var _wobble_t: float = 0.0

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	hitbox.disabled = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if !is_instance_valid(player) or !is_instance_valid(player.tank):
		return

	var tank := player.tank
	var to_player: Vector2 = tank.global_position - global_position
	var dist: float = to_player.length()

	var active := dist < aggro_radius
	if active:
		lens.active = true
		$AnimatedSprite2D.play("default")
	else:
		lens.active = false
		$AnimatedSprite2D.play("default")


	_apply_friction_like_tank(state, forward_friction_strength, sideways_friction_strength)
	_face_velocity(state)

	if !active:
		return


	var desired_dir := Vector2.ZERO
	if dist > 0.001:
		desired_dir = to_player / dist

	var lead: Vector2 = tank.linear_velocity * lead_amount
	var aim_point: Vector2 = tank.global_position + lead
	var aim_vec: Vector2 = (aim_point - global_position)
	if aim_vec.length() > 0.001:
		desired_dir = aim_vec.normalized()

	var desired_v: Vector2 = desired_dir * max_speed
	desired_v = desired_v.lerp(tank.linear_velocity, velocity_match)

	_wobble_t += state.step * wobble_hz
	var wobble_vec := Vector2(cos(_wobble_t * 6.28318), sin(_wobble_t * 6.28318))
	desired_v += wobble_vec * (max_speed * wobble_amount)

	
	var v: Vector2 = state.linear_velocity
	var dv: Vector2 = desired_v - v

	var forward := desired_dir
	if v.length() > 10.0:
		forward = v.normalized()
	var right := forward.orthogonal()

	var dv_forward: float = dv.dot(forward)
	var dv_side: float = dv.dot(right)

	
	var accel_vec: Vector2 = forward * dv_forward + right * (dv_side * lateral_grip)
	if accel_vec.length() > 0.001:
		accel_vec = accel_vec.normalized() * drive_force

	state.apply_force(accel_vec)

	# clamp speed
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed

func _apply_friction_like_tank(state: PhysicsDirectBodyState2D, fwd: float, side: float) -> void:
	var facing := Vector2.from_angle(rotation)

	var forward_velocity: Vector2 = state.linear_velocity.project(facing)
	var sideways_velocity: Vector2 = state.linear_velocity.slide(facing)

	if forward_velocity.length() > 0.001:
		state.apply_force(fwd * -forward_velocity.normalized())
	if sideways_velocity.length() > 0.001:
		state.apply_force(side * -sideways_velocity.normalized())

func _face_velocity(state: PhysicsDirectBodyState2D) -> void:
	if state.linear_velocity.length() > 6.0:
		rotation = state.linear_velocity.angle()
