extends Node3D
var camroot_h:float = 0
var camroot_v:float = 0
@export var cam_v_max: int =10
@export var cam_v_min: int = -30
var h_sensitivity: float = 0.01
var v_sensitivity: float = 0.01
var h_acceleration: float = 10
var v_acceleration: float = 10
var stop_delay := 0.5 # Time in seconds to wait before stopping the camera
var last_mouse_position = Vector2()
var current_mouse_position = Vector2()
var timer := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)#Changes the settings of the mosue to confined whether it is hidden or not

func _input(event):
	if event is InputEventMouseMotion:
		camroot_v -= event.relative.y * v_sensitivity
		camroot_h += -event.relative.x * h_sensitivity
	
			
		
	


# Called when the node enters the scene tree for the first time.

func stop_camera():
	camroot_h=last_mouse_position.x
	camroot_v = last_mouse_position.y
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_mouse_position =get_viewport().get_mouse_position()
	if current_mouse_position != last_mouse_position:
		last_mouse_position = current_mouse_position
		timer = 0.0
	else:
		#mouse is not moving
		timer += delta
		if timer >= stop_delay:
			pass
	
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	camroot_v = clamp(camroot_v, deg_to_rad(cam_v_min),deg_to_rad(cam_v_max))#clamp only allows the variable to be a number inbetween these values
	get_node("horizontal").rotation.y =lerpf(get_node("horizontal").rotation.y, camroot_h,1)#lerpf translates a float(given by f) from one to another with a weight which im guessing it is the factor
	get_node("horizontal/vertical").rotation.x = lerpf(get_node("horizontal/vertical").rotation.x, camroot_v,1)
