extends Node3D
@onready var noiseterrain:FastNoiseLite = FastNoiseLite.new()
@onready var noiseterrain_color:FastNoiseLite = FastNoiseLite.new()
@onready var material_suelo = load("res://Recursos/Suelo_mat.tres")
var terr_size:int = 80#ratio of the terrain
var terr_alt:int = 10#variation of the terrain

var amount:float = 0#Variables auxiliares
var cant:int = 0
var prom:float = 0
var color_poner:Color
var check:Vector2
var paths_amout:int = 5
var cam_size:int = 3
var cam_p:Vector2
var cam_p_step:float = 1
var cam_count:float = 0
var angle:float = 90
var angle_var:float = 0

var CA:Array = []#tiles pertenecientes a extras de camino(ancho)
var CA_H:Array = []#altura promedio de extras en base a principales
var VF:Array = []
var st = SurfaceTool.new()
var add:Array = [0,0,1,1,0,1,0,0,1,0,1,1]
var CP:Array
var CA_prom_area_t:int = 5#area a promediar de los extras con el terreno
var paths:Array

var cont_spawn:int = 0

func _ready() -> void:
	randomize()
	noiseterrain.seed = randi()
	noiseterrain_color.seed = randi()
	create_paths()
	crear_plataforma()
	$Suelo/Tienda_1.position.y = 0
	$Suelo/CollisionShape3D2.position.y = 5

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):get_tree().change_scene_to_file("res://Escenas/main.tscn")
	$Suelo.angular_velocity -= $Suelo.rotation*delta*0.1
	$Suelo.linear_velocity.x -= $Suelo.position.x*delta
	$Suelo.linear_velocity.z -= $Suelo.position.z*delta

func spawn_enemy(type:int,path:int):
	var ins = preload("res://Enemies/light.tscn").instantiate()
	ins.path_asig = path
	#ins.position = Vector3.UP*100
	add_child(ins)

func create_paths():#creates the paths of the level
	var start_distance:int = 15
	CP = []
	cam_p_step = 1
	for i in paths_amout:
		var ins:Path3D = Path3D.new()
		ins.curve = Curve3D.new()
		angle = 360/paths_amout * i
		cam_p = Vector2(start_distance,0).rotated(deg_to_rad(angle))
		angle_var = 0
		cam_count = 0
		while cam_count < terr_size-start_distance-cam_size:
			if !CP.has(round(cam_p)):
				ins.curve.bake_interval = 512
				var point_pos:Vector3 = Vector3(cam_p.x,noiseterrain.get_noise_2d(cam_p.x,cam_p.y)*terr_alt+1,cam_p.y)
				if cam_p.length() < 10:
					point_pos.y = 0
				elif cam_p.length() < 20:
					point_pos.y *= (min(pow((cam_p.length()-10)/10,2),1))
				ins.curve.add_point(point_pos)
				CP.append(round(cam_p))
			cam_p += Vector2(cam_p_step,0).rotated(deg_to_rad(angle))
			cam_count += cam_p_step
			angle_var += randf_range(-10,10)*cam_p_step
			angle_var -= angle_var*0.15
			angle += angle_var
			angle += (360/paths_amout * i-angle)*0.2
		$Suelo.add_child(ins)
		paths.append(ins)

func crear_plataforma():#creates the patform
	CA.clear()
	CA_H.clear()
	amount = 0
	cant = 0
	#Comienzo de creacion de ruta
	for i in CP:
		for X in cam_size*2:
			for Y in cam_size*2:
				check = Vector2(X-cam_size,Y-cam_size)
				if check.length() <= cam_size and !CA.has(check+i):
					CA.append(check+i)
	CA_H.clear()
	for i in CA:
		CA_H.append(noiseterrain.get_noise_2d(i.x,i.y) * terr_alt)
	#Creacion de VF
	VF.clear()
	
	for X in terr_size*2:#Llenado y asignacion de VF
		VF.insert(X,[])
		for Y in terr_size*2:
			VF[X].insert(Y,0)
	for X in VF.size():
		for Y in VF[X].size():
			check = Vector2(X-terr_size,Y-terr_size)
			if CA.has(check):#pista
				VF[X][Y] = CA_H[CA.find(check)]
			else:#resto
				VF[X][Y] = noiseterrain.get_noise_2d(check.x,check.y)*terr_alt
			if check.length() < 10:
				VF[X][Y] = 0
			elif check.length() < 20:
				VF[X][Y] *= (min(pow((check.length()-10)/10,2),1))
	
	#Creacion de terreno
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for X in (VF.size())-1:
		for Y in (VF[X].size())-1:
			if Vector2(X-terr_size,Y-terr_size).length() <= terr_size:
				for i in add.size()/2:
					if CA.has(Vector2(X+add[i*2]-terr_size,Y+add[i*2+1]-terr_size)):#Pista
						color_poner = Color(0.5,0.5,0.5)# * randf_range(0.98,1.02)
					else:
						color_poner = Color(0.4,0.4,0.4)#Fuera
					color_poner = color_poner * (1 + (VF[X+add[i*2]][Y+add[i*2+1]])/ terr_alt)*randf_range(0.98,1.02)#variacion extra
					
					st.set_color(color_poner)
					st.add_vertex(Vector3(X+add[i*2]-terr_size, VF[(X+add[i*2])][(Y+add[i*2+1])] - int(Vector2(X+add[i*2]-terr_size,Y+add[i*2+1]-terr_size).length() > terr_size-cam_size)* pow(Vector2(X+add[i*2]-terr_size,Y+add[i*2+1]-terr_size).length() - (terr_size-cam_size),2), Y+add[i*2+1]-terr_size))
	
	var ins = MeshInstance3D.new()
	ins.cast_shadow = false
	ins.material_override = material_suelo
	ins.mesh = st.commit()
	ins.create_trimesh_collision()
	#ins.get_child(0).set_collision_layer_value(2,true)
	#ins.get_child(0).set_collision_mask_value(2,true)
	ins.position.y = 0
	$Suelo.add_child(ins)
	ins.get_child(0).get_child(0).reparent($Suelo)
	ins.get_child(0).queue_free()


func _on_timer_timeout() -> void:
	cont_spawn += 1
	spawn_enemy(0,cont_spawn%paths.size()-1)
