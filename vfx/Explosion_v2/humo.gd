extends Node3D

# Señales
signal explosion_ended(smoke : Node3D)

@onready var anim := $AnimationPlayer
@onready var smoke := $HumoPrincipal

@export var time_scale : float = 1.0
@export var spread : float = 1.0


func _ready():
	var h : ParticleProcessMaterial = $HumoPrincipal.process_material
	h.damping_max *= spread
	# $HumoPrincipal.process_material.spread =  90.0 * spread
	# $AnimationPlayer.speed_scale = time_scale
	$AnimationPlayer.play("Explosion")


func _on_viento_y_value_changed(value):
	$HumoPrincipal.process_material.direction.z = value
	$HumoPrincipal.process_material.gravity.z = value
	if value == 0:
		$HumoPrincipal.process_material.damping = Vector2(0.0, 100.0)
	else:
		$HumoPrincipal.process_material.damping = Vector2(0.0, 10.0)

func _on_viento_x_value_changed(value):
	$HumoPrincipal.process_material.direction.x = value
	$HumoPrincipal.process_material.gravity.x = value
	if value == 0:
		$HumoPrincipal.process_material.damping = Vector2(0.0, 100.0)
	else:
		$HumoPrincipal.process_material.damping = Vector2(0.0, 10.0)

func _on_rain_value_changed(enabled : bool):
	if enabled:
		
		$HumoPrincipal.amount_ratio = .2
		$HumoPrincipal.interp_to_end = .005
	else:
		$HumoPrincipal.amount_ratio = 1.0
		$HumoPrincipal.interp_to_end = 0.0
		

func _on_button_pressed():
	$HumoPrincipal.process_material.direction.x = 0
	$HumoPrincipal.process_material.direction.z = 0


func _on_smoke_finished():
	explosion_ended.emit(self)
