extends Node3D

@onready var camera : Camera3D = $Camera3D
@onready var terrain : Terrain3D = $Terrain3D
@onready var exp_handler : Node = $Explosion_Handler
@onready var player_handler : Node = $Player_Manager

var RAY_LENGTH : float = 9999900000000.0
var get_position : bool = false
var flag_path : bool = false
var flag_explotion : bool = false

func _physics_process(delta: float) -> void:
	if get_position:
		var space_state = get_world_3d().direct_space_state
		var cam = $Camera3D
		var mousepos = get_viewport().get_mouse_position()

		var origin = cam.project_ray_origin(mousepos)
		var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		
		var result = space_state.intersect_ray(query)

		if !result.is_empty():
			var position_collition = result.position
			if flag_explotion:
				exp_handler.simulate_explosion(position_collition)
				flag_explotion = !flag_explotion
			if flag_path:
				player_handler.add_path(position_collition)
				flag_path = !flag_path
			
		get_position = !get_position
			



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("add_explotion"):
		get_position = true
		flag_explotion = true
	if event.is_action_pressed("add_path"):
		get_position = true
		flag_path = true
		
		
