extends CharacterBody3D

@onready var ray : RayCast3D = $RayCast3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal get_new_path(target: Node, actual_position: Vector3, facing : Vector3, points : int)

var flag_mover : bool = false
var flag_formar : bool = false
var flag_loop : bool = false

var pos_formacion : Vector3


var last_expl_position : Vector3


@export var velocity_speed : float = 5.0
@export var path_points : int = 10
var path_position : int = 0
var path_array : Array[Vector3]
var return_path_array : Array[Vector3]


func _physics_process(delta):
	if !self.is_on_floor():
		velocity.y -= gravity * delta
	if flag_mover:
		if ray.is_colliding():
			var parent = ray.get_collider().get_parent().get_name()
			if parent != 'Terrain':
				flag_mover = !flag_mover
				check_clean_path()
				return
		if global_position.distance_to(path_array[0]) < 2:
			remove_point_in_path()
			if path_array.size() > 0:
				look_at(path_array[0])
				move_forward()
				path_position += 1
			else:
				path_position = 0
				if flag_loop:
					path_array = return_path_array
					return_path_array.clear()
				else:
					flag_mover = !flag_mover
					velocity = Vector3.ZERO
		else:
			move_forward()
				
	if flag_formar:
		if position.distance_to(pos_formacion) <= 10.0:
			flag_formar = !flag_formar
			velocity = Vector3.ZERO
		if ray.is_colliding(): 
			var parent = ray.get_collider().get_parent().get_name()
			if parent != 'Terrain':
				check_clean_path()
		move_forward()



func check_clean_path() -> void:
	var hit_normal = ray.get_collision_point().normalized()
	var ray_normal = ray.target_position.normalized()
	var dot_prod = ray_normal.dot(hit_normal)
	if dot_prod < -0.9:
		rotate_me(deg_to_rad(90.0))
	else:
		var cos_angle = acos(dot_prod)
		var sin_angle = asin(dot_prod)
		var vec_left = position + ray.target_position * cos_angle
		var vec_right = position + ray.target_position * sin_angle
		var dist1 = vec_left.distance_to(last_expl_position)
		var dist2 = vec_right.distance_to(last_expl_position)
		if dist1 < dist2 :
			rotate_me(cos_angle / 4.0)
		else:
			rotate_me(sin_angle / 4.0)
		
		
func rotate_me(angle):
	rotate_y(angle)
	ray.target_position = -transform.basis.z.normalized()
	get_new_path.emit(self, global_position, global_transform.basis.z, path_position)
	
	
func move_forward():
	var forward = -global_transform.basis.z.normalized()
	velocity = forward * velocity_speed
	if !self.is_on_floor():
		velocity.y -= gravity
	move_and_slide()

	
func formar_en(posicion: Vector3) -> void:
	look_at(posicion)
	flag_formar = !flag_formar
	pos_formacion = posicion
		
	
func remove_point_in_path() -> void:
	if flag_loop:
		return_path_array.append(path_array[0])
		path_array.remove_at(0)
	else:
		path_array.remove_at(0)
		var path_point = self.find_child("Path", true, false)
		var child = path_point.get_child(0)
		child.free()
	
	
	
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
		
func swap_to_new_path(new_path: Array) -> void:
	if new_path.size() > 0 :
		path_array = new_path
		flag_mover = true
		look_at(path_array[0])
		move_forward()
		
func clear_path() ->void:
	var path = get_node('./Path')
	if path != null:
		for child in path.get_children():
			child.free()
			path_array.clear()
			
			
#Movimiento sin path a mano:
#var explotion_added : bool = false

#func run_to_cover_from(explotion_position: Vector3):
	#last_expl_position = explotion_position
	#explotion_added = true
	#var my_position = self.global_transform.origin
	#var direction_to_target = (explotion_position - my_position).normalized()
#
	#var opposite_direction = -direction_to_target
	#opposite_direction.y = 0.0
	#
	#var fake_target = my_position + opposite_direction
	#look_at(fake_target)
	#ray.look_at(fake_target)
	
#func _physics_process(delta: float) -> void:	
	#if explotion_added:
		#var distance_to_exp = position.distance_to(last_expl_position)
		#if distance_to_exp < 30.0:
			#if ray.is_colliding():
				#var parent = ray.get_collider().get_parent().get_name()
				#if parent != 'Terrain':
					##velocity = Vector3.ZERO
					#check_clean_path()
			#else:
				#move_forward()
		#else:
			#explotion_added = !explotion_added
	#
	#
#func add_path(to: Vector3) -> void:
	#var path_init
	#if path_array.is_empty():
		#path_init = position
	#else:
		#path_init = path_array.get(path_array.size() - 1)
#
	#for i in range(path_points):
		#var t = float(i) / float(path_points)
		#var punto_intermedio = path_init.lerp(to, t)
		#var ground_height = get_ground_height(punto_intermedio)
		#if ground_height == -INF:
			#break
		#path_array.append(punto_intermedio)
