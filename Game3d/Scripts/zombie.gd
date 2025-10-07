extends CharacterBody3D


enum States {attack , idle ,chase , die}
var state = States.idle
var hp = 30
var speed = 3
var accel = 10
var damage = 35
var gravity = 9.8
var target = null
var value = 1

@export var navAgent : NavigationAgent3D
@export var animationPlyer : AnimationPlayer


func enemy():
	pass
func _process(delta):
	if hp <= 0:
		state = States.die

func give_loot():
	target.gold += value
	
func _physics_process(delta) :
	if state == States.idle:
		velocity = Vector3(0,velocity.y,0)
		animationPlyer.play("Idle")
	elif state == States.chase:
		look_at(Vector3(target.global_position.x,global_position.y,global_position.z),Vector3.UP,true)
		navAgent.target_position = target.global_position
		
		var direction = navAgent.get_next_path_position() - global_position
		direction= direction.normalized()
		
		velocity = velocity.lerp(direction * speed,accel * delta)
		animationPlyer.play("Walk")
		
	elif state == States.attack:
		look_at(Vector3(target.global_position.x,global_position.y,global_position.z),Vector3.UP,true)
		animationPlyer.play("Punch")
		velocity = Vector3.ZERO
		
	elif state == States.die:
		animationPlyer.play("Die")
		velocity = Vector3.ZERO	
	move_and_slide()
	
func attack():
	target.hp -= damage
	
func _on_chase_area_body_entered(body):
	if body.has_method("players") and state != States.die:
		$AudioStreamPlayer2D.play()
		target = body
		state = States.chase

func _on_chase_area_body_exited(body):
	if body.has_method("players")and state != States.die:
		target = null
		state = States.idle


func _on_attack_area_body_entered(body) :
	if body.has_method("players")and state != States.die:
		state = States.attack


func _on_attack_area_body_exited(body):
	if body.has_method("players")and state != States.die:
		state = States.chase
