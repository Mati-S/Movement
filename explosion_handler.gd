extends Node

signal explosion_emited(position: Vector3)

@onready var explotion = preload("res://explotion.tscn")


func simulate_explosion(position: Vector3) -> void:
	var new_exp = explotion.instantiate()
	self.add_child(new_exp)
	new_exp.position = position
	#new_exp.explosion_ended.connect(self._on_explosion_ended)
	explosion_emited.emit(position)

#func _on_explosion_ended(nodo : Node3D) -> void:
	#nodo.queue_free()
