extends Node3D

#@onready var path = %Path
#@onready var path_follow = %PathFollower
#@onready var model = $Path/PathFollower/RigidBody3D/MeshInstance3D
@export var path_points : int = 10
@export var speed : float = 5.0
var flag_movement : bool = false
var offset_height : int
#
#func _ready() -> void:
	#offset_height = model.mesh.height / 2.0
#
#
#func _process(delta: float) -> void:
	#if flag_movement:
		#path_follow.progress += (delta * speed)
		#if path_follow.progress_ratio == 1.0:
			#flag_movement = !flag_movement
			#path.set_curve(Curve3D.new())
			#path_follow.progress = 0.0

func  run_to_cover_from(explotion : Vector3) -> void:		
	$RigidBody3D.run_to_cover_from(explotion)
	#var path_init = model.global_position
	#var path_direction = - model.global_position.direction_to(explotion)
	#var path_curve : Curve3D = Curve3D.new()
	#for i in range(path_points):
		#var path_road = Vector3.ZERO
		#var ground_height = get_ground_height(path_init)
		#if ground_height == -INF:
			#break
		#path_init.y = ground_height
		#path_road += path_direction * i
		#path_road.y = path_init.y - model.global_position.y + offset_height
		#path_curve.add_point(path_road)
		#path_init += path_direction
	#if flag_movement:
		#path.set_curve(path_curve)
		#path_follow.progress = 0.0
	#else: 
		#flag_movement = true
	#
		
func get_ground_height(position_a: Vector3, max_distance: float = 100.0) -> float:
	var from = position_a
	var to = position_a - Vector3.UP * max_distance

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]  # para no colisionar con uno mismo

	var result = space_state.intersect_ray(query)
	if result:
		return result.position.y  # Altura del terreno
	else:
		return -INF  # No se detectó terreno
