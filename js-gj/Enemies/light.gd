extends RigidBody3D
var des_vel:Vector3
@onready var speed:int = randf_range(0.9,1.1)*10
@onready var caminador:PathFollow3D =  $PathFollow3D
var path_asig:int
var des_look_point:Vector3
var life:int = 10
var spawning:bool = true
var impacting:bool = false
@onready var offset:Vector3 = Vector3(randf_range(-1,1)*get_parent().cam_size,1,randf_range(-1,1)*get_parent().cam_size)

func _ready() -> void:
	caminador.reparent(get_parent().paths[path_asig])
	caminador.progress = 0.1
	des_look_point = caminador.global_position + offset
	position = caminador.global_position + offset
	position.y = randf_range(-2,-3)
	caminador.progress = 5
	des_look_point = caminador.global_position + offset
	rotation_degrees = Vector3(-90,90,0)


func _physics_process(delta: float) -> void:
	$CollisionShape3D.disabled = spawning
	if spawning:
		linear_velocity.y = 5
		angular_velocity.y = 50
		if position.y > caminador.global_position.y+1:spawning = false
	elif !impacting:
		#Impact
		while position.distance_to(caminador.global_position) < offset.length() + 2 and caminador.progress_ratio < 1:
			caminador.progress += 1
		if caminador.progress_ratio == 1:
			impact()
		
		#Mooving
		des_vel = position.direction_to(caminador.global_position + offset)
		des_vel.y = 0
		des_vel = des_vel.normalized()*speed
		if $Ray_suelo.is_colliding():
			if des_vel != Vector3.ZERO:
				var normal:Vector3 = $Ray_suelo.get_collision_normal(0)
				var aply_force:Vector3 = normal.rotated(des_vel.normalized().rotated(Vector3.UP,-PI/2),-PI/2)*des_vel.length()
				aply_force.x = des_vel.x * (Vector3(aply_force.x,0,aply_force.z).length() / des_vel.length())
				aply_force.z = des_vel.z * (Vector3(aply_force.x,0,aply_force.z).length() / des_vel.length())
				apply_force((aply_force-linear_velocity)*2,Vector3.UP)
		#apply_force(Vector3((des_vel-linear_velocity).x,0,(des_vel-linear_velocity).z)*20,Vector3.UP)
		
		#Spining
		des_look_point = caminador.global_position + offset
		var direction:Vector2 = Vector2(position.x,-position.z).direction_to(Vector2(des_look_point.x,-des_look_point.z))
		var angle:float = Vector2(-1,0).rotated(rotation.y).angle_to(direction)
		var rot_aply:Vector3 = Vector3(-rotation.x,angle,-rotation.z)
		apply_torque(rot_aply*3)
	else:
		angular_velocity.y = 50
		if linear_velocity.y < 0 and get_contact_count() > 0 and get_colliding_bodies()[0].is_in_group("Suelo"):
			queue_free()

func impact():
	if !impacting:
		rotation_degrees = Vector3(90,90,0)
		impacting = true
		linear_velocity = Vector3(0,10,0)
		mass = 10
