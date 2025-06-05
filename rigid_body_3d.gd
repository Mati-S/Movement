extends RigidBody3D

@export var path_points : int = 10
@export var speed : float = .25
var path_array : Array[Vector3]
var direction_movement : Vector3

var flag_movement : bool = false
var offset_height : int = 1.0




func _physics_process(delta: float) -> void:
	#if flag_movement:
		#if position.distance_to(path_array[0]) < 0.5:
			#path_array.remove_at(0)
			#if path_array.size() == 0:
				#flag_movement = !flag_movement
				#self.freeze
				#direction_movement = Vector3.ZERO
			#else:
				#direction_movement = position.direction_to(path_array[0])
		#else:
			#if direction_movement == Vector3.ZERO:
				#direction_movement = position.direction_to(path_array[0])
			#add_constant_central_force(direction_movement * speed * delta)
	pass


func  run_to_cover_from(explotion : Vector3) -> void:		
	var path_init = position
	var path_direction = - position.direction_to(explotion)
	var new_path : Array[Vector3] = []
	if flag_movement:
		self.freeze
	for i in range(path_points):
		path_init +=  2 * path_direction
		var ground_height = get_ground_height(path_init)
		if ground_height == -INF:
			break
		path_init.y = ground_height
		path_init.y += offset_height
		new_path.append(path_init)
	path_array = new_path
	#direction_movement = path_array[0]
	flag_movement = true
	
		
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
