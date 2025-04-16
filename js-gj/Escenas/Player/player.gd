extends CharacterBody3D
@onready var player_mesh = $Visuals
@export var walk_speed:int = 3
@export var run_speed: int = 10
@onready var animation_player: AnimationPlayer = $Visuals/Dummy/AnimationPlayer
@onready var horizontal: Node3D = $FPS_CameraController/horizontal




#animation node names
var idle_node_name: String = "Idle"
var walk_node_name: String = "Walk"
var run_node_name: String = "Run"
var attack1_node_name: String = "Attack1"
var death_node_name: String = "DeathA"
var attack2_node_name: String = "Attack2"


#state machine conditions
var is_attacking: bool  
var is_attacking2: bool
var is_walking: bool 
var is_running: bool 
var is_dying: bool 

#physics values
var direction: Vector3
var horizontal_velocity: Vector3
var vertical_velocity: Vector3
var aim_turn: float
var movement: Vector3
var vertical_velocoty: Vector3
var movement_speed: int
var angular_acceleration: int
var acceleration: int
var just_hit:bool

@onready var camroot_h =$FPS_CameraController/horizontal/vertical

func _ready() -> void:
	animation_player.set_blend_time("Running","Idle", 0.4)
	animation_player.set_blend_time("Idle","Running", 0.4)
	
	pass
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		aim_turn = -event.relative.x * 0.015
	if event.is_action_pressed("aim"):
		direction = camroot_h.global_transform.basis.z #camroot_h.global_transform.basis..rotation.z
func _physics_process(delta: float) -> void:
	var on_floor = is_on_floor()
	
	
	if !is_dying:
		if !on_floor:
			vertical_velocity += Vector3.UP*get_gravity()*delta
		angular_acceleration =10
		movement_speed = 0
		acceleration =1
		
		
		var h_rot = camroot_h.global_transform.basis.get_euler().y
		if(Input.is_action_pressed("fowards") or Input.is_action_pressed("backwards") or Input.is_action_pressed("left") or Input.is_action_pressed("right") ):
			# get all the cases of movement w
			
			direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"), 0, Input.get_action_strength("fowards") - Input.get_action_strength("backwards"))
			direction = (direction.rotated(Vector3.UP, h_rot).normalized())*-1
		
			
			if Input.is_action_pressed("sprint") and (is_walking):
				movement_speed = run_speed
				is_running = true
			else:
				is_walking = true
				movement_speed = walk_speed
				if(Input.is_action_just_released("sprint")):
					is_running=false
					
				
		else:
			is_walking = false
			is_running = false
			
		if Input.is_action_pressed("aim"):
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, camroot_h.rotation.y, delta *angular_acceleration)
		else:
			
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y , delta *angular_acceleration)
			
		if is_attacking:
			horizontal_velocity = horizontal_velocity.lerp(direction.normalized()*0.1,acceleration)
		else:
			horizontal_velocity = horizontal_velocity.lerp(direction.normalized()*movement_speed,acceleration)
			
		velocity.z = horizontal_velocity.z + vertical_velocity.z
		velocity.x = horizontal_velocity.x + vertical_velocity.x
		
		velocity.y =  vertical_velocity.y
		move_and_slide()
