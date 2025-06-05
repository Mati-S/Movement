extends AnimatedSprite3D

func _ready():
	play("default")

func _on_animation_looped():
	stop()
