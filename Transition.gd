extends Node2D


func set_day(day:int):
	$CanvasLayer/CenterContainer/Label.set_text("DAY %s" % (day+1))

func start():
	$Timer.start()

func _on_timer_timeout():
	GameManager.end_transition()
