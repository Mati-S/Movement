extends Node

@onready var players : Array[CharacterBody3D]
var posObs : Vector3 = Vector3.ZERO

@export var path_points : int = 10
@export var path_lenght : int = 5
@onready var terrain : Terrain3D = $"../Terrain3D"
@onready var points : PackedScene = preload("res://dot.tscn")

func _ready() -> void:
	for child in self.get_children():
		var path = Node.new()
		path.name = 'Path'
		child.add_child(path)
		if child is CharacterBody3D:
			child.get_new_path.connect(on_get_new_path)

func dispararRayo(posRayo : Vector3) -> float :
	return 0.0


func punto_mas_cercano_en_recta(posObs: Vector3, posProm: Vector3, posTarget: Vector3) -> Vector3:
	var recta_ObsProm = posProm - posObs
	var punto_MasCercano = posTarget - posObs
	
	var t = recta_ObsProm.dot(punto_MasCercano) / recta_ObsProm.length_squared()
	return posObs + recta_ObsProm * t

func formar_linea() -> void:
	var pos_promedio = Vector3.ZERO
	for player in self.get_children():
		pos_promedio += player.position
	pos_promedio /= self.get_child_count()
	pos_promedio.y = dispararRayo(Vector3(pos_promedio.x, 500.0, pos_promedio.z))
	for player in self.get_children():
		player.formar_en(punto_mas_cercano_en_recta(posObs, pos_promedio, player.position))



func _on_explosion_handler_explosion_emited(position: Vector3) -> void:
	for player in self.get_children():
		if player.position.distance_to(position) < 20 and player.visible:
			run_to_cover_from(player, position)

func move() -> void:
	for player in self.get_children():
		if player.get_name() == 'CharacterBody3D':
			player.flag_mover

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("form_up"):
		formar_linea()
	if event.is_action_pressed("move!"):
		move()

func  run_to_cover_from(target: Node, explotion : Vector3, path_steps : int = path_points) -> void:
	var target_node = target
	var script = target.get_script()
	if script.get_global_name() == 'Destruible':
		target_node = target.get_node('./Vivo')
	var path_init = target_node.global_position
	var path_direction = - target_node.global_position.direction_to(explotion)
	var new_path : Array[Vector3] = []
	target.clear_path()
	var point_number = 0
	for i in range(path_steps):
		path_init +=  path_lenght * path_direction
		var ground_height = get_ground_height(path_init)
		if ground_height == -INF:
			break
		path_init.y = ground_height
		new_path.append(path_init)
		add_point(target, path_init, point_number)
		point_number += 1
	target.swap_to_new_path(new_path)
	

func get_ground_height(position_a: Vector3, max_distance: float = 400.0) -> float:
	var from = position_a + Vector3.UP * max_distance
	return terrain.get_intersection(from, Vector3.DOWN, true).y

func add_point(target: Node, point_position : Vector3, point_number: int) -> void:
	var path = target.get_node('./Path')
	var dot = points.instantiate()
	path.add_child(dot)
	dot.name = 'Point' + str(point_number)
	dot.global_position = point_position
	
func on_get_new_path(target: Node, position: Vector3, facing: Vector3, points_taken : int) -> void:
	
	run_to_cover_from(target, position + facing, path_points - points_taken)
