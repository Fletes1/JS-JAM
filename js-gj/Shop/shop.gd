extends Area3D

var shop_gui : Control

func open_shop() -> void:
	shop_gui.visible = true

func _ready() -> void:
	
	shop_gui = preload("res://Escenas/shop_gui.tscn").instantiate()
	add_child(shop_gui)

func collided_check(body:Node3D)  -> void:
	if body.is_in_group("Player"):
		open_shop()
