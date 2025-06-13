class_name TelemetryBody extends StaticBody3D

@export_range(0.0, 1.0) var opacidad: float = 1.0
@export_range(0.0, 1.0) var reflexividad: float = 1.0


func _ready() -> void:
	visibility_changed.connect(_collision_status)


func _collision_status():
	if has_node("CollisionShape3D"):
		$CollisionShape3D.disabled = !visible
