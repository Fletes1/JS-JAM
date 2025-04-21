extends PanelContainer

var shop_item : ShopItem

signal buy(ShopItem)

func _ready() -> void:
	
	if shop_item:
		
		%Price.text = str(shop_item.price)
		%Name.text = shop_item.name

func _pressed() -> void:
	buy.emit(shop_item)
