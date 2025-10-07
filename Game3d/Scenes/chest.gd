extends StaticBody3D

@export var key_scene: PackedScene
@export var potion_scene: PackedScene

@onready var btn = $Open/Button2
@onready var label = $Open/Label
@onready var open_chest = $OpenChest
@onready var close_chest = $CloseChest

var can_open: bool = false
var is_open: bool = false


# RNG instance
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()                  # สุ่ม seed
	btn.hide()
	label.hide()
	open_chest.visible = false
	close_chest.visible = true

func _process(delta: float) -> void:
	if can_open and Input.is_action_just_pressed("open"):
		toggle_chest()

func _on_check_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		can_open = true
		btn.show()
		label.show()
	if is_open:
		btn.hide()
		label.hide()
func _on_check_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		can_open = false
		btn.hide()
		label.hide()

func toggle_chest():
	if is_open:
		return  # ถ้าเปิดแล้ว ไม่ทำอะไร

	# เปิดสมบัติครั้งเดียว
	is_open = true
	open_chest.visible = true
	close_chest.visible = false

	btn.hide()
	label.hide()

	# spawn item ครั้งเดียว
	drop_item()


func drop_item() -> void:
	# ความน่าจะเป็น: key 30% / potion 70%
	# ใช้ rng.randf() คืนค่า 0.0 - 1.0
	var r = rng.randf()
	var item_instance: Node = null

	if r < 0.45:
		if key_scene:
			item_instance = key_scene.instantiate()
			print("Spawned KEY (30%)")
		else:
			print("key_scene not set!")
	else:
		if potion_scene:
			item_instance = potion_scene.instantiate()
			print("Spawned POTION (70%)")
		else:
			print("potion_scene not set!")

	if item_instance:
		# เพิ่มเข้าใน world — ปรับ parent ตามโครงสร้างของคุณ
		# ถ้า chest อยู่ใต้ node "world" ก็ใช้ get_parent() หรือ get_tree().get_current_scene()
		var parent_node = get_parent() if get_parent() != null else get_tree().get_current_scene()
		parent_node.add_child(item_instance)

		# วางตำแหน่งให้เหนือหีบเล็กน้อย (item ถ้าเป็น RigidBody3D จะตกลงมา)
		var spawn_pos = global_transform.origin + Vector3(0, 0.6, 0)
		# ถ้าเป็น Node3D ให้ตั้ง global_transform.origin (หรือ translation) ได้
		if item_instance is Node3D:
			var t = item_instance.global_transform
			t.origin = spawn_pos
			item_instance.global_transform = t
