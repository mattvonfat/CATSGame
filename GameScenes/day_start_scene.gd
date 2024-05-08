extends Node2D

@onready var company_list = [ 	$CanvasLayer/MarginContainer2/VBoxContainer/HBoxContainer/VBoxContainer/Company1,
								$CanvasLayer/MarginContainer2/VBoxContainer/HBoxContainer/VBoxContainer/Company2,
								$CanvasLayer/MarginContainer2/VBoxContainer/HBoxContainer/VBoxContainer/Company3,
								$CanvasLayer/MarginContainer2/VBoxContainer/HBoxContainer/VBoxContainer/Company4,
								$CanvasLayer/MarginContainer2/VBoxContainer/HBoxContainer/VBoxContainer/Company5,
								$CanvasLayer/MarginContainer2/VBoxContainer/HBoxContainer/VBoxContainer/Company6 ]

@onready var convo_text:Label = $CanvasLayer/MarginContainer/CenterContainer/MarginContainer/VBoxContainer/MarginContainer/Convotext

# loads the text for the current day
func run_day(day_number:int):
	var companies = GameData.get_companies(day_number)
	for i in range(0, companies.size()):
		company_list[i].get_node("Logo").set_texture(GameData.get_logo(companies[i]))
		company_list[i].get_node("Name").set_text(GameData.get_company_name(companies[i]))
		company_list[i].show()
	
	
	convo_text.set_text(GameData.get_start_text(day_number))


func _on_continue_button_pressed():
	GameManager.begin_trading()
