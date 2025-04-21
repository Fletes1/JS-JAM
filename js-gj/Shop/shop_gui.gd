extends Control

var shop_list : Array[ShopItem]
@onready var item_button : Control = preload("res://Shop/item_button.tscn").instantiate()
@onready var main = get_tree().root.get_node("Main")
@onready var player = main.get_node("Player")

func _ready() -> void:
	load_shop()

func close_shop() -> void:
	visible = false

func load_shop() -> void:
	var shop_dir = DirAccess.open("res://Shop/Items/")
	for item in shop_dir.get_files():
		var item_res = ResourceLoader.load("res://Shop/Items/"+item)
		shop_list.append(item_res)
		var ib = item_button.duplicate()
		ib.shop_item = item_res
		ib.connect("buy",buy)
		%List.add_child(ib)

func buy(shop_item:ShopItem) -> void:
	if main.scraps >= shop_item.price:
		
		if shop_item is CharacterItem:
			
			player.set(shop_item.stat_name,player.get(shop_item.stat_name)+shop_item.boost)
			
		elif shop_item is TurretItem:
			
			pass
			
	else:
		print("Needs more scraps")
