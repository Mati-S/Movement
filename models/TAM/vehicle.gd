extends VehicleBody3D


@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 300.0

@export var path_points : int = 10
var path_array : Array[Vector3]

var flag_movement : bool = false

func _ready():
	ENGINE_POWER = self.mass * 3.0

func _physics_process(delta: float) -> void:
	if flag_movement:
		var target_position = path_array[0]
		if position.distance_to(target_position) < 0.5:
			path_array.remove_at(0)
			if path_array.size() == 0:
				flag_movement = !flag_movement
				engine_force = 0.0
				brake = 1.0
		else:
			
			#var angle_towards_next = position.angle_to()
			#var distance = position.distance_to(target_position)
			#steering = angle_towards_next
			#engine_force = ENGINE_POWER
			
			var to_target = (target_position - global_transform.origin)
	
			var local_target = global_transform.basis.inverse() * to_target

			var angle_to_target = atan2(local_target.x, local_target.z)

			steering = clamp(angle_to_target, -MAX_STEER, MAX_STEER)

			var distance = to_target.length()
			if distance > 1.0:
				engine_force = ENGINE_POWER
