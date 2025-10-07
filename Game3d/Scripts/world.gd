extends Node3D

@onready var light = $DirectionalLight3D
@onready var player = $Players
#@onready var control = get_node_or_null("Control")

func _ready() -> void:
	light.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#if not control:
		#push_error("Control node not found! ตรวจชื่อและ path ให้ถูกต้อง")
		#return
	#control.show()  # ใช้งานต่อได้ปลอดภัย
	player.sta_full.connect(_on_players_sta_full)
	$Teach.show()
	$startgame.play()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	pass


func _on_startsound_timeout() -> void:
	$Soundgame.play()
	$Soundgame2.play()


func _on_close_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Teach.hide()


func _on_players_sta_full() -> void:
	light.visible = true
	$AudioStreamPlayer2D.play()
	print("ไฟถูกเปิดแล้ว! 🎉")
