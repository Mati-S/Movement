extends VehicleBody3D

signal point_achieved()

@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 40.0
@export var ROTATE_SPEED = .5

@export var path_points : int = 10
var path_array : Array[Vector3]
var return_path_array : Array[Vector3]

var flag_movement : bool = false
var flag_loop: bool = false
var flag_rotate : bool = false

var movement_timer : Timer

@onready var vivo : MeshInstance3D = $Vivo

#
#func _ready():
	#ENGINE_POWER = self.mass * 1.0

func _physics_process(delta: float) -> void:
	if flag_movement:
		if flag_rotate:
			rotate_towards_target(delta)
		else:
			var parent = self.get_parent()
			var target_position = path_array[0]
			if global_position.distance_to(path_array[0]) < 5:
				point_achieved.emit()
				if path_array.size() == 0:
					flag_movement = !flag_movement
					engine_force = 0.0
					brake = 1.0
			else:

				var to_target = (target_position - global_transform.origin)
			
				var local_target = global_transform.basis.inverse() * to_target

				var angle_to_target = atan2(local_target.x, local_target.z)

				steering = clamp(angle_to_target, -MAX_STEER, MAX_STEER)

				var distance = to_target.length()
				if distance > 1.0:
					engine_force = ENGINE_POWER
				parent.global_position += parent.global_position.direction_to(path_array[0]) * delta * 10

func rotate_towards_target(delta: float):
	var to_target = (path_array.front() - global_transform.origin).normalized()
	to_target.y = 0

	var facing = -global_transform.basis.z.normalized()
	facing.y = 0

	var alignment = facing.dot(to_target)
	if alignment <= -0.99:
		clear_timer()
		return

	var target_angle = atan2(-to_target.z, to_target.x)
	var current_angle = rotation.y
	rotation.y = lerp_angle(current_angle, target_angle, ROTATE_SPEED * delta)
	print(movement_timer.time_left)

	
func _on_timer_timeout():
	clear_timer()

func clear_timer():
	flag_rotate = false
	movement_timer.stop()
	movement_timer.queue_free()
