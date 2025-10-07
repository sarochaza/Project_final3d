extends Node3D

@onready var note1 = $CanvasLayer/note1
@onready var note2 = $CanvasLayer/note2
@onready var sfx = $AudioStreamPlayer2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	note1.visible = true
	note2.visible = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_next_pressed() -> void:
	if note1.visible == true:
		sfx.play()
		note1.visible = false
		note2.visible = true
		$CanvasLayer/Next.hide()
	else:
		return


func _on_back_pressed() -> void:
	if note2.visible == true:
		note2.visible = false
		note1.visible = true
		$CanvasLayer/Next.show()
		sfx.play()
	else:
		return


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
