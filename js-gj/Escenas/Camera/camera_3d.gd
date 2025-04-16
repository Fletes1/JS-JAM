extends Camera3D
@onready var camera =$"."
@export var target = Node3D
func _ready() -> void:
	var camera_distance = camera.global_transform.origin.distance_to(target.global_transform.origin)
	look_at_from_position((Vector3.UP + Vector3.BACK) * camera_distance,get_parent().position, Vector3.UP)
