@tool
class_name Destruible extends Node3D

signal salud_changed(value: int)

@export_category("Visual")
@export var modelo_vivo: PackedScene
@export var modelo_muerto: PackedScene

@export var salud: int = 1:
	set(value):
		if value <= 0:
			salud = 0
			if vivo:
				vivo.propagate_call("hide", [], true)
			if muerto:
				muerto.propagate_call("show", [], true)
		elif value >= 100:
			salud = 100
		else:
			salud = value
		salud_changed.emit(salud)

var vivo: Node3D = null
var muerto: Node3D = null

var stuck: bool = false

func load_model(p: PackedScene, model_name: String) -> Node3D:
	if p == null:
		return
	if get_node_or_null(model_name) != null:
		var m := get_node(model_name)
		remove_child(m)
		m.queue_free()
	var model: Node3D = p.instantiate()
	model.name = model_name
	add_child(model)
	model.owner = self
	return model


func _ready() -> void:
	vivo = load_model(modelo_vivo, "Vivo")
	muerto = load_model(modelo_muerto, "Muerto")
	vivo.propagate_call("show", [], true)
	muerto.propagate_call("hide", [], true)
	vivo.point_achieved.connect(_on_vivo_point_achieved)
	
func swap_to_new_path(new_path: Array) -> void:
	if new_path.size() > 0 :
		if salud > 0 and !stuck:
			vivo.path_array = new_path
			if vivo.flag_rotate:
				vivo.clear_timer()
			vivo.flag_rotate = true
			vivo.movement_timer = Timer.new()
			vivo.movement_timer.set_one_shot(true)
			vivo.movement_timer.timeout.connect(vivo._on_timer_timeout)
			vivo.add_child(vivo.movement_timer)
			vivo.movement_timer.start(7.5)

			if !vivo.flag_movement:
				vivo.flag_movement = !vivo.flag_movement
				
				

func clear_path() ->void:
	if salud > 0:
		var path = get_node('./Path')
		if path != null:
			for child in path.get_children():
				child.free()
				vivo.path_array.clear()
	


func _on_vivo_point_achieved() -> void:
	if salud > 0:
		if vivo.flag_loop:
			vivo.return_path_array.append(vivo.path_array[0])
			vivo.path_array.remove_at(0)
		else:
			vivo.path_array.remove_at(0)
			var path_point = self.find_child("Path", true, false)
			var child = path_point.get_child(0)
			child.free()

func got_stucked():
	stuck = true
	clear_path()
