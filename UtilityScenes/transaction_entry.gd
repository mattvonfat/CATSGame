extends StaticBody2D

class_name TransactionEntry

signal entry_clicked(column, index)

@onready var price_label:Label = $Sprite2D/HBoxContainer/CenterContainer/PriceLabel
@onready var logo_texture:TextureRect = $Sprite2D/HBoxContainer/MarginContainer/LogoTexture

var column:int
var index:int

var transaction_data:Dictionary

func set_transaction_data(data:Dictionary):
	transaction_data = data
	set_price(transaction_data["price"])
	set_logo(GameData.get_logo(transaction_data["id"]))

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == false:
			emit_signal("entry_clicked", column, index)

func enable_entry():
	$Sprite2D.set_modulate(Color(1.0, 1.0, 1.0))

func disable_entry():
	$Sprite2D.set_modulate(Color(0.5, 0.5, 0.5))

func set_price(new_price:float):
	var price_string:String = "%s" % new_price
	price_string = price_string.pad_decimals(2)
	price_label.set_text("$%s" % price_string)

func set_logo(new_logo:Texture2D):
	logo_texture.set_texture(new_logo)

func set_column(new_column:int):
	column = new_column

func set_index(new_index):
	index = new_index

func get_transaction_data():
	return transaction_data
