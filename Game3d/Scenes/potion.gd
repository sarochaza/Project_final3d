extends StaticBody3D
var potion: int = 0   
var target = null
var valuepotion = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("players"):
		body.potion += valuepotion          # เพิ่มค่า key ของ player โดยตรง
		queue_free()  


	
