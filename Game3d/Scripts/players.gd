extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var onCooldown = false
var sensivity = 0.003
var gold: int = 30
var hp = 100
var maxHp = 100
var damage = 10
var target = []
var key: int = 6
var potion: int = 0
var sta: int = 3
# --- เพิ่มตัวแปรนี้เพื่อเก็บจำนวนศัตรูที่อยู่ในโซน regen ---
var enemies_in_regen_area: int = 0
signal sta_full
var max_sta: int = 4  # กำหนดเงื่อนไข เช่น ต้องครบ 3


@onready var camera = $FirstPerson
@onready var animatonPlayer = $AnimationPlayer
@onready var cooldown = $AttackCooldown
@onready var hpBar = $HUD/HpBar
@onready var goldlabel = $HUD/Goldlabel
@onready var keylabel = $HUD/keylabel
@onready var statuelabel = $HUD/statuelabel
@onready var Potionlabel = $HUD/Potionlabel
@onready var animation = $"pivot/Root Scene/AnimationPlayer"

func players():
	pass

func deal_damage():
	for enemies in target:
		enemies.hp -= damage
	
func _ready():
	animatonPlayer.play("Start game")
	$Control.hide()
	animatonPlayer.play("idle")
	hpBar.max_value = 100
	$FirstPerson.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func attack():
	if Input.is_action_just_pressed("attack") and onCooldown == false:
		animatonPlayer.play("SwordSwing")
		onCooldown = true
		$Swordsound.play()
		cooldown.start()
			
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		
		rotate_y(-event.relative.x * sensivity)
		camera.rotate_x(-event.relative.y *sensivity)
		camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-60),deg_to_rad(70))
		
func update_HUD():
	hpBar.value = hp
	hpBar.max_value = maxHp   # เพื่อให้ bar รู้ค่าสูงสุด
	
	# แสดงค่าแบบ x / max
	goldlabel.text = str(gold) + "/" + str(25)
	keylabel.text  = str(key)  + "/" + str(7)
	Potionlabel.text = str(potion)
	statuelabel.text = str(sta) + "/" + str(4)

	
func _switch_view():
	if Input.is_action_just_pressed("switch"):
		if camera == $FirstPerson:
			camera = $Head
			$Head/ThirdPerson.current = true
		else:
			camera = $FirstPerson
			$FirstPerson.current = true
	
	
func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		animation.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		animation.play("Idle")
	
	move_and_slide()

func _process(delta): 
	update_HUD()
	attack()
	_switch_view()
	if Input.is_action_just_pressed("escape"): 
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
	drink_potion()
	gameover()


func _on_attack_cooldown_timeout() -> void:
	onCooldown = false


func _on_attack_zone_body_entered(body):
	if body.is_in_group("enemies"):
		target.append(body)


func _on_attack_zone_body_exited(body) :
	if body.is_in_group("enemies"):
		target.erase(body)


# ------------------ Regen logic (แก้ไขที่นี่) ------------------

func regen():
	# เรียกให้แสดงค่า current hp บน bar (defensive)
	hpBar.value = hp
	# ถ้าไม่มีศัตรูในโซน และเลือดยังไม่เต็ม และยังไม่ตาย ให้เริ่ม timer
	if enemies_in_regen_area == 0 and hp > 0 and hp < maxHp:
		if not $regen.is_stopped():
			# ถ้า timer กำลังทำงานอยู่แล้ว ไม่ต้องเริ่มซ้ำ
			return
		$regen.start()
	else:
		# ถ้ามีศัตรูในโซนหรือเลือดเต็ม หรือผู้เล่นตาย ให้หยุด timer
		if $regen.is_stopped() == false:
			$regen.stop()

func _on_regen_timeout() -> void:
	# ฟื้นเลือดทีละหน่วย (7) เมื่อ timer หมดเวลา
	# แต่ฟื้นเฉพาะเมื่อยังไม่มีศัตรูในโซน (ป้องกัน race condition)
	if enemies_in_regen_area == 0 and hp > 0:
		hp = min(hp + 9, maxHp)
		hpBar.value = hp

		# ถ้าฟื้นจนเต็มแล้ว ให้หยุด timer
		if hp >= maxHp:
			if $regen.is_stopped() == false:
				$regen.stop()
	else:
		# ถ้ามีศัตรูเข้ามาแล้ว ให้หยุด timer
		if $regen.is_stopped() == false:
			$regen.stop()
	
func gameover():
	# Trigger game over once when hp drops to zero or below.
	if hp <= 0:
		# Ensure hp never goes negative
		hp = 0
		# Update HUD immediately
		hpBar.value = hp

		# If the Control (game over UI) is already visible, do nothing more.
		# This prevents repeated triggers / repeated animation plays.
		if $Control.visible:
			return

		# Play death animation (only once)
		if animatonPlayer.current_animation != "Death":
			animatonPlayer.play("Death")

		# Show the game-over UI and newgame button
		$Control.show()
	

		# Stop movement & processing so character can't move or act after death
		set_process(false)
		set_physics_process(false)

		# Make mouse visible so player can click UI
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		# Make sure first-person camera isn't capturing input anymore
		# (safeguard: try to unset current cameras if present)
		if has_node("$FirstPerson"):
			$FirstPerson.current = false
		if has_node("$Head/ThirdPerson"):
			$Head/ThirdPerson.current = false

		# Stop timers (safe to call stop even if they are already stopped)
		if has_node("$regen"):
			$regen.stop()
		if cooldown:
			# cooldown is onready var at top — stop it too
			cooldown.stop()




func _on_regen_body_exited(body: Node3D) -> void:
	# เมื่อมี body ออกจากโซน regen ถ้าเป็นศัตรู ให้ลด counter
	if body.is_in_group("enemies"):
		enemies_in_regen_area = max(enemies_in_regen_area - 1, 0)
		# ถ้าในโซนไม่มีศัตรูแล้ว ให้ลองเริ่ม regen (ถ้า hp ยังไม่เต็ม)
		if enemies_in_regen_area == 0:
			regen()

func _on_regen_body_entered(body: Node3D) -> void:
	# เมื่อมี body เข้าสู่โซน regen ถ้าเป็นศัตรู ให้เพิ่ม counter และหยุด regen
	if body.is_in_group("enemies"):
		enemies_in_regen_area += 1
		# หยุด timer ทันทีเมื่อมีศัตรูเข้ามา
		if $regen.is_stopped() == false:
			$regen.stop()
	# ถ้เป็น non-enemy (เช่น ผู้เล่นเข้ามา trigger), ถ้า hp > 0 ก็เรียก regen เพื่อให้ฟังก์ชันตรวจสอบเงื่อนไข
	else:
		# เรียก regen เผื่อผู้เล่นเป็นคนเข้าโซน (ถ้ามีการใช้ Area แบบ player เข้าออก)
		if hp > 0:
			regen()
func drink_potion():
	# ตรวจสอบ input
	if Input.is_action_just_pressed("potion"):
		if potion > 0:
			# เพิ่มเลือด ไม่เกิน max_hp
			hp = min(hp + 100, maxHp)
			hpBar.value = hp
			
			# ลดจำนวน potion
			potion -= 1
			print("Potion used! Remaining:", potion)
		else:
			print("Potion is empty!")

func add_sta(value: int):
	sta += value
	if sta >= max_sta:
		emit_signal("sta_full")
