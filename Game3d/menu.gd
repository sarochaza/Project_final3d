extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	$AudioStreamPlayer2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		get_tree().quit() 

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_story_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/story.tscn")
