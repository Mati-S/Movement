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
	
func swap_to_new_path(new_path: Array) -> void:
	if new_path.size() > 0 :
		if salud > 0:
			vivo.path_array = new_path
			if !vivo.flag_movement: 
				vivo.brake = 0.0
				vivo.flag_movement = !vivo.flag_movement

func clear_path() ->void:
	if salud > 0:
		var path = get_node('./Path')
		if path != null:
			for child in path.get_children():
				child.free()
				vivo.path_array.clear()
	
