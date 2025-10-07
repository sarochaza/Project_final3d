# statue.gd (node ที่คุณโพสต์มา)
extends StaticBody3D

@onready var btn = $Open/Button2
@onready var label = $Open/Label
@onready var light = $Light
@onready var label2 = $Open/Label/Label2

var player_ref: Node3D = null
var statuevalue: int = 1
var gold: int = 0

var can_open: bool = false
var is_open: bool = false

func _ready() -> void:
	btn.hide()
	label.hide()
	light.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open") and can_open and not is_open:
		if player_ref.gold < 5:
			label2.text = " Statue want soul of demon!!  " + "("+ str(gold) + "/" + str(5) +")"
			label2.show()
			return
		else:
			statue()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		can_open = true
		btn.show()
		label.show()
		player_ref = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		can_open = false
		btn.hide()
		label.hide()
		if player_ref == body:
			player_ref = null

func statue() -> void:
	if is_open:
		return
	$AudioStreamPlayer2D.play()
	player_ref.gold -= 5
	is_open = true
	btn.hide()
	label.hide()
	light.visible = true

	if player_ref != null:
		# เรียก method add_sta ของ Player ถ้ามี
		if player_ref.has_method("add_sta"):
			player_ref.call("add_sta", statuevalue)
		else:
			# ถ้าไม่มี method ให้ลองเพิ่ม property แบบเดิม (น้อยปลอดภัย) — แต่ แจ้งเตือนด้วย
			var val = player_ref.get("sta")
			if val != null:
				player_ref.sta = val + statuevalue
				print("เพิ่ม sta ให้ผู้เล่นแบบ fallback +%d (ตอนนี้ %s)" % [statuevalue, str(player_ref.sta)])
				# ถ้าต้องการให้ Player ส่งสัญญาณจากที่นี่แทน (ไม่แนะนำ) ก็ต้อง connect Main กับ statue แทน
			else:
				print("ผู้เล่นไม่มีตัวแปร 'sta' และไม่มี method add_sta — ไม่สามารถเพิ่มค่าได้")
	else:
		print("ไม่มีผู้เล่นในพื้นที่ขณะเปิดหีบ")
