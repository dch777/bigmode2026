class_name Bullet extends RigidBody2D

var lifetime: float = 0

func _process(delta: float):
	lifetime += delta

	if lifetime > 2:
		expire()

func body_hit(body: Node):
	if $Bullet.visible:
		$ExplosionSound.playing = true
		$Bullet.visible = false
		$CPUParticles2D.emitting = true
		set_deferred("contact_monitor", true)

func expire():
	queue_free()
