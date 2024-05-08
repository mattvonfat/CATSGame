extends Node2D

@onready var convo_text:Label = $CanvasLayer/MarginContainer/CenterContainer/MarginContainer/VBoxContainer/MarginContainer/ConvoText

var end_game:bool

var responses = [
	"The system seems to be performing perfectly! Good job!",
	"We're very pleased with the current performance of the system.",
	"The system seems to be performing adequately but there still seem to be some issues that need to be sorted out.",
	"The performance of the system has been unsatisfactory, you should make some modifications to it before tomorrow.",
	"The system has been an unmitigated disaster, we'd be better off if a cat was doing the work! We are terminating the use of the system immediately and you will be hearing from our lawyers."
]

func start(response_id:int, lost_game:bool):
	end_game = lost_game
	convo_text.set_text(responses[response_id])
	
	$CanvasLayer/MarginContainer2/VBoxContainer/HBoxContainer/VBoxContainer2/Company1/CP.set_text("%s" % GameManager.correct_price)
	$CanvasLayer/MarginContainer2/VBoxContainer/HBoxContainer/VBoxContainer2/Company2/WP.set_text("%s" % GameManager.wrong_price)
	$CanvasLayer/MarginContainer2/VBoxContainer/HBoxContainer/VBoxContainer2/Company4/WC.set_text("%s" % GameManager.wrong_companies)
	$CanvasLayer/MarginContainer2/VBoxContainer/HBoxContainer/VBoxContainer2/Company5/LT.set_text("%s" % GameManager.lost_transactions)

func _on_continue_button_pressed():
	if end_game == true:
		GameManager.game_lost()
	else:
		GameManager.next_day()
