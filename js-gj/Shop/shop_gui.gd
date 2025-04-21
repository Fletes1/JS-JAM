extends Control

@onready var item_button : Control = preload("res://Shop/item_button.tscn").instantiate()
@onready var main = get_tree().root.get_node("Main")
@onready var player = main.get_node("Player")

func _ready() -> void:
	
	load_shop()

func close_shop() -> void:
	visible = false

func load_shop() -> void: ##Loads the items into the list
	
	var shop_dir = DirAccess.open("res://Shop/Items/")
	for item in shop_dir.get_files():
		#Loads item:String as item_res:Resource
		var item_res = ResourceLoader.load("res://Shop/Items/"+item)
		#Item Button
		var ib = item_button.duplicate()
		ib.shop_item = item_res
		ib.connect("buy",buy)
		
		%List.add_child(ib)

func buy(shop_item:ShopItem) -> void:
	if main.scraps >= shop_item.price:
		close_shop()
		#Class check
		if shop_item is CharacterItem:
			
			player.set(shop_item.stat_name,player.get(shop_item.stat_name)+shop_item.boost)
			
		elif shop_item is TurretItem:
			
			var turret_to_place = load(shop_item.turret).instantiate()
			player.hold_turret(turret_to_place)
			
		else:
			printerr(shop_item," does not have a function as of now.")
	else:
		print("Needs more scraps")
