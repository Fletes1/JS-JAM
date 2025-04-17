extends RigidBody3D
var des_vel:Vector3
@onready var speed:int = randf_range(0.9,1.1)*3
@onready var caminador:PathFollow3D =  $PathFollow3D
var path_asig:int
var des_look_pos:Vector3
var life:int = 10
var impacting:bool = false

func _ready() -> void:
	caminador.reparent(get_parent().paths[path_asig])
	caminador.progress = 0.1
	des_look_pos = caminador.global_position
	position = caminador.global_position + Vector3(randf_range(-1,1)*get_parent().cam_size,1,randf_range(-1,1)*get_parent().cam_size)

func _physics_process(delta: float) -> void:
	while position.distance_to(caminador.global_position) < 3 and caminador.progress_ratio < 1:
		caminador.progress += 1
	if caminador.progress_ratio == 1:
		impact()
	des_look_pos += (caminador.global_position-des_look_pos)*delta*3
	$MeshInstance3D.look_at(des_look_pos)
	$MeshInstance3D.rotation.x = 0
	$MeshInstance3D.rotation.z = 0
	des_vel = position.direction_to(caminador.global_position)
	des_vel.y = 0
	des_vel = des_vel.normalized()*speed
	apply_force(Vector3((des_vel-linear_velocity).x,0,(des_vel-linear_velocity).z)*20,Vector3.UP)
	
	apply_torque(-rotation*20)
	if impacting and linear_velocity.y < 0 and get_contact_count() > 0 and get_colliding_bodies()[0].is_in_group("Suelo"):
		queue_free()

func impact():
	if !impacting:
		impacting = true
		linear_velocity = Vector3(0,10,0)
		mass = 10
